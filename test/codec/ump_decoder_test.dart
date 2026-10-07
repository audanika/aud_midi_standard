// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  late List<(MidiDiagnosticKind, String)> issues;
  late UmpDecoder decoder;

  UmpDecoder create({int maxSysExLength = 1 << 20, Duration? duration}) =>
      UmpDecoder(
        maxSysExLength: maxSysExLength,
        maxSysExDuration: duration,
        onIssue: (kind, cause) => issues.add((kind, cause)),
      );

  List<int> words(String hex) => [
    for (final word in hex.trim().split(RegExp(r'\s+')))
      if (word.isNotEmpty) int.parse(word, radix: 16),
  ];

  List<UmpDecodedMessage> add(String hex, {int time = 0}) =>
      decoder.add(words(hex), time: MidiTime(time));

  List<MidiMessage> decode(String hex, {int time = 0}) => [
    for (final decoded in add(hex, time: time)) decoded.message,
  ];

  MidiUnknownMessage unknown(String hex) =>
      MidiUnknownMessage([Ump.fromHex(hex)]);

  List<int> count(int n, {int from = 1}) => [
    for (var i = 0; i < n; i++) from + i,
  ];

  setUp(() {
    issues = [];
    decoder = create();
  });

  const invalid = MidiDiagnosticKind.invalidData;
  const incomplete = MidiDiagnosticKind.sysExIncomplete;
  const tooLong = MidiDiagnosticKind.sysExTooLong;

  group('UmpDecoder', () {
    group('UmpDecoder(...)', () {
      test('uses defaults', () {
        final decoder = UmpDecoder();
        expect(decoder.maxSysExLength, 1 << 20);
        expect(decoder.maxSysExDuration, isNull);
        expect(decoder.onIssue, isNull);
      });

      test('ignores issues without callback', () {
        expect(UmpDecoder().add(words('35260102 03040506 30000000')), isEmpty);
      });
    });

    group('add(words, time)', () {
      group('decodes the packets', () {
        final cases = <(String, MidiMessage)>[
          ('00000000', const MidiNoop()),
          ('000fffff', const MidiNoop()),
          ('00101234', const MidiJrClock(time: 0x1234)),
          ('0020ffff', const MidiJrTimestamp(time: 0xFFFF)),
          (
            '003001e0',
            const MidiDeltaClockstampTicksPerQuarterNote(
              ticksPerQuarterNote: 480,
            ),
          ),
          ('004fffff', const MidiDeltaClockstamp(ticks: 0xFFFFF)),
          ('15f13c00', const MidiTimeCodeQuarterFrame(piece: 3, value: 0xC)),
          ('15f23424', const MidiSongPositionPointer(position: 0x1234)),
          ('15f35500', const MidiSongSelect(song: 0x55)),
          ('15f60000', const MidiTuneRequest()),
          ('15f80000', const MidiTimingClock()),
          ('15fa0000', const MidiStart()),
          ('15fb0000', const MidiContinue()),
          ('15fc0000', const MidiStop()),
          ('15fe0000', const MidiActiveSensing()),
          ('15ff0000', const MidiSystemReset()),
          ('25823c40', const MidiNoteOff(channel: 2, note: 0x3C)),
          (
            '259fbcc0',
            const MidiNoteOn(channel: 15, note: 0x3C, velocity: 0x40),
          ),
          (
            '25a04010',
            const MidiPolyPressure(channel: 0, note: 0x40, pressure: 0x10),
          ),
          (
            '25b10764',
            const MidiControlChange(channel: 1, controller: 7, value: 0x64),
          ),
          ('25c37fff', const MidiProgramChange(channel: 3, program: 0x7F)),
          ('25d42000', const MidiChannelPressure(channel: 4, pressure: 0x20)),
          ('25e90040', const MidiPitchBend(channel: 9, value: 0x2000)),
          ('35030102 03000000', MidiSysEx(const [1, 2, 3])),
          ('35000000 00000000', MidiSysEx(const [])),
          (
            '3506f1f2 f3f4f5f6',
            MidiSysEx(const [0x71, 0x72, 0x73, 0x74, 0x75, 0x76]),
          ),
          ('45823c00 80000000', const MidiNoteOff2(channel: 2, note: 0x3C)),
          (
            '459f7f03 ffff1234',
            const MidiNoteOn2(
              channel: 15,
              note: 0x7F,
              velocity: 0xFFFF,
              attributeType: 3,
              attribute: 0x1234,
            ),
          ),
          (
            '45a04000 12345678',
            const MidiPolyPressure2(
              channel: 0,
              note: 0x40,
              pressure: 0x12345678,
            ),
          ),
          (
            '45011003 80000000',
            const MidiRegisteredPerNoteController(
              channel: 1,
              note: 0x10,
              index: 3,
              value: 0x80000000,
            ),
          ),
          (
            '451110ff 00000001',
            const MidiAssignablePerNoteController(
              channel: 1,
              note: 0x10,
              index: 0xFF,
              value: 1,
            ),
          ),
          (
            '45f23c02 00000000',
            const MidiPerNoteManagement(channel: 2, note: 0x3C, detach: true),
          ),
          (
            '45f23c01 00000000',
            const MidiPerNoteManagement(channel: 2, note: 0x3C, reset: true),
          ),
          (
            '45b30700 ffffffff',
            const MidiControlChange2(
              channel: 3,
              controller: 7,
              value: 0xFFFFFFFF,
            ),
          ),
          (
            '4524ff80 10000000',
            const MidiRegisteredController(
              channel: 4,
              bank: 0x7F,
              index: 0,
              value: 0x10000000,
            ),
          ),
          (
            '45351234 deadbeef',
            const MidiAssignableController(
              channel: 5,
              bank: 0x12,
              index: 0x34,
              value: 0xDEADBEEF,
            ),
          ),
          (
            '45460102 ffffffff',
            const MidiRelativeRegisteredController(
              channel: 6,
              bank: 1,
              index: 2,
              value: -1,
            ),
          ),
          (
            '45570304 80000000',
            const MidiRelativeAssignableController(
              channel: 7,
              bank: 3,
              index: 4,
              value: -0x80000000,
            ),
          ),
          (
            '45570304 7fffffff',
            const MidiRelativeAssignableController(
              channel: 7,
              bank: 3,
              index: 4,
              value: 0x7FFFFFFF,
            ),
          ),
          (
            '45c800fe 10001234',
            const MidiProgramChange2(channel: 8, program: 0x10),
          ),
          (
            '45c80001 7f001234',
            const MidiProgramChange2(
              channel: 8,
              program: 0x7F,
              bank: (msb: 0x12, lsb: 0x34),
            ),
          ),
          (
            '45d90000 abcdef01',
            const MidiChannelPressure2(channel: 9, pressure: 0xABCDEF01),
          ),
          (
            '45ea0000 80000000',
            const MidiPitchBend2(channel: 10, value: 0x80000000),
          ),
          (
            '456b3c00 7fffffff',
            const MidiPerNotePitchBend(
              channel: 11,
              note: 0x3C,
              value: 0x7FFFFFFF,
            ),
          ),
          (
            '550407aa bbcc0000 00000000 00000000',
            MidiSysEx8(streamId: 7, data: const [0xAA, 0xBB, 0xCC]),
          ),
          (
            '55010000 00000000 00000000 00000000',
            MidiSysEx8(streamId: 0, data: const []),
          ),
          (
            '55830020 00010001 00437f7f 01020304 '
                '55930102 03040506 0708090a 0b0c0d0e',
            MidiMixedDataSet(
              mdsId: 3,
              manufacturerId: 0x43,
              deviceId: 0x7F7F,
              subId1: 0x0102,
              subId2: 0x0304,
              data: count(14),
            ),
          ),
          (
            'd5100000 02faf080 00000000 00000000',
            const MidiSetTempo(tenNanosecondsPerQuarterNote: 50000000),
          ),
          (
            'd5000000 02faf080 00000000 00000000',
            const MidiSetTempo(tenNanosecondsPerQuarterNote: 50000000),
          ),
          (
            'd5100001 06030800 00000000 00000000',
            const MidiSetTimeSignature(numerator: 6, denominator: 3),
          ),
          (
            'd5100002 18030201 02040000 00000000',
            const MidiSetMetronome(
              clocksPerPrimaryClick: 24,
              barAccent1: 3,
              barAccent2: 2,
              barAccent3: 1,
              subdivisionClicks1: 2,
              subdivisionClicks2: 4,
            ),
          ),
          (
            'd5100005 c4000000 00000000 00000000',
            const MidiSetKeySignature(sharpsFlats: -4, tonicNote: 4),
          ),
          (
            'd5090005 73000000 00000000 00000000',
            const MidiSetKeySignature(channel: 9, sharpsFlats: 7, tonicNote: 3),
          ),
          (
            'd5030006 130d1935 4b230000 f7012517',
            MidiSetChordName(
              channel: 3,
              tonicSharpsFlats: 1,
              chordTonic: 3,
              chordType: 0x0D,
              alterations: const [
                MidiChordAlteration(type: 1, degree: 9),
                MidiChordAlteration(type: 3, degree: 5),
                MidiChordAlteration(type: 4, degree: 11),
                MidiChordAlteration(type: 2, degree: 3),
              ],
              bassSharpsFlats: -1,
              bassNote: 7,
              bassChordType: 0x01,
              bassAlterations: const [
                MidiChordAlteration(type: 2, degree: 5),
                MidiChordAlteration(type: 1, degree: 7),
              ],
            ),
          ),
          (
            'd5100006 e1070019 00000000 80000000',
            MidiSetChordName(
              tonicSharpsFlats: -2,
              chordTonic: 1,
              chordType: 0x07,
              alterations: const [
                MidiChordAlteration(type: 0, degree: 0),
                MidiChordAlteration(type: 1, degree: 9),
              ],
            ),
          ),
          (
            'd5100104 48690000 00000000 00000000',
            const MidiFlexText(statusBank: 1, status: 4, text: 'Hi'),
          ),
          (
            'd5100104 00000000 00000000 00000000',
            const MidiFlexText(statusBank: 1, status: 4, text: ''),
          ),
          (
            'd5020201 c3a40000 00000000 00000000',
            const MidiFlexText(channel: 2, statusBank: 2, status: 1, text: 'ä'),
          ),
          (
            'd5100104 ff410000 00000000 00000000',
            const MidiFlexText(statusBank: 1, status: 4, text: '�A'),
          ),
          (
            'f0000101 00000000 00000000 00000000',
            const MidiEndpointDiscovery(),
          ),
          (
            'f0000203 0000001f 00000000 00000000',
            const MidiEndpointDiscovery(
              umpVersionMajor: 2,
              umpVersionMinor: 3,
              requestEndpointInfo: true,
              requestDeviceIdentity: true,
              requestEndpointName: true,
              requestProductInstanceId: true,
              requestStreamConfiguration: true,
            ),
          ),
          (
            'f0010203 83000302 00000000 00000000',
            const MidiEndpointInfoNotification(
              umpVersionMajor: 2,
              umpVersionMinor: 3,
              staticFunctionBlocks: true,
              numberOfFunctionBlocks: 3,
              supportsMidi2: true,
              supportsMidi1: true,
              supportsRxJr: true,
            ),
          ),
          (
            'f0010101 20000101 00000000 00000000',
            const MidiEndpointInfoNotification(
              staticFunctionBlocks: false,
              numberOfFunctionBlocks: 32,
              supportsMidi2: false,
              supportsMidi1: true,
              supportsTxJr: true,
            ),
          ),
          (
            'f0020000 00002109 34240202 01020304',
            MidiDeviceIdentityNotification(
              manufacturerId: const [0x00, 0x21, 0x09],
              familyId: 0x1234,
              modelId: 0x0102,
              softwareRevision: const [1, 2, 3, 4],
            ),
          ),
          (
            'f0035379 6e746800 00000000 00000000',
            const MidiEndpointNameNotification(name: 'Synth'),
          ),
          (
            'f004534e 31323300 00000000 00000000',
            const MidiProductInstanceIdNotification(productInstanceId: 'SN123'),
          ),
          (
            'f0050202 00000000 00000000 00000000',
            const MidiStreamConfigurationRequest(
              protocol: MidiProtocol.midi2,
              receiveJr: true,
            ),
          ),
          (
            'f0060101 00000000 00000000 00000000',
            const MidiStreamConfigurationNotification(
              protocol: MidiProtocol.midi1,
              transmitJr: true,
            ),
          ),
          (
            'f010ff03 00000000 00000000 00000000',
            const MidiFunctionBlockDiscovery(),
          ),
          (
            'f0100201 00000000 00000000 00000000',
            const MidiFunctionBlockDiscovery(
              functionBlock: 2,
              requestName: false,
            ),
          ),
          (
            'f011812b 00040201 00000000 00000000',
            const MidiFunctionBlockInfoNotification(
              active: true,
              functionBlock: 1,
              uiHint: MidiFunctionBlockUiHint.sender,
              midi1: MidiFunctionBlockMidi1.restricted31250,
              direction: MidiFunctionBlockDirection.bidirectional,
              firstGroup: 0,
              numberOfGroups: 4,
              midiCiVersion: 2,
              maxSysEx8Streams: 1,
            ),
          ),
          (
            'f0111f01 0f100000 00000000 00000000',
            const MidiFunctionBlockInfoNotification(
              active: false,
              functionBlock: 0x1F,
              direction: MidiFunctionBlockDirection.input,
              firstGroup: 0xF,
              numberOfGroups: 16,
            ),
          ),
          (
            'f0120150 69616e6f 00000000 00000000',
            const MidiFunctionBlockNameNotification(
              functionBlock: 1,
              name: 'Piano',
            ),
          ),
          ('f0200000 00000000 00000000 00000000', const MidiStartOfClip()),
          ('f0210000 00000000 00000000 00000000', const MidiEndOfClip()),
        ];

        for (final (hex, message) in cases) {
          test('$hex as $message', () {
            final first = words(hex).first;
            final type = UmpMessageType.fromWord(first);
            final group = type.hasGroup ? (first >> 24) & 0xF : null;
            expect(
              add(hex, time: 42),
              equals([
                (message: message, group: group, time: const MidiTime(42)),
              ]),
            );
            expect(issues, isEmpty);
          });
        }
      });

      group('returns unknown messages for', () {
        final cases = <(String, String)>[
          ('reserved message type 0x6', '6f123456'),
          ('reserved message type 0x7', '70000000'),
          ('reserved message type 0x8', '80000000 00000000'),
          ('reserved message type 0x9', '90000000 00000000'),
          ('reserved message type 0xA', 'a0000000 00000000'),
          ('reserved message type 0xB', 'b0000000 00000000 00000000'),
          ('reserved message type 0xC', 'c0000000 00000000 00000000'),
          ('reserved message type 0xE', 'e0000000 00000000 00000000 00000000'),
          ('utility status 0x5', '00500000'),
          ('utility status 0xF', '00f00000'),
          ('system status 0xF0', '13f00000'),
          ('system status 0xF4', '13f40000'),
          ('system status 0xF5', '13f50000'),
          ('system status 0xF7', '13f70000'),
          ('system status 0xF9', '13f90000'),
          ('system status 0xFD', '13fd0000'),
          ('channel voice status in a system message', '13903c40'),
          ('data byte as MIDI 1.0 status', '237f0000'),
          ('system status as MIDI 1.0 channel voice', '23f80000'),
          ('System Exclusive status 0x4', '33400000 00000000'),
          ('System Exclusive status 0xF', '33f00000 00000000'),
          ('MIDI 2.0 opcode 0x7', '43700000 00000000'),
          ('data status 0x4', '53400000 00000000 00000000 00000000'),
          ('data status 0xA', '53a00000 00000000 00000000 00000000'),
          ('flex address 2', 'd3200000 00000000 00000000 00000000'),
          ('flex address 3', 'd3300104 41000000 00000000 00000000'),
          ('flex status bank 3', 'd3100300 00000000 00000000 00000000'),
          ('flex status bank 0xFF', 'd31dff00 00000000 00000000 00000000'),
          ('flex setup status 0x03', 'd3100003 00000000 00000000 00000000'),
          ('flex setup status 0x07', 'd3100007 00000000 00000000 00000000'),
          ('flex setup start packet', 'd3500000 02faf080 00000000 00000000'),
          ('flex setup end packet', 'd3d00001 06030800 00000000 00000000'),
          ('stream status 0x07', 'f0070000 00000000 00000000 00000000'),
          ('stream status 0x3FF', 'f3ff0000 00000000 00000000 00000000'),
          ('stream info as start', 'f4010101 00000000 00000000 00000000'),
          ('stream protocol 0x00', 'f0050000 00000000 00000000 00000000'),
          ('stream protocol 0x03', 'f0060300 00000000 00000000 00000000'),
          ('function block group 16', 'f011812b 10040201 00000000 00000000'),
          (
            'function block of 17 groups',
            'f011812b 00110201 00000000 00000000',
          ),
        ];
        for (final (name, hex) in cases) {
          test(name, () {
            final ump = Ump.fromHex(hex);
            expect(
              add(hex, time: 3),
              equals([
                (
                  message: MidiUnknownMessage([ump]),
                  group: ump.group,
                  time: const MidiTime(3),
                ),
              ]),
            );
            expect(issues, isEmpty);
          });
        }

        test('each packet of an unknown flex data message', () {
          const hex = [
            'd3500300 01020304 05060708 090a0b0c',
            'd3d00300 0d000000 00000000 00000000',
          ];
          expect(
            decode(hex.join(' ')),
            equals([unknown(hex[0]), unknown(hex[1])]),
          );
        });

        test('without group for reserved message types', () {
          expect(add('6f123456').single.group, isNull);
        });
      });

      group('reports', () {
        test('an incomplete last packet', () {
          expect(
            decode('10f80000 40000000'),
            equals([const MidiTimingClock()]),
          );
          expect(
            issues,
            equals([(invalid, 'Incomplete packet of 1 of 2 words')]),
          );
        });
      });

      group('System Exclusive', () {
        test('reassembles packets across calls at the first time', () {
          expect(add('35160102 03040506', time: 10), isEmpty);
          expect(add('35260708 090a0b0c', time: 20), isEmpty);
          expect(
            add('35310d00 00000000', time: 30),
            equals([
              (
                message: MidiSysEx(count(13)),
                group: 5,
                time: const MidiTime(10),
              ),
            ]),
          );
          expect(issues, isEmpty);
        });

        test('accepts packets with fewer bytes and empty packets', () {
          expect(
            decode('31120102 00000000 31200000 00000000 31310300 00000000'),
            equals([
              MidiSysEx(const [1, 2, 3]),
            ]),
          );
        });

        test('reassembles each group on its own', () {
          expect(
            decode(
              '31160102 03040506 32160a0b 0c0d0e0f '
              '31310700 00000000 32311000 00000000',
            ),
            equals([
              MidiSysEx(count(7)),
              MidiSysEx(const [10, 11, 12, 13, 14, 15, 16]),
            ]),
          );
        });

        test('keeps real-time and groupless messages of the group', () {
          expect(
            decode(
              '31160102 03040506 11f80000 00000000 '
              'f0200000 00000000 00000000 00000000 31310700 00000000',
            ),
            equals([
              const MidiTimingClock(),
              const MidiNoop(),
              const MidiStartOfClip(),
              MidiSysEx(count(7)),
            ]),
          );
          expect(issues, isEmpty);
        });

        for (final (name, hex, message) in [
          (
            'a channel voice message',
            '21903c40',
            const MidiNoteOn(channel: 0, note: 0x3C, velocity: 0x40),
          ),
          ('a system common message', '11f60000', const MidiTuneRequest()),
          (
            'a flex data message',
            'd1100000 00000001 00000000 00000000',
            const MidiSetTempo(tenNanosecondsPerQuarterNote: 1),
          ),
          (
            'an unknown System Exclusive status',
            '31400000 00000000',
            unknown('31400000 00000000'),
          ),
        ]) {
          test('is terminated by $name of the group', () {
            expect(
              decode('31160102 03040506 $hex 31310700 00000000'),
              equals([message]),
            );
            expect(
              issues,
              equals([
                (incomplete, 'System Exclusive incomplete, interrupted'),
                (invalid, 'System Exclusive ended without start'),
              ]),
            );
          });
        }

        test('is terminated by a new start', () {
          expect(
            decode('31160102 03040506 31160a0b 0c0d0e0f 31310700 00000000'),
            equals([
              MidiSysEx(const [10, 11, 12, 13, 14, 15, 7]),
            ]),
          );
          expect(
            issues,
            equals([(incomplete, 'System Exclusive incomplete, interrupted')]),
          );
        });

        test('is terminated by a complete message', () {
          expect(
            decode('31160102 03040506 31010900 00000000'),
            equals([
              MidiSysEx(const [9]),
            ]),
          );
          expect(issues, hasLength(1));
        });

        test('reports a continue packet without start', () {
          expect(decode('31260102 03040506'), isEmpty);
          expect(
            issues,
            equals([(invalid, 'System Exclusive continued without start')]),
          );
        });

        group('with an invalid number of bytes', () {
          test('in a start packet skips the message', () {
            expect(
              decode('31170102 03040506 31260102 03040506 31310100 00000000'),
              isEmpty,
            );
            expect(
              issues,
              equals([(invalid, 'System Exclusive with 7 bytes')]),
            );
          });

          test('in a continue packet drops the message', () {
            expect(
              decode('31160102 03040506 312f0102 03040506 31310100 00000000'),
              isEmpty,
            );
            expect(
              issues,
              equals([(invalid, 'System Exclusive with 15 bytes')]),
            );
          });

          test('in an end packet drops the message', () {
            expect(decode('31160102 03040506 31380100 00000000'), isEmpty);
            expect(
              issues,
              equals([(invalid, 'System Exclusive with 8 bytes')]),
            );
            expect(decode('31310100 00000000'), isEmpty);
            expect(issues.last.$2, 'System Exclusive ended without start');
          });

          test('in a complete packet terminates a message', () {
            expect(decode('31160102 03040506 31070102 03040506'), isEmpty);
            expect(
              issues,
              equals([
                (incomplete, 'System Exclusive incomplete, interrupted'),
                (invalid, 'System Exclusive with 7 bytes'),
              ]),
            );
          });
        });

        group('longer than maxSysExLength', () {
          setUp(() => decoder = create(maxSysExLength: 8));

          test('is dropped with its remaining packets', () {
            expect(
              decode(
                '31160102 03040506 31260708 090a0b0c 31310d00 00000000 '
                '31020102 00000000',
              ),
              equals([
                MidiSysEx(const [1, 2]),
              ]),
            );
            expect(
              issues,
              equals([(tooLong, 'System Exclusive longer than 8 bytes')]),
            );
          });

          test('is accepted up to the limit', () {
            expect(
              decode('31160102 03040506 31320708 00000000'),
              equals([MidiSysEx(count(8))]),
            );
          });

          test('drops complete packets', () {
            decoder = create(maxSysExLength: 2);
            expect(decode('31030102 03000000'), isEmpty);
            expect(issues, hasLength(1));
          });

          test('is not reported again when interrupted', () {
            expect(
              decode('31160102 03040506 31260708 090a0b0c 11f60000'),
              equals([const MidiTuneRequest()]),
            );
            expect(issues, hasLength(1));
          });
        });

        group('incomplete after maxSysExDuration', () {
          setUp(
            () => decoder = create(duration: const Duration(milliseconds: 1)),
          );

          test('is accepted up to the limit', () {
            expect(add('31160102 03040506'), isEmpty);
            expect(
              decode('31310700 00000000', time: 1000),
              equals([MidiSysEx(count(7))]),
            );
            expect(issues, isEmpty);
          });

          test('is dropped with its remaining packets', () {
            expect(add('31160102 03040506'), isEmpty);
            expect(decode('31260708 090a0b0c', time: 1001), isEmpty);
            expect(decode('31310d00 00000000', time: 5000), isEmpty);
            expect(
              issues,
              equals([
                (
                  incomplete,
                  'System Exclusive incomplete after 0:00:00.001000',
                ),
              ]),
            );
          });
        });
      });

      group('System Exclusive 8', () {
        test('reassembles each stream id on its own', () {
          expect(
            decode(
              '551e0001 02030405 06070809 0a0b0c0d '
              '551e0111 12131415 16171819 1a1b1c1d '
              '5532010e 00000000 00000000 00000000 '
              '5532001e 00000000 00000000 00000000',
            ),
            equals([
              MidiSysEx8(streamId: 1, data: [...count(13, from: 0x11), 0x0E]),
              MidiSysEx8(streamId: 0, data: [...count(13), 0x1E]),
            ]),
          );
        });

        test('ends with a packet of the stream id only', () {
          expect(
            decode(
              '551e0001 02030405 06070809 0a0b0c0d '
              '55310000 00000000 00000000 00000000',
            ),
            equals([MidiSysEx8(streamId: 0, data: count(13))]),
          );
        });

        test('reports an end packet with 0xF bytes as aborted', () {
          expect(
            decode(
              '551e0001 02030405 06070809 0a0b0c0d '
              '553f0000 00000000 00000000 00000000',
            ),
            isEmpty,
          );
          expect(
            issues,
            equals([(incomplete, 'System Exclusive 8 aborted by the sender')]),
          );
        });

        test('reports an abort without start', () {
          expect(decode('553f0700 00000000 00000000 00000000'), isEmpty);
          expect(issues, hasLength(1));
        });

        test('ignores the abort of a dropped message', () {
          decoder = create(maxSysExLength: 1);
          expect(
            decode(
              '551e0001 02030405 06070809 0a0b0c0d '
              '553f0000 00000000 00000000 00000000',
            ),
            isEmpty,
          );
          expect(issues.map((issue) => issue.$1), equals([tooLong]));
        });

        for (final (name, hex) in [
          ('no bytes', '55000000 00000000 00000000 00000000'),
          (
            '0xF bytes in a start packet',
            '551f0000 00000000 00000000 00000000',
          ),
        ]) {
          test('reports a packet with $name', () {
            expect(decode(hex), isEmpty);
            expect(issues.single.$1, invalid);
          });
        }
      });

      group('Mixed Data Sets', () {
        const header = '00437f7f 01020304';
        MidiMixedDataSet set(List<int> data, {int mdsId = 3}) =>
            MidiMixedDataSet(
              mdsId: mdsId,
              manufacturerId: 0x43,
              deviceId: 0x7F7F,
              subId1: 0x0102,
              subId2: 0x0304,
              data: data,
            );

        test('decodes a set of one header packet', () {
          expect(
            add('55830010 00010001 $header', time: 4),
            equals([
              (message: set(const []), group: 5, time: const MidiTime(4)),
            ]),
          );
        });

        test('treats fewer than 16 valid bytes as header only', () {
          expect(decode('55830000 00010001 $header'), equals([set(const [])]));
        });

        test('reassembles chunks across calls at the first time', () {
          expect(
            add(
              '55830013 00020001 $header 55930102 03040506 07080900 00000000',
              time: 1,
            ),
            isEmpty,
          );
          expect(
            add(
              '55830013 00020002 $header 55930400 00000000 00000000 00000000',
              time: 2,
            ),
            equals([
              (message: set(const [1, 4]), group: 5, time: const MidiTime(1)),
            ]),
          );
        });

        test('skips payload packets without data bytes', () {
          expect(
            decode(
              '55830022 00010001 $header '
              '55930102 03040506 0708090a 0b0c0d0e '
              '5593ffff ffffffff ffffffff ffffffff',
            ),
            equals([set(count(14))]),
          );
        });

        test('ends a set of unknown size with the declared last chunk', () {
          expect(
            decode(
              '55830013 00000001 $header 55930100 00000000 00000000 00000000 '
              '55830013 00000002 $header 55930200 00000000 00000000 00000000 '
              '55830013 00030003 $header 55930300 00000000 00000000 00000000',
            ),
            equals([
              set(const [1, 2, 3]),
            ]),
          );
        });

        test('reassembles each MDS id on its own', () {
          expect(
            decode(
              '55830013 00010001 $header 55840013 00010001 $header '
              '55940200 00000000 00000000 00000000 '
              '55930100 00000000 00000000 00000000',
            ),
            equals([
              set(const [2], mdsId: 4),
              set(const [1]),
            ]),
          );
        });

        test('reports a payload packet without header', () {
          expect(decode('55930100 00000000 00000000 00000000'), isEmpty);
          expect(
            issues,
            equals([(invalid, 'Mixed Data Set payload without header')]),
          );
        });

        test('reports a set interrupted by a new first chunk', () {
          expect(
            decode(
              '55830013 00020001 $header 55930100 00000000 00000000 00000000 '
              '55830013 00010001 $header 55930200 00000000 00000000 00000000',
            ),
            equals([
              set(const [2]),
            ]),
          );
          expect(
            issues,
            equals([(incomplete, 'Mixed Data Set incomplete, interrupted')]),
          );
        });

        test('reports a chunk out of order and skips the set', () {
          expect(
            decode(
              '55830013 00040001 $header 55930100 00000000 00000000 00000000 '
              '55830013 00040003 $header 55930300 00000000 00000000 00000000 '
              '55830013 00040004 $header 55930400 00000000 00000000 00000000',
            ),
            isEmpty,
          );
          expect(
            issues,
            equals([(invalid, 'Mixed Data Set chunk 3 out of order')]),
          );
        });

        test('reports a chunk numbered 0 as aborted and skips it', () {
          expect(
            decode(
              '55830013 00020001 $header 55930100 00000000 00000000 00000000 '
              '55830013 00020000 $header 55930200 00000000 00000000 00000000 '
              '55830013 00010001 $header 55930300 00000000 00000000 00000000',
            ),
            equals([
              set(const [3]),
            ]),
          );
          expect(
            issues,
            equals([(incomplete, 'Mixed Data Set aborted by the sender')]),
          );
        });

        test('drops a set longer than maxSysExLength', () {
          decoder = create(maxSysExLength: 1);
          expect(
            decode(
              '55830014 00020001 $header 55930102 00000000 00000000 00000000 '
              '55830013 00020002 $header 55930300 00000000 00000000 00000000 '
              '55830013 00010001 $header 55930400 00000000 00000000 00000000',
            ),
            equals([
              set(const [4]),
            ]),
          );
          expect(
            issues,
            equals([(tooLong, 'Mixed Data Set longer than 1 bytes')]),
          );
        });
      });

      group('flex data texts', () {
        test('reassemble packets at the time of the first one', () {
          expect(
            add(
              'd5500102 61626364 65666768 696a6b6c '
              'd5900102 6d6e6f70 71727374 75767778',
              time: 7,
            ),
            isEmpty,
          );
          expect(
            add('d5d00102 79000000 00000000 00000000', time: 8),
            equals([
              (
                message: const MidiFlexText(
                  statusBank: 1,
                  status: 2,
                  text: 'abcdefghijklmnopqrstuvwxy',
                ),
                group: 5,
                time: const MidiTime(7),
              ),
            ]),
          );
        });

        test('reassemble characters split across packets', () {
          expect(
            decode(
              'd5420201 61626364 65666768 696a6bc3 '
              'd5c20201 a4000000 00000000 00000000',
            ),
            equals([
              const MidiFlexText(
                channel: 2,
                statusBank: 2,
                status: 1,
                text: 'abcdefghijkä',
              ),
            ]),
          );
        });

        test('reassemble each address and status on its own', () {
          expect(
            decode(
              'd5400101 61626364 65666768 696a6b6c '
              'd5500101 41424344 45464748 494a4b4c '
              'd5400102 30313233 34353637 38393a3b '
              'd5c00101 6d000000 00000000 00000000 '
              'd5d00101 4d000000 00000000 00000000 '
              'd5c00102 3c000000 00000000 00000000',
            ),
            equals([
              const MidiFlexText(
                channel: 0,
                statusBank: 1,
                status: 1,
                text: 'abcdefghijklm',
              ),
              const MidiFlexText(
                statusBank: 1,
                status: 1,
                text: 'ABCDEFGHIJKLM',
              ),
              const MidiFlexText(
                channel: 0,
                statusBank: 1,
                status: 2,
                text: '0123456789:;<',
              ),
            ]),
          );
        });

        test('report an end packet without start', () {
          expect(decode('d5d00101 6d000000 00000000 00000000'), isEmpty);
          expect(
            issues,
            equals([(invalid, 'Flex data text ended without start')]),
          );
        });

        test('report a text interrupted by a new start', () {
          expect(
            decode(
              'd5500101 61626364 65666768 696a6b6c '
              'd5500101 41424344 45464748 494a4b4c '
              'd5d00101 4d000000 00000000 00000000',
            ),
            equals([
              const MidiFlexText(
                statusBank: 1,
                status: 1,
                text: 'ABCDEFGHIJKLM',
              ),
            ]),
          );
          expect(
            issues,
            equals([(incomplete, 'Flex data text incomplete, interrupted')]),
          );
        });
      });

      group('stream texts', () {
        test('reassemble an endpoint name', () {
          expect(
            add(
              'f4034142 43444546 4748494a 4b4c4d4e '
              'fc034f00 00000000 00000000 00000000',
            ),
            equals([
              (
                message: const MidiEndpointNameNotification(
                  name: 'ABCDEFGHIJKLMNO',
                ),
                group: null,
                time: MidiTime.zero,
              ),
            ]),
          );
        });

        test('reassemble a product instance id', () {
          expect(
            decode(
              'f4044142 43444546 4748494a 4b4c4d4e '
              'f8045051 52535455 56575859 5a303132 '
              'fc043300 00000000 00000000 00000000',
            ),
            equals([
              const MidiProductInstanceIdNotification(
                productInstanceId: 'ABCDEFGHIJKLMNPQRSTUVWXYZ0123',
              ),
            ]),
          );
        });

        test('reassemble the name of each function block on its own', () {
          expect(
            decode(
              'f4120141 42434445 46474849 4a4b4c4d '
              'f4120261 62636465 66676869 6a6b6c6d '
              'fc12026e 00000000 00000000 00000000 '
              'fc12014e 00000000 00000000 00000000',
            ),
            equals([
              const MidiFunctionBlockNameNotification(
                functionBlock: 2,
                name: 'abcdefghijklmn',
              ),
              const MidiFunctionBlockNameNotification(
                functionBlock: 1,
                name: 'ABCDEFGHIJKLMN',
              ),
            ]),
          );
        });

        test('report a continue packet without start', () {
          expect(decode('f8034142 43444546 4748494a 4b4c4d4e'), isEmpty);
          expect(
            issues,
            equals([(invalid, 'Stream text continued without start')]),
          );
        });
      });

      test('returns an empty list for no words', () {
        expect(add(''), isEmpty);
      });
    });

    group('reset()', () {
      test('drops partial messages', () {
        expect(
          decode(
            '31160102 03040506 551e0001 02030405 06070809 0a0b0c0d '
            '55830013 00020001 00000000 00000000',
          ),
          isEmpty,
        );
        decoder.reset();
        expect(
          decode(
            '31310700 00000000 55320e0e 00000000 00000000 00000000 '
            '55930100 00000000 00000000 00000000',
          ),
          isEmpty,
        );
        expect(
          issues.map((issue) => issue.$2),
          equals([
            'System Exclusive ended without start',
            'System Exclusive 8 ended without start',
            'Mixed Data Set payload without header',
          ]),
        );
      });
    });

    group('round trip with UmpEncoder', () {
      final messages = <MidiMessage>[
        const MidiNoop(),
        const MidiJrClock(time: 0xFFFF),
        const MidiNoteOn(channel: 9, note: 36, velocity: 127),
        const MidiPitchBend(channel: 0, value: 0x3FFF),
        const MidiSongPositionPointer(position: 0x2001),
        const MidiActiveSensing(),
        MidiSysEx(const []),
        MidiSysEx([for (var i = 0; i < 1000; i++) i & 0x7F]),
        const MidiNoteOn2(channel: 1, note: 2, velocity: 3),
        const MidiRelativeRegisteredController(
          channel: 15,
          bank: 127,
          index: 127,
          value: -12345,
        ),
        const MidiProgramChange2(
          channel: 2,
          program: 3,
          bank: (msb: 4, lsb: 5),
        ),
        MidiSysEx8(
          streamId: 9,
          data: [for (var i = 0; i < 1000; i++) i & 0xFF],
        ),
        MidiMixedDataSet(
          mdsId: 15,
          manufacturerId: 0x8213,
          deviceId: 0xFFFF,
          subId1: 1,
          subId2: 2,
          data: [for (var i = 0; i < 70000; i++) i & 0xFF],
        ),
        const MidiSetTimeSignature(
          numerator: 255,
          denominator: 0,
          numberOf32ndNotes: 255,
        ),
        MidiSetChordName(
          channel: 15,
          tonicSharpsFlats: -8,
          chordTonic: 15,
          chordType: 0xFF,
          alterations: const [MidiChordAlteration(type: 15, degree: 15)],
          bassSharpsFlats: 7,
          bassNote: 15,
          bassChordType: 0xFF,
          bassAlterations: const [
            MidiChordAlteration(type: 0, degree: 0),
            MidiChordAlteration(type: 4, degree: 1),
          ],
        ),
        MidiFlexText(
          channel: 1,
          statusBank: 2,
          status: 1,
          text: 'Großes Glück ' * 20,
        ),
        MidiEndpointNameNotification(name: 'Endpoint ${'é' * 40}'),
        MidiFunctionBlockNameNotification(
          functionBlock: 255,
          name: 'Block ${'x' * 80}',
        ),
        const MidiFunctionBlockInfoNotification(
          active: true,
          functionBlock: 0x7F,
          uiHint: MidiFunctionBlockUiHint.senderReceiver,
          midi1: MidiFunctionBlockMidi1.reserved,
          direction: MidiFunctionBlockDirection.reserved,
          firstGroup: 15,
          numberOfGroups: 0,
          midiCiVersion: 255,
          maxSysEx8Streams: 255,
        ),
        MidiDeviceIdentityNotification(
          manufacturerId: const [0x7F, 0x7F, 0x7F],
          familyId: 0x3FFF,
          modelId: 0,
          softwareRevision: const [0x7F, 0, 0x7F, 0],
        ),
      ];

      for (final group in [0, 15]) {
        test('restores the messages of group $group packet by packet', () {
          for (final message in messages) {
            final packets = UmpEncoder.encode(message, group: group);
            final decoded = [
              for (final packet in packets) ...decoder.add(packet.words),
            ];
            expect(decoded.map((d) => d.message), equals([message]));
            expect(
              decoded.single.group,
              message.umpMessageType.hasGroup ? group : isNull,
            );
          }
          expect(issues, isEmpty);
        });
      }
    });
  });
}
