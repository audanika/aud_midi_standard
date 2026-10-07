// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

part of 'midi_message.dart';

// #############################################################################
/// The base of the MIDI 2.0 channel voice messages, UMP message type 0x4
/// (M2-104-UM 7.4).
///
/// 32-bit values are unsigned, 0 to 0xFFFFFFFF, with 0x80000000 as center,
/// unless documented otherwise.
sealed class MidiChannelVoice2Message extends MidiMessage {
  /// Creates a channel voice message on [channel].
  const MidiChannelVoice2Message({required this.channel})
    : assert(channel >= 0 && channel <= 15);

  // ...........................................................................
  /// The center of unsigned 32-bit values.
  static const int center32 = 0x80000000;

  /// The largest unsigned 32-bit value.
  static const int max32 = 0xFFFFFFFF;

  // ...........................................................................
  /// The MIDI channel, 0 to 15.
  final int channel;

  @override
  UmpMessageType get umpMessageType => UmpMessageType.midi2ChannelVoice;
}

// #############################################################################
/// A MIDI 2.0 Note Off message, status 0x8 (M2-104-UM 7.4.1).
final class MidiNoteOff2 extends MidiChannelVoice2Message {
  /// Creates a Note Off of [note] with the 16-bit release [velocity] and an
  /// optional attribute.
  const MidiNoteOff2({
    required super.channel,
    required this.note,
    this.velocity = 0x8000,
    this.attributeType = 0,
    this.attribute = 0,
  }) : assert(note >= 0 && note <= 127),
       assert(velocity >= 0 && velocity <= 0xFFFF),
       assert(attributeType >= 0 && attributeType <= 0xFF),
       assert(attribute >= 0 && attribute <= 0xFFFF);

  // ...........................................................................
  /// The note number, 0 to 127.
  final int note;

  /// The 16-bit release velocity.
  final int velocity;

  /// The attribute type, 0 for none (M2-104-UM 7.4.14).
  final int attributeType;

  /// The 16-bit attribute data.
  final int attribute;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'note': note,
    'velocity': velocity,
    'attributeType': attributeType,
    'attribute': attribute,
  };
}

// #############################################################################
/// A MIDI 2.0 Note On message, status 0x9 (M2-104-UM 7.4.2).
///
/// Unlike MIDI 1.0, a velocity of 0 does not mean Note Off.
final class MidiNoteOn2 extends MidiChannelVoice2Message {
  /// Creates a Note On of [note] with the 16-bit [velocity] and an optional
  /// attribute.
  const MidiNoteOn2({
    required super.channel,
    required this.note,
    required this.velocity,
    this.attributeType = 0,
    this.attribute = 0,
  }) : assert(note >= 0 && note <= 127),
       assert(velocity >= 0 && velocity <= 0xFFFF),
       assert(attributeType >= 0 && attributeType <= 0xFF),
       assert(attribute >= 0 && attribute <= 0xFFFF);

  // ...........................................................................
  /// The note number, 0 to 127.
  final int note;

  /// The 16-bit velocity.
  final int velocity;

  /// The attribute type, 0 for none (M2-104-UM 7.4.14).
  final int attributeType;

  /// The 16-bit attribute data.
  final int attribute;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'note': note,
    'velocity': velocity,
    'attributeType': attributeType,
    'attribute': attribute,
  };
}

// #############################################################################
/// A MIDI 2.0 Poly Pressure message, status 0xA (M2-104-UM 7.4.3).
final class MidiPolyPressure2 extends MidiChannelVoice2Message {
  /// Creates a 32-bit key [pressure] for [note].
  const MidiPolyPressure2({
    required super.channel,
    required this.note,
    required this.pressure,
  }) : assert(note >= 0 && note <= 127),
       assert(pressure >= 0 && pressure <= 0xFFFFFFFF);

  // ...........................................................................
  /// The note number, 0 to 127.
  final int note;

  /// The 32-bit pressure.
  final int pressure;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'note': note,
    'pressure': pressure,
  };
}

// #############################################################################
/// A MIDI 2.0 Registered Per-Note Controller message, status 0x0
/// (M2-104-UM 7.4.4).
final class MidiRegisteredPerNoteController extends MidiChannelVoice2Message {
  /// Creates a change of the registered per-note controller [index] of
  /// [note] to the 32-bit [value].
  const MidiRegisteredPerNoteController({
    required super.channel,
    required this.note,
    required this.index,
    required this.value,
  }) : assert(note >= 0 && note <= 127),
       assert(index >= 0 && index <= 0xFF),
       assert(value >= 0 && value <= 0xFFFFFFFF);

