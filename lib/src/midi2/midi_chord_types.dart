// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The field values of the Set Chord Name flex data message: chord types,
/// alteration types, note letters and sharps or flats (M2-104-UM 7.5.8,
/// Tables 13 to 15; note letters as in 7.5.7).
///
/// Chord types 0x1C to 0xFF, alteration types 5 to 15 and note letters 8 to
/// 15 are reserved.
abstract final class MidiChordTypes {
  // ...........................................................................
  // The chord types (M2-104-UM Table 14); bass chords use the same values.

  /// Clear Chord: no chord.
  static const int noChord = 0x00;

  /// Major.
  static const int major = 0x01;

  /// Major 6th.
  static const int major6th = 0x02;

  /// Major 7th.
  static const int major7th = 0x03;

  /// Major 9th.
  static const int major9th = 0x04;

  /// Major 11th.
  static const int major11th = 0x05;

  /// Major 13th.
  static const int major13th = 0x06;

  /// Minor.
  static const int minor = 0x07;

  /// Minor 6th.
  static const int minor6th = 0x08;

  /// Minor 7th.
  static const int minor7th = 0x09;

  /// Minor 9th.
  static const int minor9th = 0x0A;

  /// Minor 11th.
  static const int minor11th = 0x0B;

  /// Minor 13th.
  static const int minor13th = 0x0C;

  /// Dominant, the dominant seventh chord.
  static const int dominant = 0x0D;

  /// Dominant ninth.
  static const int dominant9th = 0x0E;

  /// Dominant 11th.
  static const int dominant11th = 0x0F;

  /// Dominant 13th.
  static const int dominant13th = 0x10;

  /// Augmented.
  static const int augmented = 0x11;

  /// Augmented seventh.
  static const int augmented7th = 0x12;

  /// Diminished.
  static const int diminished = 0x13;

  /// Diminished seventh.
  static const int diminished7th = 0x14;

  /// Half diminished: a diminished triad with a minor seventh.
  static const int halfDiminished = 0x15;

  /// Major-minor or minor-major: a minor triad with a major seventh.
  static const int majorMinor = 0x16;

  /// Pedal: the root and its octave.
  static const int pedal = 0x17;

  /// Power: the root and its fifth.
  static const int power = 0x18;

  /// Suspended 2nd: the root, the second and the fifth.
  static const int suspended2nd = 0x19;

  /// Suspended 4th.
  static const int suspended4th = 0x1A;

  /// 7 suspended 4th.
  static const int seventhSuspended4th = 0x1B;

  // ...........................................................................
  // The alteration types of a chord degree.

  /// No alteration.
  static const int alterationNone = 0;

  /// Adds the degree.
  static const int alterationAdd = 1;

  /// Removes the degree.
  static const int alterationSubtract = 2;

  /// Raises the degree, adding it if needed.
  static const int alterationRaise = 3;

  /// Lowers the degree, adding it if needed.
  static const int alterationLower = 4;

  // ...........................................................................
  // The note letters of the tonic, bass and key signature fields.

  /// An unknown note, or no chord; for the bass note: the chord tonic.
  static const int noteUnknown = 0;

  /// The note A.
  static const int noteA = 1;

  /// The note B.
  static const int noteB = 2;

  /// The note C.
  static const int noteC = 3;

  /// The note D.
  static const int noteD = 4;

  /// The note E.
  static const int noteE = 5;

  /// The note F.
  static const int noteF = 6;

  /// The note G.
  static const int noteG = 7;

  // ...........................................................................
  // The sharps or flats applied to a tonic or bass note (M2-104-UM Tables
  // 13 and 15), 4-bit two's complement values.

  /// Two sharps.
  static const int doubleSharp = 2;

  /// One sharp.
  static const int sharp = 1;

  /// Natural.
  static const int natural = 0;

  /// One flat.
  static const int flat = -1;

  /// Two flats.
  static const int doubleFlat = -2;

  /// The bass note is the chord tonic; the bass note field is then 0.
  static const int bassIsChordTonic = -8;

  // ...........................................................................
  /// Returns the name of the constant for [chordType], e.g. `'minor7th'`
  /// for 0x09, or null for a reserved type.
  static String? name(int chordType) =>
      chordType >= 0 && chordType < _names.length ? _names[chordType] : null;

  /// Returns the name of the constant for the alteration [type], e.g.
  /// `'alterationAdd'` for 1, or null for a reserved type.
  static String? alterationName(int type) =>
      type >= 0 && type < _alterationNames.length
      ? _alterationNames[type]
      : null;

  /// Returns the letter of [note], `'A'` for 1 to `'G'` for 7, or null for
  /// the unknown note 0 and reserved values.
  static String? noteName(int note) =>
      note >= noteA && note <= noteG ? _letters[note - noteA] : null;

  // ...........................................................................
  /// The constant names of the chord types by value.
  static const List<String> _names = [
    'noChord',
    'major',
    'major6th',
    'major7th',
    'major9th',
    'major11th',
    'major13th',
    'minor',
    'minor6th',
    'minor7th',
    'minor9th',
    'minor11th',
    'minor13th',
    'dominant',
    'dominant9th',
    'dominant11th',
    'dominant13th',
    'augmented',
    'augmented7th',
    'diminished',
    'diminished7th',
    'halfDiminished',
    'majorMinor',
    'pedal',
    'power',
    'suspended2nd',
    'suspended4th',
    'seventhSuspended4th',
  ];

  /// The constant names of the alteration types by value.
  static const List<String> _alterationNames = [
    'alterationNone',
    'alterationAdd',
    'alterationSubtract',
    'alterationRaise',
    'alterationLower',
  ];

  /// The note letters A to G.
  static const List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
}
