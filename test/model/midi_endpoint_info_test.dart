// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final identity = MidiDeviceIdentity(
    manufacturerId: const [0x00, 0x21, 0x09],
    familyId: 1,
    modelId: 2,
    softwareRevision: const [1, 0, 0, 0],
  );

  final endpoint = MidiEndpointInfo(
    name: 'Synth',
    productInstanceId: 'SN-1',
    identity: identity,
    umpVersionMajor: 1,
    umpVersionMinor: 2,
    supportsMidi1: true,
    supportsMidi2: true,
    supportsRxJr: true,
    supportsTxJr: true,
    staticFunctionBlocks: true,
    functionBlockCount: 3,
    protocol: MidiProtocol.midi2,
    receiveJr: true,
    transmitJr: true,
  );

  final endpointJson = {
    'name': 'Synth',
    'productInstanceId': 'SN-1',
    'identity': identity.toJson(),
    'umpVersionMajor': 1,
    'umpVersionMinor': 2,
    'supportsMidi1': true,
    'supportsMidi2': true,
    'supportsRxJr': true,
    'supportsTxJr': true,
    'staticFunctionBlocks': true,
    'functionBlockCount': 3,
    'protocol': 'midi2',
    'receiveJr': true,
    'transmitJr': true,
  };

  final other = MidiEndpointInfo(
    name: 'Keys',
    productInstanceId: 'SN-2',
    identity: identity.copyWith(modelId: 3),
    umpVersionMajor: 2,
    umpVersionMinor: 0,
    supportsMidi1: false,
    supportsMidi2: false,
    functionBlockCount: 1,
    protocol: MidiProtocol.midi1,
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiEndpointInfo', () {
    group('MidiEndpointInfo(...)', () {
      test('applies the defaults', () {
        const endpoint = MidiEndpointInfo(
          supportsMidi1: true,
          supportsMidi2: false,
          protocol: MidiProtocol.midi1,
        );
        expect(endpoint.toJson(), {
          'name': '',
          'productInstanceId': '',
          'identity': null,
          'umpVersionMajor': 1,
          'umpVersionMinor': 1,
          'supportsMidi1': true,
          'supportsMidi2': false,
          'supportsRxJr': false,
          'supportsTxJr': false,
          'staticFunctionBlocks': false,
          'functionBlockCount': 0,
          'protocol': 'midi1',
          'receiveJr': false,
          'transmitJr': false,
        });
      });
    });

    group('MidiEndpointInfo.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiEndpointInfo.fromJson(endpoint.toJson()), endpoint);
        final anonymous = endpoint.copyWith(clearIdentity: true);
        expect(MidiEndpointInfo.fromJson(anonymous.toJson()), anonymous);
      });

      test('reads a missing "identity" as null', () {
        expect(
          MidiEndpointInfo.fromJson({...endpointJson}..remove('identity')),
          endpoint.copyWith(clearIdentity: true),
        );
      });

      for (final key in endpointJson.keys.where((key) => key != 'identity')) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiEndpointInfo.fromJson({...endpointJson}..remove(key)),
            throwsFormat('MidiEndpointInfo: "$key" is missing'),
          );
        });
      }

      for (final key in endpointJson.keys) {
        test('throws when "$key" has the wrong type', () {
          final wrong = endpointJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiEndpointInfo.fromJson({...endpointJson, key: wrong}),
            throwsFormat(startsWith('MidiEndpointInfo: "$key" must be ')),
          );
        });
      }

      test('throws for an invalid identity', () {
        expect(
          () => MidiEndpointInfo.fromJson({
            ...endpointJson,
            'identity': {'familyId': 1},
          }),
          throwsFormat('MidiDeviceIdentity: "manufacturerId" is missing'),
        );
      });
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(endpoint.copyWith(), endpoint);
      });

      test('replaces the given fields', () {
        expect(
          endpoint.copyWith(
            name: other.name,
            productInstanceId: other.productInstanceId,
            identity: other.identity,
            umpVersionMajor: other.umpVersionMajor,
            umpVersionMinor: other.umpVersionMinor,
            supportsMidi1: other.supportsMidi1,
            supportsMidi2: other.supportsMidi2,
            supportsRxJr: other.supportsRxJr,
            supportsTxJr: other.supportsTxJr,
            staticFunctionBlocks: other.staticFunctionBlocks,
            functionBlockCount: other.functionBlockCount,
            protocol: other.protocol,
            receiveJr: other.receiveJr,
            transmitJr: other.transmitJr,
          ),
          other,
        );
      });

      test('clears the identity with clearIdentity', () {
        expect(endpoint.copyWith(clearIdentity: true).identity, isNull);
        expect(
          endpoint
              .copyWith(identity: other.identity, clearIdentity: true)
              .identity,
          isNull,
        );
      });
    });

    group('toJson()', () {
      test('writes every field, the identity as a map', () {
        expect(endpoint.toJson(), endpointJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiEndpointInfo.fromJson(endpointJson);
        expect(same, endpoint);
        expect(same.hashCode, endpoint.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            endpoint.copyWith(name: other.name),
            endpoint.copyWith(productInstanceId: other.productInstanceId),
            endpoint.copyWith(identity: other.identity),
            endpoint.copyWith(umpVersionMajor: other.umpVersionMajor),
            endpoint.copyWith(umpVersionMinor: other.umpVersionMinor),
            endpoint.copyWith(supportsMidi1: other.supportsMidi1),
            endpoint.copyWith(supportsMidi2: other.supportsMidi2),
            endpoint.copyWith(supportsRxJr: other.supportsRxJr),
            endpoint.copyWith(supportsTxJr: other.supportsTxJr),
            endpoint.copyWith(staticFunctionBlocks: other.staticFunctionBlocks),
            endpoint.copyWith(functionBlockCount: other.functionBlockCount),
            endpoint.copyWith(protocol: other.protocol),
            endpoint.copyWith(receiveJr: other.receiveJr),
            endpoint.copyWith(transmitJr: other.transmitJr),
          ].where((variant) => variant == endpoint),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          endpoint.copyWith(clearIdentity: true).toString(),
          "MidiEndpointInfo(name: 'Synth', productInstanceId: 'SN-1', "
          'identity: null, umpVersion: 1.2, supportsMidi1: true, '
          'supportsMidi2: true, supportsRxJr: true, supportsTxJr: true, '
          'staticFunctionBlocks: true, functionBlockCount: 3, '
          'protocol: midi2, receiveJr: true, transmitJr: true)',
        );
      });
    });
  });
}
