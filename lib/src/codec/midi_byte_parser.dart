// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../message/midi_message.dart';
import '../model/midi_diagnostic_kind.dart';
import '../model/midi_time.dart';
import 'midi_short_message.dart';
import 'midi_timed_message.dart';

// #############################################################################
/// Parses a MIDI 1.0 byte stream into messages (MIDI 1.0 Detailed
/// Specification).
///
/// The parser handles running status, reassembles System Exclusive across
/// chunks up to a size limit and a maximum duration, and delivers real-time
/// messages in the order they arrive, even inside System Exclusive.
///
/// It follows the rules of the MIDI 1.0 specification:
///
/// - Channel voice status bytes set the running status; system common,
///   System Exclusive and undefined status bytes (0xF4, 0xF5) clear it.
///   Real-time bytes leave it, a partial message and System Exclusive
///   untouched.
/// - Any status byte other than real-time ends a System Exclusive, as if
///   0xF7 had been received; the System Exclusive is delivered complete.
/// - Undefined status bytes (0xF4, 0xF5, 0xF9, 0xFD), a stray 0xF7, data
///   bytes without status and messages cut short by a status byte are
///   skipped and reported as [MidiDiagnosticKind.invalidData].
final class MidiByteParser {
  /// Creates a parser.
  ///
  /// - [maxSysExLength] the largest System Exclusive accepted, in data
  ///   bytes; longer ones are dropped with [MidiIssueCallback] reporting
  ///   them.
  /// - [maxSysExDuration] the longest time a System Exclusive may stay
  ///   incomplete; null for no limit.
  /// - [noteOnZeroAsNoteOff] whether Note On with velocity 0 is delivered
  ///   as Note Off with velocity 64.
  /// - [onIssue] receives the bytes the parser had to drop.
  MidiByteParser({
    this.maxSysExLength = 1 << 20,
    this.maxSysExDuration,
    this.noteOnZeroAsNoteOff = false,
    this.onIssue,
  });

  // ...........................................................................
  /// Parses [bytes] received at [time] and returns the completed messages.
  ///
  /// Each message gets the time of the chunk that completed it; a System
  /// Exclusive gets the time of the chunk that started it. A System
  /// Exclusive still incomplete [maxSysExDuration] after its start is
  /// dropped when a later chunk arrives; its remaining bytes are skipped.
  List<MidiTimedMessage> add(List<int> bytes, {MidiTime time = MidiTime.zero}) {
    final messages = <MidiTimedMessage>[];
    _expireSysEx(time);
    for (final byte in bytes) {
      _parse(byte & 0xFF, time, messages);
    }
    _reportStray();
    return messages;
  }

  // ...........................................................................
  /// Drops partial messages and running status, e.g. after a gap in the
  /// stream.
  void reset() {
    _runningStatus = null;
    _status = null;
    _sysEx = null;
    _skipSysEx = false;
    _stray = 0;
  }

  // ...........................................................................
  /// The largest System Exclusive accepted, in data bytes.
  final int maxSysExLength;

  /// The longest time a System Exclusive may stay incomplete.
  final Duration? maxSysExDuration;

  /// Whether Note On with velocity 0 is delivered as Note Off.
  final bool noteOnZeroAsNoteOff;

  /// Receives the bytes the parser had to drop.
  final MidiIssueCallback? onIssue;

  // ######################
  // Private
  // ######################

  /// The channel voice status data bytes without status refer to.
  int? _runningStatus;

  /// The status of the message waiting for data bytes.
  int? _status;

  /// The number of data bytes the message of [_status] needs.
  int _length = 0;

  /// The data bytes received for [_status].
  final _data = <int>[];

  /// The data of the System Exclusive being received.
  List<int>? _sysEx;

  /// The time of the chunk that started [_sysEx].
  MidiTime _sysExTime = MidiTime.zero;

  /// Whether the rest of a dropped System Exclusive is skipped.
  bool _skipSysEx = false;

  /// The number of stray data bytes not reported yet.
  int _stray = 0;

  // ...........................................................................
  /// Parses one [byte] received at [time] into [messages].
  void _parse(int byte, MidiTime time, List<MidiTimedMessage> messages) {
    if (byte < 0x80) return _dataByte(byte, time, messages);
    _reportStray();
    if (byte >= 0xF8) return _realTime(byte, time, messages);
    _statusByte(byte, time, messages);
  }

  /// Delivers the real-time [byte] at once, or reports it when undefined.
  void _realTime(int byte, MidiTime time, List<MidiTimedMessage> messages) {
    if (MidiShortMessage.dataLength(byte) == null) {
      return _issue(MidiDiagnosticKind.invalidData, _undefined(byte));
    }
    messages.add((message: MidiShortMessage.decode(byte), time: time));
  }

