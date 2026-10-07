// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiTimeCode', () {
    // Returns the quarter frames with [values] for the pieces 0 to 7.
    List<MidiTimeCodeQuarterFrame> frames(List<int> values) => [
      for (var piece = 0; piece < values.length; piece++)
        MidiTimeCodeQuarterFrame(piece: piece, value: values[piece]),
    ];

    // Returns the fields of a time as a list for whole-list comparison.
    List<int>? fieldsOf(
      ({int hours, int minutes, int seconds, int frames, int rate})? time,
    ) => time == null
        ? null
        : [time.hours, time.minutes, time.seconds, time.frames, time.rate];

    // .........................................................................
    group('constants', () {
      test('number the rates as the MIDI Time Code specification', () {
        expect([
          MidiTimeCode.rate24,
          MidiTimeCode.rate25,
          MidiTimeCode.rate2997Drop,
          MidiTimeCode.rate30,
        ], equals([0, 1, 2, 3]));
      });

      test('number the quarter frame pieces 0 to 7', () {
        expect([
          MidiTimeCode.pieceFramesLow,
          MidiTimeCode.pieceFramesHigh,
          MidiTimeCode.pieceSecondsLow,
          MidiTimeCode.pieceSecondsHigh,
          MidiTimeCode.pieceMinutesLow,
          MidiTimeCode.pieceMinutesHigh,
          MidiTimeCode.pieceHoursLow,
          MidiTimeCode.pieceHoursHighAndRate,
        ], equals([0, 1, 2, 3, 4, 5, 6, 7]));
      });
    });

    // .........................................................................
    group('framesPerSecond(rate)', () {
      test('returns 24, 25, 29.97 and 30', () {
        expect(
          [0, 1, 2, 3].map(MidiTimeCode.framesPerSecond),
          equals([24.0, 25.0, 30000 / 1001, 30.0]),
        );
        expect(MidiTimeCode.framesPerSecond(2), closeTo(29.97, 0.001));
      });

      for (final rate in [-1, 4]) {
        test('throws for the rate $rate', () {
          expect(
            () => MidiTimeCode.framesPerSecond(rate),
            throwsA(isA<RangeError>().having((e) => e.name, 'name', 'rate')),
          );
        });
      }
    });

    // .........................................................................
    group('frameCount(rate)', () {
      test('returns 24, 25, 30 and 30', () {
        expect(
          [0, 1, 2, 3].map(MidiTimeCode.frameCount),
          equals([24, 25, 30, 30]),
        );
      });

      test('throws for an invalid rate', () {
        expect(
          () => MidiTimeCode.frameCount(4),
          throwsA(isA<RangeError>().having((e) => e.name, 'name', 'rate')),
        );
      });
    });

    // .........................................................................
    group('quarterFrames(...)', () {
      test('splits a time into eight nibbles', () {
        expect(
          MidiTimeCode.quarterFrames(
            hours: 1,
            minutes: 23,
            seconds: 45,
            frames: 12,
            rate: MidiTimeCode.rate25,
          ),
          equals(frames([0xC, 0x0, 0xD, 0x2, 0x7, 0x1, 0x1, 0x2])),
        );
      });

      test('puts the rate and the high hour bit into piece 7', () {
        expect(
          MidiTimeCode.quarterFrames(
            hours: 23,
            minutes: 59,
            seconds: 59,
            frames: 29,
            rate: MidiTimeCode.rate30,
          ),
          equals(frames([0xD, 0x1, 0xB, 0x3, 0xB, 0x3, 0x7, 0x7])),
        );
      });

      test('returns an unmodifiable list', () {
        final quarterFrames = MidiTimeCode.quarterFrames(
          hours: 0,
          minutes: 0,
          seconds: 0,
          frames: 0,
          rate: MidiTimeCode.rate24,
        );
        expect(quarterFrames.clear, throwsUnsupportedError);
      });

      for (final (name, time) in [
        ('hours', [24, 0, 0, 0, MidiTimeCode.rate30]),
        ('minutes', [0, 60, 0, 0, MidiTimeCode.rate30]),
        ('seconds', [0, 0, -1, 0, MidiTimeCode.rate30]),
        ('frames', [0, 0, 0, 24, MidiTimeCode.rate24]),
        ('frames', [0, 0, 0, 25, MidiTimeCode.rate25]),
        ('frames', [0, 0, 0, 30, MidiTimeCode.rate2997Drop]),
        ('rate', [0, 0, 0, 0, 4]),
      ]) {
        test('throws for the $name of $time', () {
          expect(
            () => MidiTimeCode.quarterFrames(
              hours: time[0],
              minutes: time[1],
              seconds: time[2],
              frames: time[3],
              rate: time[4],
            ),
            throwsA(isA<RangeError>().having((e) => e.name, 'name', name)),
          );
        });
      }
    });

    // .........................................................................
    group('assemble(quarterFrames)', () {
      test('reverses quarterFrames for all rates', () {
        for (final time in [
          [0, 0, 0, 0, MidiTimeCode.rate24],
          [1, 23, 45, 12, MidiTimeCode.rate25],
          [10, 0, 1, 29, MidiTimeCode.rate2997Drop],
          [23, 59, 59, 29, MidiTimeCode.rate30],
          [16, 32, 16, 16, MidiTimeCode.rate30],
        ]) {
          final quarterFrames = MidiTimeCode.quarterFrames(
            hours: time[0],
            minutes: time[1],
            seconds: time[2],
            frames: time[3],
            rate: time[4],
          );
          expect(fieldsOf(MidiTimeCode.assemble(quarterFrames)), time);
        }
      });

      test('assembles the pieces of reverse playback', () {
        final quarterFrames = frames([0xC, 0x0, 0xD, 0x2, 0x7, 0x1, 0x1, 0x2]);
        expect(
          fieldsOf(MidiTimeCode.assemble(quarterFrames.reversed)),
          equals([1, 23, 45, 12, MidiTimeCode.rate25]),
        );
      });

      test('ignores the reserved bits', () {
        expect(
          fieldsOf(
            MidiTimeCode.assemble(
              frames([0x0, 0xF, 0x0, 0xC, 0x0, 0xC, 0x0, 0x8]),
            ),
          ),
          equals([0, 0, 0, 16, MidiTimeCode.rate24]),
        );
      });

      test('returns null when a piece is missing', () {
        expect(MidiTimeCode.assemble(frames([0, 0, 0, 0, 0, 0, 0])), isNull);
      });

      test('returns null when a piece repeats', () {
        expect(
          MidiTimeCode.assemble([
            ...frames([0, 0, 0, 0, 0, 0, 0, 0]),
            const MidiTimeCodeQuarterFrame(piece: 3, value: 0),
          ]),
          isNull,
        );
      });

      test('returns null for an invalid time', () {
        // Seconds 0x3F = 63 and frames 24 at 24 frames per second.
        expect(
          MidiTimeCode.assemble(frames([0, 0, 0xF, 0x3, 0, 0, 0, 0])),
          isNull,
        );
        expect(
          MidiTimeCode.assemble(frames([0x8, 0x1, 0, 0, 0, 0, 0, 0])),
          isNull,
        );
      });
    });

    // .........................................................................
    group('fullMessage(...)', () {
      test('writes the rate into the hours byte', () {
        expect(
          MidiTimeCode.fullMessage(
            hours: 1,
            minutes: 23,
            seconds: 45,
            frames: 12,
            rate: MidiTimeCode.rate25,
          ),
          MidiSysEx([0x7F, 0x7F, 0x01, 0x01, 0x21, 23, 45, 12]),
        );
      });

      test('addresses a device', () {
        expect(
          MidiTimeCode.fullMessage(
            hours: 23,
            minutes: 0,
            seconds: 0,
            frames: 29,
            rate: MidiTimeCode.rate30,
            deviceId: 0x05,
          ),
          MidiSysEx([0x7F, 0x05, 0x01, 0x01, 0x77, 0, 0, 29]),
        );
      });

      test('throws for an invalid time', () {
        expect(
          () => MidiTimeCode.fullMessage(
            hours: 0,
            minutes: 0,
            seconds: 60,
            frames: 0,
            rate: MidiTimeCode.rate25,
          ),
          throwsA(isA<RangeError>().having((e) => e.name, 'name', 'seconds')),
        );
      });

      test('throws for an invalid device id', () {
        expect(
          () => MidiTimeCode.fullMessage(
            hours: 0,
            minutes: 0,
            seconds: 0,
            frames: 0,
            rate: MidiTimeCode.rate25,
            deviceId: 0x80,
          ),
          throwsA(isA<RangeError>().having((e) => e.name, 'name', 'deviceId')),
        );
      });
    });

    // .........................................................................
    group('parseFullMessage(sysEx)', () {
      test('reverses fullMessage', () {
        final sysEx = MidiTimeCode.fullMessage(
          hours: 12,
          minutes: 34,
          seconds: 56,
          frames: 7,
          rate: MidiTimeCode.rate2997Drop,
        );
        expect(
          fieldsOf(MidiTimeCode.parseFullMessage(sysEx)),
          equals([12, 34, 56, 7, MidiTimeCode.rate2997Drop]),
        );
      });

      for (final (reason, data) in [
        ('too short', [0x7F, 0x7F, 0x01, 0x01, 0x00, 0, 0]),
        ('too long', [0x7F, 0x7F, 0x01, 0x01, 0x00, 0, 0, 0, 0]),
        ('non-real-time', [0x7E, 0x7F, 0x01, 0x01, 0x00, 0, 0, 0]),
        ('device control', [0x7F, 0x7F, 0x04, 0x01, 0x00, 0, 0, 0]),
        ('user bits', [0x7F, 0x7F, 0x01, 0x02, 0x00, 0, 0, 0]),
        ('an invalid time', [0x7F, 0x7F, 0x01, 0x01, 0x00, 60, 0, 0]),
      ]) {
        test('returns null for a message that is $reason', () {
          expect(MidiTimeCode.parseFullMessage(MidiSysEx(data)), isNull);
        });
      }
    });
  });
}
