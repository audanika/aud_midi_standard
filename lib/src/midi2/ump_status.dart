// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../midi1/midi_status.dart';
import 'ump_message_type.dart';

// #############################################################################
/// The status values of the Universal MIDI Packet by message type
/// (M2-104-UM Appendix F, Tables 26 to 33, and Appendix G).
///
/// Utility, data and channel voice packets carry a 4-bit status in bits 20
/// to 23 of the first word, UMP stream packets a 10-bit status in bits 16 to
/// 25. System messages use the MIDI 1.0 status bytes of [MidiStatus]. MIDI
/// 1.0 channel voice packets use the status nibbles [noteOff] to
/// [pitchBend], the same values as MIDI 2.0. The statuses of flex data
/// messages are in `MidiFlexDataStatus`.
abstract final class UmpStatus {
  // ...........................................................................
  // Utility messages, message type 0x0 (M2-104-UM 7.2).

  /// NOOP, no operation.
  static const int noop = 0x0;

  /// JR Clock: the time of the sender's clock.
  static const int jrClock = 0x1;

  /// JR Timestamp: the send time of the following message.
  static const int jrTimestamp = 0x2;

  /// Delta Clockstamp Ticks Per Quarter Note (DCTPQ).
  static const int deltaClockstampTicksPerQuarterNote = 0x3;

  /// Delta Clockstamp (DC): the ticks since the last event.
  static const int deltaClockstamp = 0x4;

  // ...........................................................................
  // System Exclusive (7-bit) messages, message type 0x3 (M2-104-UM 7.7,
  // Table 18).

  /// A complete System Exclusive message in one packet.
  static const int sysExComplete = 0x0;

  /// The start packet of a System Exclusive message.
  static const int sysExStart = 0x1;

  /// A continue packet of a System Exclusive message.
  static const int sysExContinue = 0x2;

  /// The end packet of a System Exclusive message.
  static const int sysExEnd = 0x3;

  // ...........................................................................
  // System Exclusive 8 and Mixed Data Set messages, message type 0x5
  // (M2-104-UM 7.8, Table 19, and 7.9).

  /// A complete System Exclusive 8 message in one packet.
  static const int sysEx8Complete = 0x0;

  /// The start packet of a System Exclusive 8 message.
  static const int sysEx8Start = 0x1;

  /// A continue packet of a System Exclusive 8 message.
  static const int sysEx8Continue = 0x2;

  /// The end packet of a System Exclusive 8 message.
  static const int sysEx8End = 0x3;

  /// The header packet of a Mixed Data Set chunk.
  static const int mixedDataSetHeader = 0x8;

  /// A payload packet of a Mixed Data Set chunk.
  static const int mixedDataSetPayload = 0x9;

  // ...........................................................................
  // Channel voice messages, message type 0x4 (M2-104-UM 7.4); [noteOff] to
  // [pitchBend] are also the statuses of message type 0x2 (7.3).

  /// Registered Per-Note Controller.
  static const int registeredPerNoteController = 0x0;

  /// Assignable Per-Note Controller.
  static const int assignablePerNoteController = 0x1;

  /// Registered Controller, the RPN of MIDI 2.0.
  static const int registeredController = 0x2;

  /// Assignable Controller, the NRPN of MIDI 2.0.
  static const int assignableController = 0x3;

  /// Relative Registered Controller.
  static const int relativeRegisteredController = 0x4;

  /// Relative Assignable Controller.
  static const int relativeAssignableController = 0x5;

  /// Per-Note Pitch Bend.
  static const int perNotePitchBend = 0x6;

  /// Note Off.
  static const int noteOff = 0x8;

  /// Note On.
  static const int noteOn = 0x9;

  /// Poly Pressure.
  static const int polyPressure = 0xA;

  /// Control Change.
  static const int controlChange = 0xB;

  /// Program Change.
  static const int programChange = 0xC;

  /// Channel Pressure.
  static const int channelPressure = 0xD;

  /// Pitch Bend.
  static const int pitchBend = 0xE;

  /// Per-Note Management.
  static const int perNoteManagement = 0xF;

  // ...........................................................................
  // The format field of flex data messages, message type 0xD (M2-104-UM
  // 7.5.1, Table 9), and of UMP stream messages, message type 0xF (7.1).

  /// A complete message in one packet.
  static const int formatComplete = 0x0;

  /// The start packet of a message that spans several packets.
  static const int formatStart = 0x1;

  /// A continue packet of a message that spans three or more packets.
  static const int formatContinue = 0x2;

  /// The end packet of a message that spans several packets.
  static const int formatEnd = 0x3;

  // ...........................................................................
  // The address field of flex data messages (M2-104-UM 7.5.1, Table 10).

  /// The message addresses the channel in its channel field.
  static const int flexAddressChannel = 0x0;

  /// The message addresses the whole group.
  static const int flexAddressGroup = 0x1;

  // ...........................................................................
  // UMP stream messages, message type 0xF (M2-104-UM 7.1).

  /// Endpoint Discovery.
  static const int endpointDiscovery = 0x00;

