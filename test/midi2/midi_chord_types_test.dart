// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiChordTypes', () {
    // The chord type constants with their names, in the order of Table 14.
    final chordTypes = <String, int>{
      'noChord': MidiChordTypes.noChord,
      'major': MidiChordTypes.major,
      'major6th': MidiChordTypes.major6th,
      'major7th': MidiChordTypes.major7th,
      'major9th': MidiChordTypes.major9th,
      'major11th': MidiChordTypes.major11th,
      'major13th': MidiChordTypes.major13th,
      'minor': MidiChordTypes.minor,
      'minor6th': MidiChordTypes.minor6th,
      'minor7th': MidiChordTypes.minor7th,
      'minor9th': MidiChordTypes.minor9th,
      'minor11th': MidiChordTypes.minor11th,
      'minor13th': MidiChordTypes.minor13th,
      'dominant': MidiChordTypes.dominant,
      'dominant9th': MidiChordTypes.dominant9th,
      'dominant11th': MidiChordTypes.dominant11th,
      'dominant13th': MidiChordTypes.dominant13th,
      'augmented': MidiChordTypes.augmented,
      'augmented7th': MidiChordTypes.augmented7th,
      'diminished': MidiChordTypes.diminished,
      'diminished7th': MidiChordTypes.diminished7th,
      'halfDiminished': MidiChordTypes.halfDiminished,
      'majorMinor': MidiChordTypes.majorMinor,
      'pedal': MidiChordTypes.pedal,
      'power': MidiChordTypes.power,
      'suspended2nd': MidiChordTypes.suspended2nd,
      'suspended4th': MidiChordTypes.suspended4th,
      'seventhSuspended4th': MidiChordTypes.seventhSuspended4th,
    };

    // .........................................................................
    group('constants', () {
      test('number the chord types 0x00 to 0x1B (Table 14)', () {
        expect(
          chordTypes.values,
          equals([for (var t = 0x00; t <= 0x1B; t++) t]),
        );
      });

      test('match spot values of Table 14', () {
        expect(MidiChordTypes.major, 0x01);
        expect(MidiChordTypes.minor, 0x07);
        expect(MidiChordTypes.dominant, 0x0D);
        expect(MidiChordTypes.halfDiminished, 0x15);
        expect(MidiChordTypes.seventhSuspended4th, 0x1B);
      });

      test('number the alteration types 0 to 4', () {
        expect([
          MidiChordTypes.alterationNone,
          MidiChordTypes.alterationAdd,
          MidiChordTypes.alterationSubtract,
          MidiChordTypes.alterationRaise,
          MidiChordTypes.alterationLower,
        ], equals([0, 1, 2, 3, 4]));
      });

      test('number the notes 1 = A to 7 = G', () {
        expect([
          MidiChordTypes.noteUnknown,
          MidiChordTypes.noteA,
          MidiChordTypes.noteB,
          MidiChordTypes.noteC,
          MidiChordTypes.noteD,
          MidiChordTypes.noteE,
          MidiChordTypes.noteF,
          MidiChordTypes.noteG,
        ], equals([0, 1, 2, 3, 4, 5, 6, 7]));
      });

      test('hold the sharps and flats of Tables 13 and 15', () {
        expect([
          MidiChordTypes.doubleSharp,
          MidiChordTypes.sharp,
          MidiChordTypes.natural,
          MidiChordTypes.flat,
          MidiChordTypes.doubleFlat,
          MidiChordTypes.bassIsChordTonic,
        ], equals([2, 1, 0, -1, -2, -8]));
      });
    });

    // .........................................................................
    group('name(chordType)', () {
      test('names every chord type', () {
        for (final MapEntry(key: name, value: chordType)
            in chordTypes.entries) {
          expect(MidiChordTypes.name(chordType), name);
        }
      });

      test('returns null for reserved types', () {
        expect(
          [-1, 0x1C, 0xFF].map(MidiChordTypes.name),
          equals([null, null, null]),
        );
      });
    });

    // .........................................................................
    group('alterationName(type)', () {
      test('names the alteration types', () {
        expect(
          [0, 1, 2, 3, 4].map(MidiChordTypes.alterationName),
          equals([
            'alterationNone',
            'alterationAdd',
            'alterationSubtract',
            'alterationRaise',
            'alterationLower',
          ]),
        );
      });

      test('returns null for reserved types', () {
        expect(
          [-1, 5, 15].map(MidiChordTypes.alterationName),
          equals([null, null, null]),
        );
      });
    });

    // .........................................................................
    group('noteName(note)', () {
      test('returns the letters A to G', () {
        expect(
          [1, 2, 3, 4, 5, 6, 7].map(MidiChordTypes.noteName),
          equals(['A', 'B', 'C', 'D', 'E', 'F', 'G']),
        );
      });

      test('returns null for the unknown note and reserved values', () {
        expect(
          [0, 8, 15, -1].map(MidiChordTypes.noteName),
          equals([null, null, null, null]),
        );
      });
    });
  });
}
