// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// Who may connect to a network MIDI session.
enum MidiNetworkConnectionPolicy {
  /// Every host may connect.
  anyone,

  /// Only the hosts in the contact list of the session may connect.
  contacts,

  /// Only the peers the app names may connect.
  specificPeers,
}
