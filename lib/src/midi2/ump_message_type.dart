// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The message types of the Universal MIDI Packet, taken from the four most
/// significant bits of the first word (M2-104-UM 2.1.4, Table 4).
enum UmpMessageType {
  /// Utility messages: NOOP, JR clock and timestamps, delta clockstamps.
  utility(0x0, 1, hasGroup: false),

  /// System common and system real-time messages.
  system(0x1, 1, hasGroup: true),

  /// MIDI 1.0 channel voice messages.
  midi1ChannelVoice(0x2, 1, hasGroup: true),

  /// 64-bit data messages: System Exclusive (7-bit).
  data64(0x3, 2, hasGroup: true),

  /// MIDI 2.0 channel voice messages.
  midi2ChannelVoice(0x4, 2, hasGroup: true),

  /// 128-bit data messages: System Exclusive 8 and Mixed Data Set.
  data128(0x5, 4, hasGroup: true),

  /// Reserved 32-bit message type 0x6.
  reserved6(0x6, 1, hasGroup: false),

  /// Reserved 32-bit message type 0x7.
  reserved7(0x7, 1, hasGroup: false),

  /// Reserved 64-bit message type 0x8.
  reserved8(0x8, 2, hasGroup: false),

  /// Reserved 64-bit message type 0x9.
  reserved9(0x9, 2, hasGroup: false),

  /// Reserved 64-bit message type 0xA.
  reservedA(0xA, 2, hasGroup: false),

  /// Reserved 96-bit message type 0xB.
  reservedB(0xB, 3, hasGroup: false),

  /// Reserved 96-bit message type 0xC.
  reservedC(0xC, 3, hasGroup: false),

  /// Flex data messages: tempo, time and key signature, chords, text.
  flexData(0xD, 4, hasGroup: true),

  /// Reserved 128-bit message type 0xE.
  reservedE(0xE, 4, hasGroup: false),

  /// UMP stream messages: endpoint and function block discovery.
  umpStream(0xF, 4, hasGroup: false);

  /// Creates a message type with its 4-bit [value] and its size in words.
  const UmpMessageType(this.value, this.wordCount, {required this.hasGroup});

  // ...........................................................................
  /// Returns the message type stored in the top four bits of [word].
  static UmpMessageType fromWord(int word) => values[(word >> 28) & 0xF];

  // ...........................................................................
  /// The 4-bit value of the message type.
  final int value;

  /// The number of 32-bit words of a packet of this message type.
  final int wordCount;

  /// Whether packets of this type carry a group in bits 24 to 27.
  ///
  /// Utility and UMP stream messages have no group; reserved message types
  /// are treated as groupless because their layout is not defined yet.
  final bool hasGroup;
}
