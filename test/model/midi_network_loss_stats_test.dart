// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const stats = MidiNetworkLossStats(
    packetsReceived: 100,
    packetsLost: 4,
    packetsRecovered: 3,
    journalRepairs: 2,
  );

  const statsJson = {
    'packetsReceived': 100,
    'packetsLost': 4,
    'packetsRecovered': 3,
    'journalRepairs': 2,
  };

  Matcher throwsFormat(String message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiNetworkLossStats', () {
    group('MidiNetworkLossStats()', () {
      test('starts every count at zero', () {
        expect(const MidiNetworkLossStats().toJson(), {
          for (final key in statsJson.keys) key: 0,
        });
      });
    });

    group('MidiNetworkLossStats.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiNetworkLossStats.fromJson(stats.toJson()), stats);
      });

      for (final key in statsJson.keys) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiNetworkLossStats.fromJson({...statsJson}..remove(key)),
            throwsFormat('MidiNetworkLossStats: "$key" is missing'),
          );
        });

        test('throws when "$key" is no int', () {
          expect(
            () => MidiNetworkLossStats.fromJson({...statsJson, key: 1.5}),
            throwsFormat(
              'MidiNetworkLossStats: "$key" must be int, but is double',
            ),
          );
        });
      }
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(stats.copyWith(), stats);
      });

      test('replaces the given fields', () {
        expect(
          stats.copyWith(
            packetsReceived: 0,
            packetsLost: 0,
            packetsRecovered: 0,
            journalRepairs: 0,
          ),
          const MidiNetworkLossStats(),
        );
      });
    });

    group('toJson()', () {
      test('writes every count', () {
        expect(stats.toJson(), statsJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal counts', () {
        final same = MidiNetworkLossStats.fromJson(statsJson);
        expect(same, stats);
        expect(same.hashCode, stats.hashCode);
      });

      test('differ in every count', () {
        expect(
          [
            stats.copyWith(packetsReceived: 0),
            stats.copyWith(packetsLost: 0),
            stats.copyWith(packetsRecovered: 0),
            stats.copyWith(journalRepairs: 0),
          ].where((other) => other == stats),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every count', () {
        expect(
          stats.toString(),
          'MidiNetworkLossStats(packetsReceived: 100, packetsLost: 4, '
          'packetsRecovered: 3, journalRepairs: 2)',
        );
      });
    });
  });
}
