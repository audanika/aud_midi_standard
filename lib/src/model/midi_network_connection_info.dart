// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_json_reader.dart';
import 'midi_list_equality.dart';
import 'midi_network_connection_state.dart';
import 'midi_network_host_info.dart';
import 'midi_network_loss_stats.dart';
import 'midi_port_id.dart';

// #############################################################################
/// A connection of a network MIDI session to a remote host.
final class MidiNetworkConnectionInfo {
  /// Creates the description of a connection from a copy of [portIds].
  ///
  /// - [clockOffset] the offset of the remote clock, null before the clocks
  ///   were synchronised.
  /// - [roundTrip] the last measured round trip time, null before the first
  ///   measurement.
  MidiNetworkConnectionInfo({
    required this.host,
    required this.state,
    this.clockOffset,
    this.roundTrip,
    this.lossStats = const MidiNetworkLossStats(),
    List<MidiPortId> portIds = const [],
  }) : portIds = List.unmodifiable(portIds);

  // ...........................................................................
  /// Decodes a connection that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type; `clockOffset` and `roundTrip` may be missing.
  factory MidiNetworkConnectionInfo.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiNetworkConnectionInfo');
    Duration duration(int microseconds) => Duration(microseconds: microseconds);
    return MidiNetworkConnectionInfo(
      host: reader.object('host', MidiNetworkHostInfo.fromJson),
      state: reader.enumValue('state', MidiNetworkConnectionState.values),
      clockOffset: reader.optional('clockOffset', duration),
      roundTrip: reader.optional('roundTrip', duration),
      lossStats: reader.object('lossStats', MidiNetworkLossStats.fromJson),
      portIds: reader.list<MidiPortId>('portIds'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  ///
  /// - [clearClockOffset] sets [clockOffset] to null; it wins over a given
  ///   offset.
  /// - [clearRoundTrip] sets [roundTrip] to null; it wins over a given
  ///   time.
  MidiNetworkConnectionInfo copyWith({
    MidiNetworkHostInfo? host,
    MidiNetworkConnectionState? state,
    Duration? clockOffset,
    bool clearClockOffset = false,
    Duration? roundTrip,
    bool clearRoundTrip = false,
    MidiNetworkLossStats? lossStats,
    List<MidiPortId>? portIds,
  }) => MidiNetworkConnectionInfo(
    host: host ?? this.host,
    state: state ?? this.state,
    clockOffset: clearClockOffset ? null : clockOffset ?? this.clockOffset,
    roundTrip: clearRoundTrip ? null : roundTrip ?? this.roundTrip,
    lossStats: lossStats ?? this.lossStats,
    portIds: portIds ?? this.portIds,
  );

  /// Returns the connection as a JSON map; durations in microseconds.
  Map<String, Object?> toJson() => {
    'host': host.toJson(),
    'state': state.name,
    'clockOffset': clockOffset?.inMicroseconds,
    'roundTrip': roundTrip?.inMicroseconds,
    'lossStats': lossStats.toJson(),
    'portIds': [for (final portId in portIds) portId.value],
  };

  // ...........................................................................
  /// The remote host.
  final MidiNetworkHostInfo host;

  /// The state of the connection.
  final MidiNetworkConnectionState state;

  /// The offset of the remote clock to the local clock, or null before the
  /// clocks were synchronised.
  final Duration? clockOffset;

  /// The last measured round trip time, or null before the first
  /// measurement.
  final Duration? roundTrip;

  /// The packet statistics of the connection.
  final MidiNetworkLossStats lossStats;

  /// The ids of the ports the connection provides; cannot be modified.
  final List<MidiPortId> portIds;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiNetworkConnectionInfo &&
          other.host == host &&
          other.state == state &&
          other.clockOffset == clockOffset &&
          other.roundTrip == roundTrip &&
          other.lossStats == lossStats &&
          other.portIds.equals(portIds);

  @override
  int get hashCode => Object.hash(
    host,
    state,
    clockOffset,
    roundTrip,
    lossStats,
    Object.hashAll(portIds),
  );

  @override
  String toString() =>
      'MidiNetworkConnectionInfo(host: $host, state: ${state.name}, '
      'clockOffset: $clockOffset, roundTrip: $roundTrip, '
      'lossStats: $lossStats, portIds: $portIds)';
}
