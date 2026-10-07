// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_device_id.dart';
import 'midi_direction.dart';
import 'midi_endpoint_info.dart';
import 'midi_function_block_info.dart';
import 'midi_group_info.dart';
import 'midi_json_reader.dart';
import 'midi_list_equality.dart';
import 'midi_port_capabilities.dart';
import 'midi_port_id.dart';
import 'midi_port_state.dart';
import 'midi_protocol.dart';
import 'midi_transport.dart';

// #############################################################################
/// A MIDI port: the primary entity of the package, a source or a
/// destination of MIDI seen from the app.
///
/// Byte ports exchange MIDI 1.0 bytes, UMP ports Universal MIDI Packets
/// ([MidiPortCapabilities.ump]). A port optionally belongs to a device.
final class MidiPortInfo {
  /// Creates the description of a port from copies of [groups],
  /// [functionBlocks] and [native].
  ///
  /// - [group] the group a byte port maps to, 0 to 15.
  /// - [native] backend-specific extras with JSON-compatible values only.
  MidiPortInfo({
    required this.id,
    this.deviceId,
    required this.name,
    this.manufacturer = '',
    required this.direction,
    this.index = 0,
    this.transport = MidiTransport.unknown,
    this.protocol = MidiProtocol.midi1,
    this.state = MidiPortState.connected,
    this.isVirtual = false,
    this.isOwn = false,
    this.group = 0,
    List<MidiGroupInfo> groups = const [],
    List<MidiFunctionBlockInfo> functionBlocks = const [],
    this.endpoint,
    this.capabilities = const MidiPortCapabilities(),
    this.serialNumber = '',
    Map<String, Object?> native = const {},
  }) : assert(group >= 0 && group <= 15),
       groups = List.unmodifiable(groups),
       functionBlocks = List.unmodifiable(functionBlocks),
       native = Map.unmodifiable(native);

