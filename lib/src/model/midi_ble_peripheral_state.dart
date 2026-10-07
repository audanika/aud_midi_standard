// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The connection state of a BLE-MIDI peripheral.
enum MidiBlePeripheralState {
  /// The peripheral advertises itself and is not connected.
  advertising,

  /// A connection to the peripheral is being established.
  connecting,

  /// The peripheral is connected; its ports are available.
  connected,

  /// The connection to the peripheral was closed or lost.
  disconnected,
}
