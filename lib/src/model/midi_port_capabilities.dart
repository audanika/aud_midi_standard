// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_json_reader.dart';

// #############################################################################
/// What a single port can do beyond plain sending and receiving.
///
/// Backends probe these flags per port. Every flag is false unless the
/// backend states otherwise.
final class MidiPortCapabilities {
  /// Creates the capabilities of a port.
  const MidiPortCapabilities({
    this.timestampsIn = false,
    this.scheduledSend = false,
    this.cancelPending = false,
    this.ump = false,
    this.sysEx8 = false,
  });

  // ...........................................................................
  /// Decodes capabilities that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type.
  factory MidiPortCapabilities.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiPortCapabilities');
    return MidiPortCapabilities(
      timestampsIn: reader.value<bool>('timestampsIn'),
      scheduledSend: reader.value<bool>('scheduledSend'),
      cancelPending: reader.value<bool>('cancelPending'),
      ump: reader.value<bool>('ump'),
      sysEx8: reader.value<bool>('sysEx8'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiPortCapabilities copyWith({
    bool? timestampsIn,
    bool? scheduledSend,
    bool? cancelPending,
    bool? ump,
    bool? sysEx8,
  }) => MidiPortCapabilities(
    timestampsIn: timestampsIn ?? this.timestampsIn,
    scheduledSend: scheduledSend ?? this.scheduledSend,
    cancelPending: cancelPending ?? this.cancelPending,
    ump: ump ?? this.ump,
    sysEx8: sysEx8 ?? this.sysEx8,
  );

  /// Returns the capabilities as a JSON map.
  Map<String, Object?> toJson() => {
    'timestampsIn': timestampsIn,
    'scheduledSend': scheduledSend,
    'cancelPending': cancelPending,
    'ump': ump,
    'sysEx8': sysEx8,
  };

  // ...........................................................................
  /// Whether input events carry the receive time of the operating system
  /// instead of the time the package saw them.
  final bool timestampsIn;

  /// Whether the port accepts messages for a later time and sends them when
  /// they are due.
  final bool scheduledSend;

  /// Whether messages scheduled on the port can be discarded before they
  /// are sent.
  final bool cancelPending;

  /// Whether the backend exchanges Universal MIDI Packets with this port
  /// instead of MIDI 1.0 bytes.
  final bool ump;

  /// Whether the port carries System Exclusive 8 messages.
  final bool sysEx8;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiPortCapabilities &&
          other.timestampsIn == timestampsIn &&
          other.scheduledSend == scheduledSend &&
          other.cancelPending == cancelPending &&
          other.ump == ump &&
          other.sysEx8 == sysEx8;

  @override
  int get hashCode =>
      Object.hash(timestampsIn, scheduledSend, cancelPending, ump, sysEx8);

  @override
  String toString() =>
      'MidiPortCapabilities(timestampsIn: $timestampsIn, '
      'scheduledSend: $scheduledSend, cancelPending: $cancelPending, '
      'ump: $ump, sysEx8: $sysEx8)';
}
