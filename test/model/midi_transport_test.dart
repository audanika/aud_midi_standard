// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiTransport', () {
    group('values', () {
      test('keep their names, the JSON form of the models', () {
        expect(MidiTransport.values.map((value) => value.name), [
          'usb',
          'bluetoothLe',
          'network',
          'virtual',
          'software',
          'unknown',
        ]);
      });
    });
  });
}
