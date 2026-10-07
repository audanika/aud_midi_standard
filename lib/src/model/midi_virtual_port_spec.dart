// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_direction.dart';
import 'midi_json_reader.dart';
import 'midi_list_equality.dart';
import 'midi_protocol.dart';

// #############################################################################
/// The request for a virtual port that other apps can see.
///
/// The result is a port whose `isOwn` flag is set. On platforms with static
/// virtual ports, e.g. the Android manifest, the spec only describes the
/// declared port.
final class MidiVirtualPortSpec {
  /// Creates the request for a virtual port from a copy of [groups].
  ///
  /// - [direction] [MidiDirection.input] creates a destination other apps
  ///   send to, [MidiDirection.output] a source the app sends from.
  /// - [uniqueId] the id the port keeps across launches where the platform
  ///   supports it, e.g. a CoreMIDI unique id; null lets the system choose.
  /// - [groups] the groups 0 to 15 a UMP port spans; empty for the default
  ///   of the backend.
  MidiVirtualPortSpec({
    required this.name,
    required this.direction,
    this.protocol = MidiProtocol.midi1,
    this.uniqueId,
    List<int> groups = const [],
    this.manufacturer = '',
    this.model = '',
  }) : assert(groups.every((group) => group >= 0 && group <= 15)),
       groups = List.unmodifiable(groups);

  // ...........................................................................
  /// Decodes a spec that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type; `uniqueId` may be missing.
  factory MidiVirtualPortSpec.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiVirtualPortSpec');
    return MidiVirtualPortSpec(
      name: reader.value<String>('name'),
      direction: reader.enumValue('direction', MidiDirection.values),
      protocol: reader.enumValue('protocol', MidiProtocol.values),
      uniqueId: reader.value<int?>('uniqueId'),
      groups: reader.list<int>('groups'),
      manufacturer: reader.value<String>('manufacturer'),
      model: reader.value<String>('model'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  ///
  /// - [clearUniqueId] sets [uniqueId] to null; it wins over a given id.
  MidiVirtualPortSpec copyWith({
    String? name,
    MidiDirection? direction,
    MidiProtocol? protocol,
    int? uniqueId,
    bool clearUniqueId = false,
    List<int>? groups,
    String? manufacturer,
    String? model,
  }) => MidiVirtualPortSpec(
    name: name ?? this.name,
    direction: direction ?? this.direction,
    protocol: protocol ?? this.protocol,
    uniqueId: clearUniqueId ? null : uniqueId ?? this.uniqueId,
    groups: groups ?? this.groups,
    manufacturer: manufacturer ?? this.manufacturer,
    model: model ?? this.model,
  );

  /// Returns the spec as a JSON map.
  Map<String, Object?> toJson() => {
    'name': name,
    'direction': direction.name,
    'protocol': protocol.name,
    'uniqueId': uniqueId,
    'groups': [...groups],
    'manufacturer': manufacturer,
    'model': model,
  };

  // ...........................................................................
  /// The name other apps see.
  final String name;

  /// [MidiDirection.input] for a destination other apps send to,
  /// [MidiDirection.output] for a source the app sends from.
  final MidiDirection direction;

  /// The protocol of the port.
  final MidiProtocol protocol;

  /// The id the port keeps across launches, or null to let the system
  /// choose.
  final int? uniqueId;

  /// The groups a UMP port spans; empty for the default of the backend;
  /// cannot be modified.
  final List<int> groups;

  /// The manufacturer other apps see where the platform shows one.
  final String manufacturer;

  /// The model other apps see where the platform shows one.
  final String model;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiVirtualPortSpec &&
          other.name == name &&
          other.direction == direction &&
          other.protocol == protocol &&
          other.uniqueId == uniqueId &&
          other.groups.equals(groups) &&
          other.manufacturer == manufacturer &&
          other.model == model;

  @override
  int get hashCode => Object.hash(
    name,
    direction,
    protocol,
    uniqueId,
    Object.hashAll(groups),
    manufacturer,
    model,
  );

  @override
  String toString() =>
      "MidiVirtualPortSpec(name: '$name', direction: ${direction.name}, "
      'protocol: ${protocol.name}, uniqueId: $uniqueId, groups: $groups, '
      "manufacturer: '$manufacturer', model: '$model')";
}
