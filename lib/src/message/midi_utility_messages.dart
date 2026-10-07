// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

part of 'midi_message.dart';

// #############################################################################
/// The base of the utility messages, UMP message type 0x0 (M2-104-UM 7.2).
///
/// Utility messages have no group and no MIDI 1.0 byte form.
sealed class MidiUtilityMessage extends MidiMessage {
  /// Creates a utility message.
  const MidiUtilityMessage();

  @override
  UmpMessageType get umpMessageType => UmpMessageType.utility;
}

// #############################################################################
/// A NOOP message, status 0x0 (M2-104-UM 7.2.1).
final class MidiNoop extends MidiUtilityMessage {
  /// Creates a NOOP.
  const MidiNoop();

  @override
  Map<String, Object?> get _fields => const {};
}

// #############################################################################
/// A Jitter Reduction Clock message, status 0x1 (M2-104-UM 7.2.2.1).
final class MidiJrClock extends MidiUtilityMessage {
  /// Creates a JR clock with the sender clock [time].
  const MidiJrClock({required this.time}) : assert(time >= 0 && time <= 0xFFFF);

  // ...........................................................................
  /// The 16-bit sender clock time in units of 1/31250 second.
  final int time;

  @override
  Map<String, Object?> get _fields => {'time': time};
}

// #############################################################################
/// A Jitter Reduction Timestamp message, status 0x2 (M2-104-UM 7.2.2.2).
///
/// It precedes the message it timestamps.
final class MidiJrTimestamp extends MidiUtilityMessage {
  /// Creates a JR timestamp with the sender clock [time].
  const MidiJrTimestamp({required this.time})
    : assert(time >= 0 && time <= 0xFFFF);

  // ...........................................................................
  /// The 16-bit sender clock time in units of 1/31250 second.
  final int time;

  @override
  Map<String, Object?> get _fields => {'time': time};
}

// #############################################################################
/// A Delta Clockstamp Ticks Per Quarter Note message, status 0x3
/// (M2-104-UM 7.2.3.1).
final class MidiDeltaClockstampTicksPerQuarterNote extends MidiUtilityMessage {
  /// Creates the declaration of [ticksPerQuarterNote].
  const MidiDeltaClockstampTicksPerQuarterNote({
    required this.ticksPerQuarterNote,
  }) : assert(ticksPerQuarterNote >= 0 && ticksPerQuarterNote <= 0xFFFF);

  // ...........................................................................
  /// The 16-bit number of ticks per quarter note.
  final int ticksPerQuarterNote;

  @override
  Map<String, Object?> get _fields => {
    'ticksPerQuarterNote': ticksPerQuarterNote,
  };
}

// #############################################################################
/// A Delta Clockstamp message, status 0x4 (M2-104-UM 7.2.3.2).
final class MidiDeltaClockstamp extends MidiUtilityMessage {
  /// Creates a delta of [ticks] since the last event.
  const MidiDeltaClockstamp({required this.ticks})
    : assert(ticks >= 0 && ticks <= 0xFFFFF);

  // ...........................................................................
  /// The 20-bit number of ticks since the last event.
  final int ticks;

  @override
  Map<String, Object?> get _fields => {'ticks': ticks};
}
