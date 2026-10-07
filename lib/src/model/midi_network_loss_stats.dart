// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_json_reader.dart';

// #############################################################################
/// The packet statistics of a network MIDI connection.
///
/// All counts start at zero when the connection is established.
final class MidiNetworkLossStats {
  /// Creates the statistics of a connection.
  const MidiNetworkLossStats({
    this.packetsReceived = 0,
    this.packetsLost = 0,
    this.packetsRecovered = 0,
    this.journalRepairs = 0,
  });

  // ...........................................................................
  /// Decodes statistics that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type.
  factory MidiNetworkLossStats.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiNetworkLossStats');
    return MidiNetworkLossStats(
      packetsReceived: reader.value<int>('packetsReceived'),
      packetsLost: reader.value<int>('packetsLost'),
      packetsRecovered: reader.value<int>('packetsRecovered'),
      journalRepairs: reader.value<int>('journalRepairs'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiNetworkLossStats copyWith({
    int? packetsReceived,
    int? packetsLost,
    int? packetsRecovered,
    int? journalRepairs,
  }) => MidiNetworkLossStats(
    packetsReceived: packetsReceived ?? this.packetsReceived,
    packetsLost: packetsLost ?? this.packetsLost,
    packetsRecovered: packetsRecovered ?? this.packetsRecovered,
    journalRepairs: journalRepairs ?? this.journalRepairs,
  );

  /// Returns the statistics as a JSON map.
  Map<String, Object?> toJson() => {
    'packetsReceived': packetsReceived,
    'packetsLost': packetsLost,
    'packetsRecovered': packetsRecovered,
    'journalRepairs': journalRepairs,
  };

  // ...........................................................................
  /// The number of packets received.
  final int packetsReceived;

  /// The number of packets that never arrived, detected by gaps in the
  /// sequence numbers.
  final int packetsLost;

  /// The number of lost packets whose messages were restored, e.g. by
  /// retransmission or forward error correction.
  final int packetsRecovered;

  /// The number of repairs applied from the RTP-MIDI recovery journal.
  final int journalRepairs;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiNetworkLossStats &&
          other.packetsReceived == packetsReceived &&
          other.packetsLost == packetsLost &&
          other.packetsRecovered == packetsRecovered &&
          other.journalRepairs == journalRepairs;

  @override
  int get hashCode => Object.hash(
    packetsReceived,
    packetsLost,
    packetsRecovered,
    journalRepairs,
  );

  @override
  String toString() =>
      'MidiNetworkLossStats(packetsReceived: $packetsReceived, '
      'packetsLost: $packetsLost, packetsRecovered: $packetsRecovered, '
      'journalRepairs: $journalRepairs)';
}
