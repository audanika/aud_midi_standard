// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiGeneralMidi', () {
    // .........................................................................
    group('constants', () {
      test('put the drums on MIDI channel 10', () {
        expect(MidiGeneralMidi.percussionChannel, 9);
      });

      test('hold the GM2 bank MSBs', () {
        expect(MidiGeneralMidi.rhythmBankMsb, 0x78);
        expect(MidiGeneralMidi.melodyBankMsb, 0x79);
      });

      test('hold the GM system messages without F0 and F7', () {
        expect(
          [
            MidiGeneralMidi.gm1SystemOn,
            MidiGeneralMidi.gmSystemOff,
            MidiGeneralMidi.gm2SystemOn,
          ],
          equals([
            [0x7E, 0x7F, 0x09, 0x01],
            [0x7E, 0x7F, 0x09, 0x02],
            [0x7E, 0x7F, 0x09, 0x03],
          ]),
        );
      });

      test('make valid SysEx messages', () {
        expect(
          MidiSysEx(MidiGeneralMidi.gm2SystemOn).data,
          equals([0x7E, 0x7F, 0x09, 0x03]),
        );
      });
    });

    // .........................................................................
    group('programNames', () {
      test('name 128 distinct programs', () {
        expect(MidiGeneralMidi.programNames, hasLength(128));
        expect(MidiGeneralMidi.programNames.toSet(), hasLength(128));
      });

      test('start each family of eight at its GM1 program', () {
        expect(
          [
            for (var program = 0; program < 128; program += 8)
              MidiGeneralMidi.programNames[program],
          ],
          equals([
            'Acoustic Grand Piano',
            'Celesta',
            'Drawbar Organ',
            'Acoustic Guitar (nylon)',
            'Acoustic Bass',
            'Violin',
            'String Ensemble 1',
            'Trumpet',
            'Soprano Sax',
            'Piccolo',
            'Lead 1 (square)',
            'Pad 1 (new age)',
            'FX 1 (rain)',
            'Sitar',
            'Tinkle Bell',
            'Guitar Fret Noise',
          ]),
        );
      });

      test('end each family of eight at its GM1 program', () {
        expect(
          [
            for (var program = 7; program < 128; program += 8)
              MidiGeneralMidi.programNames[program],
          ],
          equals([
            'Clavi',
            'Dulcimer',
            'Tango Accordion',
            'Guitar harmonics',
            'Synth Bass 2',
            'Timpani',
            'Orchestra Hit',
            'SynthBrass 2',
            'Clarinet',
            'Ocarina',
            'Lead 8 (bass + lead)',
            'Pad 8 (sweep)',
            'FX 8 (sci-fi)',
            'Shanai',
            'Reverse Cymbal',
            'Gunshot',
          ]),
        );
      });
    });

    // .........................................................................
    group('gm1DrumNames', () {
      test('name the keys 35 to 81', () {
        expect(
          MidiGeneralMidi.gm1DrumNames.keys,
          equals([for (var key = 35; key <= 81; key++) key]),
        );
        expect(MidiGeneralMidi.gm1DrumNames.values.toSet(), hasLength(47));
      });

      test('name the common drums', () {
        expect(
          [
            35,
            36,
            38,
            42,
            46,
            49,
            51,
            81,
          ].map((key) => MidiGeneralMidi.gm1DrumNames[key]),
          equals([
            'Acoustic Bass Drum',
            'Bass Drum 1',
            'Acoustic Snare',
            'Closed Hi Hat',
            'Open Hi-Hat',
            'Crash Cymbal 1',
            'Ride Cymbal 1',
            'Open Triangle',
          ]),
        );
      });
    });

    // .........................................................................
    group('gm2DrumAdditions', () {
      test('name the keys 27 to 34 and 82 to 87', () {
        expect(
          MidiGeneralMidi.gm2DrumAdditions.keys,
          equals([
            for (var key = 27; key <= 34; key++) key,
            for (var key = 82; key <= 87; key++) key,
          ]),
        );
      });

      test('add no key of GM1', () {
        expect(
          MidiGeneralMidi.gm2DrumAdditions.keys.where(
            MidiGeneralMidi.gm1DrumNames.containsKey,
          ),
          isEmpty,
        );
      });
    });

    // .........................................................................
    group('programName(program)', () {
      test('returns the GM1 names of 0-based programs', () {
        expect(
          [0, 40, 56, 73, 127].map(MidiGeneralMidi.programName),
          equals([
            'Acoustic Grand Piano',
            'Violin',
            'Trumpet',
            'Flute',
            'Gunshot',
          ]),
        );
      });

      for (final program in [-1, 128]) {
        test('throws for $program', () {
          expect(
            () => MidiGeneralMidi.programName(program),
            throwsA(isA<RangeError>().having((e) => e.name, 'name', 'program')),
          );
        });
      }
    });

    // .........................................................................
    group('drumName(key, gm2)', () {
      test('returns GM1 and GM2 names by default', () {
        expect(
          [26, 27, 34, 35, 81, 82, 87, 88].map(MidiGeneralMidi.drumName),
          equals([
            null,
            'High Q',
            'Metronome Bell',
            'Acoustic Bass Drum',
            'Open Triangle',
            'Shaker',
            'Open Surdo',
            null,
          ]),
        );
      });

      test('returns only GM1 names when gm2 is false', () {
        expect(
          [
            27,
            35,
            81,
            82,
          ].map((key) => MidiGeneralMidi.drumName(key, gm2: false)),
          equals([null, 'Acoustic Bass Drum', 'Open Triangle', null]),
        );
      });
    });
  });
}
