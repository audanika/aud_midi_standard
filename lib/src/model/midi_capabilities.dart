// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_json_reader.dart';
import 'midi_network_support.dart';
import 'midi_permission.dart';
import 'midi_scheduling_support.dart';
import 'midi_virtual_port_support.dart';

// #############################################################################
/// What a backend can do on the current platform.
///
/// Every backend reports one instance. The flags of single ports are in
/// `MidiPortCapabilities`.
final class MidiCapabilities {
  /// Creates the capabilities of a backend from copies of [network] and
  /// [missingPermissions].
  ///
  /// Without arguments it equals [MidiCapabilities.none].
  MidiCapabilities({
    this.virtualPorts = MidiVirtualPortSupport.none,
    this.bleScan = false,
    this.blePeripheral = false,
    Set<MidiNetworkSupport> network = const {},
    this.ump = false,
    this.scheduling = MidiSchedulingSupport.software,
    Set<MidiPermission> missingPermissions = const {},
  }) : network = Set.unmodifiable(network),
       missingPermissions = Set.unmodifiable(missingPermissions);

  // ...........................................................................
  /// Creates the capabilities of a backend that supports nothing beyond
  /// plain ports, scheduled in software.
  const MidiCapabilities.none()
    : virtualPorts = MidiVirtualPortSupport.none,
      bleScan = false,
      blePeripheral = false,
      network = const {},
      ump = false,
      scheduling = MidiSchedulingSupport.software,
      missingPermissions = const {};

  /// Decodes capabilities that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type.
  factory MidiCapabilities.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiCapabilities');
    return MidiCapabilities(
      virtualPorts: reader.enumValue(
        'virtualPorts',
        MidiVirtualPortSupport.values,
      ),
      bleScan: reader.value<bool>('bleScan'),
      blePeripheral: reader.value<bool>('blePeripheral'),
      network: reader.enumSet('network', MidiNetworkSupport.values),
      ump: reader.value<bool>('ump'),
      scheduling: reader.enumValue('scheduling', MidiSchedulingSupport.values),
      missingPermissions: reader.enumSet(
        'missingPermissions',
        MidiPermission.values,
      ),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiCapabilities copyWith({
    MidiVirtualPortSupport? virtualPorts,
    bool? bleScan,
    bool? blePeripheral,
    Set<MidiNetworkSupport>? network,
    bool? ump,
    MidiSchedulingSupport? scheduling,
    Set<MidiPermission>? missingPermissions,
  }) => MidiCapabilities(
    virtualPorts: virtualPorts ?? this.virtualPorts,
    bleScan: bleScan ?? this.bleScan,
    blePeripheral: blePeripheral ?? this.blePeripheral,
    network: network ?? this.network,
    ump: ump ?? this.ump,
    scheduling: scheduling ?? this.scheduling,
    missingPermissions: missingPermissions ?? this.missingPermissions,
  );

  /// Returns the capabilities as a JSON map; sets become lists of names in
  /// declaration order.
  Map<String, Object?> toJson() => {
    'virtualPorts': virtualPorts.name,
    'bleScan': bleScan,
    'blePeripheral': blePeripheral,
    'network': _names(MidiNetworkSupport.values, network),
    'ump': ump,
    'scheduling': scheduling.name,
    'missingPermissions': _names(MidiPermission.values, missingPermissions),
  };

  // ...........................................................................
  /// Whether the backend creates virtual ports at runtime, only declares
  /// them statically, or has none.
  final MidiVirtualPortSupport virtualPorts;

  /// Whether the backend scans for and connects to BLE-MIDI peripherals.
  final bool bleScan;

  /// Whether the backend can advertise the device as a BLE-MIDI peripheral.
  final bool blePeripheral;

  /// The network MIDI flavours the backend provides; cannot be modified.
  final Set<MidiNetworkSupport> network;

  /// Whether the backend exchanges Universal MIDI Packets with the
  /// operating system.
  final bool ump;

  /// Who honours the due time of messages sent for a later time.
  final MidiSchedulingSupport scheduling;

  /// The permissions the app still needs for all capabilities; cannot be
  /// modified.
  final Set<MidiPermission> missingPermissions;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiCapabilities &&
          other.virtualPorts == virtualPorts &&
          other.bleScan == bleScan &&
          other.blePeripheral == blePeripheral &&
          other.network.length == network.length &&
          other.network.containsAll(network) &&
          other.ump == ump &&
          other.scheduling == scheduling &&
          other.missingPermissions.length == missingPermissions.length &&
          other.missingPermissions.containsAll(missingPermissions);

  @override
  int get hashCode => Object.hash(
    virtualPorts,
    bleScan,
    blePeripheral,
    Object.hashAllUnordered(network),
    ump,
    scheduling,
    Object.hashAllUnordered(missingPermissions),
  );

  @override
  String toString() =>
      'MidiCapabilities(virtualPorts: ${virtualPorts.name}, '
      'bleScan: $bleScan, blePeripheral: $blePeripheral, '
      'network: ${_names(MidiNetworkSupport.values, network)}, ump: $ump, '
      'scheduling: ${scheduling.name}, missingPermissions: '
      '${_names(MidiPermission.values, missingPermissions)})';

  // ...........................................................................
  /// Returns the names of the [values] that [set] contains, in declaration
  /// order.
  static List<String> _names(List<Enum> values, Set<Enum> set) => [
    for (final value in values)
      if (set.contains(value)) value.name,
  ];
}
