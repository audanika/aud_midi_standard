// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// How the operating system reaches a MIDI port.
enum MidiTransport {
  /// The port belongs to a USB device.
  usb,

  /// The port belongs to a Bluetooth Low Energy peripheral (BLE-MIDI).
  bluetoothLe,

  /// The port belongs to a network session, e.g. AppleMIDI (RTP-MIDI) or
  /// Network MIDI 2.0.
  network,

  /// The port is a virtual port created by an application.
  virtual,

  /// The port belongs to a software device of the operating system or a
  /// driver, e.g. a built-in synthesizer or an inter-application bus.
  software,

  /// The transport is not known.
  unknown,
}