  /// Handles a status byte of 0x80 to 0xF7.
  void _statusByte(int byte, MidiTime time, List<MidiTimedMessage> messages) {
    if (_sysEx != null || _skipSysEx) {
      _endSysEx(messages);
      if (byte == 0xF7) return;
    }
    _dropPartial();
    if (byte >= 0xF0) _runningStatus = null;
    if (byte == 0xF0) return _startSysEx(time);
    final length = MidiShortMessage.dataLength(byte);
    if (length == null) {
      final cause = byte == 0xF7 ? 'End of Exclusive without start' : null;
      return _issue(MidiDiagnosticKind.invalidData, cause ?? _undefined(byte));
    }
    if (byte < 0xF0) _runningStatus = byte;
    _status = byte;
    _length = length;
    _data.clear();
    if (length == 0) _complete(time, messages);
  }

  /// Handles a data [byte].
  void _dataByte(int byte, MidiTime time, List<MidiTimedMessage> messages) {
    final sysEx = _sysEx;
    if (sysEx != null) return _addSysEx(sysEx, byte);
    if (_skipSysEx) return;
    if (_status == null && !_resumeRunningStatus()) {
      _stray++;
      return;
    }
    _data.add(byte);
    if (_data.length == _length) _complete(time, messages);
  }

  /// Starts a message with the running status; returns false without one.
  bool _resumeRunningStatus() {
    final status = _runningStatus;
    if (status == null) return false;
    _status = status;
    _length = MidiShortMessage.dataLength(status)!;
    _data.clear();
    return true;
  }

  /// Delivers the message of [_status] and [_data] at [time].
  void _complete(MidiTime time, List<MidiTimedMessage> messages) {
    final message = MidiShortMessage.decode(
      _status!,
      data1: _data.isEmpty ? 0 : _data[0],
      data2: _data.length < 2 ? 0 : _data[1],
    );
    _status = null;
    messages.add((message: _noteOffFor(message), time: time));
  }

  /// Returns a Note Off for a Note On with velocity 0 when
  /// [noteOnZeroAsNoteOff] is set, otherwise [message].
  MidiMessage _noteOffFor(MidiMessage message) =>
      noteOnZeroAsNoteOff && message is MidiNoteOn && message.isNoteOff
      ? MidiNoteOff(channel: message.channel, note: message.note)
      : message;

  /// Drops a message that misses data bytes.
  void _dropPartial() {
    final status = _status;
    if (status == null) return;
    _status = null;
    _issue(
      MidiDiagnosticKind.invalidData,
      'Message ${_hex(status)} incomplete, '
      '${_data.length} of $_length data bytes',
    );
  }

  // ...........................................................................
  /// Starts a System Exclusive at [time].
  void _startSysEx(MidiTime time) {
    _sysEx = [];
    _sysExTime = time;
  }

  /// Adds [byte] to [sysEx], or drops [sysEx] when it gets too long.
  void _addSysEx(List<int> sysEx, int byte) {
    if (sysEx.length < maxSysExLength) return sysEx.add(byte);
    _skipRestOfSysEx(
      MidiDiagnosticKind.sysExTooLong,
      'System Exclusive longer than $maxSysExLength bytes',
    );
  }

  /// Delivers the System Exclusive being received, if any, and ends it.
  void _endSysEx(List<MidiTimedMessage> messages) {
    final sysEx = _sysEx;
    _sysEx = null;
    _skipSysEx = false;
    if (sysEx != null) {
      messages.add((message: MidiSysEx(sysEx), time: _sysExTime));
    }
  }

  /// Drops a System Exclusive still incomplete [maxSysExDuration] after
  /// its start.
  void _expireSysEx(MidiTime time) {
    final maxDuration = maxSysExDuration;
    if (maxDuration == null || _sysEx == null) return;
    if (time.difference(_sysExTime) <= maxDuration) return;
    _skipRestOfSysEx(
      MidiDiagnosticKind.sysExIncomplete,
      'System Exclusive incomplete after $maxDuration',
    );
  }

  /// Drops the System Exclusive and skips its remaining bytes.
  void _skipRestOfSysEx(MidiDiagnosticKind kind, String cause) {
    _sysEx = null;
    _skipSysEx = true;
    _issue(kind, cause);
  }

  // ...........................................................................
  /// Reports the stray data bytes counted so far.
  void _reportStray() {
    if (_stray == 0) return;
    final bytes = _stray == 1 ? 'byte' : 'bytes';
    _issue(
      MidiDiagnosticKind.invalidData,
      '$_stray data $bytes without status',
    );
    _stray = 0;
  }

  /// Reports an issue of [kind] with [cause].
  void _issue(MidiDiagnosticKind kind, String cause) =>
      onIssue?.call(kind, cause);

  /// Returns the cause for the undefined status [byte].
  static String _undefined(int byte) => 'Undefined status byte ${_hex(byte)}';

  /// Returns [byte] as 0x-prefixed hex.
  static String _hex(int byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}';
}
