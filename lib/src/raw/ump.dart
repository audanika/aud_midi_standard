// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:typed_data';

import '../midi2/ump_message_type.dart';

// #############################################################################
/// One Universal MIDI Packet: one to four 32-bit words (M2-104-UM 2.1).
///
/// The size is fixed by the message type in the top four bits of the first
/// word. A packet holds one complete message or, for data messages longer
/// than 128 bits, one part of it. It is one of the two raw forms of the
/// package and independent of `MidiBytes`.
final class Ump {
  /// Creates a packet from a copy of [words]; each value keeps its low 32
  /// bits. The number of words must match the message type.
  Ump(Iterable<int> words)
    : words = Uint32List.fromList(words.toList()).asUnmodifiableView() {
    if (this.words.isEmpty ||
        this.words.length != UmpMessageType.fromWord(this.words[0]).wordCount) {
      throw ArgumentError.value(
        words,
        'words',
        'The number of words does not match the message type',
      );
    }
  }

  // ...........................................................................
  /// Parses [hex], one group of eight hex digits per word separated by
  /// whitespace, e.g. `'40903c00 c8000000'`.
  factory Ump.fromHex(String hex) => Ump(
    hex.trim().split(RegExp(r'\s+')).map((word) => int.parse(word, radix: 16)),
  );

  // ...........................................................................
  /// Splits a stream of [words] into packets.
  ///
  /// Throws an [ArgumentError] when the last packet is incomplete.
  static List<Ump> split(List<int> words) {
    final result = <Ump>[];
    var i = 0;
    while (i < words.length) {
      final size = sizeOf(words[i]);
      if (i + size > words.length) {
        throw ArgumentError.value(words, 'words', 'Incomplete last packet');
      }
      result.add(Ump(words.sublist(i, i + size)));
      i += size;
    }
    return result;
  }

  // ...........................................................................
  /// Returns the number of words of a packet starting with [firstWord].
  static int sizeOf(int firstWord) =>
      UmpMessageType.fromWord(firstWord).wordCount;

  // ...........................................................................
  /// The words of the packet; the list cannot be modified.
  final Uint32List words;

  /// The message type of the packet.
  UmpMessageType get messageType => UmpMessageType.fromWord(words[0]);

  /// The group 0 to 15, or null for groupless message types.
  int? get group => messageType.hasGroup ? (words[0] >> 24) & 0xF : null;

  // ...........................................................................
  /// Returns the words as eight-digit lower-case hex groups.
  String toHex() =>
      words.map((w) => w.toRadixString(16).padLeft(8, '0')).join(' ');

  // ...........................................................................
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Ump || other.words.length != words.length) return false;
    for (var i = 0; i < words.length; i++) {
      if (other.words[i] != words[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(words);

  @override
  String toString() => 'Ump(${toHex()})';
}
