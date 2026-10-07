// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

part of 'midi_message.dart';

// #############################################################################
/// A message the package does not interpret: a reserved message type or an
/// undefined status, kept as its packets.
///
/// Decoders deliver such messages instead of dropping them, so routers can
/// pass them on unchanged. Encoding returns the packets as they are, with
/// the group of the first packet kept.
final class MidiUnknownMessage extends MidiMessage {
  /// Creates an unknown message from its [umps].
  MidiUnknownMessage(Iterable<Ump> umps) : umps = List.unmodifiable(umps) {
    assert(this.umps.isNotEmpty);
  }

  // ...........................................................................
  /// The packets of the message; cannot be modified.
  final List<Ump> umps;

  @override
  UmpMessageType get umpMessageType => umps.first.messageType;

  @override
  Map<String, Object?> get _fields => {'umps': umps};
}
