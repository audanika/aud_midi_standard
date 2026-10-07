// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The System Exclusive manufacturer ids: the special ids, a selection of
/// well-known manufacturers, and the 16-bit form used by System Exclusive 8
/// and Mixed Data Set messages (MIDI 1.0 Detailed Specification 4.2.1,
/// System Exclusive Messages; M2-104-UM 7.10).
///
/// An id is either one byte, 0x01 to 0x7F, or three bytes starting with
/// 0x00. The manufacturer constants are lists, so they splice into SysEx
/// data: `MidiSysEx([...MidiManufacturerIds.roland, 0x10, 0x42])`. The
/// complete list is published by the MIDI Association.
abstract final class MidiManufacturerIds {
  // ...........................................................................
  /// The first byte of every three-byte id; as a one-byte id it is
  /// reserved.
  static const int threeBytePrefix = 0x00;

  /// The special id for non-commercial use, research and development; it
  /// must never appear in a released product.
  static const int nonCommercial = 0x7D;

  /// The special id of Universal System Exclusive non-real-time messages.
  static const int universalNonRealTime = 0x7E;

  /// The special id of Universal System Exclusive real-time messages.
  static const int universalRealTime = 0x7F;

  // ...........................................................................
  // One-byte ids of American manufacturers, 0x01 to 0x1F.

  /// Sequential Circuits, today Sequential.
  static const List<int> sequential = [0x01];

  /// Moog Music.
  static const List<int> moog = [0x04];

  /// Kurzweil, Young Chang.
  static const List<int> kurzweil = [0x07];

  /// Ensoniq.
  static const List<int> ensoniq = [0x0F];

  /// Oberheim.
  static const List<int> oberheim = [0x10];

  /// Apple.
  static const List<int> apple = [0x11];

  /// E-mu Systems.
  static const List<int> emu = [0x18];

  // ...........................................................................
  // One-byte ids of European manufacturers, 0x20 to 0x3F.

  /// Clavia Digital Instruments, the maker of Nord instruments.
  static const List<int> clavia = [0x33];

  /// Waldorf Electronics.
  static const List<int> waldorf = [0x3E];

  // ...........................................................................
  // One-byte ids of Japanese manufacturers, 0x40 to 0x5F.

  /// Kawai Musical Instruments.
  static const List<int> kawai = [0x40];

  /// Roland.
  static const List<int> roland = [0x41];

  /// Korg.
  static const List<int> korg = [0x42];

  /// Yamaha.
  static const List<int> yamaha = [0x43];

  /// Casio.
  static const List<int> casio = [0x44];

  /// Akai.
  static const List<int> akai = [0x47];

  // ...........................................................................
  // Three-byte ids.

  /// Alesis.
  static const List<int> alesis = [0x00, 0x00, 0x0E];

  /// Mark of the Unicorn (MOTU).
  static const List<int> markOfTheUnicorn = [0x00, 0x00, 0x3B];

  /// Novation, Focusrite.
  static const List<int> novation = [0x00, 0x20, 0x29];

  /// Behringer.
  static const List<int> behringer = [0x00, 0x20, 0x32];

  /// Access Music.
  static const List<int> access = [0x00, 0x20, 0x33];

  /// Elektron.
  static const List<int> elektron = [0x00, 0x20, 0x3C];

  /// Arturia.
  static const List<int> arturia = [0x00, 0x20, 0x6B];

  /// Native Instruments.
  static const List<int> nativeInstruments = [0x00, 0x21, 0x09];

  /// Ableton.
  static const List<int> ableton = [0x00, 0x21, 0x1D];

  /// Bome Software.
  static const List<int> bome = [0x00, 0x21, 0x32];

  // ...........................................................................
  /// Returns whether [data] starts with a three-byte id.
  static bool isThreeByte(List<int> data) =>
      data.isNotEmpty && data[0] == threeBytePrefix;

  /// Returns the number of bytes of the id at the start of [data]: 3 for a
  /// three-byte id, otherwise 1.
  ///
  /// Throws an [ArgumentError] when [data] is empty.
  static int idLength(List<int> data) {
    if (data.isEmpty) {
      throw ArgumentError.value(data, 'data', 'No manufacturer id');
    }
    return isThreeByte(data) ? 3 : 1;
  }

