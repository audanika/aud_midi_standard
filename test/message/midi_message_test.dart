// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const noteOn = MidiNoteOn(channel: 0, note: 0x3C, velocity: 0x64);
  const noteOn2 = MidiNoteOn2(channel: 0, note: 0x3C, velocity: 0xC924);

  group('MidiMessage', () {
    group('toUmp(group)', () {
      test('encodes for group 0 by default', () {
        expect(noteOn.toUmp(), equals([Ump.fromHex('20903c64')]));
      });

      test('encodes for the given group', () {
        expect(noteOn.toUmp(group: 3), equals([Ump.fromHex('23903c64')]));
      });

      test('spans several packets for long messages', () {
        expect(
          MidiSysEx(const [1, 2, 3, 4, 5, 6, 7]).toUmp(),
          equals([
            Ump.fromHex('30160102 03040506'),
            Ump.fromHex('30310700 00000000'),
          ]),
        );
      });
    });

    group('toBytes()', () {
      test('encodes MIDI 1.0 messages', () {
        expect(noteOn.toBytes(), MidiBytes.fromHex('90 3c 64'));
      });

      test('returns null for messages without byte form', () {
        expect(noteOn2.toBytes(), isNull);
      });
    });

    group('toMidi1()', () {
      test('translates MIDI 2.0 channel voice messages', () {
        expect(noteOn2.toMidi1(), equals([noteOn]));
      });

      test('returns MIDI 1.0 messages unchanged', () {
        expect(noteOn.toMidi1(), equals([noteOn]));
      });

      test('returns nothing for messages without MIDI 1.0 equivalent', () {
        expect(
          const MidiPerNotePitchBend(channel: 0, note: 1, value: 2).toMidi1(),
          isEmpty,
        );
      });
    });

    group('toMidi2()', () {
      test('translates MIDI 1.0 channel voice messages', () {
        expect(
          const MidiNoteOn(channel: 0, note: 0x3C, velocity: 0x40).toMidi2(),
          equals([const MidiNoteOn2(channel: 0, note: 0x3C, velocity: 0x8000)]),
        );
      });

      test('returns nothing for controllers that need context', () {
        expect(
          const MidiControlChange(
            channel: 0,
            controller: 0,
            value: 1,
          ).toMidi2(),
          isEmpty,
        );
      });

      test('returns messages of both protocols unchanged', () {
        expect(const MidiStart().toMidi2(), equals([const MidiStart()]));
      });
    });

    group('==', () {
      test('is true for the identical message', () {
        final message = MidiSysEx(const [1]);
        expect(message == message, isTrue);
      });

      test('is true for equal fields', () {
        expect(MidiSysEx(const [1, 2]), MidiSysEx([1, 2]));
        expect(
          noteOn,
          MidiNoteOn(channel: noteOn.channel, note: 0x3C, velocity: 0x64),
        );
      });

      test('is false for different fields', () {
        expect(
          noteOn,
          isNot(const MidiNoteOn(channel: 1, note: 0x3C, velocity: 0x64)),
        );
      });

      test('is false for lists of different length', () {
        expect(MidiSysEx(const [1, 2]), isNot(MidiSysEx(const [1])));
      });

      test('is false for lists with different elements', () {
        expect(MidiSysEx(const [1, 2]), isNot(MidiSysEx(const [1, 3])));
      });

      test('is false for different types with equal fields', () {
        expect(const MidiStart(), isNot(const MidiStop()));
      });

      test('is false for other objects', () {
        expect(noteOn == Object(), isFalse);
      });
    });

    group('hashCode', () {
      test('is equal for equal messages', () {
        expect(MidiSysEx(const [1, 2]).hashCode, MidiSysEx([1, 2]).hashCode);
        expect(
          noteOn.hashCode,
          MidiNoteOn(
            channel: noteOn.channel,
            note: 0x3C,
            velocity: 0x64,
          ).hashCode,
        );
      });

      test('differs for different list contents', () {
        expect(
          MidiSysEx(const [1, 2]).hashCode,
          isNot(MidiSysEx(const [2, 1]).hashCode),
        );
      });
    });

    group('toString()', () {
      test('lists the fields', () {
        expect('$noteOn', 'MidiNoteOn(channel: 0, note: 60, velocity: 100)');
      });

      test('prints bytes as hex', () {
        expect(
          '${MidiSysEx(const [0x7E, 0x0A, 0x7F])}',
          'MidiSysEx(data: [7e 0a 7f])',
        );
      });

      test('quotes texts', () {
        expect(
          '${const MidiEndpointNameNotification(name: 'Synth')}',
          "MidiEndpointNameNotification(name: 'Synth')",
        );
      });

      test('prints other values as they print themselves', () {
        expect(
          '${const MidiProgramChange2(channel: 1, program: 2)}',
          'MidiProgramChange2(channel: 1, program: 2, bank: null)',
        );
      });

      test('prints messages without fields with empty parentheses', () {
        expect('${const MidiStart()}', 'MidiStart()');
      });
    });
  });
}
