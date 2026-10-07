// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  late List<(MidiDiagnosticKind, String)> issues;
  late MidiByteParser parser;

  MidiByteParser create({
    int maxSysExLength = 1 << 20,
    Duration? maxSysExDuration,
    bool noteOnZeroAsNoteOff = false,
  }) => MidiByteParser(
    maxSysExLength: maxSysExLength,
    maxSysExDuration: maxSysExDuration,
    noteOnZeroAsNoteOff: noteOnZeroAsNoteOff,
    onIssue: (kind, cause) => issues.add((kind, cause)),
  );

  List<int> bytes(String hex) => MidiBytes.fromHex(hex).bytes;

  List<MidiMessage> parse(String hex, {MidiTime time = MidiTime.zero}) => [
    for (final timed in parser.add(bytes(hex), time: time)) timed.message,
  ];

  setUp(() {
    issues = [];
    parser = create();
  });

  const invalid = MidiDiagnosticKind.invalidData;
  const noteOn = MidiNoteOn(channel: 0, note: 0x3C, velocity: 0x40);
  const noteOn2 = MidiNoteOn(channel: 0, note: 0x3E, velocity: 0x40);

  group('MidiByteParser', () {
    group('MidiByteParser(...)', () {
      test('uses defaults', () {
        final parser = MidiByteParser();
        expect(parser.maxSysExLength, 1 << 20);
        expect(parser.maxSysExDuration, isNull);
        expect(parser.noteOnZeroAsNoteOff, isFalse);
        expect(parser.onIssue, isNull);
      });

      test('ignores issues without callback', () {
        expect(MidiByteParser().add(bytes('f4 01 f7')), isEmpty);
      });
    });

    group('add(bytes, time)', () {
      group('parses', () {
        final cases = <(String, MidiMessage)>[
          ('80 3c 40', const MidiNoteOff(channel: 0, note: 0x3C)),
          ('9f 7f 7f', const MidiNoteOn(channel: 15, note: 127, velocity: 127)),
          ('91 3c 00', const MidiNoteOn(channel: 1, note: 0x3C, velocity: 0)),
          (
            'a2 40 10',
            const MidiPolyPressure(channel: 2, note: 0x40, pressure: 0x10),
          ),
          (
            'b3 07 64',
            const MidiControlChange(channel: 3, controller: 7, value: 0x64),
          ),
          ('c4 05', const MidiProgramChange(channel: 4, program: 5)),
          ('d5 33', const MidiChannelPressure(channel: 5, pressure: 0x33)),
          ('e6 01 40', const MidiPitchBend(channel: 6, value: 0x2001)),
          ('f1 5a', const MidiTimeCodeQuarterFrame(piece: 5, value: 0xA)),
          ('f2 7f 01', const MidiSongPositionPointer(position: 0xFF)),
          ('f3 12', const MidiSongSelect(song: 0x12)),
          ('f6', const MidiTuneRequest()),
          ('f8', const MidiTimingClock()),
          ('fa', const MidiStart()),
          ('fb', const MidiContinue()),
          ('fc', const MidiStop()),
          ('fe', const MidiActiveSensing()),
          ('ff', const MidiSystemReset()),
        ];
        for (final (hex, message) in cases) {
          test('$hex as $message', () {
            expect(parse(hex), equals([message]));
            expect(issues, isEmpty);
          });
        }

        test('System Exclusive without 0xF0 and 0xF7', () {
          expect(
            parse('f0 7e 7f 06 01 f7'),
            equals([
              MidiSysEx(const [0x7E, 0x7F, 0x06, 0x01]),
            ]),
          );
        });

        test('an empty System Exclusive', () {
          expect(parse('f0 f7'), equals([MidiSysEx(const [])]));
        });

        test('values above 0xFF by their low eight bits', () {
          expect(
            parser.add(const [0x190, 0x13C, 0x140]).single.message,
            noteOn,
          );
        });

        test('nothing from an empty chunk', () {
          expect(parse(''), isEmpty);
        });
      });

      group('with running status', () {
        test('repeats three-byte messages', () {
          expect(
            parse('90 3c 40 3e 40 40 00'),
            equals([
              noteOn,
              noteOn2,
              const MidiNoteOn(channel: 0, note: 0x40, velocity: 0),
            ]),
          );
        });

        test('repeats two-byte messages', () {
          expect(
            parse('c1 01 02 d2 10 20'),
            equals([
              const MidiProgramChange(channel: 1, program: 1),
              const MidiProgramChange(channel: 1, program: 2),
              const MidiChannelPressure(channel: 2, pressure: 0x10),
              const MidiChannelPressure(channel: 2, pressure: 0x20),
            ]),
          );
        });

        test('continues across chunks', () {
          expect(parse('90 3c 40'), equals([noteOn]));
          expect(parse('3e 40'), equals([noteOn2]));
        });

        test('is kept by real-time messages inside a message', () {
          expect(
            parse('90 3c f8 40 3e fe 40'),
            equals([
              const MidiTimingClock(),
              noteOn,
              const MidiActiveSensing(),
              noteOn2,
            ]),
          );
          expect(issues, isEmpty);
        });

        for (final common in ['f1 00', 'f2 00 00', 'f3 00', 'f6']) {
          test('is cleared by system common $common', () {
            final messages = parse('90 3c 40 $common 3e 40');
            expect(messages.first, noteOn);
            expect(messages, hasLength(2));
            expect(issues, equals([(invalid, '2 data bytes without status')]));
          });
        }

        test('is cleared by System Exclusive', () {
          expect(
            parse('90 3c 40 f0 01 f7 3e 40'),
            equals([
              noteOn,
              MidiSysEx(const [1]),
            ]),
          );
          expect(issues, equals([(invalid, '2 data bytes without status')]));
        });

        for (final status in [0xF4, 0xF5]) {
          final hex = status.toRadixString(16);
          test('is cleared by the undefined status 0x$hex', () {
            expect(parse('90 3c 40 $hex 3e 40'), equals([noteOn]));
            expect(
              issues,
              equals([
                (invalid, 'Undefined status byte 0x$hex'),
                (invalid, '2 data bytes without status'),
              ]),
            );
          });
        }

        for (final status in [0xF9, 0xFD]) {
          final hex = status.toRadixString(16);
          test('is kept by the undefined status 0x$hex', () {
            expect(parse('90 3c $hex 40 3e 40'), equals([noteOn, noteOn2]));
            expect(issues, equals([(invalid, 'Undefined status byte 0x$hex')]));
          });
        }

        test('is cleared by a stray 0xF7', () {
          expect(parse('90 3c 40 f7 3e 40'), equals([noteOn]));
          expect(
            issues,
            equals([
              (invalid, 'End of Exclusive without start'),
              (invalid, '2 data bytes without status'),
            ]),
          );
        });
      });

      group('System Exclusive', () {
        test('delivers real-time messages first', () {
          expect(
            parse('f0 43 f8 10 fa f7'),
            equals([
              const MidiTimingClock(),
              const MidiStart(),
              MidiSysEx(const [0x43, 0x10]),
            ]),
          );
        });

        test('gets the time of the chunk that started it', () {
          expect(
            parser.add(bytes('f0 43 12'), time: const MidiTime(1000)),
            isEmpty,
          );
          final messages = parser.add(
            bytes('00 f7 90 3c 40'),
            time: const MidiTime(2000),
          );
          expect(
            messages,
            equals([
              (
                message: MidiSysEx(const [0x43, 0x12, 0x00]),
                time: const MidiTime(1000),
              ),
              (message: noteOn, time: const MidiTime(2000)),
            ]),
          );
        });

        test('ends with any other status as if 0xF7 was received', () {
          expect(
            parse('f0 43 12 90 3c 40'),
            equals([
              MidiSysEx(const [0x43, 0x12]),
              noteOn,
            ]),
          );
          expect(issues, isEmpty);
        });

        test('ends with a new System Exclusive', () {
          expect(
            parse('f0 01 f0 02 f7'),
            equals([
              MidiSysEx(const [1]),
              MidiSysEx(const [2]),
            ]),
          );
        });

        test('ends with an undefined status', () {
          expect(
            parse('f0 01 f5'),
            equals([
              MidiSysEx(const [1]),
            ]),
          );
          expect(issues, equals([(invalid, 'Undefined status byte 0xf5')]));
        });

        test('skips undefined real-time status bytes', () {
          expect(
            parse('f0 01 fd 02 f7'),
            equals([
              MidiSysEx(const [1, 2]),
            ]),
          );
          expect(issues, equals([(invalid, 'Undefined status byte 0xfd')]));
        });

        group('longer than maxSysExLength', () {
          setUp(() => parser = create(maxSysExLength: 3));

          test('is accepted up to the limit', () {
            expect(
              parse('f0 01 02 03 f7'),
              equals([
                MidiSysEx(const [1, 2, 3]),
              ]),
            );
            expect(issues, isEmpty);
          });

          test('is dropped up to 0xF7', () {
            expect(parse('f0 01 02 03 04 05'), isEmpty);
            expect(parse('06 07 f7 90 3c 40'), equals([noteOn]));
            expect(
              issues,
              equals([
                (
                  MidiDiagnosticKind.sysExTooLong,
                  'System Exclusive longer than 3 bytes',
                ),
              ]),
            );
          });

          test('is dropped up to the next status', () {
            expect(parse('f0 01 02 03 04 90 3c 40'), equals([noteOn]));
            expect(issues, hasLength(1));
          });

          test('keeps real-time messages', () {
            expect(
              parse('f0 01 02 03 04 f8 05 f7'),
              equals([const MidiTimingClock()]),
            );
          });
        });

        group('incomplete after maxSysExDuration', () {
          setUp(
            () => parser = create(
              maxSysExDuration: const Duration(milliseconds: 100),
            ),
          );

          test('is accepted up to the limit', () {
            expect(parse('f0 01'), isEmpty);
            expect(parse('02 f7', time: const MidiTime(100000)), [
              MidiSysEx(const [1, 2]),
            ]);
            expect(issues, isEmpty);
          });

          test('is dropped with its remaining bytes', () {
            expect(parse('f0 01'), isEmpty);
            expect(parse('02 03 f7 90 3c 40', time: const MidiTime(100001)), [
              noteOn,
            ]);
            expect(
              issues,
              equals([
                (
                  MidiDiagnosticKind.sysExIncomplete,
                  'System Exclusive incomplete after 0:00:00.100000',
                ),
              ]),
            );
          });

          test('does not affect other messages', () {
            expect(parse('90 3c 40'), equals([noteOn]));
            expect(
              parse('3e 40', time: const MidiTime(1000000)),
              equals([noteOn2]),
            );
            expect(issues, isEmpty);
          });
        });

        test('never expires without maxSysExDuration', () {
          expect(parse('f0 01'), isEmpty);
          expect(parse('02 f7', time: const MidiTime(1 << 40)), [
            MidiSysEx(const [1, 2]),
          ]);
        });
      });

      group('noteOnZeroAsNoteOff', () {
        test('delivers Note On with velocity 0 as Note Off', () {
          parser = create(noteOnZeroAsNoteOff: true);
          expect(
            parse('91 3c 00 3c 01'),
            equals([
              const MidiNoteOff(channel: 1, note: 0x3C),
              const MidiNoteOn(channel: 1, note: 0x3C, velocity: 1),
            ]),
          );
        });

        test('keeps Note On with velocity 0 by default', () {
          expect(
            parse('91 3c 00'),
            equals([const MidiNoteOn(channel: 1, note: 0x3C, velocity: 0)]),
          );
        });
      });

      group('reports', () {
        test('data bytes without status', () {
          expect(parse('3c 40 41'), isEmpty);
          expect(issues, equals([(invalid, '3 data bytes without status')]));
        });

        test('each run of data bytes without status', () {
          expect(parse('01 f8 02 03'), equals([const MidiTimingClock()]));
          expect(
            issues,
            equals([
              (invalid, '1 data byte without status'),
              (invalid, '2 data bytes without status'),
            ]),
          );
        });

        test('a message cut short by a status', () {
          expect(
            parse('90 3c 80 3c 40'),
            equals([const MidiNoteOff(channel: 0, note: 0x3C)]),
          );
          expect(
            issues,
            equals([(invalid, 'Message 0x90 incomplete, 1 of 2 data bytes')]),
          );
        });

        test('a status without data bytes', () {
          expect(parse('c0 f3 01'), equals([const MidiSongSelect(song: 1)]));
          expect(
            issues,
            equals([(invalid, 'Message 0xc0 incomplete, 0 of 1 data bytes')]),
          );
        });

        test('a system common message cut short', () {
          expect(parse('f2 01 f0 f7'), equals([MidiSysEx(const [])]));
          expect(
            issues,
            equals([(invalid, 'Message 0xf2 incomplete, 1 of 2 data bytes')]),
          );
        });
      });

      test('completes messages across chunks at the later time', () {
        expect(parser.add(bytes('f2 01'), time: const MidiTime(5)), isEmpty);
        expect(
          parser.add(bytes('02'), time: const MidiTime(6)),
          equals([
            (
              message: const MidiSongPositionPointer(position: 0x101),
              time: const MidiTime(6),
            ),
          ]),
        );
      });

      test('gives real-time messages the time of their chunk', () {
        expect(
          parser.add(bytes('f8'), time: const MidiTime(7)),
          equals([(message: const MidiTimingClock(), time: const MidiTime(7))]),
        );
      });
    });

    group('reset()', () {
      test('drops the running status', () {
        parse('90 3c 40');
        parser.reset();
        expect(parse('3e 40'), isEmpty);
        expect(issues, equals([(invalid, '2 data bytes without status')]));
      });

      test('drops a partial message', () {
        parse('80 3c');
        parser.reset();
        expect(parse('90 3c 40'), equals([noteOn]));
        expect(issues, isEmpty);
      });

      test('drops a partial System Exclusive', () {
        parse('f0 01');
        parser.reset();
        expect(parse('02 f7'), isEmpty);
        expect(
          issues,
          equals([
            (invalid, '1 data byte without status'),
            (invalid, 'End of Exclusive without start'),
          ]),
        );
      });

      test('ends skipping a dropped System Exclusive', () {
        parser = create(maxSysExLength: 0);
        parse('f0 01');
        parser.reset();
        expect(parse('02'), isEmpty);
        expect(issues.last, (invalid, '1 data byte without status'));
      });
    });

    group('round trip with MidiByteEncoder', () {
      final messages = <MidiMessage>[
        for (var status = 0x80; status < 0xF0; status += 0x10)
          for (final channel in [0, 9, 15])
            for (var data1 = 0; data1 < 128; data1++)
              for (final data2 in [0, 0x40, 0x7F])
                if ((status != 0xC0 && status != 0xD0) || data2 == 0)
                  switch (status) {
                    0x80 => MidiNoteOff(
                      channel: channel,
                      note: data1,
                      velocity: data2,
                    ),
                    0x90 => MidiNoteOn(
                      channel: channel,
                      note: data1,
                      velocity: data2,
                    ),
                    0xA0 => MidiPolyPressure(
                      channel: channel,
                      note: data1,
                      pressure: data2,
                    ),
                    0xB0 => MidiControlChange(
                      channel: channel,
                      controller: data1,
                      value: data2,
                    ),
                    0xC0 => MidiProgramChange(channel: channel, program: data1),
                    0xD0 => MidiChannelPressure(
                      channel: channel,
                      pressure: data1,
                    ),
                    _ => MidiPitchBend(
                      channel: channel,
                      value: data2 << 7 | data1,
                    ),
                  },
        for (var piece = 0; piece < 8; piece++)
          MidiTimeCodeQuarterFrame(piece: piece, value: 15 - 2 * piece),
        for (final position in [0, 1, 0x80, 0x2000, 0x3FFF])
          MidiSongPositionPointer(position: position),
        for (final song in [0, 0x7F]) MidiSongSelect(song: song),
        const MidiTuneRequest(),
        const MidiTimingClock(),
        const MidiStart(),
        const MidiContinue(),
        const MidiStop(),
        const MidiActiveSensing(),
        const MidiSystemReset(),
        MidiSysEx(const []),
        MidiSysEx([for (var i = 0; i < 300; i++) i & 0x7F]),
      ];

      test('restores all MIDI 1.0 messages', () {
        final encoded = MidiByteEncoder.encodeAll(messages).bytes;
        expect([
          for (final timed in parser.add(encoded)) timed.message,
        ], equals(messages));
        expect(issues, isEmpty);
      });

      test('restores messages split at every byte', () {
        final sample = [
          const MidiNoteOn(channel: 3, note: 60, velocity: 100),
          const MidiPitchBend(channel: 3, value: 0x1234),
          MidiSysEx(const [0x43, 0x10, 0x4C]),
          const MidiSongPositionPointer(position: 0x1234),
          const MidiProgramChange(channel: 3, program: 7),
        ];
        final encoded = MidiByteEncoder.encodeAll(sample).bytes;
        for (var split = 0; split <= encoded.length; split++) {
          parser.reset();
          final result = [
            ...parser.add(encoded.sublist(0, split)),
            ...parser.add(encoded.sublist(split)),
          ];
          expect(
            [for (final timed in result) timed.message],
            equals(sample),
            reason: 'split at $split',
          );
        }
        expect(issues, isEmpty);
      });

      test('restores messages fed byte by byte', () {
        final sample = messages.sublist(messages.length - 12);
        final encoded = MidiByteEncoder.encodeAll(sample).bytes;
        final result = [
          for (final byte in encoded)
            for (final timed in parser.add([byte])) timed.message,
        ];
        expect(result, equals(sample));
      });
    });
  });
}
