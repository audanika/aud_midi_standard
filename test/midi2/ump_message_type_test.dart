// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('UmpMessageType', () {
    group('values', () {
      test('are ordered by their 4-bit value', () {
        expect(
          UmpMessageType.values.map((type) => type.value),
          List.generate(16, (i) => i),
        );
      });

      test('have the word counts of M2-104-UM Table 4', () {
        const wordCounts = [1, 1, 1, 2, 2, 4, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4];
        expect(UmpMessageType.values.map((type) => type.wordCount), wordCounts);
      });

      test('have a group only for the defined grouped types', () {
        expect(UmpMessageType.values.where((type) => type.hasGroup), [
          UmpMessageType.system,
          UmpMessageType.midi1ChannelVoice,
          UmpMessageType.data64,
          UmpMessageType.midi2ChannelVoice,
          UmpMessageType.data128,
          UmpMessageType.flexData,
        ]);
      });
    });

    group('fromWord(word)', () {
      test('returns the type of the top four bits', () {
        for (final type in UmpMessageType.values) {
          expect(UmpMessageType.fromWord(type.value << 28), type);
          expect(UmpMessageType.fromWord(type.value << 28 | 0x0FFFFFFF), type);
        }
      });
    });
  });
}
