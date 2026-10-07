// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiPerNoteControllers', () {
    // Every constant with its name.
    final controllers = <String, int>{
      'modulation': MidiPerNoteControllers.modulation,
      'breath': MidiPerNoteControllers.breath,
      'pitch': MidiPerNoteControllers.pitch,
      'volume': MidiPerNoteControllers.volume,
      'balance': MidiPerNoteControllers.balance,
      'pan': MidiPerNoteControllers.pan,
      'expression': MidiPerNoteControllers.expression,
      'soundController1': MidiPerNoteControllers.soundController1,
      'soundController2': MidiPerNoteControllers.soundController2,
      'soundController3': MidiPerNoteControllers.soundController3,
      'soundController4': MidiPerNoteControllers.soundController4,
      'soundController5': MidiPerNoteControllers.soundController5,
      'soundController6': MidiPerNoteControllers.soundController6,
      'soundController7': MidiPerNoteControllers.soundController7,
      'soundController8': MidiPerNoteControllers.soundController8,
      'soundController9': MidiPerNoteControllers.soundController9,
      'soundController10': MidiPerNoteControllers.soundController10,
      'effects1Depth': MidiPerNoteControllers.effects1Depth,
      'effects2Depth': MidiPerNoteControllers.effects2Depth,
      'effects3Depth': MidiPerNoteControllers.effects3Depth,
      'effects4Depth': MidiPerNoteControllers.effects4Depth,
      'effects5Depth': MidiPerNoteControllers.effects5Depth,
    };

    // .........................................................................
    group('constants', () {
      test('number the controllers of M2-104-UM Table 22', () {
        expect(
          controllers.values,
          equals([
            1,
            2,
            3,
            7,
            8,
            10,
            11,
            for (var n = 70; n <= 79; n++) n,
            for (var n = 91; n <= 95; n++) n,
          ]),
        );
      });

      test('match the MIDI 1.0 controllers of the same function', () {
        expect(
          [
            MidiPerNoteControllers.modulation,
            MidiPerNoteControllers.breath,
            MidiPerNoteControllers.volume,
            MidiPerNoteControllers.balance,
            MidiPerNoteControllers.pan,
            MidiPerNoteControllers.expression,
            MidiPerNoteControllers.soundController1,
            MidiPerNoteControllers.soundController10,
            MidiPerNoteControllers.effects1Depth,
            MidiPerNoteControllers.effects5Depth,
          ],
          equals([
            MidiControllers.modulationWheel,
            MidiControllers.breathController,
            MidiControllers.channelVolume,
            MidiControllers.balance,
            MidiControllers.pan,
            MidiControllers.expression,
            MidiControllers.soundController1,
            MidiControllers.soundController10,
            MidiControllers.effects1Depth,
            MidiControllers.effects5Depth,
          ]),
        );
      });
    });

    // .........................................................................
    group('pitchToNote(value)', () {
      test('reads seven bits of note and 25 bits of fraction', () {
        expect(
          [
            0,
            60 << 25,
            (60 << 25) | (1 << 24),
            0xFFFFFFFF,
          ].map(MidiPerNoteControllers.pitchToNote),
          equals([0.0, 60.0, 60.5, 128 - 1 / (1 << 25)]),
        );
      });

      for (final value in [-1, 0x100000000]) {
        test('throws for $value', () {
          expect(
            () => MidiPerNoteControllers.pitchToNote(value),
            throwsA(isA<RangeError>().having((e) => e.name, 'name', 'value')),
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
            69,
            60.5,
            128 - 1 / (1 << 25),
          ].map(MidiPerNoteControllers.noteToPitch),
          equals([0, 69 << 25, (60 << 25) | (1 << 24), 0xFFFFFFFF]),
        );
      });

      test('reverses pitchToNote', () {
        for (final value in [1, 0x12345678, 0x7FFFFFFF, 0xFFFFFFFE]) {
          final note = MidiPerNoteControllers.pitchToNote(value);
          expect(MidiPerNoteControllers.noteToPitch(note), value);
        }
      });

      for (final note in [-0.001, 128, double.negativeInfinity]) {
        test('throws for $note', () {
          expect(
            () => MidiPerNoteControllers.noteToPitch(note),
            throwsA(
              isA<RangeError>()
                  .having((e) => e.name, 'name', 'note')
                  .having(
                    (e) => e.message,
                    'message',
                    'Not a Pitch 7.25 note number',
                  ),
            ),
          );
        });
      }
    });

    // .........................................................................
    group('name(controller)', () {
      test('names every controller', () {
        for (final MapEntry(key: name, value: controller)
            in controllers.entries) {
          expect(MidiPerNoteControllers.name(controller), name);
        }
      });

      test('returns null for reserved numbers', () {
        expect(
          [0, 4, 9, 12, 69, 80, 90, 96, 255].map(MidiPerNoteControllers.name),
          everyElement(isNull),
        );
      });
    });
  });
}
