// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:typed_data';

import '../raw/midi_bytes.dart';
import '../raw/ump.dart';
import 'midi_json_reader.dart';
import 'midi_list_equality.dart';
import 'midi_time.dart';

// #############################################################################
/// Raw MIDI as a port delivers or takes it: MIDI 1.0 bytes or Universal
/// MIDI Packets, with a time.
///
/// The JSON form names the raw form in its `type` key: `bytes` or `ump`.
sealed class MidiPacket {
  /// Creates a packet received or due at [time].
  const MidiPacket({required this.time});

  // ...........................................................................
  /// Decodes a packet that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing, has the wrong type
  /// or `type` names no known packet.
  factory MidiPacket.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiPacket');
    final type = reader.oneOf('type', const ['bytes', 'ump']);
    final time = reader.value<MidiTime>('time');
    return switch (type) {
      'bytes' => MidiBytesPacket(
        bytes: MidiBytes(reader.list<int>('bytes')),
        time: time,
      ),
      _ => MidiUmpPacket(words: reader.list<int>('words'), time: time),
    };
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiPacket copyWith({MidiTime? time});

  /// Returns the packet as a JSON map; the time in microseconds.
  Map<String, Object?> toJson();

  // ...........................................................................
  /// The time on the package clock the packet was received at or is due.
  final MidiTime time;
}

// #############################################################################
/// A chunk of a MIDI 1.0 byte stream with its time.
final class MidiBytesPacket extends MidiPacket {
  /// Creates a packet of [bytes] received or due at [time].
  const MidiBytesPacket({required this.bytes, required super.time});

  // ...........................................................................
  @override
  MidiBytesPacket copyWith({MidiBytes? bytes, MidiTime? time}) =>
      MidiBytesPacket(bytes: bytes ?? this.bytes, time: time ?? this.time);

  @override
  Map<String, Object?> toJson() => {
    'type': 'bytes',
    'bytes': [...bytes.bytes],
    'time': time.microseconds,
  };

  // ...........................................................................
  /// The bytes of the packet.
  final MidiBytes bytes;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiBytesPacket && other.bytes == bytes && other.time == time;

  @override
  int get hashCode => Object.hash(MidiBytesPacket, bytes, time);

  @override
  String toString() =>
      'MidiBytesPacket(bytes: ${bytes.toHex()}, time: ${time.microseconds})';
}

// #############################################################################
/// A sequence of complete Universal MIDI Packets with their time.
final class MidiUmpPacket extends MidiPacket {
  /// Creates a packet from a copy of [words] received or due at [time]; each
  /// value keeps its low 32 bits.
  ///
  /// The words must form complete packets, see [umps].
  MidiUmpPacket({required Iterable<int> words, required super.time})
    : words = Uint32List.fromList(words.toList()).asUnmodifiableView();

  // ...........................................................................
  @override
  MidiUmpPacket copyWith({Iterable<int>? words, MidiTime? time}) =>
      MidiUmpPacket(words: words ?? this.words, time: time ?? this.time);

  @override
  Map<String, Object?> toJson() => {
    'type': 'ump',
    'words': [...words],
    'time': time.microseconds,
  };

  // ...........................................................................
  /// The 32-bit words of the packets; cannot be modified.
  final Uint32List words;

  /// Returns the words split into packets.
  ///
  /// Throws an [ArgumentError] when the last packet is incomplete.
  List<Ump> get umps => Ump.split(words);

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiUmpPacket && other.words.equals(words) && other.time == time;

  @override
  int get hashCode => Object.hash(MidiUmpPacket, Object.hashAll(words), time);

  @override
  String toString() {
    final hex = words.map((w) => w.toRadixString(16).padLeft(8, '0'));
    return 'MidiUmpPacket(words: ${hex.join(' ')}, '
        'time: ${time.microseconds})';
  }
}
