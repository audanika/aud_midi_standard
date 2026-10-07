// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:aud_midi_standard/src/codec/midi_short_message.dart';
import 'package:test/test.dart';

void main() {
  group('MidiShortMessage', () {
    group('dataLength(status)', () {
      test('returns null for data bytes', () {
        final lengths = {
          for (var status = 0; status < 0x80; status++)
            MidiShortMessage.dataLength(status),
        };
        expect(lengths, equals({null}));
      });

      test('returns the lengths of the channel voice messages', () {
        final lengths = [
          for (var status = 0x80; status < 0xF0; status += 0x10)
            for (final channel in [0, 15])
              MidiShortMessage.dataLength(status | channel),
        ];
        expect(lengths, equals([2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 2, 2]));
      });

      test('returns the lengths of the system messages', () {
        final lengths = [
          for (var status = 0xF0; status <= 0xFF; status++)
            MidiShortMessage.dataLength(status),
        ];
        expect(
          lengths,
          equals([
            null, 1, 2, 1, null, null, 0, null, //
            0, null, 0, 0, 0, null, 0, 0,
          ]),
        );
      });
    });

    group('decode(status, data1, data2)', () {
      final cases = <(int, int, int, MidiMessage)>[
        (0x80, 0x3C, 0x40, const MidiNoteOff(channel: 0, note: 0x3C)),
        (
          0x9F,
          0x3C,
          0x00,
          const MidiNoteOn(channel: 15, note: 0x3C, velocity: 0),
        ),
        (
          0xA1,
          0x10,
          0x7F,
          const MidiPolyPressure(channel: 1, note: 0x10, pressure: 0x7F),
        ),
        (
          0xB2,
          0x07,
          0x64,
          const MidiControlChange(channel: 2, controller: 7, value: 0x64),
        ),
        (0xC3, 0x05, 0x00, const MidiProgramChange(channel: 3, program: 5)),
        (
          0xD4,
          0x33,
          0x00,
          const MidiChannelPressure(channel: 4, pressure: 0x33),
        ),
        (0xE5, 0x01, 0x40, const MidiPitchBend(channel: 5, value: 0x2001)),
        (
          0xF1,
          0x7A,
          0x00,
          const MidiTimeCodeQuarterFrame(piece: 7, value: 0xA),
        ),
        (0xF2, 0x7F, 0x01, const MidiSongPositionPointer(position: 0xFF)),
        (0xF3, 0x12, 0x00, const MidiSongSelect(song: 0x12)),
        (0xF6, 0x00, 0x00, const MidiTuneRequest()),
        (0xF8, 0x00, 0x00, const MidiTimingClock()),
        (0xFA, 0x00, 0x00, const MidiStart()),
        (0xFB, 0x00, 0x00, const MidiContinue()),
        (0xFC, 0x00, 0x00, const MidiStop()),
        (0xFE, 0x00, 0x00, const MidiActiveSensing()),
        (0xFF, 0x00, 0x00, const MidiSystemReset()),
      ];
      for (final (status, data1, data2, message) in cases) {
        test('returns $message for status 0x${status.toRadixString(16)}', () {
          expect(
            MidiShortMessage.decode(status, data1: data1, data2: data2),
            message,
          );
        });
      }

      test('defaults the data bytes to 0', () {
        expect(
          MidiShortMessage.decode(0xC0),
          const MidiProgramChange(channel: 0, program: 0),
        );
      });

      for (final status in [0x7F, 0xF0, 0xF4, 0xF5, 0xF7, 0xF9, 0xFD]) {
        test('throws for status 0x${status.toRadixString(16)}', () {
          expect(
            () => MidiShortMessage.decode(status),
            throwsA(
              isA<ArgumentError>()
                  .having((e) => e.name, 'name', 'status')
                  .having((e) => e.message, 'message', 'No short message'),
            ),
          );
        });
      }
    });
  });
}
