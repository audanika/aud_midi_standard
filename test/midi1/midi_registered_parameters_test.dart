// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiRegisteredParameters', () {
    // Every constant with its MSB and LSB from the specifications.
    final parameters = <String, (int, ({int msb, int lsb}))>{
      'pitchBendSensitivity': (
        MidiRegisteredParameters.pitchBendSensitivity,
        (msb: 0x00, lsb: 0x00),
      ),
      'channelFineTuning': (
        MidiRegisteredParameters.channelFineTuning,
        (msb: 0x00, lsb: 0x01),
      ),
      'channelCoarseTuning': (
        MidiRegisteredParameters.channelCoarseTuning,
        (msb: 0x00, lsb: 0x02),
      ),
      'tuningProgramChange': (
        MidiRegisteredParameters.tuningProgramChange,
        (msb: 0x00, lsb: 0x03),
      ),
      'tuningBankSelect': (
        MidiRegisteredParameters.tuningBankSelect,
        (msb: 0x00, lsb: 0x04),
      ),
      'modulationDepthRange': (
        MidiRegisteredParameters.modulationDepthRange,
        (msb: 0x00, lsb: 0x05),
      ),
      'mpeConfiguration': (
        MidiRegisteredParameters.mpeConfiguration,
        (msb: 0x00, lsb: 0x06),
      ),
      'perNotePitchBendSensitivity': (
        MidiRegisteredParameters.perNotePitchBendSensitivity,
        (msb: 0x00, lsb: 0x07),
      ),
      'threeDAzimuthAngle': (
        MidiRegisteredParameters.threeDAzimuthAngle,
        (msb: 0x3D, lsb: 0x00),
      ),
      'threeDElevationAngle': (
        MidiRegisteredParameters.threeDElevationAngle,
        (msb: 0x3D, lsb: 0x01),
      ),
      'threeDGain': (
        MidiRegisteredParameters.threeDGain,
        (msb: 0x3D, lsb: 0x02),
      ),
      'threeDDistanceRatio': (
        MidiRegisteredParameters.threeDDistanceRatio,
        (msb: 0x3D, lsb: 0x03),
      ),
      'threeDMaximumDistance': (
        MidiRegisteredParameters.threeDMaximumDistance,
        (msb: 0x3D, lsb: 0x04),
      ),
      'threeDGainAtMaximumDistance': (
        MidiRegisteredParameters.threeDGainAtMaximumDistance,
        (msb: 0x3D, lsb: 0x05),
      ),
      'threeDReferenceDistanceRatio': (
        MidiRegisteredParameters.threeDReferenceDistanceRatio,
        (msb: 0x3D, lsb: 0x06),
      ),
      'threeDPanSpreadAngle': (
        MidiRegisteredParameters.threeDPanSpreadAngle,
        (msb: 0x3D, lsb: 0x07),
      ),
      'threeDRollAngle': (
        MidiRegisteredParameters.threeDRollAngle,
        (msb: 0x3D, lsb: 0x08),
      ),
      'nullFunction': (
        MidiRegisteredParameters.nullFunction,
        (msb: 0x7F, lsb: 0x7F),
      ),
    };

    // .........................................................................
    group('constants', () {
      test('hold the 14-bit numbers of their MSB and LSB', () {
        for (final MapEntry(key: name, value: (number, parts))
            in parameters.entries) {
          expect(number, parts.msb << 7 | parts.lsb, reason: name);
        }
      });

      test('are unique', () {
        final numbers = parameters.values.map((p) => p.$1).toSet();
        expect(numbers, hasLength(parameters.length));
      });

      test('match the RPNs of M2-104-UM 7.4.7.1 written as 0xMMLL', () {
        // The specification writes MSB and LSB as the two bytes of a hex
        // number, e.g. RPN 0x0006 for MPE MCM.
        int fromBytes(int mmll) => (mmll >> 8) << 7 | (mmll & 0xFF);
        expect([
          MidiRegisteredParameters.pitchBendSensitivity,
          MidiRegisteredParameters.channelCoarseTuning,
          MidiRegisteredParameters.tuningProgramChange,
          MidiRegisteredParameters.tuningBankSelect,
          MidiRegisteredParameters.mpeConfiguration,
        ], equals([0x0000, 0x0002, 0x0003, 0x0004, 0x0006].map(fromBytes)));
      });

      test('place the 3D sound controllers in bank 0x3D', () {
        expect(MidiRegisteredParameters.threeDSoundBank, 0x3D);
        expect(MidiRegisteredParameters.threeDAzimuthAngle, 0x1E80);
        expect(MidiRegisteredParameters.threeDRollAngle, 0x1E88);
      });

      test('use 0x3FFF for the null function', () {
        expect(MidiRegisteredParameters.nullFunction, 0x3FFF);
      });
    });

    // .........................................................................
    group('numberOf(msb, lsb)', () {
      test('joins MSB and LSB', () {
        for (final (number, parts) in parameters.values) {
          expect(
            MidiRegisteredParameters.numberOf(msb: parts.msb, lsb: parts.lsb),
            number,
          );
        }
      });

      for (final (msb, lsb, name) in [
        (-1, 0, 'msb'),
        (128, 0, 'msb'),
        (0, -1, 'lsb'),
        (0, 128, 'lsb'),
      ]) {
        test('throws for msb $msb and lsb $lsb', () {
          expect(
            () => MidiRegisteredParameters.numberOf(msb: msb, lsb: lsb),
            throwsA(isA<RangeError>().having((e) => e.name, 'name', name)),
          );
        });
      }
    });

    // .........................................................................
    group('msbLsbOf(number)', () {
      test('splits the constants into MSB and LSB', () {
        for (final (number, parts) in parameters.values) {
          expect(MidiRegisteredParameters.msbLsbOf(number), parts);
        }
      });

      test('reverses numberOf for all 16384 numbers', () {
        for (var number = 0; number <= 0x3FFF; number++) {
          final (:msb, :lsb) = MidiRegisteredParameters.msbLsbOf(number);
          expect(MidiRegisteredParameters.numberOf(msb: msb, lsb: lsb), number);
        }
      });

      for (final number in [-1, 0x4000]) {
        test('throws for $number', () {
          expect(
            () => MidiRegisteredParameters.msbLsbOf(number),
            throwsA(isA<RangeError>().having((e) => e.name, 'name', 'number')),
          );
        });
      }
    });

    // .........................................................................
    group('name(number)', () {
      test('returns the constant name of every parameter', () {
        for (final MapEntry(key: name, value: (number, _))
            in parameters.entries) {
          expect(MidiRegisteredParameters.name(number), name);
        }
      });

      test('returns null for unknown numbers', () {
        expect(
          [
            0x0008,
            0x3D << 7 | 0x09,
            0x3FFE,
            -1,
          ].map(MidiRegisteredParameters.name).toList(),
          equals([null, null, null, null]),
        );
      });
    });
  });
}
