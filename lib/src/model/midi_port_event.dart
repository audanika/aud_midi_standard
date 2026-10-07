// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_json_reader.dart';
import 'midi_port_info.dart';

// #############################################################################
/// A change of the set of ports: a port was added, removed or changed.
///
/// The JSON form names the kind of change in its `type` key: `added`,
/// `removed` or `changed`.
sealed class MidiPortEvent {
  /// Creates an event about [port].
  const MidiPortEvent({required this.port});

  // ...........................................................................
  /// Decodes an event that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing, has the wrong type
  /// or `type` names no known event.
  factory MidiPortEvent.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiPortEvent');
    final type = reader.oneOf('type', const ['added', 'removed', 'changed']);
    final port = reader.object('port', MidiPortInfo.fromJson);
    return switch (type) {
      'added' => MidiPortAdded(port: port),
      'removed' => MidiPortRemoved(port: port),
      _ => MidiPortChanged(
        port: port,
        previous: reader.object('previous', MidiPortInfo.fromJson),
      ),
    };
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  MidiPortEvent copyWith({MidiPortInfo? port});

  /// Returns the event as a JSON map.
  Map<String, Object?> toJson();

  // ...........................................................................
  /// The port the event is about, as it is after the change.
  final MidiPortInfo port;
}

// #############################################################################
/// A port appeared, e.g. its device was plugged in.
final class MidiPortAdded extends MidiPortEvent {
  /// Creates the event that [port] appeared.
  const MidiPortAdded({required super.port});

  // ...........................................................................
  @override
  MidiPortAdded copyWith({MidiPortInfo? port}) =>
      MidiPortAdded(port: port ?? this.port);

  @override
  Map<String, Object?> toJson() => {'type': 'added', 'port': port.toJson()};

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MidiPortAdded && other.port == port;

  @override
  int get hashCode => Object.hash(MidiPortAdded, port);

  @override
  String toString() => 'MidiPortAdded(port: $port)';
}

// #############################################################################
/// A port disappeared, e.g. its device was unplugged.
final class MidiPortRemoved extends MidiPortEvent {
  /// Creates the event that [port] disappeared.
  const MidiPortRemoved({required super.port});

  // ...........................................................................
  @override
  MidiPortRemoved copyWith({MidiPortInfo? port}) =>
      MidiPortRemoved(port: port ?? this.port);

  @override
  Map<String, Object?> toJson() => {'type': 'removed', 'port': port.toJson()};

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MidiPortRemoved && other.port == port;

  @override
  int get hashCode => Object.hash(MidiPortRemoved, port);

  @override
  String toString() => 'MidiPortRemoved(port: $port)';
}

// #############################################################################
/// A port changed, e.g. its name, its state or its function blocks.
final class MidiPortChanged extends MidiPortEvent {
  /// Creates the event that [previous] changed into [port].
  const MidiPortChanged({required super.port, required this.previous});

  // ...........................................................................
  @override
  MidiPortChanged copyWith({MidiPortInfo? port, MidiPortInfo? previous}) =>
      MidiPortChanged(
        port: port ?? this.port,
        previous: previous ?? this.previous,
      );

  @override
  Map<String, Object?> toJson() => {
    'type': 'changed',
    'port': port.toJson(),
    'previous': previous.toJson(),
  };

  // ...........................................................................
  /// The port as it was before the change.
  final MidiPortInfo previous;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiPortChanged &&
          other.port == port &&
          other.previous == previous;

  @override
  int get hashCode => Object.hash(MidiPortChanged, port, previous);

  @override
  String toString() => 'MidiPortChanged(port: $port, previous: $previous)';
}