  /// Returns the one- or three-byte id at the start of [data].
  ///
  /// Throws an [ArgumentError] when [data] is shorter than its id or an id
  /// byte is no 7-bit value.
  static List<int> idOf(List<int> data) {
    final length = idLength(data);
    final id = data.take(length).toList();
    if (id.length < length || id.any((b) => b < 0 || b > 0x7F)) {
      throw ArgumentError.value(data, 'data', 'Invalid manufacturer id');
    }
    return List.unmodifiable(id);
  }

  // ...........................................................................
  /// Returns the 16-bit form of the id at the start of [data]
  /// (M2-104-UM 7.10): one-byte ids keep their value, three-byte ids put
  /// their second and third byte into the high and low byte and set the
  /// top bit.
  ///
  /// Throws an [ArgumentError] like [idOf].
  static int toSixteenBit(List<int> data) {
    final id = idOf(data);
    return id.length == 3 ? 0x8000 | (id[1] << 8) | id[2] : id[0];
  }

  /// Returns the one- or three-byte id of the 16-bit [id]
  /// (M2-104-UM 7.10).
  ///
  /// The reserved value 0x0000 returns `[0x00]`. Throws a [RangeError] when
  /// [id] is outside 0 to 0xFFFF.
  static List<int> fromSixteenBit(int id) {
    RangeError.checkValueInInterval(id, 0, 0xFFFF, 'id');
    return List.unmodifiable(
      (id & 0x8000) == 0 ? [id & 0x7F] : [0x00, (id >> 8) & 0x7F, id & 0x7F],
    );
  }

  // ...........................................................................
  /// Returns the three-byte form of the id at the start of [data] used by
  /// device identities (M2-104-UM 7.1.3): one-byte ids are followed by two
  /// zeros.
  ///
  /// Throws an [ArgumentError] like [idOf].
  static List<int> toThreeBytes(List<int> data) {
    final id = idOf(data);
    return id.length == 3 ? id : List.unmodifiable([id[0], 0x00, 0x00]);
  }

  /// Returns the one- or three-byte id of the three-byte device identity
  /// form [bytes]; it reverses [toThreeBytes].
  ///
  /// Throws an [ArgumentError] when [bytes] does not hold three bytes.
  static List<int> fromThreeBytes(List<int> bytes) {
    if (bytes.length != 3) {
      throw ArgumentError.value(bytes, 'bytes', 'Not three bytes');
    }
    return idOf(bytes);
  }

  // ...........................................................................
  /// Returns the name of the manufacturer or special id at the start of
  /// [data], e.g. `'Roland'`, or null for an id not in this selection.
  ///
  /// Throws an [ArgumentError] like [idOf].
  static String? name(List<int> data) => _names[toSixteenBit(data)];

  // ...........................................................................
  /// The names of the ids by their 16-bit form.
  static const Map<int, String> _names = {
    nonCommercial: 'Non-Commercial',
    universalNonRealTime: 'Universal Non-Real Time',
    universalRealTime: 'Universal Real Time',
    0x0001: 'Sequential',
    0x0004: 'Moog Music',
    0x0007: 'Kurzweil',
    0x000F: 'Ensoniq',
    0x0010: 'Oberheim',
    0x0011: 'Apple',
    0x0018: 'E-mu Systems',
    0x0033: 'Clavia',
    0x003E: 'Waldorf',
    0x0040: 'Kawai',
    0x0041: 'Roland',
    0x0042: 'Korg',
    0x0043: 'Yamaha',
    0x0044: 'Casio',
    0x0047: 'Akai',
    0x800E: 'Alesis',
    0x803B: 'Mark of the Unicorn',
    0xA029: 'Novation',
    0xA032: 'Behringer',
    0xA033: 'Access Music',
    0xA03C: 'Elektron',
    0xA06B: 'Arturia',
    0xA109: 'Native Instruments',
    0xA11D: 'Ableton',
    0xA132: 'Bome Software',
  };
}
