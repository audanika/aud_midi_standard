// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../message/midi_message.dart';
import 'midi_value_scaling.dart';

// #############################################################################
/// Translates MIDI 1.0 protocol messages to the MIDI 2.0 protocol with the
/// default translation of M2-104-UM Appendix D.3.
///
/// The translator keeps the context of a stream per group and channel:
/// Bank Select values wait for the next Program Change, RPN and NRPN
/// selections and Data Entry MSB wait for Data Entry LSB.
///
/// In detail:
///
/// - Note On with velocity 0 becomes Note Off with velocity 0; other
///   velocities and all controller and pressure values are scaled up with
///   the min-center-max method.
/// - Bank Select MSB and LSB (controllers 0 and 32) are held and sent with
///   every following Program Change; a missing half counts as 0.
/// - RPN and NRPN selections (controllers 101, 100, 99, 98) and Data Entry
///   MSB (controller 6) are held. Data Entry LSB (controller 38) sends a
///   Registered or Assignable Controller with the 14-bit value scaled up to
///   32 bits; the MSB stays valid for further LSBs. A new selection
///   forgets the Data Entry MSB. Nothing is sent without a complete
///   selection, without Data Entry MSB or for the null function 127/127.
/// - Data Increment and Decrement (controllers 96 and 97) and all other
///   controllers become MIDI 2.0 Control Change messages.
final class MidiTranslator1To2 {
  /// Creates a translator.
  ///
  /// - [flushDataEntryMsb] also sends a registered or assignable
  ///   controller when a new RPN or NRPN is selected after a Data Entry MSB
  ///   without LSB. This alternate translation (M2-104-UM D.4) serves
  ///   senders that never send Data Entry LSB.
  MidiTranslator1To2({this.flushDataEntryMsb = false});

  // ...........................................................................
  /// Translates [message] received on [group] and returns zero or more
  /// MIDI 2.0 protocol messages.
  ///
  /// Messages that are valid in both protocols are returned unchanged.
  List<MidiMessage> translate(MidiMessage message, {int group = 0}) =>
      switch (message) {
        MidiNoteOn(:final channel, :final note, velocity: 0) => [
          MidiNoteOff2(channel: channel, note: note, velocity: 0),
        ],
        MidiNoteOn(:final channel, :final note, :final velocity) => [
          MidiNoteOn2(channel: channel, note: note, velocity: _up16(velocity)),
        ],
        MidiNoteOff(:final channel, :final note, :final velocity) => [
          MidiNoteOff2(channel: channel, note: note, velocity: _up16(velocity)),
        ],
        MidiPolyPressure(:final channel, :final note, :final pressure) => [
          MidiPolyPressure2(
            channel: channel,
            note: note,
            pressure: _up32(pressure),
          ),
        ],
        MidiControlChange() => _controlChange(message, group),
        MidiProgramChange(:final channel, :final program) => [
          MidiProgramChange2(
            channel: channel,
            program: program,
            bank: _state(group, channel).bank,
          ),
        ],
        MidiChannelPressure(:final channel, :final pressure) => [
          MidiChannelPressure2(channel: channel, pressure: _up32(pressure)),
        ],
        MidiPitchBend(:final channel, :final value) => [
          MidiPitchBend2(
            channel: channel,
            value: MidiValueScaling.scaleUp(value, fromBits: 14, toBits: 32),
          ),
        ],
        _ => [message],
      };

  // ...........................................................................
  /// Forgets the context of all groups and channels.
  void reset() => _states.clear();

  // ...........................................................................
  /// Whether a Data Entry MSB without LSB is sent on a new selection.
  final bool flushDataEntryMsb;

  // ######################
  // Private
  // ######################

  /// The context per group and channel, by group * 16 + channel.
  final _states = <int, _ChannelState>{};

  /// Returns the context of [channel] on [group].
  _ChannelState _state(int group, int channel) =>
      _states.putIfAbsent((group & 0xF) << 4 | channel, _ChannelState.new);

