// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../message/midi_message.dart';
import 'midi_manufacturer_ids.dart';

// #############################################################################
/// The Universal System Exclusive messages: their sub-ids, builders of
/// common requests and a parser of the identity reply (MIDI 1.0 Detailed
/// Specification 4.2.1, Table VIII: Universal System Exclusive ID Numbers,
/// with its amendments).
///
/// A Universal SysEx message carries, between 0xF0 and 0xF7, the id
/// [MidiManufacturerIds.universalNonRealTime] or
/// [MidiManufacturerIds.universalRealTime], the device id, sub-id #1 and
/// mostly sub-id #2. Sub-id #1 values mean different things for non-real-
/// time and real-time messages. Sub-id #2 constants carry the name of their
/// sub-id #1 as prefix.
abstract final class MidiUniversalSysEx {
  // ...........................................................................
  /// The device id that addresses every device.
  static const int allCallDeviceId = 0x7F;

  // ...........................................................................
  // Sub-id #1 of non-real-time messages (id 0x7E).

  /// Sample Dump Header.
  static const int sampleDumpHeader = 0x01;

  /// Sample Data Packet.
  static const int sampleDataPacket = 0x02;

  /// Sample Dump Request.
  static const int sampleDumpRequest = 0x03;

  /// MIDI Time Code set-up messages such as punch and cue points.
  static const int timeCodeSetup = 0x04;

  /// Sample Dump Extensions.
  static const int sampleDumpExtensions = 0x05;

  /// General Information: the device inquiry.
  static const int generalInformation = 0x06;

  /// File Dump.
  static const int fileDump = 0x07;

  /// MIDI Tuning Standard, non-real-time.
  static const int tuningStandardNonRealTime = 0x08;

  /// General MIDI system messages.
  static const int generalMidi = 0x09;

  /// Downloadable Sounds.
  static const int downloadableSounds = 0x0A;

  /// File Reference Message.
  static const int fileReference = 0x0B;

  /// MIDI Visual Control.
  static const int visualControl = 0x0C;

  /// MIDI Capability Inquiry (MIDI-CI).
  static const int capabilityInquiry = 0x0D;

  /// End of File of a handshaking transfer.
  static const int endOfFile = 0x7B;

  /// Wait of a handshaking transfer.
  static const int wait = 0x7C;

  /// Cancel of a handshaking transfer.
  static const int cancel = 0x7D;

  /// Negative acknowledge (NAK) of a handshaking transfer.
  static const int nak = 0x7E;

  /// Acknowledge (ACK) of a handshaking transfer.
  static const int ack = 0x7F;

  // ...........................................................................
  // Sub-id #2 of non-real-time messages.

  /// Identity Request, sub-id #2 of [generalInformation].
  static const int generalInformationIdentityRequest = 0x01;

  /// Identity Reply, sub-id #2 of [generalInformation].
  static const int generalInformationIdentityReply = 0x02;

  /// General MIDI 1 System On, sub-id #2 of [generalMidi].
  static const int generalMidi1SystemOn = 0x01;

  /// General MIDI System Off, sub-id #2 of [generalMidi].
  static const int generalMidiSystemOff = 0x02;

  /// General MIDI 2 System On, sub-id #2 of [generalMidi].
  static const int generalMidi2SystemOn = 0x03;

  // ...........................................................................
  // Sub-id #1 of real-time messages (id 0x7F).

  /// MIDI Time Code full message and user bits.
  static const int timeCode = 0x01;

  /// MIDI Show Control.
  static const int showControl = 0x02;

  /// Notation Information: bar number and time signature.
  static const int notationInformation = 0x03;

  /// Device Control: master volume, balance and tuning.
  static const int deviceControl = 0x04;

  /// Real Time MIDI Time Code Cueing.
  static const int timeCodeCueing = 0x05;

  /// MIDI Machine Control commands.
  static const int machineControlCommand = 0x06;

  /// MIDI Machine Control responses.
  static const int machineControlResponse = 0x07;

  /// MIDI Tuning Standard, real-time.
  static const int tuningStandardRealTime = 0x08;

  /// Controller Destination Setting (MMA CA-022).
  static const int controllerDestination = 0x09;

  /// Key-Based Instrument Control (MMA CA-023).
  static const int keyBasedInstrumentControl = 0x0A;

  /// Scalable Polyphony MIDI MIP message.
  static const int scalablePolyphony = 0x0B;

  /// Mobile Phone Control.
  static const int mobilePhoneControl = 0x0C;

  // ...........................................................................
  // Sub-id #2 of real-time messages.

  /// Full Message, sub-id #2 of [timeCode]: the complete time code.
  static const int timeCodeFullMessage = 0x01;

  /// User Bits, sub-id #2 of [timeCode].
  static const int timeCodeUserBits = 0x02;

  /// Master Volume, sub-id #2 of [deviceControl].
  static const int deviceControlMasterVolume = 0x01;

  /// Master Balance, sub-id #2 of [deviceControl].
  static const int deviceControlMasterBalance = 0x02;

  /// Master Fine Tuning, sub-id #2 of [deviceControl].
  static const int deviceControlMasterFineTuning = 0x03;

