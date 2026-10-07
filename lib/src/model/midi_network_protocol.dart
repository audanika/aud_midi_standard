// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The protocol of a network MIDI session.
enum MidiNetworkProtocol {
  /// AppleMIDI, the session protocol of RTP-MIDI (RFC 6295), carrying MIDI
  /// 1.0 byte streams.
  appleMidi,

  /// Network MIDI 2.0 (UDP), carrying Universal MIDI Packets.
  networkMidi2,
}