  /// Translates the Control Change [message] received on [group].
  List<MidiMessage> _controlChange(MidiControlChange message, int group) {
    final MidiControlChange(:channel, :controller, :value) = message;
    final state = _state(group, channel);
    switch (controller) {
      case 0:
        state.bankMsb = value;
      case 32:
        state.bankLsb = value;
      case 6:
        state
          ..dataMsb = value
          ..dataPending = true;
      case 38:
        return _dataEntry(state, channel, value);
      case 98 || 99 || 100 || 101:
        return _select(state, channel, controller, value);
      default:
        return [
          MidiControlChange2(
            channel: channel,
            controller: controller,
            value: _up32(value),
          ),
        ];
    }
    return const [];
  }

  /// Sends the parameter of [state] with the held Data Entry MSB and
  /// [lsb].
  List<MidiMessage> _dataEntry(_ChannelState state, int channel, int lsb) {
    final msb = state.dataMsb;
    if (msb == null) return const [];
    state.dataPending = false;
    return _parameter(state, channel, msb << 7 | lsb);
  }

  /// Holds the RPN or NRPN selection of [controller] with [value]; flushes
  /// a pending Data Entry MSB first with [flushDataEntryMsb].
  List<MidiMessage> _select(
    _ChannelState state,
    int channel,
    int controller,
    int value,
  ) {
    final flushed = flushDataEntryMsb && state.dataPending
        ? _parameter(state, channel, state.dataMsb! << 7)
        : const <MidiMessage>[];
    state
      ..registered = controller >= 100
      ..dataMsb = null
      ..dataPending = false;
    switch (controller) {
      case 101:
        state.rpnMsb = value;
      case 100:
        state.rpnLsb = value;
      case 99:
        state.nrpnMsb = value;
      default:
        state.nrpnLsb = value;
    }
    return flushed;
  }

  /// Returns the Registered or Assignable Controller of the selection of
  /// [state] with the 14-bit [value], or nothing without a valid selection.
  List<MidiMessage> _parameter(_ChannelState state, int channel, int value) {
    final registered = state.registered;
    final bank = registered ? state.rpnMsb : state.nrpnMsb;
    final index = registered ? state.rpnLsb : state.nrpnLsb;
    if (bank == null || index == null || (bank == 0x7F && index == 0x7F)) {
      return const [];
    }
    final scaled = MidiValueScaling.scaleUp(value, fromBits: 14, toBits: 32);
    return [
      registered
          ? MidiRegisteredController(
              channel: channel,
              bank: bank,
              index: index,
              value: scaled,
            )
          : MidiAssignableController(
              channel: channel,
              bank: bank,
              index: index,
              value: scaled,
            ),
    ];
  }

  /// Scales a 7-bit [value] up to 16 bits.
  static int _up16(int value) =>
      MidiValueScaling.scaleUp(value, fromBits: 7, toBits: 16);

  /// Scales a 7-bit [value] up to 32 bits.
  static int _up32(int value) =>
      MidiValueScaling.scaleUp(value, fromBits: 7, toBits: 32);
}

// #############################################################################
/// The translation context of one channel of one group.
final class _ChannelState {
  /// The held Bank Select MSB.
  int? bankMsb;

  /// The held Bank Select LSB.
  int? bankLsb;

  /// Whether the last selection was an RPN rather than an NRPN.
  bool registered = true;

  /// The held RPN MSB, controller 101.
  int? rpnMsb;

  /// The held RPN LSB, controller 100.
  int? rpnLsb;

  /// The held NRPN MSB, controller 99.
  int? nrpnMsb;

  /// The held NRPN LSB, controller 98.
  int? nrpnLsb;

  /// The held Data Entry MSB, controller 6.
  int? dataMsb;

  /// Whether [dataMsb] arrived after the last parameter was sent.
  bool dataPending = false;

  /// The bank for a Program Change, or null when no Bank Select arrived.
  ({int msb, int lsb})? get bank => bankMsb == null && bankLsb == null
      ? null
      : (msb: bankMsb ?? 0, lsb: bankLsb ?? 0);
}
