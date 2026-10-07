// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The MIDI protocol of a UMP stream or port (M2-104-UM 7.1.6).
enum MidiProtocol {
  /// The MIDI 1.0 protocol: byte streams, or UMP message types 0x2 and 0x3.
  midi1(0x01),

  /// The MIDI 2.0 protocol: UMP message type 0x4 for channel voice.
  midi2(0x02);

  /// Creates a protocol with its value in stream configuration messages.
  const MidiProtocol(this.value);

  // ...........................................................................
  /// Returns the protocol of the stream configuration [value], or null for
  /// an unknown value.
  static MidiProtocol? fromValue(int value) => switch (value) {
    0x01 => midi1,
    0x02 => midi2,
    _ => null,
  };

  // ...........................................................................
  /// The value in stream configuration messages.
  final int value;
}
