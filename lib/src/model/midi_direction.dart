// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The direction of a MIDI port, seen from the app.
///
/// An [input] delivers MIDI into the app, an [output] carries MIDI out of
/// it. Platforms that name ports from the device's point of view are
/// mapped: an Android "input port" is an [output] here.
enum MidiDirection {
  /// The port delivers MIDI into the app.
  input,

  /// The port carries MIDI from the app to the device.
  output,
}
