// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final connection = MidiNetworkConnectionInfo(
    host: const MidiNetworkHostInfo(
      name: 'Studio Mac',
      address: '192.168.1.20',
      port: 5004,
    ),
    state: MidiNetworkConnectionState.connected,
  );

  final session = MidiNetworkSessionInfo(
    localName: 'iPad',
    enabled: true,
    port: 5004,
    protocol: MidiNetworkProtocol.appleMidi,
    connectionPolicy: MidiNetworkConnectionPolicy.contacts,
    connections: [connection],
  );

  final sessionJson = {
    'localName': 'iPad',
    'enabled': true,
    'port': 5004,
    'protocol': 'appleMidi',
    'connectionPolicy': 'contacts',
    'connections': [connection.toJson()],
  };

  final other = MidiNetworkSessionInfo(
    localName: 'Phone',
    enabled: false,
    port: 5008,
    protocol: MidiNetworkProtocol.networkMidi2,
    connectionPolicy: MidiNetworkConnectionPolicy.anyone,
    connections: [
      connection.copyWith(state: MidiNetworkConnectionState.disconnected),
    ],
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiNetworkSessionInfo', () {
    group('MidiNetworkSessionInfo(...)', () {
      test('has no connections by default', () {
        final session = MidiNetworkSessionInfo(
          localName: 'iPad',
          enabled: false,
          port: 5004,
          protocol: MidiNetworkProtocol.appleMidi,
          connectionPolicy: MidiNetworkConnectionPolicy.anyone,
        );
        expect(session.connections, isEmpty);
      });

      test('keeps an unmodifiable copy of the connections', () {
        final connections = [connection];
        final session = other.copyWith(connections: connections);
        connections.clear();
        expect(session.connections, [connection]);
        expect(session.connections.clear, throwsUnsupportedError);
      });
    });

    group('MidiNetworkSessionInfo.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiNetworkSessionInfo.fromJson(session.toJson()), session);
      });

      for (final key in sessionJson.keys) {
        test('throws when "$key" is missing', () {
          expect(
            () =>
                MidiNetworkSessionInfo.fromJson({...sessionJson}..remove(key)),
            throwsFormat('MidiNetworkSessionInfo: "$key" is missing'),
          );
        });

        test('throws when "$key" has the wrong type', () {
          final wrong = sessionJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiNetworkSessionInfo.fromJson({...sessionJson, key: wrong}),
            throwsFormat(startsWith('MidiNetworkSessionInfo: "$key" must be ')),
          );
        });
      }

      test('throws for an invalid connection', () {
        expect(
          () => MidiNetworkSessionInfo.fromJson({
            ...sessionJson,
            'connections': [
              {'state': 'connected'},
            ],
          }),
          throwsFormat('MidiNetworkConnectionInfo: "host" is missing'),
        );
      });
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(session.copyWith(), session);
      });

      test('replaces the given fields', () {
        expect(
          session.copyWith(
            localName: other.localName,
            enabled: other.enabled,
            port: other.port,
            protocol: other.protocol,
            connectionPolicy: other.connectionPolicy,
            connections: other.connections,
          ),
          other,
        );
      });
    });

    group('toJson()', () {
      test('writes every field, connections as maps', () {
        expect(session.toJson(), sessionJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiNetworkSessionInfo.fromJson(sessionJson);
        expect(same, session);
        expect(same.hashCode, session.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            session.copyWith(localName: other.localName),
            session.copyWith(enabled: other.enabled),
            session.copyWith(port: other.port),
            session.copyWith(protocol: other.protocol),
            session.copyWith(connectionPolicy: other.connectionPolicy),
            session.copyWith(connections: other.connections),
          ].where((variant) => variant == session),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          session.toString(),
          "MidiNetworkSessionInfo(localName: 'iPad', enabled: true, "
          'port: 5004, protocol: appleMidi, connectionPolicy: contacts, '
          'connections: [$connection])',
        );
      });
    });
  });
}
