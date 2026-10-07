// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  List<Ump> umps(List<String> hex) => [for (final h in hex) Ump.fromHex(h)];
  List<int> count(int n) => [for (var i = 1; i <= n; i++) i];

  void expectEncoded(List<(MidiMessage, List<String>)> cases, {int group = 5}) {
    for (final (message, hex) in cases) {
      test('encodes $message', () {
        expect(UmpEncoder.encode(message, group: group), equals(umps(hex)));
      });
    }
  }

  group('UmpEncoder', () {
    group('encode(message, group)', () {
      group('utility messages without group', () {
        expectEncoded([
          (const MidiNoop(), ['00000000']),
          (const MidiJrClock(time: 0x1234), ['00101234']),
          (const MidiJrTimestamp(time: 0xFFFF), ['0020ffff']),
          (
            const MidiDeltaClockstampTicksPerQuarterNote(
              ticksPerQuarterNote: 480,
            ),
            ['003001e0'],
          ),
          (const MidiDeltaClockstamp(ticks: 0xFFFFF), ['004fffff']),
        ]);
      });

      group('system messages', () {
        expectEncoded([
          (const MidiTimeCodeQuarterFrame(piece: 3, value: 0xC), ['15f13c00']),
          (const MidiSongPositionPointer(position: 0x1234), ['15f23424']),
          (const MidiSongPositionPointer(position: 0x3FFF), ['15f27f7f']),
          (const MidiSongSelect(song: 0x55), ['15f35500']),
          (const MidiTuneRequest(), ['15f60000']),
          (const MidiTimingClock(), ['15f80000']),
          (const MidiStart(), ['15fa0000']),
          (const MidiContinue(), ['15fb0000']),
          (const MidiStop(), ['15fc0000']),
          (const MidiActiveSensing(), ['15fe0000']),
          (const MidiSystemReset(), ['15ff0000']),
        ]);
      });

      group('MIDI 1.0 channel voice messages', () {
        expectEncoded([
          (const MidiNoteOff(channel: 2, note: 0x3C), ['25823c40']),
          (
            const MidiNoteOn(channel: 15, note: 0x7F, velocity: 0x7F),
            ['259f7f7f'],
          ),
          (
            const MidiPolyPressure(channel: 0, note: 0x40, pressure: 0x10),
            ['25a04010'],
          ),
          (
            const MidiControlChange(channel: 1, controller: 7, value: 0x64),
            ['25b10764'],
          ),
          (const MidiProgramChange(channel: 3, program: 0x7F), ['25c37f00']),
          (const MidiChannelPressure(channel: 4, pressure: 0x20), ['25d42000']),
          (const MidiPitchBend(channel: 9, value: 0x2000), ['25e90040']),
          (const MidiPitchBend(channel: 9, value: 0x3FFF), ['25e97f7f']),
        ]);
      });

      group('System Exclusive in 6-byte packets', () {
        expectEncoded([
          (MidiSysEx(const []), ['35000000 00000000']),
          (MidiSysEx(count(3)), ['35030102 03000000']),
          (MidiSysEx(count(6)), ['35060102 03040506']),
          (MidiSysEx(count(7)), ['35160102 03040506', '35310700 00000000']),
          (MidiSysEx(count(12)), ['35160102 03040506', '35360708 090a0b0c']),
          (
            MidiSysEx(count(13)),
            ['35160102 03040506', '35260708 090a0b0c', '35310d00 00000000'],
          ),
        ]);
      });

      group('MIDI 2.0 channel voice messages', () {
        expectEncoded([
          (const MidiNoteOff2(channel: 2, note: 0x3C), ['45823c00 80000000']),
          (
            const MidiNoteOn2(
              channel: 15,
              note: 0x7F,
              velocity: 0xFFFF,
              attributeType: 3,
              attribute: 0x1234,
            ),
            ['459f7f03 ffff1234'],
          ),
          (
            const MidiPolyPressure2(
              channel: 0,
              note: 0x40,
              pressure: 0x12345678,
            ),
            ['45a04000 12345678'],
          ),
          (
            const MidiRegisteredPerNoteController(
              channel: 1,
              note: 0x10,
              index: 3,
              value: 0x80000000,
            ),
            ['45011003 80000000'],
          ),
          (
            const MidiAssignablePerNoteController(
              channel: 1,
              note: 0x10,
              index: 0xFF,
              value: 1,
            ),
            ['451110ff 00000001'],
          ),
          for (final (detach, reset, flags) in [
            (false, false, 0),
            (false, true, 1),
            (true, false, 2),
            (true, true, 3),
          ])
            (
              MidiPerNoteManagement(
                channel: 2,
                note: 0x3C,
                detach: detach,
                reset: reset,
              ),
              ['45f23c0$flags 00000000'],
            ),
          (
            const MidiControlChange2(
              channel: 3,
              controller: 7,
              value: 0xFFFFFFFF,
            ),
            ['45b30700 ffffffff'],
          ),
          (
            const MidiRegisteredController(
              channel: 4,
              bank: 0x7F,
              index: 0x7F,
              value: 0x10000000,
            ),
            ['45247f7f 10000000'],
          ),
          (
            const MidiAssignableController(
              channel: 5,
              bank: 0x12,
              index: 0x34,
              value: 0xDEADBEEF,
            ),
            ['45351234 deadbeef'],
          ),
          (
            const MidiRelativeRegisteredController(
              channel: 6,
              bank: 1,
              index: 2,
              value: -1,
            ),
            ['45460102 ffffffff'],
          ),
          (
            const MidiRelativeAssignableController(
              channel: 7,
              bank: 3,
              index: 4,
              value: -0x80000000,
            ),
            ['45570304 80000000'],
          ),
          (
            const MidiRelativeAssignableController(
              channel: 7,
              bank: 3,
              index: 4,
              value: 0x7FFFFFFF,
            ),
            ['45570304 7fffffff'],
          ),
          (
            const MidiProgramChange2(channel: 8, program: 0x10),
            ['45c80000 10000000'],
          ),
          (
            const MidiProgramChange2(
              channel: 8,
              program: 0x7F,
              bank: (msb: 0x12, lsb: 0x34),
            ),
            ['45c80001 7f001234'],
          ),
          (
            const MidiChannelPressure2(channel: 9, pressure: 0xABCDEF01),
            ['45d90000 abcdef01'],
          ),
          (
            const MidiPitchBend2(channel: 10, value: 0x80000000),
            ['45ea0000 80000000'],
          ),
          (
            const MidiPerNotePitchBend(
              channel: 11,
              note: 0x3C,
              value: 0x7FFFFFFF,
            ),
            ['456b3c00 7fffffff'],
          ),
        ]);
      });

      group('System Exclusive 8 in 13-byte packets', () {
        expectEncoded([
          (
            MidiSysEx8(streamId: 0, data: const []),
            ['55010000 00000000 00000000 00000000'],
          ),
          (
            MidiSysEx8(streamId: 7, data: const [0xAA, 0xBB, 0xCC]),
            ['550407aa bbcc0000 00000000 00000000'],
          ),
          (
            MidiSysEx8(streamId: 7, data: count(13)),
            ['550e0701 02030405 06070809 0a0b0c0d'],
          ),
          (
            MidiSysEx8(streamId: 0xFF, data: count(27)),
            [
              '551eff01 02030405 06070809 0a0b0c0d',
              '552eff0e 0f101112 13141516 1718191a',
              '5532ff1b 00000000 00000000 00000000',
            ],
          ),
        ]);
      });

      group('Mixed Data Sets in chunks', () {
        MidiMixedDataSet set(List<int> data) => MidiMixedDataSet(
          mdsId: 3,
          manufacturerId: 0x0043,
          deviceId: 0x7F7F,
          subId1: 0x0102,
          subId2: 0x0304,
          data: data,
        );

        expectEncoded([
          (set(const []), ['55830010 00010001 00437f7f 01020304']),
          (
            set(count(14)),
            [
              '55830020 00010001 00437f7f 01020304',
              '55930102 03040506 0708090a 0b0c0d0e',
            ],
          ),
          (
            set(count(15)),
            [
              '55830023 00010001 00437f7f 01020304',
              '55930102 03040506 0708090a 0b0c0d0e',
              '55930f00 00000000 00000000 00000000',
            ],
          ),
        ]);

        test('splits large sets into chunks of 4094 packets', () {
          final data = [for (var i = 0; i < 4094 * 14 + 1; i++) i & 0xFF];
          final packets = UmpEncoder.encode(set(data), group: 5);
          expect(packets, hasLength(1 + 4094 + 1 + 1));
          expect(
            packets[0],
            Ump.fromHex('5583fff0 00020001 00437f7f 01020304'),
          );
          expect(
            packets[4095],
            Ump.fromHex('55830013 00020002 00437f7f 01020304'),
          );
          expect(
            packets[4096],
            Ump.fromHex('5593e400 00000000 00000000 00000000'),
          );
        });
      });

      group('flex data messages', () {
        expectEncoded([
          (
            const MidiSetTempo(tenNanosecondsPerQuarterNote: 50000000),
            ['d5100000 02faf080 00000000 00000000'],
          ),
          (
            const MidiSetTimeSignature(numerator: 6, denominator: 3),
            ['d5100001 06030800 00000000 00000000'],
          ),
          (
            const MidiSetMetronome(
              clocksPerPrimaryClick: 24,
              barAccent1: 3,
              barAccent2: 2,
              barAccent3: 1,
              subdivisionClicks1: 2,
              subdivisionClicks2: 4,
            ),
            ['d5100002 18030201 02040000 00000000'],
          ),
          (
            const MidiSetKeySignature(sharpsFlats: -4, tonicNote: 4),
            ['d5100005 c4000000 00000000 00000000'],
          ),
          (
            const MidiSetKeySignature(channel: 9, sharpsFlats: 7, tonicNote: 3),
            ['d5090005 73000000 00000000 00000000'],
          ),
          (
            MidiSetChordName(
              channel: 3,
              tonicSharpsFlats: 1,
              chordTonic: 3,
              chordType: 0x0D,
              alterations: const [
                MidiChordAlteration(type: 1, degree: 9),
                MidiChordAlteration(type: 3, degree: 5),
                MidiChordAlteration(type: 4, degree: 11),
                MidiChordAlteration(type: 2, degree: 3),
              ],
              bassSharpsFlats: -1,
              bassNote: 7,
              bassChordType: 0x01,
              bassAlterations: const [
                MidiChordAlteration(type: 2, degree: 5),
                MidiChordAlteration(type: 1, degree: 7),
              ],
            ),
            ['d5030006 130d1935 4b230000 f7012517'],
          ),
          (
            MidiSetChordName(
              tonicSharpsFlats: -2,
              chordTonic: 1,
              chordType: 0x07,
            ),
            ['d5100006 e1070000 00000000 80000000'],
          ),
          (
            const MidiFlexText(statusBank: 1, status: 4, text: 'Hi'),
            ['d5100104 48690000 00000000 00000000'],
          ),
          (
            const MidiFlexText(statusBank: 1, status: 4, text: ''),
            ['d5100104 00000000 00000000 00000000'],
          ),
          (
            const MidiFlexText(channel: 2, statusBank: 2, status: 1, text: 'ä'),
            ['d5020201 c3a40000 00000000 00000000'],
          ),
          (
            const MidiFlexText(statusBank: 1, status: 2, text: 'abcdefghijkl'),
            ['d5100102 61626364 65666768 696a6b6c'],
          ),
          (
            const MidiFlexText(
              statusBank: 1,
              status: 2,
              text: 'abcdefghijklmnopqrstuvwxy',
            ),
            [
              'd5500102 61626364 65666768 696a6b6c',
              'd5900102 6d6e6f70 71727374 75767778',
              'd5d00102 79000000 00000000 00000000',
            ],
          ),
        ]);
      });

      group('UMP stream messages without group', () {
        expectEncoded([
          (
            const MidiEndpointDiscovery(),
            ['f0000101 00000000 00000000 00000000'],
          ),
          for (final (filter, message) in [
            (0x01, const MidiEndpointDiscovery(requestEndpointInfo: true)),
            (0x02, const MidiEndpointDiscovery(requestDeviceIdentity: true)),
            (0x04, const MidiEndpointDiscovery(requestEndpointName: true)),
            (0x08, const MidiEndpointDiscovery(requestProductInstanceId: true)),
            (
              0x10,
              const MidiEndpointDiscovery(requestStreamConfiguration: true),
            ),
          ])
            (
              message,
              [
                'f0000101 000000${filter.toRadixString(16).padLeft(2, '0')} '
                    '00000000 00000000',
              ],
            ),
          (
            const MidiEndpointInfoNotification(
              umpVersionMajor: 2,
              umpVersionMinor: 3,
              staticFunctionBlocks: true,
              numberOfFunctionBlocks: 3,
              supportsMidi2: true,
              supportsMidi1: true,
              supportsRxJr: true,
            ),
            ['f0010203 83000302 00000000 00000000'],
          ),
          (
            const MidiEndpointInfoNotification(
              staticFunctionBlocks: false,
              numberOfFunctionBlocks: 32,
              supportsMidi2: false,
              supportsMidi1: true,
              supportsTxJr: true,
            ),
            ['f0010101 20000101 00000000 00000000'],
          ),
          (
            MidiDeviceIdentityNotification(
              manufacturerId: const [0x00, 0x21, 0x09],
              familyId: 0x1234,
              modelId: 0x0102,
              softwareRevision: const [1, 2, 3, 4],
            ),
            ['f0020000 00002109 34240202 01020304'],
          ),
          (
            const MidiEndpointNameNotification(name: 'Synth'),
            ['f0035379 6e746800 00000000 00000000'],
          ),
          (
            const MidiEndpointNameNotification(name: 'ABCDEFGHIJKLMNO'),
            [
              'f4034142 43444546 4748494a 4b4c4d4e',
              'fc034f00 00000000 00000000 00000000',
            ],
          ),
          (
            const MidiProductInstanceIdNotification(productInstanceId: 'SN123'),
            ['f004534e 31323300 00000000 00000000'],
          ),
          (
            const MidiStreamConfigurationRequest(
              protocol: MidiProtocol.midi2,
              receiveJr: true,
            ),
            ['f0050202 00000000 00000000 00000000'],
          ),
          (
            const MidiStreamConfigurationNotification(
              protocol: MidiProtocol.midi1,
              transmitJr: true,
            ),
            ['f0060101 00000000 00000000 00000000'],
          ),
          (
            const MidiFunctionBlockDiscovery(),
            ['f010ff03 00000000 00000000 00000000'],
          ),
          (
            const MidiFunctionBlockDiscovery(
              functionBlock: 2,
              requestName: false,
            ),
            ['f0100201 00000000 00000000 00000000'],
          ),
          (
            const MidiFunctionBlockDiscovery(
              functionBlock: 2,
              requestInfo: false,
            ),
            ['f0100202 00000000 00000000 00000000'],
          ),
          (
            const MidiFunctionBlockInfoNotification(
              active: true,
              functionBlock: 1,
              uiHint: MidiFunctionBlockUiHint.sender,
              midi1: MidiFunctionBlockMidi1.restricted31250,
              direction: MidiFunctionBlockDirection.bidirectional,
              firstGroup: 0,
              numberOfGroups: 4,
              midiCiVersion: 2,
              maxSysEx8Streams: 1,
            ),
            ['f011812b 00040201 00000000 00000000'],
          ),
          (
            const MidiFunctionBlockInfoNotification(
              active: false,
              functionBlock: 0x1F,
              direction: MidiFunctionBlockDirection.input,
              firstGroup: 0xF,
              numberOfGroups: 1,
            ),
            ['f0111f01 0f010000 00000000 00000000'],
          ),
          (
            const MidiFunctionBlockNameNotification(
              functionBlock: 1,
              name: 'Piano',
            ),
            ['f0120150 69616e6f 00000000 00000000'],
          ),
          (
            const MidiFunctionBlockNameNotification(
              functionBlock: 2,
              name: 'ABCDEFGHIJKLMN',
            ),
            [
              'f4120241 42434445 46474849 4a4b4c4d',
              'fc12024e 00000000 00000000 00000000',
            ],
          ),
          (const MidiStartOfClip(), ['f0200000 00000000 00000000 00000000']),
          (const MidiEndOfClip(), ['f0210000 00000000 00000000 00000000']),
        ]);

        for (final (length, maxLength, perPacket) in [
          (100, 98, 14),
          (50, 42, 14),
          (95, 91, 13),
        ]) {
          test('cuts texts of $length bytes to $maxLength bytes', () {
            final text = 'x' * length;
            final message = switch (maxLength) {
              98 => MidiEndpointNameNotification(name: text),
              42 => MidiProductInstanceIdNotification(productInstanceId: text),
              _ => MidiFunctionBlockNameNotification(
                functionBlock: 0,
                name: text,
              ),
            };
            final packets = UmpEncoder.encode(message);
            expect(packets, hasLength(maxLength ~/ perPacket));
            expect([
              for (final p in packets) (p.words[0] >> 26) & 3,
            ], equals([1, for (var i = 2; i < packets.length; i++) 2, 3]));
            expect(packets.last.words.last & 0xFF, 0x78);
          });
        }

        test('cuts texts before an incomplete character', () {
          final name = '${'x' * 97}ä';
          final packets = UmpEncoder.encode(
            MidiEndpointNameNotification(name: name),
          );
          expect(packets, hasLength(7));
          expect(packets.last.words.last, 0x78787800);
        });
      });

      test('returns the packets of unknown messages unchanged', () {
        final packets = umps([
          '60000000',
          'f0ff0000 00000000 00000000 00000000',
        ]);
        expect(
          UmpEncoder.encode(MidiUnknownMessage(packets), group: 3),
          equals(packets),
        );
      });

      test('uses group 0 by default', () {
        expect(
          UmpEncoder.encode(const MidiTimingClock()),
          equals(umps(['10f80000'])),
        );
      });

      test('keeps the low four bits of the group', () {
        expect(
          UmpEncoder.encode(const MidiTimingClock(), group: 0x1E),
          equals(umps(['1ef80000'])),
        );
      });
    });
  });
}
