// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_json_reader.dart';
import 'midi_network_host_source.dart';

// #############################################################################
/// A host that offers a network MIDI session, discovered by DNS-SD or
/// entered by hand.
final class MidiNetworkHostInfo {
  /// Creates the description of a host.
  ///
  /// - [address] the IP address or the host name.
  /// - [port] the UDP port; the control port for AppleMIDI.
  /// - [serviceType] the DNS-SD service type, [appleMidiServiceType] or
  ///   [networkMidi2ServiceType].
  const MidiNetworkHostInfo({
    required this.name,
    required this.address,
    required this.port,
    this.source = MidiNetworkHostSource.manual,
    this.serviceType = appleMidiServiceType,
  });

  // ...........................................................................
  /// Decodes a host that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type.
  factory MidiNetworkHostInfo.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiNetworkHostInfo');
    return MidiNetworkHostInfo(
      name: reader.value<String>('name'),
      address: reader.value<String>('address'),
      port: reader.value<int>('port'),
      source: reader.enumValue('source', MidiNetworkHostSource.values),
      serviceType: reader.value<String>('serviceType'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiNetworkHostInfo copyWith({
    String? name,
    String? address,
    int? port,
    MidiNetworkHostSource? source,
    String? serviceType,
  }) => MidiNetworkHostInfo(
    name: name ?? this.name,
    address: address ?? this.address,
    port: port ?? this.port,
    source: source ?? this.source,
    serviceType: serviceType ?? this.serviceType,
  );

  /// Returns the host as a JSON map.
  Map<String, Object?> toJson() => {
    'name': name,
    'address': address,
    'port': port,
    'source': source.name,
    'serviceType': serviceType,
  };

  // ...........................................................................
  /// The name of the host, e.g. its DNS-SD service name.
  final String name;

  /// The IP address or the host name.
  final String address;

  /// The UDP port; the control port for AppleMIDI.
  final int port;

  /// Where the description of the host comes from.
  final MidiNetworkHostSource source;

  /// The DNS-SD service type, [appleMidiServiceType] or
  /// [networkMidi2ServiceType].
  final String serviceType;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiNetworkHostInfo &&
          other.name == name &&
          other.address == address &&
          other.port == port &&
          other.source == source &&
          other.serviceType == serviceType;

  @override
  int get hashCode => Object.hash(name, address, port, source, serviceType);

  @override
  String toString() =>
      "MidiNetworkHostInfo(name: '$name', address: '$address', port: $port, "
      "source: ${source.name}, serviceType: '$serviceType')";

  // ...........................................................................
  /// The DNS-SD service type of AppleMIDI (RTP-MIDI) sessions.
  static const String appleMidiServiceType = '_apple-midi._udp';

  /// The DNS-SD service type of Network MIDI 2.0 sessions.
  static const String networkMidi2ServiceType = '_midi2._udp';
}
