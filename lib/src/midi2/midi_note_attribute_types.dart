// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The attribute types of MIDI 2.0 Note On and Note Off messages and the
/// conversion of the Pitch 7.9 attribute (M2-104-UM 7.4.14, Table 8, and
/// 7.4.15.3).
///
/// The types 0x04 to 0xFF are reserved.
abstract final class MidiNoteAttributeTypes {
  // ...........................................................................
  /// No attribute data; the attribute value is 0x0000 and ignored.
  static const int none = 0x00;

  /// Manufacturer specific data, also used for data of an unknown type.
  static const int manufacturerSpecific = 0x01;

  /// Profile specific data, defined by the active MIDI-CI profile.
  static const int profileSpecific = 0x02;

  /// Pitch 7.9: the pitch of this one note as an unsigned Q7.9 fixed-point
  /// note number; the note number of the message is only an index then.
  static const int pitch = 0x03;

  // ...........................................................................
  /// Returns the note number, with fraction, of the Pitch 7.9 [attribute]:
  /// seven bits of note number and nine bits of fraction of a semitone.
  ///
  /// Throws a [RangeError] when [attribute] is outside 0 to 0xFFFF.
  static double pitchToNote(int attribute) {
    RangeError.checkValueInInterval(attribute, 0, 0xFFFF, 'attribute');
    return attribute / _unit;
  }

  /// Returns the Pitch 7.9 attribute of the note number [note], rounded to
  /// 1/512 semitone.
  ///
  /// Throws a [RangeError] when the rounded value is outside 0 to 0xFFFF,
  /// i.e. [note] is outside 0 to about 127.998.
  static int noteToPitch(num note) {
    final attribute = note.isFinite ? (note * _unit).round() : -1;
    if (attribute < 0 || attribute > 0xFFFF) {
      throw RangeError.value(note, 'note', 'Not a Pitch 7.9 note number');
    }
    return attribute;
  }

  /// Returns the name of the constant for the attribute [type], e.g.
  /// `'pitch'` for 0x03, or null for a reserved type.
  static String? name(int type) => _names[type];

  // ...........................................................................
  /// The value of one semitone in Pitch 7.9: 2^9.
  static const int _unit = 1 << 9;

  /// The constant names by attribute type.
  static const Map<int, String> _names = {
    none: 'none',
    manufacturerSpecific: 'manufacturerSpecific',
    profileSpecific: 'profileSpecific',
    pitch: 'pitch',
  };
}
