// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:typed_data';

import '../model/midi_time.dart';
import 'midi_byte_encoder.dart';
import 'midi_timed_message.dart';

// #############################################################################
/// Encodes messages into the packets of a BLE-MIDI characteristic
/// (Specification for MIDI over Bluetooth Low Energy, BLE-MIDI 1.0).
///
/// Each packet starts with a header byte; every message carries a 13-bit
/// millisecond timestamp. Long System Exclusive messages span packets.
///
/// The encoder fills each packet with as many whole messages as fit and
/// never uses running status, so every message starts with a timestamp and
/// a status byte. A message starts a new packet when it does not fit, when
/// it is earlier than the message before it, or when it is 128 ms or more
/// after it, since the timestamps of one packet only advance by less than
/// 128 ms from one to the next. A System Exclusive continues in packets
/// that hold its data bytes right after the header; its 0xF7 gets the
/// timestamp of its 0xF0.
final class MidiBleEncoder {
  /// Creates an encoder for packets of at most [maxPacketLength] bytes,
  /// the negotiated ATT MTU minus 3; at least 5 bytes.
  MidiBleEncoder({this.maxPacketLength = 20}) : assert(maxPacketLength >= 5);

  // ...........................................................................
  /// Encodes [messages], each with the time it is due, into packets.
  ///
  /// Messages without a MIDI 1.0 byte form are skipped.
  List<Uint8List> encode(List<MidiTimedMessage> messages) {
    final writer = _PacketWriter(maxPacketLength);
    for (final (:message, :time) in messages) {
      final bytes = MidiByteEncoder.encode(message)?.bytes;
      if (bytes != null) writer.write(bytes, _milliseconds(time));
    }
    return writer.finish();
  }

  // ...........................................................................
  /// The largest packet, in bytes.
  final int maxPacketLength;

  // ...........................................................................
  /// Returns [time] in whole milliseconds, rounded down.
  static int _milliseconds(MidiTime time) {
    final microseconds = time.microseconds;
    return (microseconds - microseconds % 1000) ~/ 1000;
  }
}

// #############################################################################
/// Writes the bytes of messages into BLE-MIDI packets.
final class _PacketWriter {
  /// Creates a writer of packets of at most [maxLength] bytes.
  _PacketWriter(this.maxLength);

  /// Writes the MIDI 1.0 [bytes] of a message due at [milliseconds].
  void write(List<int> bytes, int milliseconds) {
    if (bytes.first == 0xF0) return _sysEx(bytes, milliseconds);
    _reserve(1 + bytes.length, milliseconds);
    _packet
      ..add(_timestamp(milliseconds))
      ..addAll(bytes);
  }

  /// Returns all packets written.
  List<Uint8List> finish() {
    _flush();
    return _packets;
  }

  /// The largest packet, in bytes.
  final int maxLength;

  // ...........................................................................
  /// The completed packets.
  final _packets = <Uint8List>[];

  /// The packet being filled.
  final _packet = <int>[];

  /// The time of the first timestamp of [_packet].
  int _first = 0;

  /// The time of the last timestamp of [_packet].
  int _last = 0;

  /// Writes the System Exclusive [bytes], 0xF0 to 0xF7, due at
  /// [milliseconds], and continues it in new packets as needed.
  void _sysEx(List<int> bytes, int milliseconds) {
    _reserve(3, milliseconds);
    _packet
      ..add(_timestamp(milliseconds))
      ..add(0xF0);
    for (final byte in bytes.sublist(1, bytes.length - 1)) {
      if (_packet.length == maxLength) _start(milliseconds);
      _packet.add(byte);
    }
    if (_packet.length + 2 > maxLength) _start(milliseconds);
    _packet
      ..add(_timestamp(milliseconds))
      ..add(0xF7);
  }

  /// Makes room for [length] bytes stamped at [milliseconds], in the
  /// current packet if they fit, else in a new one.
  void _reserve(int length, int milliseconds) {
    final fits =
        _packet.isNotEmpty &&
        _packet.length + length <= maxLength &&
        milliseconds >= _last &&
        milliseconds - _last < 128 &&
        milliseconds - _first < 0x2000;
    if (!fits) return _start(milliseconds);
    _last = milliseconds;
  }

  /// Completes the current packet and starts a new one at [milliseconds].
  void _start(int milliseconds) {
    _flush();
    _packet.add(0x80 | (milliseconds >> 7) & 0x3F);
    _first = _last = milliseconds;
  }

  /// Adds the current packet, if any, to the completed packets.
  void _flush() {
    if (_packet.isEmpty) return;
    _packets.add(Uint8List.fromList(_packet));
    _packet.clear();
  }

  /// Returns the timestamp byte of [milliseconds].
  static int _timestamp(int milliseconds) => 0x80 | milliseconds & 0x7F;
}
