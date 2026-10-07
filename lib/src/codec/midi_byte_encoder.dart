// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../message/midi_message.dart';
import '../raw/midi_bytes.dart';

// #############################################################################
/// Encodes messages as a MIDI 1.0 byte stream (MIDI 1.0 Detailed
/// Specification). The encoder never uses running status.
///
/// Only MIDI 1.0 channel voice, system common, system real-time and System
/// Exclusive messages have a byte form; every field keeps only the bits of
/// its width.
abstract final class MidiByteEncoder {
  // ...........................................................................
  /// Encodes [message], or returns null when it has no MIDI 1.0 byte form.
  static MidiBytes? encode(MidiMessage message) {
    final bytes = _bytesOf(message);
    return bytes == null ? null : MidiBytes(bytes);
  }

  // ...........................................................................
  /// Encodes [messages] into one chunk and skips messages without a MIDI
  /// 1.0 byte form.
  static MidiBytes encodeAll(Iterable<MidiMessage> messages) =>
      MidiBytes([for (final message in messages) ...?_bytesOf(message)]);

  // ...........................................................................
  /// Returns the bytes of [message], or null without a byte form.
  static List<int>? _bytesOf(MidiMessage message) => switch (message) {
    MidiChannelVoice1Message() => _channelVoice(message),
    MidiSystemMessage() => _system(message),
    MidiSysEx() => [0xF0, for (final byte in message.data) byte & 0x7F, 0xF7],
    _ => null,
  };

  /// Returns the bytes of the channel voice [message].
  static List<int> _channelVoice(MidiChannelVoice1Message message) {
    final channel = message.channel & 0xF;
    return switch (message) {
      MidiNoteOff(:final note, :final velocity) => [
        0x80 | channel,
        note & 0x7F,
        velocity & 0x7F,
      ],
      MidiNoteOn(:final note, :final velocity) => [
        0x90 | channel,
        note & 0x7F,
        velocity & 0x7F,
      ],
      MidiPolyPressure(:final note, :final pressure) => [
        0xA0 | channel,
        note & 0x7F,
        pressure & 0x7F,
      ],
      MidiControlChange(:final controller, :final value) => [
        0xB0 | channel,
        controller & 0x7F,
        value & 0x7F,
      ],
      MidiProgramChange(:final program) => [0xC0 | channel, program & 0x7F],
      MidiChannelPressure(:final pressure) => [0xD0 | channel, pressure & 0x7F],
      MidiPitchBend(:final value) => [
        0xE0 | channel,
        value & 0x7F,
        (value >> 7) & 0x7F,
      ],
    };
  }

  /// Returns the bytes of the system common or real-time [message].
  static List<int> _system(MidiSystemMessage message) => switch (message) {
    MidiTimeCodeQuarterFrame(:final piece, :final value) => [
      0xF1,
      (piece & 0x7) << 4 | value & 0xF,
    ],
    MidiSongPositionPointer(:final position) => [
      0xF2,
      position & 0x7F,
      (position >> 7) & 0x7F,
    ],
    MidiSongSelect(:final song) => [0xF3, song & 0x7F],
    MidiTuneRequest() || MidiSystemRealTimeMessage() => [message.status],
  };
}
