// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

part of 'midi_message.dart';

// #############################################################################
/// A complete System Exclusive message with 7-bit data: 0xF0 ... 0xF7 in a
/// byte stream, UMP message type 0x3 (MIDI 1.0 Detailed Specification,
/// M2-104-UM 7.7).
///
/// Fragmented transfers are reassembled by the parsers; this class always
/// holds the whole message.
final class MidiSysEx extends MidiMessage {
  /// Creates a System Exclusive message from a copy of [data], the bytes
  /// between 0xF0 and 0xF7, starting with the manufacturer id.
  MidiSysEx(Iterable<int> data) : data = _bytes(data) {
    assert(this.data.every((b) => b <= 0x7F));
  }

  // ...........................................................................
  /// The 7-bit data bytes without 0xF0 and 0xF7; cannot be modified.
  final Uint8List data;

  @override
  UmpMessageType get umpMessageType => UmpMessageType.data64;

  @override
  Map<String, Object?> get _fields => {'data': data};
}

// #############################################################################
/// A complete System Exclusive 8 message with 8-bit data, UMP message type
/// 0x5 (M2-104-UM 7.8).
///
/// It has no MIDI 1.0 byte form.
final class MidiSysEx8 extends MidiMessage {
  /// Creates a System Exclusive 8 message of [streamId] from a copy of
  /// [data], the bytes after the stream id, starting with the 16-bit
  /// manufacturer id.
  MidiSysEx8({required this.streamId, required Iterable<int> data})
    : data = _bytes(data) {
    assert(streamId >= 0 && streamId <= 0xFF);
  }

  // ...........................................................................
  /// The stream id, 0 to 255; it allows interleaving of messages.
  final int streamId;

  /// The 8-bit data bytes after the stream id; cannot be modified.
  final Uint8List data;

  @override
  UmpMessageType get umpMessageType => UmpMessageType.data128;

  @override
  Map<String, Object?> get _fields => {'streamId': streamId, 'data': data};
}

// #############################################################################
/// A complete Mixed Data Set, UMP message type 0x5 (M2-104-UM 7.9).
///
/// A set carries any payload, e.g. files or firmware, in chunks of header
/// and payload packets; the decoder reassembles all chunks into one
/// message. It has no MIDI 1.0 byte form.
final class MidiMixedDataSet extends MidiMessage {
  /// Creates a Mixed Data Set of [mdsId] with a copy of [data].
  MidiMixedDataSet({
    required this.mdsId,
    required this.manufacturerId,
    required this.deviceId,
    required this.subId1,
    required this.subId2,
    required Iterable<int> data,
  }) : data = _bytes(data) {
    assert(mdsId >= 0 && mdsId <= 0xF);
    assert(manufacturerId >= 0 && manufacturerId <= 0xFFFF);
    assert(deviceId >= 0 && deviceId <= 0xFFFF);
    assert(subId1 >= 0 && subId1 <= 0xFFFF);
    assert(subId2 >= 0 && subId2 <= 0xFFFF);
  }

  // ...........................................................................
  /// The id that ties the chunks of the set together, 0 to 15.
  final int mdsId;

  /// The 16-bit manufacturer id (M2-104-UM 7.10).
  final int manufacturerId;

  /// The 16-bit device id.
  final int deviceId;

  /// The 16-bit sub id 1.
  final int subId1;

  /// The 16-bit sub id 2.
  final int subId2;

  /// The payload of all chunks; cannot be modified.
  final Uint8List data;

  @override
  UmpMessageType get umpMessageType => UmpMessageType.data128;

  @override
  Map<String, Object?> get _fields => {
    'mdsId': mdsId,
    'manufacturerId': manufacturerId,
    'deviceId': deviceId,
    'subId1': subId1,
    'subId2': subId2,
    'data': data,
  };
}