  // ...........................................................................
  /// The note number, 0 to 127.
  final int note;

  /// The controller index, 0 to 255 (M2-104-UM Appendix A).
  final int index;

  /// The 32-bit value.
  final int value;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'note': note,
    'index': index,
    'value': value,
  };
}

// #############################################################################
/// A MIDI 2.0 Assignable Per-Note Controller message, status 0x1
/// (M2-104-UM 7.4.4).
final class MidiAssignablePerNoteController extends MidiChannelVoice2Message {
  /// Creates a change of the assignable per-note controller [index] of
  /// [note] to the 32-bit [value].
  const MidiAssignablePerNoteController({
    required super.channel,
    required this.note,
    required this.index,
    required this.value,
  }) : assert(note >= 0 && note <= 127),
       assert(index >= 0 && index <= 0xFF),
       assert(value >= 0 && value <= 0xFFFFFFFF);

  // ...........................................................................
  /// The note number, 0 to 127.
  final int note;

  /// The controller index, 0 to 255.
  final int index;

  /// The 32-bit value.
  final int value;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'note': note,
    'index': index,
    'value': value,
  };
}

// #############################################################################
/// A MIDI 2.0 Per-Note Management message, status 0xF (M2-104-UM 7.4.5).
final class MidiPerNoteManagement extends MidiChannelVoice2Message {
  /// Creates a management message for [note].
  const MidiPerNoteManagement({
    required super.channel,
    required this.note,
    this.detach = false,
    this.reset = false,
  }) : assert(note >= 0 && note <= 127);

  // ...........................................................................
  /// The note number, 0 to 127.
  final int note;

  /// Whether per-note controllers detach from previously received notes of
  /// this number (option flag D).
  final bool detach;

  /// Whether per-note controllers reset to their defaults (option flag S).
  final bool reset;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'note': note,
    'detach': detach,
    'reset': reset,
  };
}

// #############################################################################
/// A MIDI 2.0 Control Change message, status 0xB (M2-104-UM 7.4.6).
///
/// Bank Select, Data Entry, Data Increment and Decrement and the RPN and
/// NRPN controllers are replaced by dedicated MIDI 2.0 messages.
final class MidiControlChange2 extends MidiChannelVoice2Message {
  /// Creates a change of [controller] to the 32-bit [value].
  const MidiControlChange2({
    required super.channel,
    required this.controller,
    required this.value,
  }) : assert(controller >= 0 && controller <= 127),
       assert(value >= 0 && value <= 0xFFFFFFFF);

  // ...........................................................................
  /// The controller number, 0 to 127.
  final int controller;

  /// The 32-bit value.
  final int value;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'controller': controller,
    'value': value,
  };
}

// #############################################################################
/// A MIDI 2.0 Registered Controller message, the RPN equivalent, status
/// 0x2 (M2-104-UM 7.4.7).
final class MidiRegisteredController extends MidiChannelVoice2Message {
  /// Creates a change of the registered controller [bank]/[index] to the
  /// 32-bit [value].
  const MidiRegisteredController({
    required super.channel,
    required this.bank,
    required this.index,
    required this.value,
  }) : assert(bank >= 0 && bank <= 127),
       assert(index >= 0 && index <= 127),
       assert(value >= 0 && value <= 0xFFFFFFFF);

  // ...........................................................................
  /// The bank, the MIDI 1.0 RPN MSB, 0 to 127.
  final int bank;

  /// The index, the MIDI 1.0 RPN LSB, 0 to 127.
  final int index;

  /// The 32-bit value.
  final int value;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'bank': bank,
    'index': index,
    'value': value,
  };
}

// #############################################################################
/// A MIDI 2.0 Assignable Controller message, the NRPN equivalent, status
/// 0x3 (M2-104-UM 7.4.7).
final class MidiAssignableController extends MidiChannelVoice2Message {
  /// Creates a change of the assignable controller [bank]/[index] to the
  /// 32-bit [value].
  const MidiAssignableController({
    required super.channel,
    required this.bank,
    required this.index,
    required this.value,
  }) : assert(bank >= 0 && bank <= 127),
       assert(index >= 0 && index <= 127),
       assert(value >= 0 && value <= 0xFFFFFFFF);

  // ...........................................................................
  /// The bank, the MIDI 1.0 NRPN MSB, 0 to 127.
  final int bank;

  /// The index, the MIDI 1.0 NRPN LSB, 0 to 127.
  final int index;

  /// The 32-bit value.
  final int value;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'bank': bank,
    'index': index,
    'value': value,
  };
}

