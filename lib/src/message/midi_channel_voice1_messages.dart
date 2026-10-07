// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

part of 'midi_message.dart';

// #############################################################################
/// The base of the MIDI 1.0 channel voice messages: status bytes 0x80 to
/// 0xEF in a byte stream, UMP message type 0x2 (MIDI 1.0 Detailed
/// Specification, M2-104-UM 7.3).
sealed class MidiChannelVoice1Message extends MidiMessage {
  /// Creates a channel voice message on [channel].
  const MidiChannelVoice1Message({required this.channel})
    : assert(channel >= 0 && channel <= 15);

  // ...........................................................................
  /// The MIDI channel, 0 to 15.
  final int channel;

  @override
  UmpMessageType get umpMessageType => UmpMessageType.midi1ChannelVoice;
}

// #############################################################################
/// A MIDI 1.0 Note Off message, status 0x8n.
final class MidiNoteOff extends MidiChannelVoice1Message {
  /// Creates a Note Off of [note] with the release [velocity].
  ///
  /// Senders without release velocity use 64, the default.
  const MidiNoteOff({
    required super.channel,
    required this.note,
    this.velocity = 64,
  }) : assert(note >= 0 && note <= 127),
       assert(velocity >= 0 && velocity <= 127);

  // ...........................................................................
  /// The note number, 0 to 127.
  final int note;

  /// The release velocity, 0 to 127.
  final int velocity;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'note': note,
    'velocity': velocity,
  };
}

// #############################################################################
/// A MIDI 1.0 Note On message, status 0x9n.
///
/// A velocity of 0 means Note Off in the MIDI 1.0 protocol, see [isNoteOff].
final class MidiNoteOn extends MidiChannelVoice1Message {
  /// Creates a Note On of [note] with [velocity].
  const MidiNoteOn({
    required super.channel,
    required this.note,
    required this.velocity,
  }) : assert(note >= 0 && note <= 127),
       assert(velocity >= 0 && velocity <= 127);

  // ...........................................................................
  /// The note number, 0 to 127.
  final int note;

  /// The velocity, 0 to 127.
  final int velocity;

  /// Whether this message acts as a Note Off because its velocity is 0.
  bool get isNoteOff => velocity == 0;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'note': note,
    'velocity': velocity,
  };
}

// #############################################################################
/// A MIDI 1.0 Polyphonic Key Pressure message, status 0xAn.
final class MidiPolyPressure extends MidiChannelVoice1Message {
  /// Creates a key pressure of [pressure] for [note].
  const MidiPolyPressure({
    required super.channel,
    required this.note,
    required this.pressure,
  }) : assert(note >= 0 && note <= 127),
       assert(pressure >= 0 && pressure <= 127);

  // ...........................................................................
  /// The note number, 0 to 127.
  final int note;

  /// The pressure, 0 to 127.
  final int pressure;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'note': note,
    'pressure': pressure,
  };
}

// #############################################################################
/// A MIDI 1.0 Control Change message, status 0xBn.
///
/// Controllers 120 to 127 are the channel mode messages, see
/// [isChannelMode].
final class MidiControlChange extends MidiChannelVoice1Message {
  /// Creates a change of [controller] to [value].
  const MidiControlChange({
    required super.channel,
    required this.controller,
    required this.value,
  }) : assert(controller >= 0 && controller <= 127),
       assert(value >= 0 && value <= 127);

  // ...........................................................................
  /// The controller number, 0 to 127.
  final int controller;

  /// The controller value, 0 to 127.
  final int value;

  /// Whether this is a channel mode message (controllers 120 to 127).
  bool get isChannelMode => controller >= 120;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'controller': controller,
    'value': value,
  };
}

// #############################################################################
/// A MIDI 1.0 Program Change message, status 0xCn.
final class MidiProgramChange extends MidiChannelVoice1Message {
  /// Creates a change to [program].
  const MidiProgramChange({required super.channel, required this.program})
    : assert(program >= 0 && program <= 127);

  // ...........................................................................
  /// The program number, 0 to 127.
  final int program;

  @override
  Map<String, Object?> get _fields => {'channel': channel, 'program': program};
}

// #############################################################################
/// A MIDI 1.0 Channel Pressure message, status 0xDn.
final class MidiChannelPressure extends MidiChannelVoice1Message {
  /// Creates a channel pressure of [pressure].
  const MidiChannelPressure({required super.channel, required this.pressure})
    : assert(pressure >= 0 && pressure <= 127);

  // ...........................................................................
  /// The pressure, 0 to 127.
  final int pressure;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'pressure': pressure,
  };
}

// #############################################################################
/// A MIDI 1.0 Pitch Bend message, status 0xEn.
final class MidiPitchBend extends MidiChannelVoice1Message {
  /// Creates a pitch bend to the 14-bit [value]; [center] means no bend.
  const MidiPitchBend({required super.channel, required this.value})
    : assert(value >= 0 && value <= 0x3FFF);

  // ...........................................................................
  /// The value that means no bend.
  static const int center = 0x2000;

  // ...........................................................................
  /// The 14-bit bend value, 0 to 16383.
  final int value;

  @override
  Map<String, Object?> get _fields => {'channel': channel, 'value': value};
}
