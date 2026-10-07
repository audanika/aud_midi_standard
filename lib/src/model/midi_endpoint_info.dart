// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_device_identity.dart';
import 'midi_json_reader.dart';
import 'midi_protocol.dart';

// #############################################################################
/// What a UMP endpoint tells about itself through the UMP stream messages
/// (M2-104-UM 7.1): name, identity, protocols and JR timestamps.
final class MidiEndpointInfo {
  /// Creates the description of an endpoint.
  ///
  /// - [supportsMidi1] and [supportsMidi2] the protocols the endpoint
  ///   supports.
  /// - [protocol] the protocol the endpoint currently uses.
  const MidiEndpointInfo({
    this.name = '',
    this.productInstanceId = '',
    this.identity,
    this.umpVersionMajor = 1,
    this.umpVersionMinor = 1,
    required this.supportsMidi1,
    required this.supportsMidi2,
    this.supportsRxJr = false,
    this.supportsTxJr = false,
    this.staticFunctionBlocks = false,
    this.functionBlockCount = 0,
    required this.protocol,
    this.receiveJr = false,
    this.transmitJr = false,
  });

  // ...........................................................................
  /// Decodes an endpoint that [toJson] encoded.
  ///
  /// Throws a [FormatException] when a key is missing or has the wrong
  /// type; `identity` may be missing.
  factory MidiEndpointInfo.fromJson(Map<String, Object?> json) {
    final reader = MidiJsonReader(json, type: 'MidiEndpointInfo');
    return MidiEndpointInfo(
      name: reader.value<String>('name'),
      productInstanceId: reader.value<String>('productInstanceId'),
      identity: reader.optional('identity', MidiDeviceIdentity.fromJson),
      umpVersionMajor: reader.value<int>('umpVersionMajor'),
      umpVersionMinor: reader.value<int>('umpVersionMinor'),
      supportsMidi1: reader.value<bool>('supportsMidi1'),
      supportsMidi2: reader.value<bool>('supportsMidi2'),
      supportsRxJr: reader.value<bool>('supportsRxJr'),
      supportsTxJr: reader.value<bool>('supportsTxJr'),
      staticFunctionBlocks: reader.value<bool>('staticFunctionBlocks'),
      functionBlockCount: reader.value<int>('functionBlockCount'),
      protocol: reader.enumValue('protocol', MidiProtocol.values),
      receiveJr: reader.value<bool>('receiveJr'),
      transmitJr: reader.value<bool>('transmitJr'),
    );
  }

  // ...........................................................................
  /// Returns a copy with the given fields replaced.
  ///
  /// - [clearIdentity] sets [identity] to null; it wins over a given
  ///   identity.
  MidiEndpointInfo copyWith({
    String? name,
    String? productInstanceId,
    MidiDeviceIdentity? identity,
    bool clearIdentity = false,
    int? umpVersionMajor,
    int? umpVersionMinor,
    bool? supportsMidi1,
    bool? supportsMidi2,
    bool? supportsRxJr,
    bool? supportsTxJr,
    bool? staticFunctionBlocks,
    int? functionBlockCount,
    MidiProtocol? protocol,
    bool? receiveJr,
    bool? transmitJr,
  }) => MidiEndpointInfo(
    name: name ?? this.name,
    productInstanceId: productInstanceId ?? this.productInstanceId,
    identity: clearIdentity ? null : identity ?? this.identity,
    umpVersionMajor: umpVersionMajor ?? this.umpVersionMajor,
    umpVersionMinor: umpVersionMinor ?? this.umpVersionMinor,
    supportsMidi1: supportsMidi1 ?? this.supportsMidi1,
    supportsMidi2: supportsMidi2 ?? this.supportsMidi2,
    supportsRxJr: supportsRxJr ?? this.supportsRxJr,
    supportsTxJr: supportsTxJr ?? this.supportsTxJr,
    staticFunctionBlocks: staticFunctionBlocks ?? this.staticFunctionBlocks,
    functionBlockCount: functionBlockCount ?? this.functionBlockCount,
    protocol: protocol ?? this.protocol,
    receiveJr: receiveJr ?? this.receiveJr,
    transmitJr: transmitJr ?? this.transmitJr,
  );