  /// Endpoint Info Notification.
  static const int endpointInfoNotification = 0x01;

  /// Device Identity Notification.
  static const int deviceIdentityNotification = 0x02;

  /// Endpoint Name Notification.
  static const int endpointNameNotification = 0x03;

  /// Product Instance Id Notification.
  static const int productInstanceIdNotification = 0x04;

  /// Stream Configuration Request.
  static const int streamConfigurationRequest = 0x05;

  /// Stream Configuration Notification.
  static const int streamConfigurationNotification = 0x06;

  /// Function Block Discovery.
  static const int functionBlockDiscovery = 0x10;

  /// Function Block Info Notification.
  static const int functionBlockInfoNotification = 0x11;

  /// Function Block Name Notification.
  static const int functionBlockNameNotification = 0x12;

  /// Start of Clip.
  static const int startOfClip = 0x20;

  /// End of Clip.
  static const int endOfClip = 0x21;

  // ...........................................................................
  /// Returns the name of the constant for [status] in packets of [type],
  /// or null when the status is not defined for that type.
  ///
  /// System packets return the names of [MidiStatus] for the statuses
  /// defined in UMP (M2-104-UM 7.6, Table 17). Flex data packets return
  /// null; `MidiFlexDataStatus.name` names their statuses.
  static String? name(int status, {required UmpMessageType type}) =>
      switch (type) {
        UmpMessageType.utility => _utilityNames[status],
        UmpMessageType.system =>
          _systemStatuses.contains(status) ? MidiStatus.name(status) : null,
        UmpMessageType.midi1ChannelVoice =>
          status >= noteOff && status <= pitchBend
              ? _channelVoiceNames[status]
              : null,
        UmpMessageType.data64 => _sysExNames[status],
        UmpMessageType.midi2ChannelVoice => _channelVoiceNames[status],
        UmpMessageType.data128 => _data128Names[status],
        UmpMessageType.umpStream => _streamNames[status],
        _ => null,
      };

  // ...........................................................................
  /// The names of the utility statuses.
  static const Map<int, String> _utilityNames = {
    noop: 'noop',
    jrClock: 'jrClock',
    jrTimestamp: 'jrTimestamp',
    deltaClockstampTicksPerQuarterNote: 'deltaClockstampTicksPerQuarterNote',
    deltaClockstamp: 'deltaClockstamp',
  };

  /// The system statuses defined in UMP.
  static const Set<int> _systemStatuses = {
    MidiStatus.timeCode,
    MidiStatus.songPosition,
    MidiStatus.songSelect,
    MidiStatus.tuneRequest,
    MidiStatus.timingClock,
    MidiStatus.start,
    MidiStatus.continueSequence,
    MidiStatus.stop,
    MidiStatus.activeSensing,
    MidiStatus.systemReset,
  };

  /// The names of the System Exclusive (7-bit) statuses.
  static const Map<int, String> _sysExNames = {
    sysExComplete: 'sysExComplete',
    sysExStart: 'sysExStart',
    sysExContinue: 'sysExContinue',
    sysExEnd: 'sysExEnd',
  };

  /// The names of the System Exclusive 8 and Mixed Data Set statuses.
  static const Map<int, String> _data128Names = {
    sysEx8Complete: 'sysEx8Complete',
    sysEx8Start: 'sysEx8Start',
    sysEx8Continue: 'sysEx8Continue',
    sysEx8End: 'sysEx8End',
    mixedDataSetHeader: 'mixedDataSetHeader',
    mixedDataSetPayload: 'mixedDataSetPayload',
  };

  /// The names of the channel voice statuses.
  static const Map<int, String> _channelVoiceNames = {
    registeredPerNoteController: 'registeredPerNoteController',
    assignablePerNoteController: 'assignablePerNoteController',
    registeredController: 'registeredController',
    assignableController: 'assignableController',
    relativeRegisteredController: 'relativeRegisteredController',
    relativeAssignableController: 'relativeAssignableController',
    perNotePitchBend: 'perNotePitchBend',
    noteOff: 'noteOff',
    noteOn: 'noteOn',
    polyPressure: 'polyPressure',
    controlChange: 'controlChange',
    programChange: 'programChange',
    channelPressure: 'channelPressure',
    pitchBend: 'pitchBend',
    perNoteManagement: 'perNoteManagement',
  };

  /// The names of the UMP stream statuses.
  static const Map<int, String> _streamNames = {
    endpointDiscovery: 'endpointDiscovery',
    endpointInfoNotification: 'endpointInfoNotification',
    deviceIdentityNotification: 'deviceIdentityNotification',
    endpointNameNotification: 'endpointNameNotification',
    productInstanceIdNotification: 'productInstanceIdNotification',
    streamConfigurationRequest: 'streamConfigurationRequest',
    streamConfigurationNotification: 'streamConfigurationNotification',
    functionBlockDiscovery: 'functionBlockDiscovery',
    functionBlockInfoNotification: 'functionBlockInfoNotification',
    functionBlockNameNotification: 'functionBlockNameNotification',
    startOfClip: 'startOfClip',
    endOfClip: 'endOfClip',
  };
}
