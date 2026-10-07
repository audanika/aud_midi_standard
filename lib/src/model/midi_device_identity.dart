// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_json_reader.dart';
import 'midi_list_equality.dart';

// #############################################################################
/// The identity of a device as the MIDI 1.0 Device Inquiry reply and the
/// Device Identity Notification report it (M2-104-UM 7.1.3).
final class MidiDeviceIdentity {
  /// Creates an identity from copies of the byte lists.
  ///
  /// - [manufacturerId] the three manufacturer SysEx id bytes; one-byte ids
  ///   are followed by two zeros.
  /// - [familyId] the 14-bit device family.
  /// - [modelId] the 14-bit device family model number.
  /// - [softwareRevision] the four software revision bytes.
  MidiDeviceIdentity({
    required List<int> manufacturerId,
    required this.familyId,
    required this.modelId,
    required List<int> softwareRevision,
  }) : assert(manufacturerId.length == 3),
       assert(softwareRevision.length == 4),
       manufacturerId = List.unmodifiable(manufacturerId),
       softwareRevision = List.unmodifiable(softwareRevision);

  // ...........................................................................
  /// Decodes an identity that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type.
  factory MidiDeviceIdentity.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiDeviceIdentity');
    return MidiDeviceIdentity(
      manufacturerId: reader.list<int>('manufacturerId'),
      familyId: reader.value<int>('familyId'),
      modelId: reader.value<int>('modelId'),
      softwareRevision: reader.list<int>('softwareRevision'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiDeviceIdentity copyWith({
    List<int>? manufacturerId,
    int? familyId,
    int? modelId,
    List<int>? softwareRevision,
  }) => MidiDeviceIdentity(
    manufacturerId: manufacturerId ?? this.manufacturerId,
    familyId: familyId ?? this.familyId,
    modelId: modelId ?? this.modelId,
    softwareRevision: softwareRevision ?? this.softwareRevision,
  );

  /// Returns the identity as a JSON map.
  Map<String, Object?> toJson() => {
    'manufacturerId': [...manufacturerId],
    'familyId': familyId,
    'modelId': modelId,
    'softwareRevision': [...softwareRevision],
  };

  // ...........................................................................
  /// The three manufacturer SysEx id bytes; cannot be modified.
  final List<int> manufacturerId;

  /// The 14-bit device family.
  final int familyId;

  /// The 14-bit device family model number.
  final int modelId;

  /// The four software revision bytes; cannot be modified.
  final List<int> softwareRevision;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiDeviceIdentity &&
          other.manufacturerId.equals(manufacturerId) &&
          other.familyId == familyId &&
          other.modelId == modelId &&
          other.softwareRevision.equals(softwareRevision);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(manufacturerId),
    familyId,
    modelId,
    Object.hashAll(softwareRevision),
  );

  @override
  String toString() =>
      'MidiDeviceIdentity(manufacturerId: $manufacturerId, '
      'familyId: $familyId, modelId: $modelId, '
      'softwareRevision: $softwareRevision)';
}
