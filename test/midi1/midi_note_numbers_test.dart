// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiNoteNumbers', () {
    // All note constants of gg_midi_vars in their declaration order.
    final notes = <String, int>{
      'cM1': MidiNoteNumbers.cM1,
      'dM1': MidiNoteNumbers.dM1,
      'eM1': MidiNoteNumbers.eM1,
      'fM1': MidiNoteNumbers.fM1,
      'gM1': MidiNoteNumbers.gM1,
      'aM1': MidiNoteNumbers.aM1,
      'bM1': MidiNoteNumbers.bM1,
      'c0': MidiNoteNumbers.c0,
      'd0': MidiNoteNumbers.d0,
      'e0': MidiNoteNumbers.e0,
      'f0': MidiNoteNumbers.f0,
      'g0': MidiNoteNumbers.g0,
      'a0': MidiNoteNumbers.a0,
      'b0': MidiNoteNumbers.b0,
      'c1': MidiNoteNumbers.c1,
      'd1': MidiNoteNumbers.d1,
      'e1': MidiNoteNumbers.e1,
      'f1': MidiNoteNumbers.f1,
      'g1': MidiNoteNumbers.g1,
      'a1': MidiNoteNumbers.a1,
      'b1': MidiNoteNumbers.b1,
      'c2': MidiNoteNumbers.c2,
      'd2': MidiNoteNumbers.d2,
      'e2': MidiNoteNumbers.e2,
      'f2': MidiNoteNumbers.f2,
      'g2': MidiNoteNumbers.g2,
      'a2': MidiNoteNumbers.a2,
      'b2': MidiNoteNumbers.b2,
      'c3': MidiNoteNumbers.c3,
      'd3': MidiNoteNumbers.d3,
      'e3': MidiNoteNumbers.e3,
      'f3': MidiNoteNumbers.f3,
      'g3': MidiNoteNumbers.g3,
      'a3': MidiNoteNumbers.a3,
      'b3': MidiNoteNumbers.b3,
      'c4': MidiNoteNumbers.c4,
      'd4': MidiNoteNumbers.d4,
      'e4': MidiNoteNumbers.e4,
      'f4': MidiNoteNumbers.f4,
      'g4': MidiNoteNumbers.g4,
      'a4': MidiNoteNumbers.a4,
      'b4': MidiNoteNumbers.b4,
      'c5': MidiNoteNumbers.c5,
      'd5': MidiNoteNumbers.d5,
      'e5': MidiNoteNumbers.e5,
      'f5': MidiNoteNumbers.f5,
      'g5': MidiNoteNumbers.g5,
      'a5': MidiNoteNumbers.a5,
      'b5': MidiNoteNumbers.b5,
      'c6': MidiNoteNumbers.c6,
      'd6': MidiNoteNumbers.d6,
      'e6': MidiNoteNumbers.e6,
      'f6': MidiNoteNumbers.f6,
      'g6': MidiNoteNumbers.g6,
      'a6': MidiNoteNumbers.a6,
      'b6': MidiNoteNumbers.b6,
      'c7': MidiNoteNumbers.c7,
      'd7': MidiNoteNumbers.d7,
      'e7': MidiNoteNumbers.e7,
      'f7': MidiNoteNumbers.f7,
      'g7': MidiNoteNumbers.g7,
      'a7': MidiNoteNumbers.a7,
      'b7': MidiNoteNumbers.b7,
      'c8': MidiNoteNumbers.c8,
      'd8': MidiNoteNumbers.d8,
      'e8': MidiNoteNumbers.e8,
      'f8': MidiNoteNumbers.f8,
      'g8': MidiNoteNumbers.g8,
      'a8': MidiNoteNumbers.a8,
      'b8': MidiNoteNumbers.b8,
      'c9': MidiNoteNumbers.c9,
      'd9': MidiNoteNumbers.d9,
      'e9': MidiNoteNumbers.e9,
      'f9': MidiNoteNumbers.f9,
      'g9': MidiNoteNumbers.g9,
      'dSharpM1': MidiNoteNumbers.dSharpM1,
      'eSharpM1': MidiNoteNumbers.eSharpM1,
      'fSharpM1': MidiNoteNumbers.fSharpM1,
      'gSharpM1': MidiNoteNumbers.gSharpM1,
      'aSharpM1': MidiNoteNumbers.aSharpM1,
      'bSharpM1': MidiNoteNumbers.bSharpM1,
      'cSharp0': MidiNoteNumbers.cSharp0,
      'dSharp0': MidiNoteNumbers.dSharp0,
      'eSharp0': MidiNoteNumbers.eSharp0,
      'fSharp0': MidiNoteNumbers.fSharp0,
      'gSharp0': MidiNoteNumbers.gSharp0,
      'aSharp0': MidiNoteNumbers.aSharp0,
      'bSharp0': MidiNoteNumbers.bSharp0,
      'cSharp1': MidiNoteNumbers.cSharp1,
      'dSharp1': MidiNoteNumbers.dSharp1,
      'eSharp1': MidiNoteNumbers.eSharp1,
      'fSharp1': MidiNoteNumbers.fSharp1,
      'gSharp1': MidiNoteNumbers.gSharp1,
      'aSharp1': MidiNoteNumbers.aSharp1,
      'bSharp1': MidiNoteNumbers.bSharp1,
      'cSharp2': MidiNoteNumbers.cSharp2,
      'dSharp2': MidiNoteNumbers.dSharp2,
      'eSharp2': MidiNoteNumbers.eSharp2,
      'fSharp2': MidiNoteNumbers.fSharp2,
      'gSharp2': MidiNoteNumbers.gSharp2,
      'aSharp2': MidiNoteNumbers.aSharp2,
      'bSharp2': MidiNoteNumbers.bSharp2,
      'cSharp3': MidiNoteNumbers.cSharp3,
      'dSharp3': MidiNoteNumbers.dSharp3,
      'eSharp3': MidiNoteNumbers.eSharp3,
      'fSharp3': MidiNoteNumbers.fSharp3,
      'gSharp3': MidiNoteNumbers.gSharp3,
      'aSharp3': MidiNoteNumbers.aSharp3,
      'bSharp3': MidiNoteNumbers.bSharp3,
      'cSharp4': MidiNoteNumbers.cSharp4,
      'dSharp4': MidiNoteNumbers.dSharp4,
      'eSharp4': MidiNoteNumbers.eSharp4,
      'fSharp4': MidiNoteNumbers.fSharp4,
      'gSharp4': MidiNoteNumbers.gSharp4,
      'aSharp4': MidiNoteNumbers.aSharp4,
      'bSharp4': MidiNoteNumbers.bSharp4,
      'cSharp5': MidiNoteNumbers.cSharp5,
      'dSharp5': MidiNoteNumbers.dSharp5,
      'eSharp5': MidiNoteNumbers.eSharp5,
      'fSharp5': MidiNoteNumbers.fSharp5,
      'gSharp5': MidiNoteNumbers.gSharp5,
      'aSharp5': MidiNoteNumbers.aSharp5,
      'bSharp5': MidiNoteNumbers.bSharp5,
      'cSharp6': MidiNoteNumbers.cSharp6,
      'dSharp6': MidiNoteNumbers.dSharp6,
      'eSharp6': MidiNoteNumbers.eSharp6,
      'fSharp6': MidiNoteNumbers.fSharp6,
      'gSharp6': MidiNoteNumbers.gSharp6,
      'aSharp6': MidiNoteNumbers.aSharp6,
      'bSharp6': MidiNoteNumbers.bSharp6,
      'cSharp7': MidiNoteNumbers.cSharp7,
      'dSharp7': MidiNoteNumbers.dSharp7,
      'eSharp7': MidiNoteNumbers.eSharp7,
      'fSharp7': MidiNoteNumbers.fSharp7,
      'gSharp7': MidiNoteNumbers.gSharp7,
      'aSharp7': MidiNoteNumbers.aSharp7,
      'bSharp7': MidiNoteNumbers.bSharp7,
      'cSharp8': MidiNoteNumbers.cSharp8,
      'dSharp8': MidiNoteNumbers.dSharp8,
      'eSharp8': MidiNoteNumbers.eSharp8,
      'fSharp8': MidiNoteNumbers.fSharp8,
      'gSharp8': MidiNoteNumbers.gSharp8,
      'aSharp8': MidiNoteNumbers.aSharp8,
      'bSharp8': MidiNoteNumbers.bSharp8,
      'cSharp9': MidiNoteNumbers.cSharp9,
      'dSharp9': MidiNoteNumbers.dSharp9,
      'eSharp9': MidiNoteNumbers.eSharp9,
      'fSharp9': MidiNoteNumbers.fSharp9,
      'gSharp9': MidiNoteNumbers.gSharp9,
      'dFlatM1': MidiNoteNumbers.dFlatM1,
      'eFlatM1': MidiNoteNumbers.eFlatM1,
      'fFlatM1': MidiNoteNumbers.fFlatM1,
      'gFlatM1': MidiNoteNumbers.gFlatM1,
      'aFlatM1': MidiNoteNumbers.aFlatM1,
      'bFlatM1': MidiNoteNumbers.bFlatM1,
      'cFlat0': MidiNoteNumbers.cFlat0,
      'dFlat0': MidiNoteNumbers.dFlat0,
      'eFlat0': MidiNoteNumbers.eFlat0,
      'fFlat0': MidiNoteNumbers.fFlat0,
      'gFlat0': MidiNoteNumbers.gFlat0,
      'aFlat0': MidiNoteNumbers.aFlat0,
      'bFlat0': MidiNoteNumbers.bFlat0,
      'cFlat1': MidiNoteNumbers.cFlat1,
      'dFlat1': MidiNoteNumbers.dFlat1,
      'eFlat1': MidiNoteNumbers.eFlat1,
      'fFlat1': MidiNoteNumbers.fFlat1,
      'gFlat1': MidiNoteNumbers.gFlat1,
      'aFlat1': MidiNoteNumbers.aFlat1,
      'bFlat1': MidiNoteNumbers.bFlat1,
      'cFlat2': MidiNoteNumbers.cFlat2,
      'dFlat2': MidiNoteNumbers.dFlat2,
      'eFlat2': MidiNoteNumbers.eFlat2,
      'fFlat2': MidiNoteNumbers.fFlat2,
      'gFlat2': MidiNoteNumbers.gFlat2,
      'aFlat2': MidiNoteNumbers.aFlat2,
      'bFlat2': MidiNoteNumbers.bFlat2,
      'cFlat3': MidiNoteNumbers.cFlat3,
      'dFlat3': MidiNoteNumbers.dFlat3,
      'eFlat3': MidiNoteNumbers.eFlat3,
      'fFlat3': MidiNoteNumbers.fFlat3,
      'gFlat3': MidiNoteNumbers.gFlat3,
      'aFlat3': MidiNoteNumbers.aFlat3,
      'bFlat3': MidiNoteNumbers.bFlat3,
      'cFlat4': MidiNoteNumbers.cFlat4,
      'dFlat4': MidiNoteNumbers.dFlat4,
      'eFlat4': MidiNoteNumbers.eFlat4,
      'fFlat4': MidiNoteNumbers.fFlat4,
      'gFlat4': MidiNoteNumbers.gFlat4,
      'aFlat4': MidiNoteNumbers.aFlat4,
      'bFlat4': MidiNoteNumbers.bFlat4,
      'cFlat5': MidiNoteNumbers.cFlat5,
      'dFlat5': MidiNoteNumbers.dFlat5,
      'eFlat5': MidiNoteNumbers.eFlat5,
      'fFlat5': MidiNoteNumbers.fFlat5,
      'gFlat5': MidiNoteNumbers.gFlat5,
      'aFlat5': MidiNoteNumbers.aFlat5,
      'bFlat5': MidiNoteNumbers.bFlat5,
      'cFlat6': MidiNoteNumbers.cFlat6,
      'dFlat6': MidiNoteNumbers.dFlat6,
      'eFlat6': MidiNoteNumbers.eFlat6,
      'fFlat6': MidiNoteNumbers.fFlat6,
      'gFlat6': MidiNoteNumbers.gFlat6,
      'aFlat6': MidiNoteNumbers.aFlat6,
      'bFlat6': MidiNoteNumbers.bFlat6,
      'cFlat7': MidiNoteNumbers.cFlat7,
      'dFlat7': MidiNoteNumbers.dFlat7,
      'eFlat7': MidiNoteNumbers.eFlat7,
      'fFlat7': MidiNoteNumbers.fFlat7,
      'gFlat7': MidiNoteNumbers.gFlat7,
      'aFlat7': MidiNoteNumbers.aFlat7,
      'bFlat7': MidiNoteNumbers.bFlat7,
      'cFlat8': MidiNoteNumbers.cFlat8,
      'dFlat8': MidiNoteNumbers.dFlat8,
      'eFlat8': MidiNoteNumbers.eFlat8,
      'fFlat8': MidiNoteNumbers.fFlat8,
      'gFlat8': MidiNoteNumbers.gFlat8,
      'aFlat8': MidiNoteNumbers.aFlat8,
      'bFlat8': MidiNoteNumbers.bFlat8,
      'cFlat9': MidiNoteNumbers.cFlat9,
      'dFlat9': MidiNoteNumbers.dFlat9,
      'eFlat9': MidiNoteNumbers.eFlat9,
      'fFlat9': MidiNoteNumbers.fFlat9,
      'gFlat9': MidiNoteNumbers.gFlat9,
    };

    // Returns the note number a constant name stands for, e.g. 61 for
    // 'cSharp4' and 0 for 'cM1', with C4 as 60.
    int numberOf(String name) {
      final match = RegExp(r'^([a-g])(Sharp|Flat)?(M1|\d)$').firstMatch(name)!;
      const pitchClasses = {
        'c': 0,
        'd': 2,
        'e': 4,
        'f': 5,
        'g': 7,
        'a': 9,
        'b': 11,
      };
      final accidental = switch (match.group(2)) {
        'Sharp' => 1,
        'Flat' => -1,
        _ => 0,
      };
      final octave = match.group(3) == 'M1' ? -1 : int.parse(match.group(3)!);
      return (octave + 1) * 12 + pitchClasses[match.group(1)]! + accidental;
    }

    // .........................................................................
    group('constants', () {
      test('hold the number their name stands for', () {
        for (final MapEntry(key: name, value: number) in notes.entries) {
          expect(number, numberOf(name), reason: name);
        }
      });

      test('keep all 223 constants of gg_midi_vars', () {
        expect(notes, hasLength(223));
      });

      test('place middle C at 60 and the tuning A at 69', () {
        expect(MidiNoteNumbers.c4, 60);
        expect(MidiNoteNumbers.a4, 69);
      });

      test('keep G#9 one above the MIDI range', () {
        expect(MidiNoteNumbers.gSharp9, 128);
        expect(notes.values.where((n) => n > MidiNoteNumbers.max), [128]);
      });

      test('define max as the constant 127', () {
        const max = MidiNoteNumbers.max;
        expect(max, 127);
      });

      test('should have the right values (gg_midi_vars)', () {
        expect(MidiNoteNumbers.c4, 60);
        expect(MidiNoteNumbers.c3, 48);
        expect(MidiNoteNumbers.cSharp3, 49);
        expect(MidiNoteNumbers.dFlat3, 49);
        expect(MidiNoteNumbers.d3, 50);
        expect(MidiNoteNumbers.dSharp3, 51);
        expect(MidiNoteNumbers.eFlat3, 51);
        expect(MidiNoteNumbers.e3, 52);
        expect(MidiNoteNumbers.f3, 53);
        expect(MidiNoteNumbers.fSharp3, 54);
        expect(MidiNoteNumbers.gFlat3, 54);
        expect(MidiNoteNumbers.g3, 55);
        expect(MidiNoteNumbers.gSharp3, 56);
        expect(MidiNoteNumbers.aFlat3, 56);
        expect(MidiNoteNumbers.a3, 57);
        expect(MidiNoteNumbers.aSharp3, 58);
        expect(MidiNoteNumbers.bFlat3, 58);
        expect(MidiNoteNumbers.b3, 59);
        expect(MidiNoteNumbers.c4, 60);
        expect(MidiNoteNumbers.cSharp4, 61);
        expect(MidiNoteNumbers.dFlat4, 61);
        expect(MidiNoteNumbers.d4, 62);
        expect(MidiNoteNumbers.dSharp4, 63);
        expect(MidiNoteNumbers.eFlat4, 63);
        expect(MidiNoteNumbers.e4, 64);
        expect(MidiNoteNumbers.f4, 65);
        expect(MidiNoteNumbers.fSharp4, 66);
        expect(MidiNoteNumbers.gFlat4, 66);
        expect(MidiNoteNumbers.g4, 67);
        expect(MidiNoteNumbers.gSharp4, 68);
        expect(MidiNoteNumbers.aFlat4, 68);
        expect(MidiNoteNumbers.a4, 69);
        expect(MidiNoteNumbers.aSharp4, 70);
        expect(MidiNoteNumbers.bFlat4, 70);
        expect(MidiNoteNumbers.b4, 71);
        expect(MidiNoteNumbers.c5, 72);
      });

      test('toString (gg_midi_vars)', () {
        expect(MidiNoteNumbers.c4.toString(), '60');
      });
    });

    // .........................................................................
    group('scales', () {
      // Returns the scale with [steps] from the C of octave 0 to the C of
      // octave 9, shifted by [offset].
      List<int> scale(List<int> steps, {int offset = 0}) => [
        for (var octave = 0; octave < 9; octave++)
          for (final step in steps) 12 * (octave + 1) + step + offset,
        120 + offset,
      ];

      test('cMajor holds the white keys from C0 to C9', () {
        expect(MidiNoteNumbers.cMajor, equals(scale([0, 2, 4, 5, 7, 9, 11])));
      });

      test('gMinor holds the G minor keys from C0 to C9', () {
        expect(MidiNoteNumbers.gMinor, equals(scale([0, 2, 3, 5, 7, 9, 10])));
      });

      test('cSharpMajor is C major one semitone up', () {
        expect(
          MidiNoteNumbers.cSharpMajor,
          equals(scale([0, 2, 4, 5, 7, 9, 11], offset: 1)),
        );
      });

      test('cFlatMajor is C major one semitone down', () {
        expect(
          MidiNoteNumbers.cFlatMajor,
          equals(scale([0, 2, 4, 5, 7, 9, 11], offset: -1)),
        );
      });
    });

    // .........................................................................
    group('name(note, sharps)', () {
      test('names notes with C4 as 60', () {
        expect(
          [0, 12, 59, 60, 61, 69, 70, 127].map(MidiNoteNumbers.name).toList(),
          equals(['C-1', 'C0', 'B3', 'C4', 'C#4', 'A4', 'A#4', 'G9']),
        );
      });

      test('names black keys as flats when sharps is false', () {
        expect([
          for (final note in [1, 3, 6, 8, 10, 60])
            MidiNoteNumbers.name(note, sharps: false),
        ], equals(['Db-1', 'Eb-1', 'Gb-1', 'Ab-1', 'Bb-1', 'C4']));
      });

      test('names every natural constant after itself', () {
        for (final MapEntry(key: constant, value: note) in notes.entries) {
          if (constant.contains('Sharp') || constant.contains('Flat')) continue;
          if (note > MidiNoteNumbers.max) continue;
          final expected =
              constant[0].toUpperCase() +
              constant.substring(1).replaceFirst('M1', '-1');
          expect(MidiNoteNumbers.name(note), expected);
        }
      });

      for (final note in [-1, 128]) {
        test('throws for $note', () {
          expect(
            () => MidiNoteNumbers.name(note),
            throwsA(isA<RangeError>().having((e) => e.name, 'name', 'note')),
          );
        });
      }
    });

    // .........................................................................
    group('frequency(note, a4)', () {
      test('returns 440 Hz for A4 and doubles per octave', () {
        expect(
          [57, 69, 81].map(MidiNoteNumbers.frequency).toList(),
          equals([220.0, 440.0, 880.0]),
        );
      });

      test('returns middle C', () {
        expect(MidiNoteNumbers.frequency(60), closeTo(261.6256, 1e-4));
      });

      test('follows another tuning A', () {
        expect(MidiNoteNumbers.frequency(69, a4: 442), 442.0);
        expect(MidiNoteNumbers.frequency(81, a4: 415), 830.0);
      });

      test('accepts fractional note numbers', () {
        expect(MidiNoteNumbers.frequency(69.5), closeTo(452.8930, 1e-4));
      });
    });

    // .........................................................................
    group('midiNoteNumbersExample', () {
      test('returns an instance (gg_midi_vars)', () {
        final e = midiNoteNumbersExample;
        expect(e, isA<MidiNoteNumbers>());
      });
    });
  });
}
