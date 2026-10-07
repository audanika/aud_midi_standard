// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const time = MidiTime(1000);
  const later = MidiTime(2000);
  final noteOn = MidiBytes(const [0x90, 0x3C, 0x64]);
  const noteOnUmp = [0x20903C64];
  const noteOn2Ump = [0x40903C00, 0xC8000000];

  final bytesPacket = MidiBytesPacket(bytes: noteOn, time: time);
  final umpPacket = MidiUmpPacket(
    words: [...noteOnUmp, ...noteOn2Ump],
    time: time,
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiPacket', () {
    group('MidiPacket.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        for (final packet in [bytesPacket, umpPacket]) {
          expect(MidiPacket.fromJson(packet.toJson()), packet);
        }
      });

      test('throws for an unknown type', () {
        expect(
          () => MidiPacket.fromJson({...bytesPacket.toJson(), 'type': 'x'}),
          throwsFormat(
            "MidiPacket: \"type\" must be one of bytes, ump, but is 'x'",
          ),
        );
      });

      for (final packet in [bytesPacket, umpPacket]) {
        for (final key in packet.toJson().keys) {
          test('throws when "$key" of ${packet.runtimeType} is missing', () {
            expect(
              () => MidiPacket.fromJson(packet.toJson()..remove(key)),
              throwsFormat('MidiPacket: "$key" is missing'),
            );
          });
        }
      }

      test('throws for a word that is no int', () {
        expect(
          () => MidiPacket.fromJson({
            ...umpPacket.toJson(),
            'words': [1, 'a'],
          }),
          throwsFormat('MidiPacket: "words[1]" must be int, but is String'),
        );
      });
    });

    group('time', () {
      test('is the receive or due time', () {
        expect([bytesPacket.time, umpPacket.time], [time, time]);
      });
    });
  });

  group('MidiBytesPacket', () {
    group('copyWith(bytes: bytes, time: time)', () {
      test('keeps or replaces the fields', () {
        final other = MidiBytes(const [0xF8]);
        expect(bytesPacket.copyWith(), bytesPacket);
        expect(
          bytesPacket.copyWith(bytes: other, time: later),
          MidiBytesPacket(bytes: other, time: later),
        );
      });

      test('retimes through the base type', () {
        final MidiPacket packet = bytesPacket;
        expect(
          packet.copyWith(time: later),
          MidiBytesPacket(bytes: noteOn, time: later),
        );
      });
    });

    group('toJson()', () {
      test('writes the type, the bytes and the time in microseconds', () {
        expect(bytesPacket.toJson(), {
          'type': 'bytes',
          'bytes': [0x90, 0x3C, 0x64],
          'time': 1000,
        });
      });
    });

    group('bytes', () {
      test('are the bytes of the packet', () {
        expect(bytesPacket.bytes, noteOn);
      });
    });

    group('==, hashCode', () {
      test('compare bytes and time', () {
        final same = MidiBytesPacket(
          bytes: MidiBytes.fromHex('903c64'),
          time: time,
        );
        expect(same, bytesPacket);
        expect(same.hashCode, bytesPacket.hashCode);
        expect(bytesPacket, isNot(bytesPacket.copyWith(time: later)));
        expect(
          bytesPacket,
          isNot(bytesPacket.copyWith(bytes: MidiBytes(const [0xF8]))),
        );
      });
    });

    group('toString()', () {
      test('shows the bytes as hex and the time', () {
        expect(
          bytesPacket.toString(),
          'MidiBytesPacket(bytes: 90 3c 64, time: 1000)',
        );
      });
    });
  });

  group('MidiUmpPacket', () {
    group('MidiUmpPacket(words: words, time: time)', () {
      test('keeps an unmodifiable copy of the words', () {
        final words = [...noteOnUmp];
        final packet = MidiUmpPacket(words: words, time: time);
        words[0] = 0;
        expect(packet.words, noteOnUmp);
        expect(() => packet.words[0] = 0, throwsUnsupportedError);
      });

      test('keeps the low 32 bits of each value', () {
        expect(
          MidiUmpPacket(words: const [0x120903C64], time: time).words,
          noteOnUmp,
        );
      });
    });

    group('copyWith(words: words, time: time)', () {
      test('keeps or replaces the fields', () {
        expect(umpPacket.copyWith(), umpPacket);
        expect(
          umpPacket.copyWith(words: noteOnUmp, time: later),
          MidiUmpPacket(words: noteOnUmp, time: later),
        );
      });
    });

    group('toJson()', () {
      test('writes the type, the words and the time in microseconds', () {
        expect(umpPacket.toJson(), {
          'type': 'ump',
          'words': [...noteOnUmp, ...noteOn2Ump],
          'time': 1000,
        });
      });
    });

    group('umps', () {
      test('splits the words into packets', () {
        expect(umpPacket.umps, [Ump(noteOnUmp), Ump(noteOn2Ump)]);
      });

      test('throws when the last packet is incomplete', () {
        expect(
          () => MidiUmpPacket(words: const [0x40903C00], time: time).umps,
          throwsArgumentError,
        );
      });
    });

    group('==, hashCode', () {
      test('compare words and time', () {
        final same = MidiUmpPacket(words: umpPacket.words, time: time);
        expect(same, umpPacket);
        expect(same.hashCode, umpPacket.hashCode);
        expect(umpPacket, isNot(umpPacket.copyWith(time: later)));
        expect(umpPacket, isNot(umpPacket.copyWith(words: noteOnUmp)));
        expect(umpPacket, isNot(bytesPacket));
      });
    });

    group('toString()', () {
      test('shows the words as hex and the time', () {
        expect(
          umpPacket.toString(),
          'MidiUmpPacket(words: 20903c64 40903c00 c8000000, time: 1000)',
        );
      });
    });
  });
}
