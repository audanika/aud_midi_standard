// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// Whether a function block represents a MIDI 1.0 port and how fast it may
/// be driven (M2-104-UM 7.1.8).
enum MidiFunctionBlockMidi1 {
  /// The block is not a MIDI 1.0 port.
  notMidi1(0),

  /// The block is a MIDI 1.0 port without bandwidth restriction.
  unrestricted(1),

  /// The block is a MIDI 1.0 port restricted to 31.25 kbit/s.
  restricted31250(2),

  /// The reserved value 3.
  reserved(3);

  /// Creates the property with its 2-bit [value].
  const MidiFunctionBlockMidi1(this.value);

  // ...........................................................................
  /// Returns the property of the low two bits of [value].
  static MidiFunctionBlockMidi1 fromValue(int value) => values[value & 3];

  // ...........................................................................
  /// The 2-bit value in function block info notifications.
  final int value;
}