  /// Master Coarse Tuning, sub-id #2 of [deviceControl].
  static const int deviceControlMasterCoarseTuning = 0x04;

  /// Global Parameter Control, sub-id #2 of [deviceControl] (MMA CA-024).
  static const int deviceControlGlobalParameterControl = 0x05;

  // ...........................................................................
  /// Returns an Identity Request, the device inquiry that asks [deviceId]
  /// for an identity reply.
  ///
  /// Throws a [RangeError] when [deviceId] is outside 0 to 127.
  static MidiSysEx identityRequest({int deviceId = allCallDeviceId}) {
    _checkDeviceId(deviceId);
    return MidiSysEx([
      MidiManufacturerIds.universalNonRealTime,
      deviceId,
      generalInformation,
      generalInformationIdentityRequest,
    ]);
  }

  /// Returns an Identity Reply of [deviceId]; it reverses
  /// [parseIdentityReply].
  ///
  /// - [manufacturerId] the one- or three-byte id, or its three-byte device
  ///   identity form, see [MidiManufacturerIds.toThreeBytes]
  /// - [familyId] the 14-bit device family code
  /// - [modelId] the 14-bit device family member code
  /// - [softwareRevision] the four software revision bytes
  ///
  /// Throws an [ArgumentError] when a value does not fit its field.
  static MidiSysEx identityReply({
    int deviceId = allCallDeviceId,
    required List<int> manufacturerId,
    required int familyId,
    required int modelId,
    required List<int> softwareRevision,
  }) {
    _checkDeviceId(deviceId);
    RangeError.checkValueInInterval(familyId, 0, 0x3FFF, 'familyId');
    RangeError.checkValueInInterval(modelId, 0, 0x3FFF, 'modelId');
    if (softwareRevision.length != 4 ||
        softwareRevision.any((b) => b < 0 || b > 0x7F)) {
      throw ArgumentError.value(
        softwareRevision,
        'softwareRevision',
        'Not four 7-bit bytes',
      );
    }
    return MidiSysEx([
      MidiManufacturerIds.universalNonRealTime,
      deviceId,
      generalInformation,
      generalInformationIdentityReply,
      ...MidiManufacturerIds.idOf(manufacturerId),
      familyId & 0x7F,
      familyId >> 7,
      modelId & 0x7F,
      modelId >> 7,
      ...softwareRevision,
    ]);
  }

  /// Returns the content of the Identity Reply [sysEx], or null when
  /// [sysEx] is no complete identity reply.
  ///
  /// The manufacturer id comes in its three-byte device identity form, as
  /// in UMP device identity notifications (M2-104-UM 7.1.3). Bytes after
  /// the software revision are ignored.
  static ({
    int deviceId,
    List<int> manufacturerId,
    int familyId,
    int modelId,
    List<int> softwareRevision,
  })?
  parseIdentityReply(MidiSysEx sysEx) {
    final data = sysEx.data;
    if (data.length < 5 ||
        data[0] != MidiManufacturerIds.universalNonRealTime ||
        data[2] != generalInformation ||
        data[3] != generalInformationIdentityReply) {
      return null;
    }
    final id = 4 + MidiManufacturerIds.idLength(data.sublist(4));
    if (data.length < id + 8) return null;
    return (
      deviceId: data[1],
      manufacturerId: MidiManufacturerIds.toThreeBytes(data.sublist(4)),
      familyId: data[id] | data[id + 1] << 7,
      modelId: data[id + 2] | data[id + 3] << 7,
      softwareRevision: List.unmodifiable(data.sublist(id + 4, id + 8)),
    );
  }

  // ...........................................................................
  /// Returns a Master Volume message for [deviceId].
  ///
  /// - [value14] the 14-bit volume, 0 silent to 0x3FFF full
  ///
  /// Throws a [RangeError] when a value does not fit its field.
  static MidiSysEx masterVolume(
    int value14, {
    int deviceId = allCallDeviceId,
  }) => _deviceControl(deviceControlMasterVolume, value14, deviceId);

  /// Returns a Master Balance message for [deviceId].
  ///
  /// - [value14] the 14-bit balance, 0 left, 0x2000 center, 0x3FFF right
  ///
  /// Throws a [RangeError] when a value does not fit its field.
  static MidiSysEx masterBalance(
    int value14, {
    int deviceId = allCallDeviceId,
  }) => _deviceControl(deviceControlMasterBalance, value14, deviceId);

  // ...........................................................................
  /// Returns a device control message of [subId2] carrying [value14] LSB
  /// first.
  static MidiSysEx _deviceControl(int subId2, int value14, int deviceId) {
    RangeError.checkValueInInterval(value14, 0, 0x3FFF, 'value14');
    _checkDeviceId(deviceId);
    return MidiSysEx([
      MidiManufacturerIds.universalRealTime,
      deviceId,
      deviceControl,
      subId2,
      value14 & 0x7F,
      value14 >> 7,
    ]);
  }

  /// Throws a [RangeError] when [deviceId] is outside 0 to 127.
  static void _checkDeviceId(int deviceId) =>
      RangeError.checkValueInInterval(deviceId, 0, 0x7F, 'deviceId');
}
