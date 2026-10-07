// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_device_id.dart';
import 'midi_json_reader.dart';
import 'midi_list_equality.dart';
import 'midi_port_id.dart';
import 'midi_transport.dart';

// #############################################################################
/// A MIDI device: the grouping of ports the operating system reports, e.g.
/// a CoreMIDI device or an Android `MidiDeviceInfo`.
///
/// Ports are the primary entity of the package; a device only groups them.
/// Backends without devices report a synthetic device per port.
final class MidiDeviceInfo {
  /// Creates the description of a device from copies of [ports] and
  /// [native].
  ///
  /// - [native] backend-specific extras with JSON-compatible values only.
  MidiDeviceInfo({
    required this.id,
    required this.name,
    this.manufacturer = '',
    this.product = '',
    this.serialNumber = '',
    this.transport = MidiTransport.unknown,
    this.driver = '',
    this.isOffline = false,
    List<MidiPortId> ports = const [],
    Map<String, Object?> native = const {},
  }) : ports = List.unmodifiable(ports),
       native = Map.unmodifiable(native);

  // ...........................................................................
  /// Decodes a device that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type.
  factory MidiDeviceInfo.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiDeviceInfo');
    return MidiDeviceInfo(
      id: reader.value<MidiDeviceId>('id'),
      name: reader.value<String>('name'),
      manufacturer: reader.value<String>('manufacturer'),
      product: reader.value<String>('product'),
      serialNumber: reader.value<String>('serialNumber'),
      transport: reader.enumValue('transport', MidiTransport.values),
      driver: reader.value<String>('driver'),
      isOffline: reader.value<bool>('isOffline'),
      ports: reader.list<MidiPortId>('ports'),
      native: reader.value<Map<String, Object?>>('native'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiDeviceInfo copyWith({
    MidiDeviceId? id,
    String? name,
    String? manufacturer,
    String? product,
    String? serialNumber,
    MidiTransport? transport,
    String? driver,
    bool? isOffline,
    List<MidiPortId>? ports,
    Map<String, Object?>? native,
  }) => MidiDeviceInfo(
    id: id ?? this.id,
    name: name ?? this.name,
    manufacturer: manufacturer ?? this.manufacturer,
    product: product ?? this.product,
    serialNumber: serialNumber ?? this.serialNumber,
    transport: transport ?? this.transport,
    driver: driver ?? this.driver,
    isOffline: isOffline ?? this.isOffline,
    ports: ports ?? this.ports,
    native: native ?? this.native,
  );

  /// Returns the device as a JSON map.
  Map<String, Object?> toJson() => {
    'id': id.value,
    'name': name,
    'manufacturer': manufacturer,
    'product': product,
    'serialNumber': serialNumber,
    'transport': transport.name,
    'driver': driver,
    'isOffline': isOffline,
    'ports': [for (final port in ports) port.value],
    'native': {...native},
  };

  // ...........................................................................
  /// The id of the device, stable for the session.
  final MidiDeviceId id;

  /// The name of the device.
  final String name;

  /// The manufacturer of the device, empty when unknown.
  final String manufacturer;

  /// The product name of the device, empty when unknown.
  final String product;

  /// The serial number of the device, empty when unknown.
  final String serialNumber;

  /// How the operating system reaches the device.
  final MidiTransport transport;

  /// The driver or the app that owns the device, empty when unknown.
  final String driver;

  /// Whether the operating system lists the device but marks it offline.
  final bool isOffline;

  /// The ids of the ports of the device; cannot be modified.
  final List<MidiPortId> ports;

  /// Backend-specific extras with JSON-compatible values; cannot be
  /// modified and takes no part in equality.
  final Map<String, Object?> native;

  /// Identifies the device across sessions as far as the operating system
  /// allows: `'manufacturer|product|serialNumber'`.
  ///
  /// Equal fingerprints only mark re-plug candidates: identical devices
  /// without a serial number share one.
  String get fingerprint => '$manufacturer|$product|$serialNumber';

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiDeviceInfo &&
          other.id == id &&
          other.name == name &&
          other.manufacturer == manufacturer &&
          other.product == product &&
          other.serialNumber == serialNumber &&
          other.transport == transport &&
          other.driver == driver &&
          other.isOffline == isOffline &&
          other.ports.equals(ports);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    manufacturer,
    product,
    serialNumber,
    transport,
    driver,
    isOffline,
    Object.hashAll(ports),
  );

  @override
  String toString() =>
      "MidiDeviceInfo(id: $id, name: '$name', manufacturer: '$manufacturer', "
      "product: '$product', serialNumber: '$serialNumber', "
      "transport: ${transport.name}, driver: '$driver', "
      'isOffline: $isOffline, ports: $ports, native: $native)';
}
