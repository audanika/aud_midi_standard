// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiNoteAttributeTypes', () {
    // .........................................................................
    group('constants', () {
      test('number the attribute types of M2-104-UM Table 8', () {
        expect([
          MidiNoteAttributeTypes.none,
          MidiNoteAttributeTypes.manufacturerSpecific,
          MidiNoteAttributeTypes.profileSpecific,
          MidiNoteAttributeTypes.pitch,
        ], equals([0x00, 0x01, 0x02, 0x03]));
      });
    });

    // .........................................................................
    group('pitchToNote(attribute)', () {
      test('reads seven bits of note and nine bits of fraction', () {
        expect(
          [
            0x0000,
            0x7800,
            0x7900,
            0x8A80,
            0xFFFF,
          ].map(MidiNoteAttributeTypes.pitchToNote),
          equals([0.0, 60.0, 60.5, 69.25, 127 + 511 / 512]),
        );
      });

      for (final attribute in [-1, 0x10000]) {
        test('throws for $attribute', () {
          expect(
            () => MidiNoteAttributeTypes.pitchToNote(attribute),
            throwsA(
              isA<RangeError>().having((e) => e.name, 'name', 'attribute'),
            ),
          );
        });
      }
    });

    // .........................................................................
    group('noteToPitch(note)', () {
      test('writes note numbers with fraction', () {
        expect(
          [
            0,
            60,
            60.5,
            69.25,
            127 + 511 / 512,
          ].map(MidiNoteAttributeTypes.noteToPitch),
          equals([0x0000, 0x7800, 0x7900, 0x8A80, 0xFFFF]),
        );
      });

      test('rounds to 1/512 semitone', () {
        expect(MidiNoteAttributeTypes.noteToPitch(60 + 0.4 / 512), 0x7800);
        expect(MidiNoteAttributeTypes.noteToPitch(60 + 0.6 / 512), 0x7801);
      });

      test('reverses pitchToNote for all attributes', () {
        for (var attribute = 0; attribute <= 0xFFFF; attribute++) {
          final note = MidiNoteAttributeTypes.pitchToNote(attribute);
          expect(MidiNoteAttributeTypes.noteToPitch(note), attribute);
        }
      });

      for (final note in [-0.01, 127.9995, 128, double.nan, double.infinity]) {
        test('throws for $note', () {
          expect(
            () => MidiNoteAttributeTypes.noteToPitch(note),
            throwsA(
              isA<RangeError>()
                  .having((e) => e.name, 'name', 'note')
                  .having(
                    (e) => e.message,
                    'message',
                    'Not a Pitch 7.9 note number',
                  ),
            ),
          );
        });
      }
    });

    // .........................................................................
    group('name(type)', () {
      test('names the defined types', () {
        expect(
          [0, 1, 2, 3].map(MidiNoteAttributeTypes.name),
          equals(['none', 'manufacturerSpecific', 'profileSpecific', 'pitch']),
        );
      });

      test('returns null for reserved types', () {
        expect(
          [0x04, 0xFF].map(MidiNoteAttributeTypes.name),
          equals([null, null]),
        );
      });
    });
  });
}
