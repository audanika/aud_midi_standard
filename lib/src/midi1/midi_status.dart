// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The status bytes of the MIDI 1.0 byte stream and helpers to classify
/// them (MIDI 1.0 Detailed Specification 4.2.1, Table I: Summary of Status
/// Bytes).
///
/// Channel message statuses carry the channel in their low nibble; the
/// constants hold channel 0. System messages use the whole byte. UMP system
/// messages (M2-104-UM 7.6) use the same status values.
abstract final class MidiStatus {
  // ...........................................................................
  /// The Note Off status of channel 0.
  static const int noteOff = 0x80;

  /// The Note On status of channel 0.
  static const int noteOn = 0x90;

  /// The Polyphonic Key Pressure (aftertouch) status of channel 0.
  static const int polyPressure = 0xA0;

  /// The Control Change status of channel 0; it also carries the channel
  /// mode messages, controllers 120 to 127.
  static const int controlChange = 0xB0;

  /// The Program Change status of channel 0.
  static const int programChange = 0xC0;

  /// The Channel Pressure (aftertouch) status of channel 0.
  static const int channelPressure = 0xD0;

  /// The Pitch Bend Change status of channel 0.
  static const int pitchBend = 0xE0;

  // ...........................................................................
  /// The start of a System Exclusive message.
  static const int sysEx = 0xF0;

  /// The MIDI Time Code Quarter Frame status.
  static const int timeCode = 0xF1;

  /// The Song Position Pointer status.
  static const int songPosition = 0xF2;

  /// The Song Select status.
  static const int songSelect = 0xF3;

  /// The undefined system common status 0xF4.
  static const int undefinedF4 = 0xF4;

  /// The undefined system common status 0xF5.
  static const int undefinedF5 = 0xF5;

  /// The Tune Request status.
  static const int tuneRequest = 0xF6;

  /// The End of System Exclusive (EOX) status.
  static const int endOfSysEx = 0xF7;

  // ...........................................................................
  /// The Timing Clock status, sent 24 times per quarter note.
  static const int timingClock = 0xF8;

  /// The undefined system real-time status 0xF9.
  static const int undefinedF9 = 0xF9;

  /// The Start status.
  static const int start = 0xFA;

  /// The Continue status; the name avoids the reserved word `continue`.
  static const int continueSequence = 0xFB;

  /// The Stop status.
  static const int stop = 0xFC;

  /// The undefined system real-time status 0xFD.
  static const int undefinedFD = 0xFD;

  /// The Active Sensing status.
  static const int activeSensing = 0xFE;

  /// The System Reset status.
  static const int systemReset = 0xFF;

  // ...........................................................................
  /// The [dataLength] of System Exclusive: its data runs until the next
  /// status byte, normally End of System Exclusive.
  static const int variableLength = -1;

  // ...........................................................................
  /// Returns whether [byte] is a status byte, 0x80 to 0xFF.
  static bool isStatus(int byte) => byte >= 0x80 && byte <= 0xFF;

  /// Returns whether [byte] is a data byte, 0x00 to 0x7F.
  static bool isData(int byte) => byte >= 0x00 && byte <= 0x7F;

  /// Returns whether [byte] is the status of a channel voice or channel
  /// mode message, 0x80 to 0xEF.
  static bool isChannelVoice(int byte) => byte >= 0x80 && byte <= 0xEF;

  /// Returns whether [byte] is a system status, 0xF0 to 0xFF.
  static bool isSystem(int byte) => byte >= 0xF0 && byte <= 0xFF;

  /// Returns whether [byte] is a system common status, 0xF1 to 0xF7.
  static bool isSystemCommon(int byte) => byte >= 0xF1 && byte <= 0xF7;

  /// Returns whether [byte] is a system real-time status, 0xF8 to 0xFF.
  ///
  /// Real-time messages may appear between the bytes of any other message.
  static bool isRealTime(int byte) => byte >= 0xF8 && byte <= 0xFF;

  // ...........................................................................
  /// Returns the channel 0 to 15 of [status], or null when [status] is no
  /// channel message status.
  static int? channelOf(int status) =>
      isChannelVoice(status) ? status & 0x0F : null;

  /// Returns the type of [status]: the channel 0 status for channel
  /// messages, e.g. [noteOn] for 0x93, and the status itself for system
  /// messages.
  ///
  /// Throws an [ArgumentError] when [status] is no status byte.
  static int typeOf(int status) {
    if (!isStatus(status)) {
      throw ArgumentError.value(status, 'status', 'Not a status byte');
    }
    return isChannelVoice(status) ? status & 0xF0 : status;
  }

  /// Returns the status of the channel message [type] on [channel].
  ///
  /// - [type] one of the channel 0 statuses [noteOff] to [pitchBend]
  /// - [channel] the channel 0 to 15
  ///
  /// Throws an [ArgumentError] for any other [type] and a [RangeError] for
  /// a channel outside 0 to 15.
  static int withChannel(int type, {required int channel}) {
    if (!isChannelVoice(type) || (type & 0x0F) != 0) {
      throw ArgumentError.value(type, 'type', 'Not a channel message type');
    }
    RangeError.checkValueInInterval(channel, 0, 15, 'channel');
    return type | channel;
  }

  /// Returns the number of data bytes that follow [status], or
  /// [variableLength] for System Exclusive.
  ///
  /// Undefined statuses carry no defined data and return 0. Throws an
  /// [ArgumentError] when [status] is no status byte.
  static int dataLength(int status) => switch (typeOf(status)) {
    sysEx => variableLength,
    programChange || channelPressure || timeCode || songSelect => 1,
    noteOff || noteOn || polyPressure || controlChange || pitchBend => 2,
    songPosition => 2,
    _ => 0,
  };

  /// Returns the name of the constant for [status], e.g. `'noteOn'` for
  /// 0x93, or null when [status] is no status byte.
  static String? name(int status) =>
      isStatus(status) ? _names[typeOf(status)] : null;

  // ...........................................................................
  /// The constant names by status type.
  static const Map<int, String> _names = {
    noteOff: 'noteOff',
    noteOn: 'noteOn',
    polyPressure: 'polyPressure',
    controlChange: 'controlChange',
    programChange: 'programChange',
    channelPressure: 'channelPressure',
    pitchBend: 'pitchBend',
    sysEx: 'sysEx',
    timeCode: 'timeCode',
    songPosition: 'songPosition',
    songSelect: 'songSelect',
    undefinedF4: 'undefinedF4',
    undefinedF5: 'undefinedF5',
    tuneRequest: 'tuneRequest',
    endOfSysEx: 'endOfSysEx',
    timingClock: 'timingClock',
    undefinedF9: 'undefinedF9',
    start: 'start',
    continueSequence: 'continueSequence',
    stop: 'stop',
    undefinedFD: 'undefinedFD',
    activeSensing: 'activeSensing',
    systemReset: 'systemReset',
  };
}
