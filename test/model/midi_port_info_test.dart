// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const groupInfo = MidiGroupInfo(group: 2, name: 'Main');
  const block = MidiFunctionBlockInfo(
    number: 0,
    name: 'Main',
    direction: MidiFunctionBlockDirection.bidirectional,
    firstGroup: 2,
    groupCount: 1,
  );
  const endpoint = MidiEndpointInfo(
    name: 'Keystation',
    supportsMidi1: true,
    supportsMidi2: true,
    protocol: MidiProtocol.midi2,
  );

  final port = MidiPortInfo(
    id: const MidiPortId('coremidi:8'),
    deviceId: const MidiDeviceId('coremidi:7'),
    name: 'Keystation Out',
    manufacturer: 'M-Audio',
    direction: MidiDirection.output,
    index: 1,
    transport: MidiTransport.usb,
    protocol: MidiProtocol.midi2,
    state: MidiPortState.offline,
    isVirtual: true,
    isOwn: true,
    group: 2,
    groups: const [groupInfo],
    functionBlocks: const [block],
    endpoint: endpoint,
    capabilities: const MidiPortCapabilities(ump: true),
    serialNumber: 'SN-1',
    native: const {'uniqueId': 8},
  );

  final portJson = {
    'id': 'coremidi:8',
    'deviceId': 'coremidi:7',
    'name': 'Keystation Out',
    'manufacturer': 'M-Audio',
    'direction': 'output',
    'index': 1,
    'transport': 'usb',
    'protocol': 'midi2',
    'state': 'offline',
    'isVirtual': true,
    'isOwn': true,
    'group': 2,
    'groups': [groupInfo.toJson()],
    'functionBlocks': [block.toJson()],
    'endpoint': endpoint.toJson(),
    'capabilities': const MidiPortCapabilities(ump: true).toJson(),
    'serialNumber': 'SN-1',
    'native': {'uniqueId': 8},
  };

  final other = MidiPortInfo(
    id: const MidiPortId('alsa:20:0'),
    deviceId: const MidiDeviceId('alsa:20'),
    name: 'Launchpad In',
    manufacturer: 'Novation',
    direction: MidiDirection.input,
    index: 0,
    transport: MidiTransport.bluetoothLe,
    protocol: MidiProtocol.midi1,
    state: MidiPortState.disconnected,
    group: 3,
    groups: [groupInfo.copyWith(name: 'Other')],
    functionBlocks: [block.copyWith(name: 'Other')],
    endpoint: endpoint.copyWith(name: 'Other'),
    capabilities: const MidiPortCapabilities(timestampsIn: true),
    serialNumber: 'SN-2',
    native: const {'client': 20},
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiPortInfo', () {
    group('MidiPortInfo(...)', () {
      test('applies the defaults', () {
        final port = MidiPortInfo(
          id: const MidiPortId('web:1'),
          name: 'Synth',
          direction: MidiDirection.input,
        );
        expect(port.toJson(), {
          'id': 'web:1',
          'deviceId': null,
          'name': 'Synth',
          'manufacturer': '',
          'direction': 'input',
          'index': 0,
          'transport': 'unknown',
          'protocol': 'midi1',
          'state': 'connected',
          'isVirtual': false,
          'isOwn': false,
          'group': 0,
          'groups': <Object?>[],
          'functionBlocks': <Object?>[],
          'endpoint': null,
          'capabilities': const MidiPortCapabilities().toJson(),
          'serialNumber': '',
          'native': <String, Object?>{},
        });
      });

      test('keeps unmodifiable copies of the collections', () {
        final groups = [groupInfo];
        final blocks = [block];
        final native = <String, Object?>{'a': 1};
        final port = MidiPortInfo(
          id: const MidiPortId('a:1'),
          name: 'A',
          direction: MidiDirection.input,
          groups: groups,
          functionBlocks: blocks,
          native: native,
        );
        groups.clear();
        blocks.clear();
        native.clear();
        expect(port.groups, [groupInfo]);
        expect(port.functionBlocks, [block]);
        expect(port.native, {'a': 1});
        expect(port.groups.clear, throwsUnsupportedError);
        expect(port.functionBlocks.clear, throwsUnsupportedError);
        expect(port.native.clear, throwsUnsupportedError);
      });

      test('asserts a group from 0 to 15', () {
        for (final group in [-1, 16]) {
          expect(
            () => port.copyWith(group: group),
            throwsA(isA<AssertionError>()),
          );
        }
      });
    });

    group('MidiPortInfo.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        final decoded = MidiPortInfo.fromJson(port.toJson());
        expect(decoded, port);
        expect(decoded.native, port.native);
        final bare = port.copyWith(clearDeviceId: true, clearEndpoint: true);
        expect(MidiPortInfo.fromJson(bare.toJson()), bare);
      });

      for (final key in ['deviceId', 'endpoint']) {
        test('reads a missing "$key" as null', () {
          final json = {...portJson}..remove(key);
          expect(MidiPortInfo.fromJson(json).toJson()[key], isNull);
        });
      }

      final required = portJson.keys.where(
        (key) => key != 'deviceId' && key != 'endpoint',
      );
      for (final key in required) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiPortInfo.fromJson({...portJson}..remove(key)),
            throwsFormat('MidiPortInfo: "$key" is missing'),
          );
        });
      }

      for (final key in portJson.keys) {
        test('throws when "$key" has the wrong type', () {
          final wrong = portJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiPortInfo.fromJson({...portJson, key: wrong}),
            throwsFormat(startsWith('MidiPortInfo: "$key" must be ')),
          );
        });
      }

      test('throws for an unknown direction', () {
        expect(
          () => MidiPortInfo.fromJson({...portJson, 'direction': 'both'}),
          throwsFormat(
            'MidiPortInfo: "direction" must be one of input, output, '
            "but is 'both'",
          ),
        );
      });

      test('throws for an invalid nested model', () {
        expect(
          () => MidiPortInfo.fromJson({
            ...portJson,
            'groups': [
              {'group': 1},
            ],
          }),
          throwsFormat('MidiGroupInfo: "name" is missing'),
        );
      });
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        final copy = port.copyWith();
        expect(copy, port);
        expect(copy.native, port.native);
      });

      test('replaces the given fields', () {
        final copy = port.copyWith(
          id: other.id,
          deviceId: other.deviceId,
          name: other.name,
          manufacturer: other.manufacturer,
          direction: other.direction,
          index: other.index,
          transport: other.transport,
          protocol: other.protocol,
          state: other.state,
          isVirtual: other.isVirtual,
          isOwn: other.isOwn,
          group: other.group,
          groups: other.groups,
          functionBlocks: other.functionBlocks,
          endpoint: other.endpoint,
          capabilities: other.capabilities,
          serialNumber: other.serialNumber,
          native: other.native,
        );
        expect(copy, other);
        expect(copy.native, other.native);
      });

      test('clears the device id with clearDeviceId', () {
        expect(port.copyWith(clearDeviceId: true).deviceId, isNull);
        expect(
          port.copyWith(deviceId: other.deviceId, clearDeviceId: true).deviceId,
          isNull,
        );
      });

      test('clears the endpoint with clearEndpoint', () {
        expect(port.copyWith(clearEndpoint: true).endpoint, isNull);
        expect(
          port.copyWith(endpoint: other.endpoint, clearEndpoint: true).endpoint,
          isNull,
        );
      });
    });

    group('toJson()', () {
      test('writes every field, nested models as maps', () {
        expect(port.toJson(), portJson);
      });
    });

    group('fingerprint', () {
      test('joins manufacturer, name, serial number, direction and index', () {
        expect(port.fingerprint, 'M-Audio|Keystation Out|SN-1|output|1');
      });

      test('ignores the session-bound ids', () {
        expect(
          port.copyWith(id: other.id, deviceId: other.deviceId).fingerprint,
          port.fingerprint,
        );
      });
    });

    group('isInput, isOutput', () {
      test('follow the direction', () {
        expect([port.isInput, port.isOutput], [false, true]);
        expect([other.isInput, other.isOutput], [true, false]);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiPortInfo.fromJson(portJson);
        expect(same, port);
        expect(same.hashCode, port.hashCode);
      });

      test('ignore native', () {
        final same = port.copyWith(native: const {'other': true});
        expect(same, port);
        expect(same.hashCode, port.hashCode);
      });

      test('differ in every other field', () {
        expect(
          [
            port.copyWith(id: other.id),
            port.copyWith(deviceId: other.deviceId),
            port.copyWith(name: other.name),
            port.copyWith(manufacturer: other.manufacturer),
            port.copyWith(direction: other.direction),
            port.copyWith(index: other.index),
            port.copyWith(transport: other.transport),
            port.copyWith(protocol: other.protocol),
            port.copyWith(state: other.state),
            port.copyWith(isVirtual: other.isVirtual),
            port.copyWith(isOwn: other.isOwn),
            port.copyWith(group: other.group),
            port.copyWith(groups: other.groups),
            port.copyWith(functionBlocks: other.functionBlocks),
            port.copyWith(endpoint: other.endpoint),
            port.copyWith(capabilities: other.capabilities),
            port.copyWith(serialNumber: other.serialNumber),
          ].where((variant) => variant == port),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        final port = MidiPortInfo(
          id: const MidiPortId('web:1'),
          name: 'Synth',
          direction: MidiDirection.input,
          groups: const [MidiGroupInfo(group: 0)],
          native: const {'a': 1},
        );
        expect(
          port.toString(),
          "MidiPortInfo(id: web:1, deviceId: null, name: 'Synth', "
          "manufacturer: '', direction: input, index: 0, "
          'transport: unknown, protocol: midi1, state: connected, '
          'isVirtual: false, isOwn: false, group: 0, '
          "groups: [MidiGroupInfo(group: 0, name: '', isActive: true)], "
          'functionBlocks: [], endpoint: null, '
          'capabilities: ${const MidiPortCapabilities()}, '
          "serialNumber: '', native: {a: 1})",
        );
      });
    });
  });
}
