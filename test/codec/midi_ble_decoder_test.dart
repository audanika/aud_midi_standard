// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  late List<(MidiDiagnosticKind, String)> issues;
  late MidiBleDecoder decoder;

  MidiBleDecoder create({int maxSysExLength = 1 << 20}) => MidiBleDecoder(
    maxSysExLength: maxSysExLength,
    onIssue: (kind, cause) => issues.add((kind, cause)),
  );

  const time = MidiTime(10000000);

  List<MidiTimedMessage> decode(String hex, {MidiTime at = time}) =>
      decoder.decode(MidiBytes.fromHex(hex).bytes, time: at);

  MidiTime before(int milliseconds) =>
      time - Duration(milliseconds: milliseconds);

  setUp(() {
    issues = [];
    decoder = create();
  });

  const invalid = MidiDiagnosticKind.invalidData;
  const noteOn = MidiNoteOn(channel: 0, note: 0x3C, velocity: 0x64);
  const noteOn2 = MidiNoteOn(channel: 0, note: 0x3E, velocity: 0x64);
  const noteOff = MidiNoteOff(channel: 0, note: 0x3C);

  group('MidiBleDecoder', () {
    group('MidiBleDecoder(maxSysExLength, onIssue)', () {
      test('uses defaults', () {
        final decoder = MidiBleDecoder();
        expect(decoder.maxSysExLength, 1 << 20);
        expect(decoder.onIssue, isNull);
      });

      test('ignores issues without callback', () {
        expect(MidiBleDecoder().decode(const []), isEmpty);
      });
    });

    group('decode(packet, time)', () {
      test('decodes a message at the receive time', () {
        expect(
          decode('87 e8 90 3c 64'),
          equals([(message: noteOn, time: time)]),
        );
        expect(issues, isEmpty);
      });

      test('places earlier timestamps before the receive time', () {
        expect(
          decode('87 e8 90 3c 64 f2 80 3c 40'),
          equals([
            (message: noteOn, time: before(10)),
            (message: noteOff, time: time),
          ]),
        );
      });

      test('carries the timestamp into the high bits', () {
        expect(
          decode('87 ff 90 3c 64 81 80 3c 40'),
          equals([
            (message: noteOn, time: before(2)),
            (message: noteOff, time: time),
          ]),
        );
      });

      test('wraps the 13-bit timestamp', () {
        expect(
          decode('bf ff 90 3c 64 80 80 3c 40'),
          equals([
            (message: noteOn, time: before(1)),
            (message: noteOff, time: time),
          ]),
        );
      });

      test('decodes running status without timestamp', () {
        expect(
          decode('80 80 90 3c 64 3e 64'),
          equals([
            (message: noteOn, time: time),
            (message: noteOn2, time: time),
          ]),
        );
      });

      test('decodes running status with its own timestamp', () {
        expect(
          decode('80 80 90 3c 64 85 3e 64'),
          equals([
            (message: noteOn, time: before(5)),
            (message: noteOn2, time: time),
          ]),
        );
      });

      test('keeps running status for the next packet', () {
        decode('80 80 90 3c 64');
        expect(decode('80 80 3e 64'), equals([(message: noteOn2, time: time)]));
      });

      test('delivers real-time messages inside other messages', () {
        expect(
          decode('80 80 90 3c 81 f8 64'),
          equals([
            (message: const MidiTimingClock(), time: time),
            (message: noteOn, time: time),
          ]),
        );
      });

      test('decodes system common messages', () {
        expect(
          decode('80 80 f2 01 02 81 f6'),
          equals([
            (
              message: const MidiSongPositionPointer(position: 0x101),
              time: before(1),
            ),
            (message: const MidiTuneRequest(), time: time),
          ]),
        );
      });

      group('System Exclusive', () {
        test('across packets at the time of 0xF0', () {
          expect(decode('80 80 f0 01 02', at: const MidiTime(5000)), isEmpty);
          expect(decode('80 03 04'), isEmpty);
          expect(
            decode('81 05 82 f7'),
            equals([
              (
                message: MidiSysEx(const [1, 2, 3, 4, 5]),
                time: const MidiTime(5000),
              ),
            ]),
          );
          expect(issues, isEmpty);
        });

        test('with real-time messages inside', () {
          expect(
            decode('80 80 f0 01 81 f8 02 82 f7'),
            equals([
              (message: const MidiTimingClock(), time: before(1)),
              (message: MidiSysEx(const [1, 2]), time: before(2)),
            ]),
          );
        });

        test('followed by other messages', () {
          expect(
            decode('80 80 f0 7e 80 f7 81 90 3c 64'),
            equals([
              (message: MidiSysEx(const [0x7E]), time: before(1)),
              (message: noteOn, time: time),
            ]),
          );
        });

        test('longer than maxSysExLength is dropped', () {
          decoder = create(maxSysExLength: 1);
          expect(decode('80 80 f0 01 02 81 f7'), isEmpty);
          expect(
            issues,
            equals([
              (
                MidiDiagnosticKind.sysExTooLong,
                'System Exclusive longer than 1 bytes',
              ),
            ]),
          );
        });
      });

      group('reports', () {
        test('an empty packet', () {
          expect(decode(''), isEmpty);
          expect(
            issues,
            equals([(invalid, 'BLE-MIDI packet without header byte')]),
          );
        });

        test('a packet without header byte', () {
          expect(decode('00 80 90 3c 64'), isEmpty);
          expect(issues, hasLength(1));
        });

        test('a timestamp without message', () {
          expect(
            decode('80 80 90 3c 64 81'),
            equals([(message: noteOn, time: before(1))]),
          );
          expect(
            issues,
            equals([(invalid, 'BLE-MIDI timestamp without message')]),
          );
        });

        test('data bytes without status', () {
          expect(decode('80 3c 64'), isEmpty);
          expect(issues, equals([(invalid, '2 data bytes without status')]));
        });
      });

      test('keeps the low eight bits of each value', () {
        expect(
          decoder.decode(const [0x180, 0x180, 0x190, 0x13C, 0x164], time: time),
          equals([(message: noteOn, time: time)]),
        );
      });

      test('uses time zero by default', () {
        expect(
          decoder.decode(MidiBytes.fromHex('80 80 90 3c 64').bytes),
          equals([(message: noteOn, time: MidiTime.zero)]),
        );
      });
    });

    group('reset()', () {
      test('drops a partial System Exclusive', () {
        decode('80 80 f0 01');
        decoder.reset();
        expect(decode('80 02 81 f7'), isEmpty);
        expect(
          issues,
          equals([
            (invalid, '1 data byte without status'),
            (invalid, 'End of Exclusive without start'),
          ]),
        );
      });
    });
  });
}
