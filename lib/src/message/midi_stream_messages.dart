// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

part of 'midi_message.dart';

// #############################################################################
/// The base of the UMP stream messages, UMP message type 0xF
/// (M2-104-UM 7.1).
///
/// Stream messages address the UMP endpoint: they have no group and no
/// MIDI 1.0 byte form.
sealed class MidiStreamMessage extends MidiMessage {
  /// Creates a stream message.
  const MidiStreamMessage();

  // ...........................................................................
  /// The 10-bit status of the message.
  int get status;

  @override
  UmpMessageType get umpMessageType => UmpMessageType.umpStream;
}

// #############################################################################
/// An Endpoint Discovery message, status 0x00 (M2-104-UM 7.1.1).
final class MidiEndpointDiscovery extends MidiStreamMessage {
  /// Creates a request for the endpoint information selected by the
  /// flags.
  const MidiEndpointDiscovery({
    this.umpVersionMajor = 1,
    this.umpVersionMinor = 1,
    this.requestEndpointInfo = false,
    this.requestDeviceIdentity = false,
    this.requestEndpointName = false,
    this.requestProductInstanceId = false,
    this.requestStreamConfiguration = false,
  }) : assert(umpVersionMajor >= 0 && umpVersionMajor <= 0xFF),
       assert(umpVersionMinor >= 0 && umpVersionMinor <= 0xFF);

  // ...........................................................................
  /// The major UMP version of the sender.
  final int umpVersionMajor;

  /// The minor UMP version of the sender.
  final int umpVersionMinor;

  /// Whether an Endpoint Info Notification is requested (filter bit e).
  final bool requestEndpointInfo;

  /// Whether a Device Identity Notification is requested (filter bit d).
  final bool requestDeviceIdentity;

  /// Whether an Endpoint Name Notification is requested (filter bit n).
  final bool requestEndpointName;

  /// Whether a Product Instance Id Notification is requested (filter bit
  /// i).
  final bool requestProductInstanceId;

  /// Whether a Stream Configuration Notification is requested (filter bit
  /// s).
  final bool requestStreamConfiguration;

  @override
  int get status => 0x00;

  @override
  Map<String, Object?> get _fields => {
    'umpVersionMajor': umpVersionMajor,
    'umpVersionMinor': umpVersionMinor,
    'requestEndpointInfo': requestEndpointInfo,
    'requestDeviceIdentity': requestDeviceIdentity,
    'requestEndpointName': requestEndpointName,
    'requestProductInstanceId': requestProductInstanceId,
    'requestStreamConfiguration': requestStreamConfiguration,
  };
}

// #############################################################################
/// An Endpoint Info Notification message, status 0x01 (M2-104-UM 7.1.2).
final class MidiEndpointInfoNotification extends MidiStreamMessage {
  /// Creates the basic information of an endpoint.
  const MidiEndpointInfoNotification({
    this.umpVersionMajor = 1,
    this.umpVersionMinor = 1,
    required this.staticFunctionBlocks,
    required this.numberOfFunctionBlocks,
    required this.supportsMidi2,
    required this.supportsMidi1,
    this.supportsRxJr = false,
    this.supportsTxJr = false,
  }) : assert(umpVersionMajor >= 0 && umpVersionMajor <= 0xFF),
       assert(umpVersionMinor >= 0 && umpVersionMinor <= 0xFF),
       assert(numberOfFunctionBlocks >= 0 && numberOfFunctionBlocks <= 0x7F);

  // ...........................................................................
  /// The major UMP version of the endpoint.
  final int umpVersionMajor;

  /// The minor UMP version of the endpoint.
  final int umpVersionMinor;

  /// Whether the function blocks never change after discovery (bit S).
  final bool staticFunctionBlocks;

  /// The number of function blocks, 0 to 32.
  final int numberOfFunctionBlocks;

  /// Whether the endpoint supports the MIDI 2.0 protocol (bit M2).
  final bool supportsMidi2;

  /// Whether the endpoint supports the MIDI 1.0 protocol (bit M1).
  final bool supportsMidi1;

  /// Whether the endpoint receives JR timestamps (bit RXJR).
  final bool supportsRxJr;

  /// Whether the endpoint sends JR timestamps (bit TXJR).
  final bool supportsTxJr;

  @override
  int get status => 0x01;

  @override
  Map<String, Object?> get _fields => {
    'umpVersionMajor': umpVersionMajor,
    'umpVersionMinor': umpVersionMinor,
    'staticFunctionBlocks': staticFunctionBlocks,
    'numberOfFunctionBlocks': numberOfFunctionBlocks,
    'supportsMidi2': supportsMidi2,
    'supportsMidi1': supportsMidi1,
    'supportsRxJr': supportsRxJr,
    'supportsTxJr': supportsTxJr,
  };
}

