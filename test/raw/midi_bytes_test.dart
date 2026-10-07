// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final noteOn = MidiBytes(const [0x90, 0x3C, 0x64]);

  group('MidiBytes', () {
    group('MidiBytes(bytes)', () {
      test('keeps a copy of the bytes', () {
        final source = [0x90, 0x3C, 0x64];
        final bytes = MidiBytes(source);
        source[0] = 0x80;
        expect(bytes.bytes, [0x90, 0x3C, 0x64]);
      });

      test('keeps the low eight bits of each value', () {
        expect(MidiBytes(const [0x190, 0xFF]).bytes, [0x90, 0xFF]);
      });

      test('makes the bytes unmodifiable', () {
        expect(() => noteOn.bytes[0] = 0x80, throwsUnsupportedError);
      });
    });

    group('MidiBytes.fromHex(hex)', () {
      test('parses pairs of hex digits with optional whitespace', () {
        expect(MidiBytes.fromHex('90 3c 64'), noteOn);
        expect(MidiBytes.fromHex('903C64'), noteOn);
        expect(MidiBytes.fromHex(' 90\n3c\t64 '), noteOn);
        expect(MidiBytes.fromHex(''), MidiBytes.empty);
      });

      test('throws on an odd number of digits', () {
        expect(
          () => MidiBytes.fromHex('90 3'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              'Odd number of hex digits',
            ),
          ),
        );
      });

      test('throws on a character that is no hex digit', () {
        expect(() => MidiBytes.fromHex('9g'), throwsFormatException);
      });
    });

    group('empty', () {
      test('holds no byte', () {
        expect(MidiBytes.empty.bytes, isEmpty);
        expect(MidiBytes.empty.isEmpty, isTrue);
      });
    });

    group('length, isEmpty, [index]', () {
      test('describe the bytes', () {
        expect(noteOn.length, 3);
        expect(noteOn.isEmpty, isFalse);
        expect([noteOn[0], noteOn[1], noteOn[2]], [0x90, 0x3C, 0x64]);
      });
    });

    group('toHex()', () {
      test('returns lower-case hex pairs separated by spaces', () {
        expect(MidiBytes(const [0x0A, 0xF7]).toHex(), '0a f7');
        expect(MidiBytes.empty.toHex(), '');
      });
    });

    group('==, hashCode', () {
      test('compare the bytes', () {
        final same = MidiBytes.fromHex('90 3c 64');
        expect(noteOn, same);
        expect(noteOn.hashCode, same.hashCode);
        expect(noteOn, noteOn);
      });

      test('differ for other bytes or another length', () {
        expect(noteOn, isNot(MidiBytes.fromHex('90 3c 65')));
        expect(noteOn, isNot(MidiBytes.fromHex('90 3c')));
        expect(noteOn, isNot(Object()));
      });
    });

    group('toString()', () {
      test('shows the bytes as hex', () {
        expect(noteOn.toString(), 'MidiBytes(90 3c 64)');
      });
    });
  });
}
