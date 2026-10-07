// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The permissions a platform may require before MIDI features work.
enum MidiPermission {
  /// The permission to scan for and connect to Bluetooth devices.
  bluetooth,

  /// The permission to access the local network, e.g. for network sessions
  /// and DNS-SD discovery.
  localNetwork,

  /// The permission to send and receive System Exclusive messages, e.g. in
  /// Web MIDI.
  sysEx,

  /// The permission to access MIDI devices at all, e.g. in Web MIDI.
  midi,
}