// #############################################################################
/// A Device Identity Notification message, status 0x02
/// (M2-104-UM 7.1.3).
///
/// It carries the data of the MIDI 1.0 Device Inquiry reply.
final class MidiDeviceIdentityNotification extends MidiStreamMessage {
  /// Creates a device identity; the byte lists are copied.
  MidiDeviceIdentityNotification({
    required List<int> manufacturerId,
    required this.familyId,
    required this.modelId,
    required List<int> softwareRevision,
  }) : manufacturerId = List.unmodifiable(manufacturerId),
       softwareRevision = List.unmodifiable(softwareRevision),
       assert(manufacturerId.length == 3),
       assert(familyId >= 0 && familyId <= 0x3FFF),
       assert(modelId >= 0 && modelId <= 0x3FFF),
       assert(softwareRevision.length == 4);

  // ...........................................................................
  /// The three manufacturer SysEx id bytes; one-byte ids are followed by
  /// two zeros. The list cannot be modified.
  final List<int> manufacturerId;

  /// The 14-bit device family, LSB first on the wire.
  final int familyId;

  /// The 14-bit device family model number, LSB first on the wire.
  final int modelId;

  /// The four software revision bytes; cannot be modified.
  final List<int> softwareRevision;

  @override
  int get status => 0x02;

  @override
  Map<String, Object?> get _fields => {
    'manufacturerId': manufacturerId,
    'familyId': familyId,
    'modelId': modelId,
    'softwareRevision': softwareRevision,
  };
}

// #############################################################################
/// An Endpoint Name Notification message, status 0x03 (M2-104-UM 7.1.4).
final class MidiEndpointNameNotification extends MidiStreamMessage {
  /// Creates the endpoint [name], up to 98 UTF-8 bytes.
  const MidiEndpointNameNotification({required this.name});

  // ...........................................................................
  /// The name of the endpoint.
  final String name;

  @override
  int get status => 0x03;

  @override
  Map<String, Object?> get _fields => {'name': name};
}

// #############################################################################
/// A Product Instance Id Notification message, status 0x04
/// (M2-104-UM 7.1.5).
final class MidiProductInstanceIdNotification extends MidiStreamMessage {
  /// Creates the [productInstanceId], up to 42 ASCII bytes, e.g. a serial
  /// number.
  const MidiProductInstanceIdNotification({required this.productInstanceId});

  // ...........................................................................
  /// The unique id of this product instance.
  final String productInstanceId;

  @override
  int get status => 0x04;

  @override
  Map<String, Object?> get _fields => {'productInstanceId': productInstanceId};
}

// #############################################################################
/// A Stream Configuration Request message, status 0x05
/// (M2-104-UM 7.1.6.2).
final class MidiStreamConfigurationRequest extends MidiStreamMessage {
  /// Creates a request to use [protocol] and JR timestamps.
  const MidiStreamConfigurationRequest({
    required this.protocol,
    this.receiveJr = false,
    this.transmitJr = false,
  });

  // ...........................................................................
  /// The requested protocol.
  final MidiProtocol protocol;

  /// Whether the endpoint shall receive JR timestamps (bit RXJR).
  final bool receiveJr;

  /// Whether the endpoint shall send JR timestamps (bit TXJR).
  final bool transmitJr;

  @override
  int get status => 0x05;

  @override
  Map<String, Object?> get _fields => {
    'protocol': protocol,
    'receiveJr': receiveJr,
    'transmitJr': transmitJr,
  };
}

// #############################################################################
/// A Stream Configuration Notification message, status 0x06
/// (M2-104-UM 7.1.6.3).
final class MidiStreamConfigurationNotification extends MidiStreamMessage {
  /// Creates the notification of the current [protocol] and JR settings.
  const MidiStreamConfigurationNotification({
    required this.protocol,
    this.receiveJr = false,
    this.transmitJr = false,
  });

  // ...........................................................................
  /// The protocol in use.
  final MidiProtocol protocol;

  /// Whether the endpoint receives JR timestamps (bit RXJR).
  final bool receiveJr;

  /// Whether the endpoint sends JR timestamps (bit TXJR).
  final bool transmitJr;

  @override
  int get status => 0x06;

  @override
  Map<String, Object?> get _fields => {
    'protocol': protocol,
    'receiveJr': receiveJr,
    'transmitJr': transmitJr,
  };
}

