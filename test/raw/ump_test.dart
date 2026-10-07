// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final noteOn1 = Ump(const [0x23903C64]);
  final noteOn2 = Ump(const [0x45903C00, 0xC8000000]);
  final endpointDiscovery = Ump(const [0xF0000101, 0x0000001F, 0, 0]);

  Matcher throwsArgumentError(String message) => throwsA(
    isA<ArgumentError>().having((e) => e.message, 'message', message),
  );

  group('Ump', () {
    group('Ump(words)', () {
      test('keeps a copy of the words', () {
        final source = [0x45903C00, 0xC8000000];
        final ump = Ump(source);
        source[1] = 0;
        expect(ump.words, [0x45903C00, 0xC8000000]);
      });

      test('keeps the low 32 bits of each value', () {
        expect(Ump(const [0x123903C64]).words, [0x23903C64]);
      });

      test('makes the words unmodifiable', () {
        expect(() => noteOn1.words[0] = 0, throwsUnsupportedError);
      });

      test('throws when the word count does not match the type', () {
        for (final words in [
          const <int>[],
          const [0x45903C00],
          const [0x23903C64, 0],
        ]) {
          expect(
            () => Ump(words),
            throwsArgumentError(
              'The number of words does not match the message type',
            ),
          );
        }
      });
    });

    group('Ump.fromHex(hex)', () {
      test('parses one group of hex digits per word', () {
        expect(Ump.fromHex('45903c00 c8000000'), noteOn2);
        expect(Ump.fromHex('  23903C64\n'), noteOn1);
      });
    });

    group('split(words)', () {
      test('splits a stream of words into packets', () {
        expect(
          Ump.split([...noteOn1.words, ...noteOn2.words, ...noteOn1.words]),
          [noteOn1, noteOn2, noteOn1],
        );
        expect(Ump.split(const []), isEmpty);
      });

      test('throws when the last packet is incomplete', () {
        expect(
          () => Ump.split([...noteOn1.words, 0x45903C00]),
          throwsArgumentError('Incomplete last packet'),
        );
      });
    });

    group('sizeOf(firstWord)', () {
      test('returns the word count of the message type', () {
        expect(Ump.sizeOf(0x23903C64), 1);
        expect(Ump.sizeOf(0x45903C00), 2);
        expect(Ump.sizeOf(0xB0000000), 3);
        expect(Ump.sizeOf(0xF0000101), 4);
      });
    });

    group('messageType', () {
      test('is the type of the first word', () {
        expect(noteOn1.messageType, UmpMessageType.midi1ChannelVoice);
        expect(noteOn2.messageType, UmpMessageType.midi2ChannelVoice);
        expect(endpointDiscovery.messageType, UmpMessageType.umpStream);
      });
    });

    group('group', () {
      test('is bits 24 to 27 of grouped types', () {
        expect(noteOn1.group, 3);
        expect(noteOn2.group, 5);
      });

      test('is null for groupless types', () {
        expect(endpointDiscovery.group, isNull);
        expect(Ump(const [0x00000000]).group, isNull);
      });
    });

    group('toHex()', () {
      test('returns eight lower-case hex digits per word', () {
        expect(noteOn2.toHex(), '45903c00 c8000000');
        expect(Ump(const [0x0000000A]).toHex(), '0000000a');
      });
    });

    group('==, hashCode', () {
      test('compare the words', () {
        final same = Ump.fromHex('45903c00 c8000000');
        expect(noteOn2, same);
        expect(noteOn2.hashCode, same.hashCode);
        expect(noteOn2, noteOn2);
      });

      test('differ for other words or another length', () {
        expect(noteOn2, isNot(Ump.fromHex('45903c00 c8000001')));
        expect(noteOn2, isNot(noteOn1));
        expect(noteOn2, isNot(Object()));
      });
    });

    group('toString()', () {
      test('shows the words as hex', () {
        expect(noteOn2.toString(), 'Ump(45903c00 c8000000)');
      });
    });
  });
}
