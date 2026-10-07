// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../codec/ump_decoder.dart';
import '../message/midi_message.dart';
import 'midi_json_reader.dart';
import 'midi_port_id.dart';
import 'midi_time.dart';

// #############################################################################
/// A message together with the port, the group and the time it was
/// received at or is due.
///
/// The JSON form stores the message as its Universal MIDI Packets in the
/// key `ump`.
final class MidiEvent {
  /// Creates an event of [message] at [time].
  ///
  /// - [port] the port of the event, null when it concerns no port.
  /// - [group] the group 0 to 15, null for groupless messages.
  /// - [senderTime] the 16-bit JR timestamp of the sender in units of
  ///   1/31250 second, null when the sender sent none.
  const MidiEvent({
    required this.message,
    required this.time,
    this.port,
    this.group,
    this.senderTime,
  }) : assert(group == null || group >= 0 && group <= 15),
       assert(senderTime == null || senderTime >= 0 && senderTime <= 0xFFFF);

  // ...........................................................................
  /// Decodes an event that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type, or when `ump` holds no complete message; `port`, `group` and
  /// `senderTime` may be missing.
  factory MidiEvent.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiEvent');
    final time = reader.value<MidiTime>('time');
    final port = reader.value<MidiPortId?>('port');
    final group = reader.value<int?>('group');
    final senderTime = reader.value<int?>('senderTime');
    return MidiEvent(
      message: _decode(reader.list<int>('ump'), json),
      time: time,
      port: port,
      group: group,
      senderTime: senderTime,
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  ///
  /// - [clearPort] sets [port] to null; it wins over a given port.
  /// - [clearGroup] sets [group] to null; it wins over a given group.
  /// - [clearSenderTime] sets [senderTime] to null; it wins over a given
  ///   time.
  MidiEvent copyWith({
    MidiMessage? message,
    MidiTime? time,
    MidiPortId? port,
    bool clearPort = false,
    int? group,
    bool clearGroup = false,
    int? senderTime,
    bool clearSenderTime = false,
  }) => MidiEvent(
    message: message ?? this.message,
    time: time ?? this.time,
    port: clearPort ? null : port ?? this.port,
    group: clearGroup ? null : group ?? this.group,
    senderTime: clearSenderTime ? null : senderTime ?? this.senderTime,
  );

  /// Returns the event as a JSON map: the message as the words of its
  /// Universal MIDI Packets addressed to [group] or group 0, the time in
  /// microseconds.
  Map<String, Object?> toJson() => {
    'ump': [for (final ump in message.toUmp(group: group ?? 0)) ...ump.words],
    'group': group,
    'time': time.microseconds,
    'port': port?.value,
    'senderTime': senderTime,
  };

  // ...........................................................................
  /// The message.
  final MidiMessage message;

  /// The time on the package clock the message was received at or is due.
  final MidiTime time;

  /// The port of the event, or null when it concerns no port.
  final MidiPortId? port;

  /// The group 0 to 15, or null for groupless messages.
  final int? group;

  /// The 16-bit JR timestamp of the sender in units of 1/31250 second, or
  /// null when the sender sent none.
  final int? senderTime;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiEvent &&
          other.message == message &&
          other.time == time &&
          other.port == port &&
          other.group == group &&
          other.senderTime == senderTime;

  @override
  int get hashCode => Object.hash(message, time, port, group, senderTime);

  @override
  String toString() =>
      'MidiEvent(message: $message, time: ${time.microseconds}, '
      'port: $port, group: $group, senderTime: $senderTime)';

  // ...........................................................................
  /// Returns the first message decoded from [words]; throws a
  /// [FormatException] with [json] as source when there is none.
  ///
  /// The size limit grows with [words], four data bytes per word at most,
  /// so System Exclusive messages of any length decode.
  static MidiMessage _decode(List<int> words, Map<String, Object?> json) {
    final decoded = UmpDecoder(maxSysExLength: words.length * 4).add(words);
    if (decoded.isEmpty) {
      throw FormatException('MidiEvent: "ump" holds no complete message', json);
    }
    return decoded.first.message;
  }
}
