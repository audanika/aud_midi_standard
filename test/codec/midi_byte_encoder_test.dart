// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final encodable = <(MidiMessage, String)>[
    (const MidiNoteOff(channel: 0, note: 0x3C), '80 3c 40'),
    (const MidiNoteOff(channel: 15, note: 0x7F, velocity: 0), '8f 7f 00'),
    (const MidiNoteOn(channel: 1, note: 0x3C, velocity: 0x64), '91 3c 64'),
    (const MidiNoteOn(channel: 2, note: 0, velocity: 0), '92 00 00'),
    (
      const MidiPolyPressure(channel: 3, note: 0x40, pressure: 0x7F),
      'a3 40 7f',
    ),
    (
      const MidiControlChange(channel: 4, controller: 0x07, value: 0x64),
      'b4 07 64',
    ),
    (
      const MidiControlChange(channel: 5, controller: 0x7B, value: 0),
      'b5 7b 00',
    ),
    (const MidiProgramChange(channel: 6, program: 0x7F), 'c6 7f'),
    (const MidiChannelPressure(channel: 7, pressure: 0x20), 'd7 20'),
    (const MidiPitchBend(channel: 8, value: MidiPitchBend.center), 'e8 00 40'),
    (const MidiPitchBend(channel: 9, value: 0x3FFF), 'e9 7f 7f'),
    (const MidiPitchBend(channel: 10, value: 0x0081), 'ea 01 01'),
    (const MidiTimeCodeQuarterFrame(piece: 3, value: 0xC), 'f1 3c'),
    (const MidiTimeCodeQuarterFrame(piece: 7, value: 0x1), 'f1 71'),
    (const MidiSongPositionPointer(position: 0x3FFF), 'f2 7f 7f'),
    (const MidiSongPositionPointer(position: 0x0102), 'f2 02 02'),
    (const MidiSongSelect(song: 0x55), 'f3 55'),
    (const MidiTuneRequest(), 'f6'),
    (const MidiTimingClock(), 'f8'),
    (const MidiStart(), 'fa'),
    (const MidiContinue(), 'fb'),
    (const MidiStop(), 'fc'),
    (const MidiActiveSensing(), 'fe'),
    (const MidiSystemReset(), 'ff'),
    (MidiSysEx(const [0x7E, 0x7F, 0x06, 0x01]), 'f0 7e 7f 06 01 f7'),
    (MidiSysEx(const []), 'f0 f7'),
  ];

  final notEncodable = <MidiMessage>[
    const MidiNoteOn2(channel: 0, note: 60, velocity: 0x8000),
    const MidiProgramChange2(channel: 0, program: 1),
    const MidiNoop(),
    const MidiJrTimestamp(time: 1),
    MidiSysEx8(streamId: 0, data: const [1, 2]),
    MidiMixedDataSet(
      mdsId: 0,
      manufacturerId: 0x43,
      deviceId: 0,
      subId1: 0,
      subId2: 0,
      data: const [1],
    ),
    const MidiSetTempo(tenNanosecondsPerQuarterNote: 50000000),
    const MidiFlexText(statusBank: 1, status: 1, text: 'Song'),
    const MidiEndpointDiscovery(),
    const MidiStartOfClip(),
    MidiUnknownMessage([Ump.fromHex('10f40000')]),
  ];

  group('MidiByteEncoder', () {
    group('encode(message)', () {
      for (final (message, hex) in encodable) {
        test('encodes $message as $hex', () {
          expect(MidiByteEncoder.encode(message), MidiBytes.fromHex(hex));
        });
      }

      for (final message in notEncodable) {
        test('returns null for ${message.runtimeType}', () {
          expect(MidiByteEncoder.encode(message), isNull);
        });
      }
    });

    group('encodeAll(messages)', () {
      test('concatenates the messages without running status', () {
        expect(
          MidiByteEncoder.encodeAll([
            const MidiNoteOn(channel: 0, note: 60, velocity: 100),
            const MidiNoteOn(channel: 0, note: 64, velocity: 100),
            const MidiTimingClock(),
            MidiSysEx(const [0x43, 0x10]),
          ]),
          MidiBytes.fromHex('90 3c 64 90 40 64 f8 f0 43 10 f7'),
        );
      });

      test('skips messages without a byte form', () {
        expect(
          MidiByteEncoder.encodeAll([
            const MidiNoop(),
            const MidiStart(),
            const MidiNoteOn2(channel: 0, note: 60, velocity: 1),
            const MidiStop(),
          ]),
          MidiBytes.fromHex('fa fc'),
        );
      });

      test('returns an empty chunk for no messages', () {
        expect(MidiByteEncoder.encodeAll(const []), MidiBytes.empty);
      });
    });
  });
}
