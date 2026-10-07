// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:typed_data';

import '../codec/midi_byte_encoder.dart';
import '../codec/midi_translator_1_to_2.dart';
import '../codec/midi_translator_2_to_1.dart';
import '../codec/ump_encoder.dart';
import '../midi2/midi_function_block_direction.dart';
import '../midi2/midi_function_block_midi1.dart';
import '../midi2/midi_function_block_ui_hint.dart';
import '../midi2/ump_message_type.dart';
import '../model/midi_protocol.dart';
import '../raw/midi_bytes.dart';
import '../raw/ump.dart';

part 'midi_channel_voice1_messages.dart';
part 'midi_channel_voice2_messages.dart';
part 'midi_data_messages.dart';
part 'midi_flex_data_messages.dart';
part 'midi_stream_messages.dart';
part 'midi_system_messages.dart';
part 'midi_unknown_message.dart';
part 'midi_utility_messages.dart';

// #############################################################################
/// The base of every message of the MIDI 1.0 and the MIDI 2.0 protocol.
///
/// Messages are immutable values. They carry neither group, port nor time;
/// an event adds those. Every message has a UMP form ([toUmp]); only MIDI
/// 1.0 messages have a byte form ([toBytes]). Conversions are always
/// explicit and follow M2-104-UM, the UMP Format and MIDI 2.0 Protocol
/// specification v1.1.1.
///
/// Channels are 0-based (0 to 15). Values outside the documented ranges
/// fail an assertion in debug builds; encoders keep only the bits of each
/// field.
sealed class MidiMessage {
  /// Creates a message.
  const MidiMessage();

  // ...........................................................................
  /// Encodes this message as Universal MIDI Packets addressed to [group].
  ///
  /// Groupless messages (utility and UMP stream messages) ignore [group].
  /// Long System Exclusive messages and texts span several packets.
  List<Ump> toUmp({int group = 0}) => UmpEncoder.encode(this, group: group);

  // ...........................................................................
  /// Encodes this message as a MIDI 1.0 byte stream, or returns null when
  /// the message has no MIDI 1.0 byte form.
  ///
  /// MIDI 2.0 messages need [toMidi1] first.
  MidiBytes? toBytes() => MidiByteEncoder.encode(this);

  // ...........................................................................
  /// Translates this message to the MIDI 1.0 protocol (M2-104-UM D.2).
  ///
  /// Messages valid in both protocols return themselves, MIDI 2.0 channel
  /// voice messages their translation, and messages without a MIDI 1.0
  /// equivalent an empty list.
  List<MidiMessage> toMidi1() => MidiTranslator2To1().translate(this);

  // ...........................................................................
  /// Translates this message to the MIDI 2.0 protocol without context
  /// (M2-104-UM D.3).
  ///
  /// Bank Select, RPN, NRPN and Data Entry control changes only translate
  /// together with the messages around them; translate streams with a
  /// [MidiTranslator1To2] that keeps this context.
  List<MidiMessage> toMidi2() => MidiTranslator1To2().translate(this);

  // ...........................................................................
  /// The UMP message type that carries this message.
  UmpMessageType get umpMessageType;

  // ...........................................................................
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MidiMessage || other.runtimeType != runtimeType) {
      return false;
    }
    final mine = _fields.values.toList();
    final theirs = other._fields.values.toList();
    for (var i = 0; i < mine.length; i++) {
      if (!_valueEquals(mine[i], theirs[i])) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, Object.hashAll(_fields.values.map(_valueHash)));

  @override
  String toString() {
    final fields = _fields.entries
        .map((e) => '${e.key}: ${_valueString(e.value)}')
        .join(', ');
    return '$runtimeType($fields)';
  }

  // ...........................................................................
  /// The values that identify this message, in declaration order; they
  /// define equality, hash code and string form.
  Map<String, Object?> get _fields;
}

// .............................................................................
/// Compares two field values; lists compare element by element.
bool _valueEquals(Object? a, Object? b) {
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_valueEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

// .............................................................................
/// Returns a hash for a field value; lists hash their elements.
int _valueHash(Object? value) =>
    value is List ? Object.hashAll(value.map(_valueHash)) : value.hashCode;

// .............................................................................
/// Returns the string form of a field value; byte lists print as hex.
String _valueString(Object? value) => switch (value) {
  Uint8List() => '[${value.map(_hex).join(' ')}]',
  String() => "'$value'",
  _ => '$value',
};

// .............................................................................
/// Returns the byte [value] as two lower-case hex digits.
String _hex(int value) => value.toRadixString(16).padLeft(2, '0');

// .............................................................................
/// Returns an unmodifiable byte copy of [bytes].
Uint8List _bytes(Iterable<int> bytes) =>
    Uint8List.fromList(bytes.toList()).asUnmodifiableView();
