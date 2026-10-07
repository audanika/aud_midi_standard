// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:typed_data';

// #############################################################################
/// An immutable chunk of a MIDI 1.0 byte stream.
///
/// A chunk carries one or more complete messages, possibly with running
/// status, or a part of a System Exclusive message, exactly as a
/// byte-stream transport delivers it (MIDI 1.0 Detailed Specification). It
/// is one of the two raw forms of the package and independent of `Ump`.
final class MidiBytes {
  /// Creates a chunk from a copy of [bytes]; each value keeps its low
  /// eight bits.
  MidiBytes(Iterable<int> bytes)
    : bytes = Uint8List.fromList(bytes.toList()).asUnmodifiableView();

  // ...........................................................................
  /// Parses [hex], pairs of hex digits separated by optional whitespace,
  /// e.g. `'90 3c 64'`.
  factory MidiBytes.fromHex(String hex) {
    final digits = hex.replaceAll(RegExp(r'\s+'), '');
    if (digits.length.isOdd) {
      throw FormatException('Odd number of hex digits', hex);
    }
    return MidiBytes([
      for (var i = 0; i < digits.length; i += 2)
        int.parse(digits.substring(i, i + 2), radix: 16),
    ]);
  }

  // ...........................................................................
  /// An empty chunk.
  static final MidiBytes empty = MidiBytes(const []);

  // ...........................................................................
  /// The bytes of the chunk; the list cannot be modified.
  final Uint8List bytes;

  /// The number of bytes.
  int get length => bytes.length;

  /// Whether the chunk holds no byte.
  bool get isEmpty => bytes.isEmpty;

  /// Returns the byte at [index].
  int operator [](int index) => bytes[index];

  // ...........................................................................
  /// Returns the bytes as lower-case hex pairs separated by spaces.
  String toHex() =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  // ...........................................................................
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MidiBytes || other.length != length) return false;
    for (var i = 0; i < length; i++) {
      if (other.bytes[i] != bytes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(bytes);

  @override
  String toString() => 'MidiBytes(${toHex()})';
}