  // ...........................................................................
  /// Decodes a port that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type; `deviceId` and `endpoint` may be missing.
  factory MidiPortInfo.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiPortInfo');
    return MidiPortInfo(
      id: reader.value<MidiPortId>('id'),
      deviceId: reader.value<MidiDeviceId?>('deviceId'),
      name: reader.value<String>('name'),
      manufacturer: reader.value<String>('manufacturer'),
      direction: reader.enumValue('direction', MidiDirection.values),
      index: reader.value<int>('index'),
      transport: reader.enumValue('transport', MidiTransport.values),
      protocol: reader.enumValue('protocol', MidiProtocol.values),
      state: reader.enumValue('state', MidiPortState.values),
      isVirtual: reader.value<bool>('isVirtual'),
      isOwn: reader.value<bool>('isOwn'),
      group: reader.value<int>('group'),
      groups: reader.objects('groups', MidiGroupInfo.fromJson),
      functionBlocks: reader.objects(
        'functionBlocks',
        MidiFunctionBlockInfo.fromJson,
      ),
      endpoint: reader.optional('endpoint', MidiEndpointInfo.fromJson),
      capabilities: reader.object(
        'capabilities',
        MidiPortCapabilities.fromJson,
      ),
      serialNumber: reader.value<String>('serialNumber'),
      native: reader.value<Map<String, Object?>>('native'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  ///
  /// - [clearDeviceId] sets [deviceId] to null; it wins over a given id.
  /// - [clearEndpoint] sets [endpoint] to null; it wins over a given
  ///   endpoint.
  MidiPortInfo copyWith({
    MidiPortId? id,
    MidiDeviceId? deviceId,
    bool clearDeviceId = false,
    String? name,
    String? manufacturer,
    MidiDirection? direction,
    int? index,
    MidiTransport? transport,
    MidiProtocol? protocol,
    MidiPortState? state,
    bool? isVirtual,
    bool? isOwn,
    int? group,
    List<MidiGroupInfo>? groups,
    List<MidiFunctionBlockInfo>? functionBlocks,
    MidiEndpointInfo? endpoint,
    bool clearEndpoint = false,
    MidiPortCapabilities? capabilities,
    String? serialNumber,
    Map<String, Object?>? native,
  }) => MidiPortInfo(
    id: id ?? this.id,
    deviceId: clearDeviceId ? null : deviceId ?? this.deviceId,
    name: name ?? this.name,
    manufacturer: manufacturer ?? this.manufacturer,
    direction: direction ?? this.direction,
    index: index ?? this.index,
    transport: transport ?? this.transport,
    protocol: protocol ?? this.protocol,
    state: state ?? this.state,
    isVirtual: isVirtual ?? this.isVirtual,
    isOwn: isOwn ?? this.isOwn,
    group: group ?? this.group,
    groups: groups ?? this.groups,
    functionBlocks: functionBlocks ?? this.functionBlocks,
    endpoint: clearEndpoint ? null : endpoint ?? this.endpoint,
    capabilities: capabilities ?? this.capabilities,
    serialNumber: serialNumber ?? this.serialNumber,
    native: native ?? this.native,
  );

  /// Returns the port as a JSON map.
  Map<String, Object?> toJson() => {
    'id': id.value,
    'deviceId': deviceId?.value,
    'name': name,
    'manufacturer': manufacturer,
    'direction': direction.name,
    'index': index,
    'transport': transport.name,
    'protocol': protocol.name,
    'state': state.name,
    'isVirtual': isVirtual,
    'isOwn': isOwn,
    'group': group,
    'groups': [for (final group in groups) group.toJson()],
    'functionBlocks': [for (final block in functionBlocks) block.toJson()],
    'endpoint': endpoint?.toJson(),
    'capabilities': capabilities.toJson(),
    'serialNumber': serialNumber,
    'native': {...native},
  };

  // ...........................................................................
  /// The id of the port, stable for the session.
  final MidiPortId id;

  /// The id of the device of the port, or null when the backend groups no
  /// ports into devices.
  final MidiDeviceId? deviceId;

  /// The name of the port.
  final String name;

  /// The manufacturer of the device of the port, empty when unknown.
  final String manufacturer;

  /// The direction of the port, seen from the app.
  final MidiDirection direction;

  /// The index of the port among the ports of its device.
  final int index;

  /// How the operating system reaches the port.
  final MidiTransport transport;

  /// The protocol the port speaks.
  final MidiProtocol protocol;

  /// Whether the port can currently be used.
  final MidiPortState state;

  /// Whether the port is a virtual port created by some app.
  final bool isVirtual;

  /// Whether the port is a virtual port created by this package.
  final bool isOwn;

  /// The group a byte port maps to when its messages become Universal MIDI
  /// Packets, 0 to 15.
  final int group;

  /// The UMP groups of the port; empty when unknown; cannot be modified.
  final List<MidiGroupInfo> groups;

  /// The function blocks of the UMP endpoint of the port; empty when
  /// unknown; cannot be modified.
  final List<MidiFunctionBlockInfo> functionBlocks;

  /// The description of the UMP endpoint of the port, or null when the
  /// port is no UMP endpoint or the endpoint is unknown.
  final MidiEndpointInfo? endpoint;

  /// What the port can do beyond plain sending and receiving.
  final MidiPortCapabilities capabilities;

  /// The serial number of the device of the port, empty when unknown.
  final String serialNumber;

  /// Backend-specific extras with JSON-compatible values; cannot be
  /// modified and takes no part in equality.
  final Map<String, Object?> native;

  /// Identifies the port across sessions as far as the operating system
  /// allows: `'manufacturer|name|serialNumber|direction|index'`.
  ///
  /// Equal fingerprints only mark re-plug candidates: identical devices
  /// without a serial number share one.
  String get fingerprint =>
      '$manufacturer|$name|$serialNumber|${direction.name}|$index';

  /// Whether the port delivers MIDI into the app.
  bool get isInput => direction == MidiDirection.input;

  /// Whether the port carries MIDI out of the app.
  bool get isOutput => direction == MidiDirection.output;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiPortInfo &&
          other.id == id &&
          other.deviceId == deviceId &&
          other.name == name &&
          other.manufacturer == manufacturer &&
          other.direction == direction &&
          other.index == index &&
          other.transport == transport &&
          other.protocol == protocol &&
          other.state == state &&
          other.isVirtual == isVirtual &&
          other.isOwn == isOwn &&
          other.group == group &&
          other.groups.equals(groups) &&
          other.functionBlocks.equals(functionBlocks) &&
          other.endpoint == endpoint &&
          other.capabilities == capabilities &&
          other.serialNumber == serialNumber;

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    name,
    manufacturer,
    direction,
    index,
    transport,
    protocol,
    state,
    isVirtual,
    isOwn,
    group,
    Object.hashAll(groups),
    Object.hashAll(functionBlocks),
    endpoint,
    capabilities,
    serialNumber,
  );

  @override
  String toString() =>
      "MidiPortInfo(id: $id, deviceId: $deviceId, name: '$name', "
      "manufacturer: '$manufacturer', direction: ${direction.name}, "
      'index: $index, transport: ${transport.name}, '
      'protocol: ${protocol.name}, state: ${state.name}, '
      'isVirtual: $isVirtual, isOwn: $isOwn, group: $group, '
      'groups: $groups, functionBlocks: $functionBlocks, '
      'endpoint: $endpoint, capabilities: $capabilities, '
      "serialNumber: '$serialNumber', native: $native)";
}
