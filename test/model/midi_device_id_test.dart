// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiDeviceId', () {
    group('MidiDeviceId(value)', () {
      test('keeps the value', () {
        for (final value in ['coremidi:7', 'alsa:20:0', '']) {
          expect(MidiDeviceId(value).value, value);
        }
      });

      test('compares by value', () {
        expect(
          const MidiDeviceId('a:1'),
          MidiDeviceId.of(backend: 'a', nativeId: '1'),
        );
        expect(const MidiDeviceId('a:1'), isNot(const MidiDeviceId('a:2')));
      });
    });

    group('MidiDeviceId.of(backend: backend, nativeId: nativeId)', () {
      test('joins backend and native id with a colon', () {
        final id = MidiDeviceId.of(backend: 'winrt', nativeId: r'\\?\USB#1');
        expect(id.value, r'winrt:\\?\USB#1');
      });
    });

    group('backend', () {
      test('is the part before the first colon', () {
        expect(const MidiDeviceId('alsa:20:0').backend, 'alsa');
      });

      test('is empty without a colon', () {
        expect(const MidiDeviceId('7').backend, '');
      });
    });

    group('nativeId', () {
      test('is the part after the first colon', () {
        expect(const MidiDeviceId('alsa:20:0').nativeId, '20:0');
      });

      test('is the whole value without a colon', () {
        expect(const MidiDeviceId('7').nativeId, '7');
      });
    });
  });
}
