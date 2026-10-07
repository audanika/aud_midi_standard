// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiProtocol', () {
    group('values', () {
      test('keep their names, the JSON form of the models', () {
        expect(MidiProtocol.values.map((value) => value.name), [
          'midi1',
          'midi2',
        ]);
      });
    });

    group('value', () {
      test('is the value in stream configuration messages', () {
        expect(MidiProtocol.values.map((value) => value.value), [0x01, 0x02]);
      });
    });

    group('fromValue(value)', () {
      test('returns the protocol of the value', () {
        for (final protocol in MidiProtocol.values) {
          expect(MidiProtocol.fromValue(protocol.value), protocol);
        }
      });

      test('returns null for an unknown value', () {
        for (final value in [0x00, 0x03, 0xFF]) {
          expect(MidiProtocol.fromValue(value), isNull);
        }
      });
    });
  });
}
