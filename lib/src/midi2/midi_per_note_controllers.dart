// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The MIDI 2.0 Registered Per-Note Controllers and the conversion of the
/// Pitch 7.25 controller (M2-104-UM Appendix A, Table 22, and 7.4.15.2).
///
/// The numbers follow the MIDI 1.0 control changes of the same function.
/// All other numbers are reserved and must not be used.
abstract final class MidiPerNoteControllers {
  // ...........................................................................
  /// Modulation.
  static const int modulation = 1;

  /// Breath.
  static const int breath = 2;

  /// Pitch 7.25: the pitch of the note as an unsigned Q7.25 fixed-point
  /// note number; it overrides the MIDI Tuning Standard and lasts for the
  /// following notes.
  static const int pitch = 3;

  /// Volume.
  static const int volume = 7;

  /// Balance.
  static const int balance = 8;

  /// Pan.
  static const int pan = 10;

  /// Expression.
  static const int expression = 11;

  // ...........................................................................
  /// Sound Controller 1, by default Sound Variation.
  static const int soundController1 = 70;

  /// Sound Controller 2, by default Timbre/Harmonic Intensity.
  static const int soundController2 = 71;

  /// Sound Controller 3, by default Release Time.
  static const int soundController3 = 72;

  /// Sound Controller 4, by default Attack Time.
  static const int soundController4 = 73;

  /// Sound Controller 5, by default Brightness.
  static const int soundController5 = 74;

  /// Sound Controller 6, by default Decay Time (MMA RP-021).
  static const int soundController6 = 75;

  /// Sound Controller 7, by default Vibrato Rate (MMA RP-021).
  static const int soundController7 = 76;

  /// Sound Controller 8, by default Vibrato Depth (MMA RP-021).
  static const int soundController8 = 77;

  /// Sound Controller 9, by default Vibrato Delay (MMA RP-021).
  static const int soundController9 = 78;

  /// Sound Controller 10, without default.
  static const int soundController10 = 79;

  // ...........................................................................
  /// Effects 1 Depth, by default Reverb Send Level (MMA RP-023).
  static const int effects1Depth = 91;

  /// Effects 2 Depth, formerly Tremolo Depth.
  static const int effects2Depth = 92;

  /// Effects 3 Depth, by default Chorus Send Level (MMA RP-023).
  static const int effects3Depth = 93;

  /// Effects 4 Depth, formerly Celeste (Detune) Depth.
  static const int effects4Depth = 94;

  /// Effects 5 Depth, formerly Phaser Depth.
  static const int effects5Depth = 95;

  // ...........................................................................
  /// Returns the note number, with fraction, of the Pitch 7.25 [value]:
  /// seven bits of note number and 25 bits of fraction of a semitone.
  ///
  /// Throws a [RangeError] when [value] is outside 0 to 0xFFFFFFFF.
  static double pitchToNote(int value) {
    RangeError.checkValueInInterval(value, 0, 0xFFFFFFFF, 'value');
    return value / _unit;
  }

  /// Returns the Pitch 7.25 value of the note number [note], rounded to
  /// 2^-25 semitone.
  ///
  /// Throws a [RangeError] when the rounded value is outside 0 to
  /// 0xFFFFFFFF, i.e. [note] is outside 0 to just below 128.
  static int noteToPitch(num note) {
    final value = note.isFinite ? (note * _unit).round() : -1;
    if (value < 0 || value > 0xFFFFFFFF) {
      throw RangeError.value(note, 'note', 'Not a Pitch 7.25 note number');
    }
    return value;
  }

  /// Returns the name of the constant for [controller], e.g.
  /// `'modulation'` for 1, or null for a reserved number.
  static String? name(int controller) => _names[controller];

  // ...........................................................................
  /// The value of one semitone in Pitch 7.25: 2^25.
  static const int _unit = 1 << 25;

  /// The constant names by controller number.
  static const Map<int, String> _names = {
    modulation: 'modulation',
    breath: 'breath',
    pitch: 'pitch',
    volume: 'volume',
    balance: 'balance',
    pan: 'pan',
    expression: 'expression',
    soundController1: 'soundController1',
    soundController2: 'soundController2',
    soundController3: 'soundController3',
    soundController4: 'soundController4',
    soundController5: 'soundController5',
    soundController6: 'soundController6',
    soundController7: 'soundController7',
    soundController8: 'soundController8',
    soundController9: 'soundController9',
    soundController10: 'soundController10',
    effects1Depth: 'effects1Depth',
    effects2Depth: 'effects2Depth',
    effects3Depth: 'effects3Depth',
    effects4Depth: 'effects4Depth',
    effects5Depth: 'effects5Depth',
  };
}
