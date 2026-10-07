// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The user interface hint of a function block: how an application should
/// present it (M2-104-UM 7.1.8).
enum MidiFunctionBlockUiHint {
  /// The use is unknown; the direction field decides.
  unknown(0),

  /// The block is primarily a receiver or destination.
  receiver(1),

  /// The block is primarily a sender or source.
  sender(2),

  /// The block is both a sender and a receiver.
  senderReceiver(3);

  /// Creates a hint with its 2-bit [value].
  const MidiFunctionBlockUiHint(this.value);

  // ...........................................................................
  /// Returns the hint of the low two bits of [value].
  static MidiFunctionBlockUiHint fromValue(int value) => values[value & 3];

  // ...........................................................................
  /// The 2-bit value in function block info notifications.
  final int value;
}
