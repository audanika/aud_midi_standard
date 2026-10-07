// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiStatus', () {
    // .........................................................................
    group('constants', () {
      test('hold the channel statuses of channel 0', () {
        expect([
          MidiStatus.noteOff,
          MidiStatus.noteOn,
          MidiStatus.polyPressure,
          MidiStatus.controlChange,
          MidiStatus.programChange,
          MidiStatus.channelPressure,
          MidiStatus.pitchBend,
        ], equals([0x80, 0x90, 0xA0, 0xB0, 0xC0, 0xD0, 0xE0]));
      });

      test('hold the system statuses 0xF0 to 0xFF in order', () {
        expect([
          MidiStatus.sysEx,
          MidiStatus.timeCode,
          MidiStatus.songPosition,
          MidiStatus.songSelect,
          MidiStatus.undefinedF4,
          MidiStatus.undefinedF5,
          MidiStatus.tuneRequest,
          MidiStatus.endOfSysEx,
          MidiStatus.timingClock,
          MidiStatus.undefinedF9,
          MidiStatus.start,
          MidiStatus.continueSequence,
          MidiStatus.stop,
          MidiStatus.undefinedFD,
          MidiStatus.activeSensing,
          MidiStatus.systemReset,
        ], equals([for (var s = 0xF0; s <= 0xFF; s++) s]));
      });

      test('match the statuses of the system message classes', () {
        expect(
          [
            const MidiTimeCodeQuarterFrame(piece: 0, value: 0).status,
            const MidiSongPositionPointer(position: 0).status,
            const MidiSongSelect(song: 0).status,
            const MidiTuneRequest().status,
            const MidiTimingClock().status,
            const MidiStart().status,
            const MidiContinue().status,
            const MidiStop().status,
            const MidiActiveSensing().status,
            const MidiSystemReset().status,
          ],
          equals([
            MidiStatus.timeCode,
            MidiStatus.songPosition,
            MidiStatus.songSelect,
            MidiStatus.tuneRequest,
            MidiStatus.timingClock,
            MidiStatus.start,
            MidiStatus.continueSequence,
            MidiStatus.stop,
            MidiStatus.activeSensing,
            MidiStatus.systemReset,
          ]),
        );
      });

      test('mark System Exclusive as variable length', () {
        expect(MidiStatus.variableLength, -1);
      });
    });

    // .........................................................................
    // The boundary bytes of all ranges; each predicate must accept exactly
    // the bytes of its range.
    const bytes = [-1, 0x00, 0x7F, 0x80, 0xEF, 0xF0, 0xF1, 0xF7, 0xF8, 0xFF];
    const outside = 0x100;

    group('isStatus(byte)', () {
      test('accepts 0x80 to 0xFF', () {
        expect(
          [...bytes, outside].where(MidiStatus.isStatus).toList(),
          equals([0x80, 0xEF, 0xF0, 0xF1, 0xF7, 0xF8, 0xFF]),
        );
      });
    });

    group('isData(byte)', () {
      test('accepts 0x00 to 0x7F', () {
        expect(
          [...bytes, outside].where(MidiStatus.isData).toList(),
          equals([0x00, 0x7F]),
        );
      });
    });

    group('isChannelVoice(byte)', () {
      test('accepts 0x80 to 0xEF', () {
        expect(
          [...bytes, outside].where(MidiStatus.isChannelVoice).toList(),
          equals([0x80, 0xEF]),
        );
      });
    });

    group('isSystem(byte)', () {
      test('accepts 0xF0 to 0xFF', () {
        expect(
          [...bytes, outside].where(MidiStatus.isSystem).toList(),
          equals([0xF0, 0xF1, 0xF7, 0xF8, 0xFF]),
        );
      });
    });

    group('isSystemCommon(byte)', () {
      test('accepts 0xF1 to 0xF7', () {
        expect(
          [...bytes, outside].where(MidiStatus.isSystemCommon).toList(),
          equals([0xF1, 0xF7]),
        );
      });
    });

    group('isRealTime(byte)', () {
      test('accepts 0xF8 to 0xFF', () {
        expect(
          [...bytes, outside].where(MidiStatus.isRealTime).toList(),
          equals([0xF8, 0xFF]),
        );
      });
    });

    // .........................................................................
    group('channelOf(status)', () {
      test('returns the low nibble of channel statuses', () {
        expect(
          [0x80, 0x93, 0xBF, 0xEA].map(MidiStatus.channelOf).toList(),
          equals([0, 3, 15, 10]),
        );
      });

      test('returns null for system statuses and data bytes', () {
        expect(
          [0xF0, 0xF8, 0xFF, 0x00, 0x7F].map(MidiStatus.channelOf).toList(),
          equals([null, null, null, null, null]),
        );
      });
    });

    // .........................................................................
    group('typeOf(status)', () {
      test('strips the channel of channel statuses', () {
        expect(
          [
            0x8F,
            0x93,
            0xA1,
            0xB2,
            0xC3,
            0xD4,
            0xE5,
          ].map(MidiStatus.typeOf).toList(),
          equals([0x80, 0x90, 0xA0, 0xB0, 0xC0, 0xD0, 0xE0]),
        );
      });

      test('returns system statuses unchanged', () {
        for (var status = 0xF0; status <= 0xFF; status++) {
          expect(MidiStatus.typeOf(status), status);
        }
      });

      for (final byte in [-1, 0x00, 0x7F, 0x100]) {
        test('throws for the non-status byte $byte', () {
          expect(
            () => MidiStatus.typeOf(byte),
            throwsA(
              isA<ArgumentError>()
                  .having((e) => e.name, 'name', 'status')
                  .having((e) => e.message, 'message', 'Not a status byte'),
            ),
          );
        });
      }
    });

    // .........................................................................
    group('withChannel(type, channel)', () {
      test('combines a type and a channel', () {
        expect([
          MidiStatus.withChannel(MidiStatus.noteOn, channel: 0),
          MidiStatus.withChannel(MidiStatus.noteOn, channel: 9),
          MidiStatus.withChannel(MidiStatus.controlChange, channel: 15),
          MidiStatus.withChannel(MidiStatus.pitchBend, channel: 1),
        ], equals([0x90, 0x99, 0xBF, 0xE1]));
      });

      for (final type in [0x91, 0xF0, 0x7F]) {
        test('throws for the type $type', () {
          expect(
            () => MidiStatus.withChannel(type, channel: 0),
            throwsA(
              isA<ArgumentError>()
                  .having((e) => e.name, 'name', 'type')
                  .having(
                    (e) => e.message,
                    'message',
                    'Not a channel message type',
                  ),
            ),
          );
        });
      }

      for (final channel in [-1, 16]) {
        test('throws for the channel $channel', () {
          expect(
            () => MidiStatus.withChannel(MidiStatus.noteOn, channel: channel),
            throwsA(isA<RangeError>().having((e) => e.name, 'name', 'channel')),
          );
        });
      }
    });

    // .........................................................................
    group('dataLength(status)', () {
      test('returns the data bytes of channel messages', () {
        expect(
          [
            0x80,
            0x91,
            0xA2,
            0xB3,
            0xC4,
            0xD5,
            0xE6,
          ].map(MidiStatus.dataLength).toList(),
          equals([2, 2, 2, 2, 1, 1, 2]),
        );
      });

      test('returns the data bytes of system messages', () {
        expect([
          for (var s = 0xF0; s <= 0xFF; s++) MidiStatus.dataLength(s),
        ], equals([-1, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]));
      });

      test('throws for data bytes', () {
        expect(
          () => MidiStatus.dataLength(0x40),
          throwsA(isA<ArgumentError>().having((e) => e.name, 'name', 'status')),
        );
      });
    });

    // .........................................................................
    group('name(status)', () {
      test('returns the constant names of the channel statuses', () {
        expect(
          [
            0x80,
            0x93,
            0xA0,
            0xB0,
            0xCF,
            0xD0,
            0xE0,
          ].map(MidiStatus.name).toList(),
          equals([
            'noteOff',
            'noteOn',
            'polyPressure',
            'controlChange',
            'programChange',
            'channelPressure',
            'pitchBend',
          ]),
        );
      });

      test('returns the constant names of the system statuses', () {
        expect(
          [for (var s = 0xF0; s <= 0xFF; s++) MidiStatus.name(s)],
          equals([
            'sysEx',
            'timeCode',
            'songPosition',
            'songSelect',
            'undefinedF4',
            'undefinedF5',
            'tuneRequest',
            'endOfSysEx',
            'timingClock',
            'undefinedF9',
            'start',
            'continueSequence',
            'stop',
            'undefinedFD',
            'activeSensing',
            'systemReset',
          ]),
        );
      });

      test('returns null for data bytes', () {
        expect(
          [0x00, 0x7F, -1, 0x100].map(MidiStatus.name).toList(),
          equals([null, null, null, null]),
        );
      });
    });
  });
}
