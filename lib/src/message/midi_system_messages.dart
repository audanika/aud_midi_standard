// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

part of 'midi_message.dart';

// #############################################################################
/// The base of the system common and system real-time messages: status
/// bytes 0xF1 to 0xFF except System Exclusive, UMP message type 0x1 (MIDI
/// 1.0 Detailed Specification, M2-104-UM 7.6).
sealed class MidiSystemMessage extends MidiMessage {
  /// Creates a system message.
  const MidiSystemMessage();

  // ...........................................................................
  /// The status byte of the message.
  int get status;

  @override
  UmpMessageType get umpMessageType => UmpMessageType.system;
}

// #############################################################################
/// The base of the system common messages.
sealed class MidiSystemCommonMessage extends MidiSystemMessage {
  /// Creates a system common message.
  const MidiSystemCommonMessage();
}

// #############################################################################
/// The base of the system real-time messages. They may appear between the
/// bytes of any other message, even inside System Exclusive.
sealed class MidiSystemRealTimeMessage extends MidiSystemMessage {
  /// Creates a system real-time message.
  const MidiSystemRealTimeMessage();

  @override
  Map<String, Object?> get _fields => const {};
}

// #############################################################################
/// A MIDI Time Code Quarter Frame message, status 0xF1.
final class MidiTimeCodeQuarterFrame extends MidiSystemCommonMessage {
  /// Creates a quarter frame carrying [value] for [piece].
  const MidiTimeCodeQuarterFrame({required this.piece, required this.value})
    : assert(piece >= 0 && piece <= 7),
      assert(value >= 0 && value <= 15);

  // ...........................................................................
  /// The piece of the time code, 0 to 7: frames low and high nibble,
  /// seconds, minutes and hours with rate.
  final int piece;

  /// The 4-bit value of the piece.
  final int value;

  @override
  int get status => 0xF1;

  @override
  Map<String, Object?> get _fields => {'piece': piece, 'value': value};
}

// #############################################################################
/// A Song Position Pointer message, status 0xF2.
final class MidiSongPositionPointer extends MidiSystemCommonMessage {
  /// Creates a pointer to [position], counted in MIDI beats (sixteenth
  /// notes) since the start of the song.
  const MidiSongPositionPointer({required this.position})
    : assert(position >= 0 && position <= 0x3FFF);

  // ...........................................................................
  /// The 14-bit position in MIDI beats.
  final int position;

  @override
  int get status => 0xF2;

  @override
  Map<String, Object?> get _fields => {'position': position};
}

// #############################################################################
/// A Song Select message, status 0xF3.
final class MidiSongSelect extends MidiSystemCommonMessage {
  /// Creates a selection of [song].
  const MidiSongSelect({required this.song}) : assert(song >= 0 && song <= 127);

  // ...........................................................................
  /// The song number, 0 to 127.
  final int song;

  @override
  int get status => 0xF3;

  @override
  Map<String, Object?> get _fields => {'song': song};
}

// #############################################################################
/// A Tune Request message, status 0xF6.
final class MidiTuneRequest extends MidiSystemCommonMessage {
  /// Creates a tune request.
  const MidiTuneRequest();

  @override
  int get status => 0xF6;

  @override
  Map<String, Object?> get _fields => const {};
}

// #############################################################################
/// A Timing Clock message, status 0xF8, sent 24 times per quarter note.
final class MidiTimingClock extends MidiSystemRealTimeMessage {
  /// Creates a timing clock.
  const MidiTimingClock();

  @override
  int get status => 0xF8;
}

// #############################################################################
/// A Start message, status 0xFA.
final class MidiStart extends MidiSystemRealTimeMessage {
  /// Creates a start message.
  const MidiStart();

  @override
  int get status => 0xFA;
}

// #############################################################################
/// A Continue message, status 0xFB.
final class MidiContinue extends MidiSystemRealTimeMessage {
  /// Creates a continue message.
  const MidiContinue();

  @override
  int get status => 0xFB;
}

// #############################################################################
/// A Stop message, status 0xFC.
final class MidiStop extends MidiSystemRealTimeMessage {
  /// Creates a stop message.
  const MidiStop();

  @override
  int get status => 0xFC;
}

// #############################################################################
/// An Active Sensing message, status 0xFE.
final class MidiActiveSensing extends MidiSystemRealTimeMessage {
  /// Creates an active sensing message.
  const MidiActiveSensing();

  @override
  int get status => 0xFE;
}

// #############################################################################
/// A System Reset message, status 0xFF.
final class MidiSystemReset extends MidiSystemRealTimeMessage {
  /// Creates a system reset.
  const MidiSystemReset();

  @override
  int get status => 0xFF;
}
