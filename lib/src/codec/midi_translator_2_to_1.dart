// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../message/midi_message.dart';
import '../model/midi_diagnostic_kind.dart';
import 'midi_timed_message.dart';
import 'midi_value_scaling.dart';

// #############################################################################
/// Translates MIDI 2.0 protocol messages to the MIDI 1.0 protocol with the
/// default translation of M2-104-UM Appendix D.2.
///
/// In detail:
///
/// - Values are scaled down by cutting off the low bits; a Note On whose
///   velocity becomes 0 gets velocity 1.
/// - A Registered Controller becomes the controllers 101, 100, 6 and 38, an
///   Assignable Controller the controllers 99, 98, 6 and 38, with the top 14
///   bits of the value as Data Entry MSB and LSB.
/// - A Program Change with bank becomes Bank Select MSB (0) and LSB (32)
///   followed by the Program Change.
/// - Relative controllers, per-note controllers, per-note management and
///   per-note pitch bend have no MIDI 1.0 equivalent (M2-104-UM D.2.8);
///   they are dropped and reported as [MidiDiagnosticKind.untranslatable].
/// - All other messages are valid in both protocols and are returned
///   unchanged; the MIDI 1.0 protocol in UMP may also carry utility, flex
///   data, stream, System Exclusive 8 and Mixed Data Set messages
///   (M2-104-UM 3.2.1.2).
final class MidiTranslator2To1 {
  /// Creates a translator; [onIssue] receives the messages that have no
  /// MIDI 1.0 equivalent and were dropped.
  MidiTranslator2To1({this.onIssue});

  // ...........................................................................
  /// Translates [message] and returns zero or more MIDI 1.0 protocol
  /// messages.
  ///
  /// Messages that are valid in both protocols are returned unchanged;
  /// messages without a MIDI 1.0 equivalent yield an empty list.
  List<MidiMessage> translate(MidiMessage message) => switch (message) {
    MidiNoteOff2(:final channel, :final note, :final velocity) => [
      MidiNoteOff(channel: channel, note: note, velocity: _down16(velocity)),
    ],
    MidiNoteOn2(:final channel, :final note, :final velocity) => [
      MidiNoteOn(
        channel: channel,
        note: note,
        velocity: _down16(velocity).clamp(1, 0x7F),
      ),
    ],
    MidiPolyPressure2(:final channel, :final note, :final pressure) => [
      MidiPolyPressure(
        channel: channel,
        note: note,
        pressure: _down32(pressure),
      ),
    ],
    MidiControlChange2(:final channel, :final controller, :final value) => [
      MidiControlChange(
        channel: channel,
        controller: controller,
        value: _down32(value),
      ),
    ],
    MidiRegisteredController(
      :final channel,
      :final bank,
      :final index,
      :final value,
    ) =>
      _parameter(channel, 101, 100, bank, index, value),
    MidiAssignableController(
      :final channel,
      :final bank,
      :final index,
      :final value,
    ) =>
      _parameter(channel, 99, 98, bank, index, value),
    MidiProgramChange2(:final channel, :final program, :final bank) => [
      if (bank != null) ...[
        MidiControlChange(
          channel: channel,
          controller: 0,
          value: bank.msb & 0x7F,
        ),
        MidiControlChange(
          channel: channel,
          controller: 32,
          value: bank.lsb & 0x7F,
        ),
      ],
      MidiProgramChange(channel: channel, program: program),
    ],
    MidiChannelPressure2(:final channel, :final pressure) => [
      MidiChannelPressure(channel: channel, pressure: _down32(pressure)),
    ],
    MidiPitchBend2(:final channel, :final value) => [
      MidiPitchBend(
        channel: channel,
        value: MidiValueScaling.scaleDown(value, fromBits: 32, toBits: 14),
      ),
    ],
    MidiRegisteredPerNoteController() ||
    MidiAssignablePerNoteController() ||
    MidiPerNoteManagement() ||
    MidiRelativeRegisteredController() ||
    MidiRelativeAssignableController() ||
    MidiPerNotePitchBend() => _untranslatable(message),
    _ => [message],
  };

  // ...........................................................................
  /// Receives the messages that were dropped.
  final MidiIssueCallback? onIssue;

  // ######################
  // Private
  // ######################

  /// Returns the MIDI 1.0 controllers that select the parameter [bank] and
  /// [index] with [msbController] and [lsbController] and set it to the
  /// top 14 bits of [value].
  static List<MidiMessage> _parameter(
    int channel,
    int msbController,
    int lsbController,
    int bank,
    int index,
    int value,
  ) {
    final data = MidiValueScaling.scaleDown(value, fromBits: 32, toBits: 14);
    return [
      for (final (controller, controllerValue) in [
        (msbController, bank),
        (lsbController, index),
        (6, data >> 7),
        (38, data & 0x7F),
      ])
        MidiControlChange(
          channel: channel,
          controller: controller,
          value: controllerValue,
        ),
    ];
  }

  /// Reports [message] as untranslatable and returns no message.
  List<MidiMessage> _untranslatable(MidiMessage message) {
    onIssue?.call(
      MidiDiagnosticKind.untranslatable,
      '$message has no MIDI 1.0 equivalent',
    );
    return const [];
  }

  /// Scales a 16-bit [value] down to 7 bits.
  static int _down16(int value) =>
      MidiValueScaling.scaleDown(value, fromBits: 16, toBits: 7);

  /// Scales a 32-bit [value] down to 7 bits.
  static int _down32(int value) =>
      MidiValueScaling.scaleDown(value, fromBits: 32, toBits: 7);
}