// #############################################################################
/// A Function Block Discovery message, status 0x10 (M2-104-UM 7.1.7).
final class MidiFunctionBlockDiscovery extends MidiStreamMessage {
  /// Creates a request for the information of [functionBlock], or of all
  /// blocks with [allFunctionBlocks].
  const MidiFunctionBlockDiscovery({
    this.functionBlock = allFunctionBlocks,
    this.requestInfo = true,
    this.requestName = true,
  }) : assert(functionBlock >= 0 && functionBlock <= 0xFF);

  // ...........................................................................
  /// The function block number that addresses all blocks.
  static const int allFunctionBlocks = 0xFF;

  // ...........................................................................
  /// The function block number, or [allFunctionBlocks].
  final int functionBlock;

  /// Whether Function Block Info Notifications are requested.
  final bool requestInfo;

  /// Whether Function Block Name Notifications are requested.
  final bool requestName;

  @override
  int get status => 0x10;

  @override
  Map<String, Object?> get _fields => {
    'functionBlock': functionBlock,
    'requestInfo': requestInfo,
    'requestName': requestName,
  };
}

// #############################################################################
/// A Function Block Info Notification message, status 0x11
/// (M2-104-UM 7.1.8).
final class MidiFunctionBlockInfoNotification extends MidiStreamMessage {
  /// Creates the description of a function block.
  const MidiFunctionBlockInfoNotification({
    required this.active,
    required this.functionBlock,
    this.uiHint = MidiFunctionBlockUiHint.unknown,
    this.midi1 = MidiFunctionBlockMidi1.notMidi1,
    required this.direction,
    required this.firstGroup,
    required this.numberOfGroups,
    this.midiCiVersion = 0,
    this.maxSysEx8Streams = 0,
  }) : assert(functionBlock >= 0 && functionBlock <= 0x7F),
       assert(firstGroup >= 0 && firstGroup <= 0xF),
       assert(numberOfGroups >= 0 && numberOfGroups <= 0x10),
       assert(midiCiVersion >= 0 && midiCiVersion <= 0xFF),
       assert(maxSysEx8Streams >= 0 && maxSysEx8Streams <= 0xFF);

  // ...........................................................................
  /// Whether the block is active.
  final bool active;

  /// The number of the block, 0 to 31.
  final int functionBlock;

  /// How a user interface should present the block.
  final MidiFunctionBlockUiHint uiHint;

  /// Whether the block is a MIDI 1.0 port and how fast it may be driven.
  final MidiFunctionBlockMidi1 midi1;

  /// The direction of the block.
  final MidiFunctionBlockDirection direction;

  /// The first group the block spans, 0 to 15.
  final int firstGroup;

  /// The number of groups the block spans, 1 to 16.
  final int numberOfGroups;

  /// The MIDI-CI message version supported, 0 for none.
  final int midiCiVersion;

  /// The maximum number of simultaneous System Exclusive 8 streams.
  final int maxSysEx8Streams;

  @override
  int get status => 0x11;

  @override
  Map<String, Object?> get _fields => {
    'active': active,
    'functionBlock': functionBlock,
    'uiHint': uiHint,
    'midi1': midi1,
    'direction': direction,
    'firstGroup': firstGroup,
    'numberOfGroups': numberOfGroups,
    'midiCiVersion': midiCiVersion,
    'maxSysEx8Streams': maxSysEx8Streams,
  };
}

// #############################################################################
/// A Function Block Name Notification message, status 0x12
/// (M2-104-UM 7.1.9).
final class MidiFunctionBlockNameNotification extends MidiStreamMessage {
  /// Creates the [name] of [functionBlock], up to 91 UTF-8 bytes.
  const MidiFunctionBlockNameNotification({
    required this.functionBlock,
    required this.name,
  }) : assert(functionBlock >= 0 && functionBlock <= 0xFF);

  // ...........................................................................
  /// The number of the block.
  final int functionBlock;

  /// The name of the block.
  final String name;

  @override
  int get status => 0x12;

  @override
  Map<String, Object?> get _fields => {
    'functionBlock': functionBlock,
    'name': name,
  };
}

// #############################################################################
/// A Start of Clip message, status 0x20 (M2-104-UM 7.1.10).
final class MidiStartOfClip extends MidiStreamMessage {
  /// Creates a start of clip.
  const MidiStartOfClip();

  @override
  int get status => 0x20;

  @override
  Map<String, Object?> get _fields => const {};
}

// #############################################################################
/// An End of Clip message, status 0x21 (M2-104-UM 7.1.11).
final class MidiEndOfClip extends MidiStreamMessage {
  /// Creates an end of clip.
  const MidiEndOfClip();

  @override
  int get status => 0x21;

  @override
  Map<String, Object?> get _fields => const {};
}