// #############################################################################
/// A MIDI 2.0 Relative Registered Controller message, status 0x4
/// (M2-104-UM 7.4.8).
final class MidiRelativeRegisteredController extends MidiChannelVoice2Message {
  /// Creates a relative change of the registered controller [bank]/[index]
  /// by the signed 32-bit [value].
  const MidiRelativeRegisteredController({
    required super.channel,
    required this.bank,
    required this.index,
    required this.value,
  }) : assert(bank >= 0 && bank <= 127),
       assert(index >= 0 && index <= 127),
       assert(value >= -0x80000000 && value <= 0x7FFFFFFF);

  // ...........................................................................
  /// The bank, 0 to 127.
  final int bank;

  /// The index, 0 to 127.
  final int index;

  /// The signed 32-bit change, -2^31 to 2^31 - 1.
  final int value;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'bank': bank,
    'index': index,
    'value': value,
  };
}

// #############################################################################
/// A MIDI 2.0 Relative Assignable Controller message, status 0x5
/// (M2-104-UM 7.4.8).
final class MidiRelativeAssignableController extends MidiChannelVoice2Message {
  /// Creates a relative change of the assignable controller [bank]/[index]
  /// by the signed 32-bit [value].
  const MidiRelativeAssignableController({
    required super.channel,
    required this.bank,
    required this.index,
    required this.value,
  }) : assert(bank >= 0 && bank <= 127),
       assert(index >= 0 && index <= 127),
       assert(value >= -0x80000000 && value <= 0x7FFFFFFF);

  // ...........................................................................
  /// The bank, 0 to 127.
  final int bank;

  /// The index, 0 to 127.
  final int index;

  /// The signed 32-bit change, -2^31 to 2^31 - 1.
  final int value;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'bank': bank,
    'index': index,
    'value': value,
  };
}

// #############################################################################
/// A MIDI 2.0 Program Change message, status 0xC (M2-104-UM 7.4.9).
///
/// It replaces the MIDI 1.0 Bank Select and Program Change sequence.
final class MidiProgramChange2 extends MidiChannelVoice2Message {
  /// Creates a change to [program], optionally in [bank].
  const MidiProgramChange2({
    required super.channel,
    required this.program,
    this.bank,
  }) : assert(program >= 0 && program <= 127);

  // ...........................................................................
  /// The program number, 0 to 127.
  final int program;

  /// The bank, Bank Select MSB and LSB of 0 to 127 each, or null when the
  /// message does not select a bank (option flag B cleared).
  final ({int msb, int lsb})? bank;

  /// Whether the message selects a bank (option flag B).
  bool get bankValid => bank != null;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'program': program,
    'bank': bank,
  };
}

// #############################################################################
/// A MIDI 2.0 Channel Pressure message, status 0xD (M2-104-UM 7.4.10).
final class MidiChannelPressure2 extends MidiChannelVoice2Message {
  /// Creates a 32-bit channel [pressure].
  const MidiChannelPressure2({required super.channel, required this.pressure})
    : assert(pressure >= 0 && pressure <= 0xFFFFFFFF);

  // ...........................................................................
  /// The 32-bit pressure.
  final int pressure;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'pressure': pressure,
  };
}

// #############################################################################
/// A MIDI 2.0 Pitch Bend message, status 0xE (M2-104-UM 7.4.11).
final class MidiPitchBend2 extends MidiChannelVoice2Message {
  /// Creates a pitch bend to the 32-bit [value]; 0x80000000 means no bend.
  const MidiPitchBend2({required super.channel, required this.value})
    : assert(value >= 0 && value <= 0xFFFFFFFF);

  // ...........................................................................
  /// The 32-bit bend value.
  final int value;

  @override
  Map<String, Object?> get _fields => {'channel': channel, 'value': value};
}

// #############################################################################
/// A MIDI 2.0 Per-Note Pitch Bend message, status 0x6 (M2-104-UM 7.4.12).
final class MidiPerNotePitchBend extends MidiChannelVoice2Message {
  /// Creates a pitch bend of [note] to the 32-bit [value]; 0x80000000 means
  /// no bend.
  const MidiPerNotePitchBend({
    required super.channel,
    required this.note,
    required this.value,
  }) : assert(note >= 0 && note <= 127),
       assert(value >= 0 && value <= 0xFFFFFFFF);

  // ...........................................................................
  /// The note number, 0 to 127.
  final int note;

  /// The 32-bit bend value.
  final int value;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'note': note,
    'value': value,
  };
}
