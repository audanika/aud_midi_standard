// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// Where the description of a network MIDI host comes from.
enum MidiNetworkHostSource {
  /// The host was discovered by DNS-SD (Bonjour, mDNS).
  bonjour,

  /// The host was entered by hand.
  manual,
}
