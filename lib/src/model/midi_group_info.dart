// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_json_reader.dart';

// #############################################################################
/// A UMP group of a port: one of the 16 groups of 16 channels each that a
/// Universal MIDI Packet stream carries (M2-104-UM 2.1.2).
final class MidiGroupInfo {
  /// Creates the description of [group].
  ///
  /// - [group] the group, 0 to 15.
  /// - [name] the name of the group, empty when unknown.
  /// - [isActive] whether the group currently carries messages.
  const MidiGroupInfo({
    required this.group,
    this.name = '',
    this.isActive = true,
  }) : assert(group >= 0 && group <= 15);

  // ...........................................................................
  /// Decodes a group that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type.
  factory MidiGroupInfo.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiGroupInfo');
    return MidiGroupInfo(
      group: reader.value<int>('group'),
      name: reader.value<String>('name'),
      isActive: reader.value<bool>('isActive'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiGroupInfo copyWith({int? group, String? name, bool? isActive}) =>
      MidiGroupInfo(
        group: group ?? this.group,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
      );

  /// Returns the group as a JSON map.
  Map<String, Object?> toJson() => {
    'group': group,
    'name': name,
    'isActive': isActive,
  };

  // ...........................................................................
  /// The group, 0 to 15.
  final int group;

  /// The name of the group, empty when unknown.
  final String name;

  /// Whether the group currently carries messages.
  final bool isActive;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiGroupInfo &&
          other.group == group &&
          other.name == name &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(group, name, isActive);

  @override
  String toString() =>
      "MidiGroupInfo(group: $group, name: '$name', isActive: $isActive)";
}
