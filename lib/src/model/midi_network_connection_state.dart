// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The state of a connection to a network MIDI host.
enum MidiNetworkConnectionState {
  /// An invitation was sent and the answer is pending.
  inviting,

  /// The connection is established and carries MIDI.
  connected,

  /// The connection was closed by one of the two sides.
  disconnected,

  /// The connection could not be established or broke down.
  failed,
}
