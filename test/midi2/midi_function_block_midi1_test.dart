// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiFunctionBlockMidi1', () {
    group('values', () {
      test('are ordered by their 2-bit value', () {
        expect(MidiFunctionBlockMidi1.values.map((value) => value.name), [
          'notMidi1',
          'unrestricted',
          'restricted31250',
          'reserved',
        ]);
        expect(MidiFunctionBlockMidi1.values.map((value) => value.value), [
          0,
          1,
          2,
          3,
        ]);
      });
    });

    group('fromValue(value)', () {
      test('returns the value of the low two bits', () {
        for (final value in MidiFunctionBlockMidi1.values) {
          expect(MidiFunctionBlockMidi1.fromValue(value.value), value);
          expect(MidiFunctionBlockMidi1.fromValue(value.value | 0xFC), value);
        }
      });
    });
  });
}
