// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The network MIDI flavours a backend can provide.
enum MidiNetworkSupport {
  /// AppleMIDI sessions (RTP-MIDI) run by the package.
  appleMidi,

  /// Network MIDI 2.0 sessions run by the package.
  networkMidi2,

  /// The network session of the operating system, e.g. MIDINetworkSession
  /// on Apple platforms.
  osSession,
}
