// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_ble_peripheral_state.dart';
import 'midi_json_reader.dart';
import 'midi_list_equality.dart';
import 'midi_port_id.dart';

// #############################################################################
/// A Bluetooth Low Energy peripheral that offers the BLE-MIDI service, as a
/// scan finds it.
final class MidiBlePeripheralInfo {
  /// Creates the description of a peripheral from a copy of [portIds].
  ///
  /// - [id] the identifier of the platform: an address or a UUID.
  /// - [rssi] the received signal strength in dBm, null when unknown.
  MidiBlePeripheralInfo({
    required this.id,
    this.name = '',
    this.rssi,
    this.isConnectable = true,
    this.state = MidiBlePeripheralState.advertising,
    List<MidiPortId> portIds = const [],
  }) : portIds = List.unmodifiable(portIds);

  // ...........................................................................
  /// Decodes a peripheral that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type; `rssi` may be missing.
  factory MidiBlePeripheralInfo.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiBlePeripheralInfo');
    return MidiBlePeripheralInfo(
      id: reader.value<String>('id'),
      name: reader.value<String>('name'),
      rssi: reader.value<int?>('rssi'),
      isConnectable: reader.value<bool>('isConnectable'),
      state: reader.enumValue('state', MidiBlePeripheralState.values),
      portIds: reader.list<MidiPortId>('portIds'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  ///
  /// - [clearRssi] sets [rssi] to null; it wins over a given value.
  MidiBlePeripheralInfo copyWith({
    String? id,
    String? name,
    int? rssi,
    bool clearRssi = false,
    bool? isConnectable,
    MidiBlePeripheralState? state,
    List<MidiPortId>? portIds,
  }) => MidiBlePeripheralInfo(
    id: id ?? this.id,
    name: name ?? this.name,
    rssi: clearRssi ? null : rssi ?? this.rssi,
    isConnectable: isConnectable ?? this.isConnectable,
    state: state ?? this.state,
    portIds: portIds ?? this.portIds,
  );

  /// Returns the peripheral as a JSON map.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'rssi': rssi,
    'isConnectable': isConnectable,
    'state': state.name,
    'portIds': [for (final portId in portIds) portId.value],
  };

  // ...........................................................................
  /// The identifier of the platform: an address or a UUID.
  final String id;

  /// The advertised name, empty when the peripheral sends none.
  final String name;

  /// The received signal strength in dBm, or null when unknown.
  final int? rssi;

  /// Whether the peripheral accepts connections.
  final bool isConnectable;

  /// The connection state of the peripheral.
  final MidiBlePeripheralState state;

  /// The ids of the ports of the connected peripheral; empty before the
  /// connection; cannot be modified.
  final List<MidiPortId> portIds;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiBlePeripheralInfo &&
          other.id == id &&
          other.name == name &&
          other.rssi == rssi &&
          other.isConnectable == isConnectable &&
          other.state == state &&
          other.portIds.equals(portIds);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    rssi,
    isConnectable,
    state,
    Object.hashAll(portIds),
  );

  @override
  String toString() =>
      "MidiBlePeripheralInfo(id: '$id', name: '$name', rssi: $rssi, "
      'isConnectable: $isConnectable, state: ${state.name}, '
      'portIds: $portIds)';
}