  /// Returns the endpoint as a JSON map.
  Map<String, Object?> toJson() => {
    'name': name,
    'productInstanceId': productInstanceId,
    'identity': identity?.toJson(),
    'umpVersionMajor': umpVersionMajor,
    'umpVersionMinor': umpVersionMinor,
    'supportsMidi1': supportsMidi1,
    'supportsMidi2': supportsMidi2,
    'supportsRxJr': supportsRxJr,
    'supportsTxJr': supportsTxJr,
    'staticFunctionBlocks': staticFunctionBlocks,
    'functionBlockCount': functionBlockCount,
    'protocol': protocol.name,
    'receiveJr': receiveJr,
    'transmitJr': transmitJr,
  };

  // ...........................................................................
  /// The name of the endpoint, empty when unknown.
  final String name;

  /// The unique id of the product instance, e.g. a serial number; empty
  /// when unknown.
  final String productInstanceId;

  /// The identity of the device, or null when unknown.
  final MidiDeviceIdentity? identity;

  /// The major UMP version of the endpoint.
  final int umpVersionMajor;

  /// The minor UMP version of the endpoint.
  final int umpVersionMinor;

  /// Whether the endpoint supports the MIDI 1.0 protocol.
  final bool supportsMidi1;

  /// Whether the endpoint supports the MIDI 2.0 protocol.
  final bool supportsMidi2;

  /// Whether the endpoint can receive JR timestamps.
  final bool supportsRxJr;

  /// Whether the endpoint can send JR timestamps.
  final bool supportsTxJr;

  /// Whether the function blocks never change after discovery.
  final bool staticFunctionBlocks;

  /// The number of function blocks, 0 to 32.
  final int functionBlockCount;

  /// The protocol the endpoint currently uses.
  final MidiProtocol protocol;

  /// Whether the endpoint currently receives JR timestamps.
  final bool receiveJr;

  /// Whether the endpoint currently sends JR timestamps.
  final bool transmitJr;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiEndpointInfo &&
          other.name == name &&
          other.productInstanceId == productInstanceId &&
          other.identity == identity &&
          other.umpVersionMajor == umpVersionMajor &&
          other.umpVersionMinor == umpVersionMinor &&
          other.supportsMidi1 == supportsMidi1 &&
          other.supportsMidi2 == supportsMidi2 &&
          other.supportsRxJr == supportsRxJr &&
          other.supportsTxJr == supportsTxJr &&
          other.staticFunctionBlocks == staticFunctionBlocks &&
          other.functionBlockCount == functionBlockCount &&
          other.protocol == protocol &&
          other.receiveJr == receiveJr &&
          other.transmitJr == transmitJr;

  @override
  int get hashCode => Object.hash(
    name,
    productInstanceId,
    identity,
    umpVersionMajor,
    umpVersionMinor,
    supportsMidi1,
    supportsMidi2,
    supportsRxJr,
    supportsTxJr,
    staticFunctionBlocks,
    functionBlockCount,
    protocol,
    receiveJr,
    transmitJr,
  );

  @override
  String toString() =>
      "MidiEndpointInfo(name: '$name', "
      "productInstanceId: '$productInstanceId', identity: $identity, "
      'umpVersion: $umpVersionMajor.$umpVersionMinor, '
      'supportsMidi1: $supportsMidi1, supportsMidi2: $supportsMidi2, '
      'supportsRxJr: $supportsRxJr, supportsTxJr: $supportsTxJr, '
      'staticFunctionBlocks: $staticFunctionBlocks, '
      'functionBlockCount: $functionBlockCount, protocol: ${protocol.name}, '
      'receiveJr: $receiveJr, transmitJr: $transmitJr)';
}
