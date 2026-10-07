// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiFunctionBlockUiHint', () {
    group('values', () {
      test('are ordered by their 2-bit value', () {
        expect(MidiFunctionBlockUiHint.values.map((value) => value.name), [
          'unknown',
          'receiver',
          'sender',
          'senderReceiver',
        ]);
        expect(MidiFunctionBlockUiHint.values.map((value) => value.value), [
          0,
          1,
          2,
          3,
        ]);
      });
    });

    group('fromValue(value)', () {
      test('returns the value of the low two bits', () {
        for (final value in MidiFunctionBlockUiHint.values) {
          expect(MidiFunctionBlockUiHint.fromValue(value.value), value);
          expect(MidiFunctionBlockUiHint.fromValue(value.value | 0xFC), value);
        }
      });
    });
  });
}
