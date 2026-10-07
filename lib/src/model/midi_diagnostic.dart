// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_diagnostic_kind.dart';
import 'midi_json_reader.dart';
import 'midi_port_id.dart';
import 'midi_time.dart';

// #############################################################################
/// A report of data loss or a fault.
///
/// Streams of the package never error; every loss becomes a diagnostic
/// instead.
final class MidiDiagnostic {
  /// Creates a diagnostic.
  ///
  /// - [port] the port affected, null when the loss concerns no port.
  /// - [count] the number of losses, e.g. dropped messages or packets.
  /// - [cause] a human-readable explanation.
  /// - [time] the time on the package clock the loss was detected at.
  const MidiDiagnostic({
    required this.kind,
    this.port,
    this.count = 1,
    required this.cause,
    required this.time,
  });

  // ...........................................................................
  /// Decodes a diagnostic that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type; `port` may be missing.
  factory MidiDiagnostic.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiDiagnostic');
    return MidiDiagnostic(
      kind: reader.enumValue('kind', MidiDiagnosticKind.values),
      port: reader.value<MidiPortId?>('port'),
      count: reader.value<int>('count'),
      cause: reader.value<String>('cause'),
      time: reader.value<MidiTime>('time'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  ///
  /// - [clearPort] sets [port] to null; it wins over a given port.
  MidiDiagnostic copyWith({
    MidiDiagnosticKind? kind,
    MidiPortId? port,
    bool clearPort = false,
    int? count,
    String? cause,
    MidiTime? time,
  }) => MidiDiagnostic(
    kind: kind ?? this.kind,
    port: clearPort ? null : port ?? this.port,
    count: count ?? this.count,
    cause: cause ?? this.cause,
    time: time ?? this.time,
  );

  /// Returns the diagnostic as a JSON map; the time in microseconds.
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'port': port?.value,
    'count': count,
    'cause': cause,
    'time': time.microseconds,
  };

  // ...........................................................................
  /// The kind of the loss or fault.
  final MidiDiagnosticKind kind;

  /// The port affected, or null when the loss concerns no port.
  final MidiPortId? port;

  /// The number of losses, e.g. dropped messages or packets.
  final int count;

  /// A human-readable explanation.
  final String cause;

  /// The time on the package clock the loss was detected at.
  final MidiTime time;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiDiagnostic &&
          other.kind == kind &&
          other.port == port &&
          other.count == count &&
          other.cause == cause &&
          other.time == time;

  @override
  int get hashCode => Object.hash(kind, port, count, cause, time);

  @override
  String toString() =>
      'MidiDiagnostic(kind: ${kind.name}, port: $port, count: $count, '
      "cause: '$cause', time: ${time.microseconds})";
}
