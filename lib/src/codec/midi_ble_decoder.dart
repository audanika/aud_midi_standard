// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../model/midi_diagnostic_kind.dart';
import '../model/midi_time.dart';
import 'midi_byte_parser.dart';
import 'midi_timed_message.dart';

// #############################################################################
/// Decodes the packets of a BLE-MIDI characteristic into messages
/// (Specification for MIDI over Bluetooth Low Energy, BLE-MIDI 1.0).
///
/// The decoder handles running status within packets, System Exclusive
/// across packets and real-time messages between other bytes, and
/// reconstructs each message's time from the 13-bit millisecond timestamps.
///
/// A packet starts with a header byte `10hhhhhh` carrying the high six bits
/// of the timestamp. A timestamp byte `1lllllll` with the low seven bits
/// precedes every status byte; a byte with the top bit set is a timestamp
/// byte unless a timestamp byte precedes it. When the low bits decrease
/// within a packet, the high bits have advanced by one. The last timestamp
/// of a packet is taken as its receive time; earlier timestamps lie as many
/// milliseconds before it as they differ, modulo 8192. Running status, as
/// in a byte stream, also carries over to the next packet.
final class MidiBleDecoder {
  /// Creates a decoder; [onIssue] receives malformed packets and dropped
  /// bytes.
  MidiBleDecoder({this.maxSysExLength = 1 << 20, this.onIssue})
    : _parser = MidiByteParser(
        maxSysExLength: maxSysExLength,
        onIssue: onIssue,
      );

  // ...........................................................................
  /// Decodes [packet], one characteristic value received at [time], and
  /// returns the completed messages with their reconstructed times.
  ///
  /// A System Exclusive gets the time of the timestamp before its 0xF0.
  List<MidiTimedMessage> decode(
    List<int> packet, {
    MidiTime time = MidiTime.zero,
  }) {
    if (packet.isEmpty || packet[0] & 0x80 == 0) {
      _issue('BLE-MIDI packet without header byte');
      return const [];
    }
    final segments = _segments(packet);
    final last = segments.last.timestamp;
    if (last != null && segments.last.bytes.isEmpty) {
      _issue('BLE-MIDI timestamp without message');
    }
    return [
      for (final (:timestamp, :bytes) in segments)
        ..._parser.add(
          bytes,
          time: timestamp == null
              ? time
              : time - Duration(milliseconds: (last! - timestamp) & 0x1FFF),
        ),
    ];
  }

  // ...........................................................................
  /// Drops partial messages, e.g. after a reconnection.
  void reset() => _parser.reset();

  // ...........................................................................
  /// The largest System Exclusive accepted, in data bytes.
  final int maxSysExLength;

  /// Receives malformed packets and dropped bytes.
  final MidiIssueCallback? onIssue;

  // ######################
  // Private
  // ######################

  /// Parses the MIDI bytes without timestamps.
  final MidiByteParser _parser;

  /// Splits the bytes of [packet] after its header at the timestamp bytes;
  /// the first segment holds the bytes before the first timestamp.
  static List<({int? timestamp, List<int> bytes})> _segments(List<int> packet) {
    var high = packet[0] & 0x3F;
    int? low;
    final segments = <({int? timestamp, List<int> bytes})>[
      (timestamp: null, bytes: []),
    ];
    var afterTimestamp = false;
    for (final value in packet.skip(1)) {
      final byte = value & 0xFF;
      afterTimestamp = byte >= 0x80 && !afterTimestamp;
      if (!afterTimestamp) {
        segments.last.bytes.add(byte);
        continue;
      }
      if (low != null && byte & 0x7F < low) high = (high + 1) & 0x3F;
      low = byte & 0x7F;
      segments.add((timestamp: high << 7 | low, bytes: []));
    }
    return segments;
  }

  /// Reports invalid data with [cause].
  void _issue(String cause) =>
      onIssue?.call(MidiDiagnosticKind.invalidData, cause);
}
