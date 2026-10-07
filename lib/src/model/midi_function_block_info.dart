// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../message/midi_message.dart';
import '../midi2/midi_function_block_direction.dart';
import '../midi2/midi_function_block_midi1.dart';
import '../midi2/midi_function_block_ui_hint.dart';
import 'midi_json_reader.dart';

// #############################################################################
/// A function block of a UMP endpoint: a named range of groups with one
/// purpose, e.g. a synthesizer part or a MIDI 1.0 DIN port
/// (M2-104-UM 6 and 7.1.8).
final class MidiFunctionBlockInfo {
  /// Creates the description of the function block [number].
  const MidiFunctionBlockInfo({
    required this.number,
    this.name = '',
    this.isActive = true,
    required this.direction,
    required this.firstGroup,
    required this.groupCount,
    this.midi1 = MidiFunctionBlockMidi1.notMidi1,
    this.uiHint = MidiFunctionBlockUiHint.unknown,
    this.midiCiVersion = 0,
    this.maxSysEx8Streams = 0,
  }) : assert(firstGroup >= 0 && firstGroup <= 15),
       assert(groupCount >= 0 && groupCount <= 16);

  // ...........................................................................
  /// Creates the description of the block that [notification] announces.
  ///
  /// - [notification] a Function Block Info Notification.
  /// - [name] the name from the matching Function Block Name Notification,
  ///   empty when not known yet.
  factory MidiFunctionBlockInfo.fromNotification(
    MidiFunctionBlockInfoNotification notification, {
    String name = '',
  }) => MidiFunctionBlockInfo(
    number: notification.functionBlock,
    name: name,
    isActive: notification.active,
    direction: notification.direction,
    firstGroup: notification.firstGroup,
    groupCount: notification.numberOfGroups,
    midi1: notification.midi1,
    uiHint: notification.uiHint,
    midiCiVersion: notification.midiCiVersion,
    maxSysEx8Streams: notification.maxSysEx8Streams,
  );

  /// Decodes a function block that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type.
  factory MidiFunctionBlockInfo.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiFunctionBlockInfo');
    return MidiFunctionBlockInfo(
      number: reader.value<int>('number'),
      name: reader.value<String>('name'),
      isActive: reader.value<bool>('isActive'),
      direction: reader.enumValue(
        'direction',
        MidiFunctionBlockDirection.values,
      ),
      firstGroup: reader.value<int>('firstGroup'),
      groupCount: reader.value<int>('groupCount'),
      midi1: reader.enumValue('midi1', MidiFunctionBlockMidi1.values),
      uiHint: reader.enumValue('uiHint', MidiFunctionBlockUiHint.values),
      midiCiVersion: reader.value<int>('midiCiVersion'),
      maxSysEx8Streams: reader.value<int>('maxSysEx8Streams'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiFunctionBlockInfo copyWith({
    int? number,
    String? name,
    bool? isActive,
    MidiFunctionBlockDirection? direction,
    int? firstGroup,
    int? groupCount,
    MidiFunctionBlockMidi1? midi1,
    MidiFunctionBlockUiHint? uiHint,
    int? midiCiVersion,
    int? maxSysEx8Streams,
  }) => MidiFunctionBlockInfo(
    number: number ?? this.number,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    direction: direction ?? this.direction,
    firstGroup: firstGroup ?? this.firstGroup,
    groupCount: groupCount ?? this.groupCount,
    midi1: midi1 ?? this.midi1,
    uiHint: uiHint ?? this.uiHint,
    midiCiVersion: midiCiVersion ?? this.midiCiVersion,
    maxSysEx8Streams: maxSysEx8Streams ?? this.maxSysEx8Streams,
  );

  /// Returns the function block as a JSON map.
  Map<String, Object?> toJson() => {
    'number': number,
    'name': name,
    'isActive': isActive,
    'direction': direction.name,
    'firstGroup': firstGroup,
    'groupCount': groupCount,
    'midi1': midi1.name,
    'uiHint': uiHint.name,
    'midiCiVersion': midiCiVersion,
    'maxSysEx8Streams': maxSysEx8Streams,
  };

  // ...........................................................................
  /// The number of the block, 0 to 31.
  final int number;

  /// The name of the block, empty when unknown.
  final String name;

  /// Whether the block is active.
  final bool isActive;

  /// The direction of the block, seen from the block.
  final MidiFunctionBlockDirection direction;

  /// The first group the block spans, 0 to 15.
  final int firstGroup;

  /// The number of groups the block spans, 1 to 16.
  final int groupCount;

  /// Whether the block is a MIDI 1.0 port and how fast it may be driven.
  final MidiFunctionBlockMidi1 midi1;

  /// How a user interface should present the block.
  final MidiFunctionBlockUiHint uiHint;

  /// The MIDI-CI message version the block supports, 0 for none.
  final int midiCiVersion;

  /// The maximum number of simultaneous System Exclusive 8 streams.
  final int maxSysEx8Streams;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiFunctionBlockInfo &&
          other.number == number &&
          other.name == name &&
          other.isActive == isActive &&
          other.direction == direction &&
          other.firstGroup == firstGroup &&
          other.groupCount == groupCount &&
          other.midi1 == midi1 &&
          other.uiHint == uiHint &&
          other.midiCiVersion == midiCiVersion &&
          other.maxSysEx8Streams == maxSysEx8Streams;

  @override
  int get hashCode => Object.hash(
    number,
    name,
    isActive,
    direction,
    firstGroup,
    groupCount,
    midi1,
    uiHint,
    midiCiVersion,
    maxSysEx8Streams,
  );

  @override
  String toString() =>
      "MidiFunctionBlockInfo(number: $number, name: '$name', "
      'isActive: $isActive, direction: ${direction.name}, '
      'firstGroup: $firstGroup, groupCount: $groupCount, '
      'midi1: ${midi1.name}, uiHint: ${uiHint.name}, '
      'midiCiVersion: $midiCiVersion, maxSysEx8Streams: $maxSysEx8Streams)';
}
