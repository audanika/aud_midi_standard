// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_json_reader.dart';
import 'midi_list_equality.dart';
import 'midi_network_connection_info.dart';
import 'midi_network_connection_policy.dart';
import 'midi_network_protocol.dart';

// #############################################################################
/// The local network MIDI session and its connections.
final class MidiNetworkSessionInfo {
  /// Creates the description of a session from a copy of [connections].
  ///
  /// - [localName] the name under which the session is announced.
  /// - [port] the UDP port the session listens on; the control port for
  ///   AppleMIDI.
  MidiNetworkSessionInfo({
    required this.localName,
    required this.enabled,
    required this.port,
    required this.protocol,
    required this.connectionPolicy,
    List<MidiNetworkConnectionInfo> connections = const [],
  }) : connections = List.unmodifiable(connections);

  // ...........................................................................
  /// Decodes a session that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type.
  factory MidiNetworkSessionInfo.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiNetworkSessionInfo');
    return MidiNetworkSessionInfo(
      localName: reader.value<String>('localName'),
      enabled: reader.value<bool>('enabled'),
      port: reader.value<int>('port'),
      protocol: reader.enumValue('protocol', MidiNetworkProtocol.values),
      connectionPolicy: reader.enumValue(
        'connectionPolicy',
        MidiNetworkConnectionPolicy.values,
      ),
      connections: reader.objects(
        'connections',
        MidiNetworkConnectionInfo.fromJson,
      ),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiNetworkSessionInfo copyWith({
    String? localName,
    bool? enabled,
    int? port,
    MidiNetworkProtocol? protocol,
    MidiNetworkConnectionPolicy? connectionPolicy,
    List<MidiNetworkConnectionInfo>? connections,
  }) => MidiNetworkSessionInfo(
    localName: localName ?? this.localName,
    enabled: enabled ?? this.enabled,
    port: port ?? this.port,
    protocol: protocol ?? this.protocol,
    connectionPolicy: connectionPolicy ?? this.connectionPolicy,
    connections: connections ?? this.connections,
  );

  /// Returns the session as a JSON map.
  Map<String, Object?> toJson() => {
    'localName': localName,
    'enabled': enabled,
    'port': port,
    'protocol': protocol.name,
    'connectionPolicy': connectionPolicy.name,
    'connections': [for (final connection in connections) connection.toJson()],
  };

  // ...........................................................................
  /// The name under which the session is announced.
  final String localName;

  /// Whether the session accepts and keeps connections.
  final bool enabled;

  /// The UDP port the session listens on; the control port for AppleMIDI.
  final int port;

  /// The protocol of the session.
  final MidiNetworkProtocol protocol;

  /// Who may connect to the session.
  final MidiNetworkConnectionPolicy connectionPolicy;

  /// The connections of the session; cannot be modified.
  final List<MidiNetworkConnectionInfo> connections;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiNetworkSessionInfo &&
          other.localName == localName &&
          other.enabled == enabled &&
          other.port == port &&
          other.protocol == protocol &&
          other.connectionPolicy == connectionPolicy &&
          other.connections.equals(connections);

  @override
  int get hashCode => Object.hash(
    localName,
    enabled,
    port,
    protocol,
    connectionPolicy,
    Object.hashAll(connections),
  );

  @override
  String toString() =>
      "MidiNetworkSessionInfo(localName: '$localName', enabled: $enabled, "
      'port: $port, protocol: ${protocol.name}, '
      'connectionPolicy: ${connectionPolicy.name}, '
      'connections: $connections)';
}
