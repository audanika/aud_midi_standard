// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// Whether a MIDI port can currently be used.
enum MidiPortState {
  /// The port is present and usable.
  connected,

  /// The device of the port is unplugged or unreachable; the port may come
  /// back.
  disconnected,

  /// The operating system lists the port but marks it offline, e.g. the
  /// offline property of CoreMIDI.
  offline,
}
