// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiPortId', () {
    group('MidiPortId(value)', () {
      test('keeps the value', () {
        for (final value in ['coremidi:42', 'alsa:20:0', '']) {
          expect(MidiPortId(value).value, value);
        }
      });

      test('compares by value', () {
        expect(
          const MidiPortId('a:1'),
          MidiPortId.of(backend: 'a', nativeId: '1'),
        );
        expect(const MidiPortId('a:1'), isNot(const MidiPortId('a:2')));
      });
    });

    group('MidiPortId.of(backend: backend, nativeId: nativeId)', () {
      test('joins backend and native id with a colon', () {
        final id = MidiPortId.of(backend: 'alsa', nativeId: '20:0');
        expect(id.value, 'alsa:20:0');
      });
    });

    group('backend', () {
      test('is the part before the first colon', () {
        expect(const MidiPortId('alsa:20:0').backend, 'alsa');
      });

      test('is empty without a colon', () {
        expect(const MidiPortId('42').backend, '');
      });
    });

    group('nativeId', () {
      test('is the part after the first colon', () {
        expect(const MidiPortId('alsa:20:0').nativeId, '20:0');
      });

      test('is the whole value without a colon', () {
        expect(const MidiPortId('42').nativeId, '42');
      });
    });
  });
}
