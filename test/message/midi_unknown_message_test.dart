// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final first = Ump.fromHex('6f123456');
  final second = Ump.fromHex('70000000');

  group('MidiUnknownMessage', () {
    test('holds a copy of its packets', () {
      final packets = [first, second];
      final message = MidiUnknownMessage(packets);
      packets.clear();
      expect(message.umps, equals([first, second]));
    });

    test('cannot be modified', () {
      expect(
        () => MidiUnknownMessage([first]).umps.add(second),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('asserts at least one packet', () {
      expect(
        () => MidiUnknownMessage(const []),
        throwsA(isA<AssertionError>()),
      );
    });

    test('takes the message type of its first packet', () {
      expect([
        MidiUnknownMessage([first, second]).umpMessageType,
        MidiUnknownMessage([second]).umpMessageType,
      ], equals([UmpMessageType.reserved6, UmpMessageType.reserved7]));
    });

    test('prints its packets', () {
      expect(
        '${MidiUnknownMessage([first, second])}',
        'MidiUnknownMessage(umps: [Ump(6f123456), Ump(70000000)])',
      );
    });

    test('compares by packets', () {
      expect(
        MidiUnknownMessage([first]),
        MidiUnknownMessage([Ump.fromHex('6f123456')]),
      );
      expect(
        MidiUnknownMessage([first]).hashCode,
        MidiUnknownMessage([Ump.fromHex('6f123456')]).hashCode,
      );
      expect(MidiUnknownMessage([first]), isNot(MidiUnknownMessage([second])));
    });
  });
}
