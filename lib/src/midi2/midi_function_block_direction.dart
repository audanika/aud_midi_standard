// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The direction of a function block, seen from the block (M2-104-UM 7.1.8).
enum MidiFunctionBlockDirection {
  /// The reserved value 0.
  reserved(0),

  /// The block receives MIDI messages.
  input(1),

  /// The block sends MIDI messages.
  output(2),

  /// The block receives and sends MIDI messages.
  bidirectional(3);

  /// Creates a direction with its 2-bit [value].
  const MidiFunctionBlockDirection(this.value);

  // ...........................................................................
  /// Returns the direction of the low two bits of [value].
  static MidiFunctionBlockDirection fromValue(int value) => values[value & 3];

  // ...........................................................................
  /// The 2-bit value in function block info notifications.
  final int value;
}
