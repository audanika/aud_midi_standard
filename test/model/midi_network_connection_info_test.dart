// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const host = MidiNetworkHostInfo(
    name: 'Studio Mac',
    address: '192.168.1.20',
    port: 5004,
  );
  const stats = MidiNetworkLossStats(packetsReceived: 10, packetsLost: 1);

  final connection = MidiNetworkConnectionInfo(
    host: host,
    state: MidiNetworkConnectionState.connected,
    clockOffset: const Duration(microseconds: -1500),
    roundTrip: const Duration(milliseconds: 3),
    lossStats: stats,
    portIds: const [MidiPortId('rtp:1:in'), MidiPortId('rtp:1:out')],
  );

  final connectionJson = {
    'host': host.toJson(),
    'state': 'connected',
    'clockOffset': -1500,
    'roundTrip': 3000,
    'lossStats': stats.toJson(),
    'portIds': ['rtp:1:in', 'rtp:1:out'],
  };

  final other = MidiNetworkConnectionInfo(
    host: host.copyWith(port: 5008),
    state: MidiNetworkConnectionState.failed,
    clockOffset: const Duration(microseconds: 20),
    roundTrip: const Duration(milliseconds: 9),
    lossStats: stats.copyWith(packetsLost: 5),
    portIds: const [MidiPortId('rtp:2:in')],
  );

  const optionalKeys = ['clockOffset', 'roundTrip'];

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiNetworkConnectionInfo', () {
    group('MidiNetworkConnectionInfo(...)', () {
      test('applies the defaults', () {
        final connection = MidiNetworkConnectionInfo(
          host: host,
          state: MidiNetworkConnectionState.inviting,
        );
        expect(connection.toJson(), {
          'host': host.toJson(),
          'state': 'inviting',
          'clockOffset': null,
          'roundTrip': null,
          'lossStats': const MidiNetworkLossStats().toJson(),
          'portIds': <Object?>[],
        });
      });

      test('keeps an unmodifiable copy of the port ids', () {
        final portIds = [const MidiPortId('rtp:1')];
        final connection = MidiNetworkConnectionInfo(
          host: host,
          state: MidiNetworkConnectionState.connected,
          portIds: portIds,
        );
        portIds.clear();
        expect(connection.portIds, [const MidiPortId('rtp:1')]);
        expect(connection.portIds.clear, throwsUnsupportedError);
      });
    });

    group('MidiNetworkConnectionInfo.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(
          MidiNetworkConnectionInfo.fromJson(connection.toJson()),
          connection,
        );
        final fresh = connection.copyWith(
          clearClockOffset: true,
          clearRoundTrip: true,
        );
        expect(MidiNetworkConnectionInfo.fromJson(fresh.toJson()), fresh);
      });

      for (final key in optionalKeys) {
        test('reads a missing "$key" as null', () {
          final json = {...connectionJson}..remove(key);
          expect(
            MidiNetworkConnectionInfo.fromJson(json).toJson()[key],
            isNull,
          );
        });
      }

      for (final key in connectionJson.keys) {
        if (!optionalKeys.contains(key)) {
          test('throws when "$key" is missing', () {
            expect(
              () => MidiNetworkConnectionInfo.fromJson(
                {...connectionJson}..remove(key),
              ),
              throwsFormat('MidiNetworkConnectionInfo: "$key" is missing'),
            );
          });
        }

        test('throws when "$key" has the wrong type', () {
          final wrong = connectionJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiNetworkConnectionInfo.fromJson({
              ...connectionJson,
              key: wrong,
            }),
            throwsFormat(
              startsWith('MidiNetworkConnectionInfo: "$key" must be '),
            ),
          );
        });
      }
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(connection.copyWith(), connection);
      });

      test('replaces the given fields', () {
        expect(
          connection.copyWith(
            host: other.host,
            state: other.state,
            clockOffset: other.clockOffset,
            roundTrip: other.roundTrip,
            lossStats: other.lossStats,
            portIds: other.portIds,
          ),
          other,
        );
      });

      test('clears the durations with clearClockOffset and clearRoundTrip', () {
        final cleared = connection.copyWith(
          clockOffset: Duration.zero,
          clearClockOffset: true,
          roundTrip: Duration.zero,
          clearRoundTrip: true,
        );
        expect([cleared.clockOffset, cleared.roundTrip], [null, null]);
      });
    });

    group('toJson()', () {
      test('writes every field, durations in microseconds', () {
        expect(connection.toJson(), connectionJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiNetworkConnectionInfo.fromJson(connectionJson);
        expect(same, connection);
        expect(same.hashCode, connection.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            connection.copyWith(host: other.host),
            connection.copyWith(state: other.state),
            connection.copyWith(clockOffset: other.clockOffset),
            connection.copyWith(roundTrip: other.roundTrip),
            connection.copyWith(lossStats: other.lossStats),
            connection.copyWith(portIds: other.portIds),
          ].where((variant) => variant == connection),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          connection.toString(),
          'MidiNetworkConnectionInfo(host: $host, state: connected, '
          'clockOffset: -0:00:00.001500, roundTrip: 0:00:00.003000, '
          'lossStats: $stats, portIds: [rtp:1:in, rtp:1:out])',
        );
      });
    });
  });
}
