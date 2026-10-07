// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  int max(int bits) => bits == 32 ? 0xFFFFFFFF : (1 << bits) - 1;
  int center(int bits) => 1 << (bits - 1);

  const resolutions = [(7, 16), (7, 32), (14, 32), (8, 16), (16, 32), (2, 8)];

  group('MidiValueScaling', () {
    group('scaleUp(value, fromBits, toBits)', () {
      test('matches the numerical examples of M2-104-UM D.1.3', () {
        final results = [
          for (final value in [0x0A, 0x40, 0x57, 0x7F])
            MidiValueScaling.scaleUp(value, fromBits: 7, toBits: 16),
        ];
        expect(results, equals([0x1400, 0x8000, 0xAEBA, 0xFFFF]));
      });

      test('translates MIDI 1.0 velocity 1 to 0x0200 (M2-104-UM D.3.1)', () {
        expect(MidiValueScaling.scaleUp(1, fromBits: 7, toBits: 16), 0x0200);
      });

      for (final (from, to) in resolutions) {
        test('keeps minimum, center and maximum from $from to $to bits', () {
          final results = [
            for (final value in [0, center(from), max(from)])
              MidiValueScaling.scaleUp(value, fromBits: from, toBits: to),
          ];
          expect(results, equals([0, center(to), max(to)]));
        });
      }

      test('shifts values up to the center (14 to 32 bits)', () {
        expect(
          MidiValueScaling.scaleUp(0x1FFF, fromBits: 14, toBits: 32),
          0x1FFF << 18,
        );
      });

      test('repeats the low bits above the center (7 to 32 bits)', () {
        expect(
          MidiValueScaling.scaleUp(0x41, fromBits: 7, toBits: 32),
          0x82082082,
        );
      });

      test('repeats fewer bits than the scale needs (16 to 18 bits)', () {
        expect(
          MidiValueScaling.scaleUp(0xC000, fromBits: 16, toBits: 18),
          0x30002,
        );
      });

      test('increases strictly for all 7-bit values to 16 bits', () {
        final results = [
          for (var value = 0; value < 128; value++)
            MidiValueScaling.scaleUp(value, fromBits: 7, toBits: 16),
        ];
        for (var i = 1; i < results.length; i++) {
          expect(results[i], greaterThan(results[i - 1]));
        }
      });

      test('returns the value when the resolutions are equal', () {
        final results = [
          for (final value in [0, 0x40, 0x41, 0x7F])
            MidiValueScaling.scaleUp(value, fromBits: 7, toBits: 7),
        ];
        expect(results, equals([0, 0x40, 0x41, 0x7F]));
      });

      test('keeps only the low fromBits bits of the value', () {
        expect(
          MidiValueScaling.scaleUp(0x17F, fromBits: 7, toBits: 16),
          0xFFFF,
        );
      });

      for (final (from, to) in [(1, 8), (8, 7), (16, 33)]) {
        test('asserts valid resolutions, here $from to $to bits', () {
          expect(
            () => MidiValueScaling.scaleUp(0, fromBits: from, toBits: to),
            throwsA(isA<AssertionError>()),
          );
        });
      }
    });

    group('scaleDown(value, fromBits, toBits)', () {
      test('matches the numerical examples of M2-104-UM D.1.4', () {
        final results = [
          for (final value in [0x1400, 0x8000, 0xAEBA, 0xFFFF])
            MidiValueScaling.scaleDown(value, fromBits: 16, toBits: 7),
        ];
        expect(results, equals([0x0A, 0x40, 0x57, 0x7F]));
      });

      test('keeps only the low fromBits bits of the value', () {
        expect(
          MidiValueScaling.scaleDown(0x1FFFF, fromBits: 16, toBits: 7),
          0x7F,
        );
      });

      test('cuts 32-bit values to 7 bits', () {
        expect(
          MidiValueScaling.scaleDown(0xFFFFFFFF, fromBits: 32, toBits: 7),
          0x7F,
        );
      });

      for (final (from, to) in [(8, 0), (7, 8), (33, 7)]) {
        test('asserts valid resolutions, here $from to $to bits', () {
          expect(
            () => MidiValueScaling.scaleDown(0, fromBits: from, toBits: to),
            throwsA(isA<AssertionError>()),
          );
        });
      }
    });

    group('round trip', () {
      for (final (from, to) in resolutions) {
        test('is lossless for all checked $from-bit values via $to bits', () {
          final step = from > 8 ? 7 : 1;
          for (var value = 0; value <= max(from); value += step) {
            final up = MidiValueScaling.scaleUp(
              value,
              fromBits: from,
              toBits: to,
            );
            expect(
              MidiValueScaling.scaleDown(up, fromBits: to, toBits: from),
              value,
            );
          }
        });
      }
    });
  });
}
