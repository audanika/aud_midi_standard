// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:typed_data';

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  late MidiBleEncoder encoder;

  setUp(() => encoder = MidiBleEncoder());

  MidiTimedMessage at(int milliseconds, MidiMessage message) =>
      (message: message, time: MidiTime(milliseconds * 1000));

  List<String> encode(List<MidiTimedMessage> messages) => [
    for (final packet in encoder.encode(messages)) MidiBytes(packet).toHex(),
  ];

  String hex(List<int> bytes) => MidiBytes(bytes).toHex();

  List<int> count(int n) => [for (var i = 1; i <= n; i++) i];

  const noteOn = MidiNoteOn(channel: 0, note: 0x3C, velocity: 0x64);
  const noteOff = MidiNoteOff(channel: 0, note: 0x3C);

  group('MidiBleEncoder', () {
    group('MidiBleEncoder(maxPacketLength)', () {
      test('uses 20 bytes by default', () {
        expect(MidiBleEncoder().maxPacketLength, 20);
      });

      test('asserts at least 5 bytes', () {
        expect(
          () => MidiBleEncoder(maxPacketLength: 4),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('encode(messages)', () {
      test('returns no packet for no messages', () {
        expect(encoder.encode(const []), isEmpty);
      });

      test('writes header, timestamp and message', () {
        expect(encode([at(1000, noteOn)]), equals(['87 e8 90 3c 64']));
      });

      test('puts messages of one time into one packet', () {
        expect(
          encode([at(1000, noteOn), at(1000, noteOff)]),
          equals(['87 e8 90 3c 64 e8 80 3c 40']),
        );
      });

      test('puts messages less than 128 ms apart into one packet', () {
        expect(
          encode([at(1000, noteOn), at(1010, noteOff), at(1137, noteOn)]),
          equals(['87 e8 90 3c 64 f2 80 3c 40 f1 90 3c 64']),
        );
      });

      test('lets the low timestamp bits wrap within a packet', () {
        expect(
          encode([at(1023, noteOn), at(1025, noteOff)]),
          equals(['87 ff 90 3c 64 81 80 3c 40']),
        );
      });

      test('starts a new packet 128 ms after the last message', () {
        expect(
          encode([at(1000, noteOn), at(1128, noteOff)]),
          equals(['87 e8 90 3c 64', '88 e8 80 3c 40']),
        );
      });

      test('starts a new packet for an earlier message', () {
        expect(
          encode([at(1000, noteOn), at(999, noteOff)]),
          equals(['87 e8 90 3c 64', '87 e7 80 3c 40']),
        );
      });

      test('starts a new packet when a message does not fit', () {
        expect(
          encode([for (var i = 0; i < 5; i++) at(0, noteOn)]),
          equals([
            '80 ${List.filled(4, '80 90 3c 64').join(' ')}',
            '80 80 90 3c 64',
          ]),
        );
      });

      test('starts a new packet 8192 ms after the first message', () {
        encoder = MidiBleEncoder(maxPacketLength: 512);
        final packets = encoder.encode([
          for (var i = 0; i <= 82; i++) at(100 * i, noteOn),
        ]);
        expect(packets.map((packet) => packet.length), equals([329, 5]));
      });

      test('skips messages without a byte form', () {
        expect(
          encode([
            at(0, const MidiNoop()),
            at(0, const MidiNoteOn2(channel: 0, note: 1, velocity: 2)),
            at(0, const MidiStart()),
          ]),
          equals(['80 80 fa']),
        );
      });

      test('rounds times down to whole milliseconds', () {
        expect([
          for (final time in [1000999, -1])
            hex(
              encoder.encode([(message: noteOn, time: MidiTime(time))]).single,
            ),
        ], equals(['87 e8 90 3c 64', 'bf ff 90 3c 64']));
      });

      group('System Exclusive', () {
        test('in one packet', () {
          expect(
            encode([
              at(0, MidiSysEx(const [1, 2])),
            ]),
            equals(['80 80 f0 01 02 80 f7']),
          );
        });

        test('without data', () {
          expect(
            encode([at(0, MidiSysEx(const []))]),
            equals(['80 80 f0 80 f7']),
          );
        });

        test('continued in packets without timestamp', () {
          final data = count(30);
          expect(
            encode([at(0, MidiSysEx(data))]),
            equals([
              '80 80 f0 ${hex(data.sublist(0, 17))}',
              '80 ${hex(data.sublist(17))} 80 f7',
            ]),
          );
        });

        test('with 0xF7 in a packet of its own', () {
          final data = count(36);
          expect(
            encode([at(0, MidiSysEx(data))]),
            equals([
              '80 80 f0 ${hex(data.sublist(0, 17))}',
              '80 ${hex(data.sublist(17))}',
              '80 80 f7',
            ]),
          );
        });

        test('followed by a message in its last packet', () {
          final data = count(30);
          expect(
            encode([at(0, MidiSysEx(data)), at(0, noteOn)]),
            equals([
              '80 80 f0 ${hex(data.sublist(0, 17))}',
              '80 ${hex(data.sublist(17))} 80 f7 80 90 3c 64',
            ]),
          );
        });

        test('starts a new packet without room for its start', () {
          encoder = MidiBleEncoder(maxPacketLength: 19);
          expect(
            encode([
              for (var i = 0; i < 4; i++) at(0, noteOn),
              at(0, MidiSysEx(const [1])),
            ]),
            equals([
              '80 ${List.filled(4, '80 90 3c 64').join(' ')}',
              '80 80 f0 01 80 f7',
            ]),
          );
        });
      });
    });

    group('round trip with MidiBleDecoder', () {
      int lastTimestamp(Uint8List packet) {
        var high = packet[0] & 0x3F;
        int? low;
        var afterTimestamp = false;
        var last = 0;
        for (final byte in packet.skip(1)) {
          afterTimestamp = byte >= 0x80 && !afterTimestamp;
          if (!afterTimestamp) continue;
          if (low != null && byte & 0x7F < low) high++;
          low = byte & 0x7F;
          last = (high << 7 | low) & 0x1FFF;
        }
        return last;
      }

      final messages = [
        at(0, noteOn),
        at(0, const MidiTimingClock()),
        at(3, MidiSysEx(count(100))),
        at(3, const MidiPitchBend(channel: 3, value: 0x1234)),
        at(130, noteOff),
        at(255, const MidiProgramChange(channel: 9, program: 1)),
        at(255, MidiSysEx(const [])),
        at(300, const MidiSongPositionPointer(position: 0x3FFF)),
        at(1000, MidiSysEx([for (var i = 0; i < 600; i++) i & 0x7F])),
        at(1001, const MidiActiveSensing()),
        at(8000, const MidiChannelPressure(channel: 15, pressure: 0x7F)),
      ];

      for (final maxPacketLength in [5, 6, 20, 64, 512]) {
        test('restores messages and times in packets of $maxPacketLength', () {
          final decoder = MidiBleDecoder();
          final packets = MidiBleEncoder(
            maxPacketLength: maxPacketLength,
          ).encode(messages);
          expect(
            packets.every((packet) => packet.length <= maxPacketLength),
            isTrue,
          );
          final decoded = [
            for (final packet in packets)
              ...decoder.decode(
                packet,
                time: MidiTime(lastTimestamp(packet) * 1000),
              ),
          ];
          expect(decoded, equals(messages));
        });
      }
    });
  });
}
