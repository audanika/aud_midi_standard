// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../message/midi_message.dart';

// #############################################################################
/// Builds the MIDI 1.0 channel voice, system common and system real-time
/// messages from their status and data bytes (MIDI 1.0 Detailed
/// Specification, M2-104-UM 7.3 and 7.6).
///
/// The byte parser and the UMP decoder share these rules; the class is not
/// exported.
abstract final class MidiShortMessage {
  // ...........................................................................
  /// Returns the number of data bytes that follow [status], or null when
  /// [status] starts no channel voice, system common or system real-time
  /// message: data bytes, System Exclusive and undefined status bytes.
  static int? dataLength(int status) => switch (status) {
    >= 0x80 && < 0xC0 || >= 0xE0 && < 0xF0 || 0xF2 => 2,
    >= 0xC0 && < 0xE0 || 0xF1 || 0xF3 => 1,
    0xF6 || 0xF8 || 0xFA || 0xFB || 0xFC || 0xFE || 0xFF => 0,
    _ => null,
  };

  // ...........................................................................
  /// Returns the message of [status] with the 7-bit data bytes [data1] and
  /// [data2]; data bytes the message does not use are ignored.
  ///
  /// Throws an [ArgumentError] when [status] has no [dataLength].
  static MidiMessage decode(int status, {int data1 = 0, int data2 = 0}) {
    final channel = status & 0xF;
    return switch (status & 0xF0) {
      0x80 => MidiNoteOff(channel: channel, note: data1, velocity: data2),
      0x90 => MidiNoteOn(channel: channel, note: data1, velocity: data2),
      0xA0 => MidiPolyPressure(channel: channel, note: data1, pressure: data2),
      0xB0 => MidiControlChange(
        channel: channel,
        controller: data1,
        value: data2,
      ),
      0xC0 => MidiProgramChange(channel: channel, program: data1),
      0xD0 => MidiChannelPressure(channel: channel, pressure: data1),
      0xE0 => MidiPitchBend(channel: channel, value: data2 << 7 | data1),
      _ => _system(status, data1, data2),
    };
  }

  // ...........................................................................
  /// Returns the system message of [status] with [data1] and [data2].
  static MidiMessage _system(int status, int data1, int data2) =>
      switch (status) {
        0xF1 => MidiTimeCodeQuarterFrame(piece: data1 >> 4, value: data1 & 0xF),
        0xF2 => MidiSongPositionPointer(position: data2 << 7 | data1),
        0xF3 => MidiSongSelect(song: data1),
        0xF6 => const MidiTuneRequest(),
        0xF8 => const MidiTimingClock(),
        0xFA => const MidiStart(),
        0xFB => const MidiContinue(),
        0xFC => const MidiStop(),
        0xFE => const MidiActiveSensing(),
        0xFF => const MidiSystemReset(),
        _ => throw ArgumentError.value(status, 'status', 'No short message'),
      };
}
