// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final device = MidiDeviceInfo(
    id: const MidiDeviceId('coremidi:7'),
    name: 'Keystation',
    manufacturer: 'M-Audio',
    product: 'Keystation 49',
    serialNumber: 'SN-1',
    transport: MidiTransport.usb,
    driver: 'com.apple.AppleMIDIUSBDriver',
    isOffline: true,
    ports: const [MidiPortId('coremidi:8'), MidiPortId('coremidi:9')],
    native: const {'uniqueId': 7},
  );

  const deviceJson = {
    'id': 'coremidi:7',
    'name': 'Keystation',
    'manufacturer': 'M-Audio',
    'product': 'Keystation 49',
    'serialNumber': 'SN-1',
    'transport': 'usb',
    'driver': 'com.apple.AppleMIDIUSBDriver',
    'isOffline': true,
    'ports': ['coremidi:8', 'coremidi:9'],
    'native': {'uniqueId': 7},
  };

  final other = MidiDeviceInfo(
    id: const MidiDeviceId('alsa:20'),
    name: 'Launchpad',
    manufacturer: 'Novation',
    product: 'Launchpad X',
    serialNumber: 'SN-2',
    transport: MidiTransport.bluetoothLe,
    driver: 'snd-usb-audio',
    ports: const [MidiPortId('alsa:20:0')],
    native: const {'client': 20},
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiDeviceInfo', () {
    group('MidiDeviceInfo(...)', () {
      test('applies the defaults', () {
        final device = MidiDeviceInfo(
          id: const MidiDeviceId('web:1'),
          name: 'Synth',
        );
        expect(device.toJson(), {
          'id': 'web:1',
          'name': 'Synth',
          'manufacturer': '',
          'product': '',
          'serialNumber': '',
          'transport': 'unknown',
          'driver': '',
          'isOffline': false,
          'ports': <Object?>[],
          'native': <String, Object?>{},
        });
      });

      test('keeps unmodifiable copies of ports and native', () {
        final ports = [const MidiPortId('a:1')];
        final native = <String, Object?>{'a': 1};
        final device = MidiDeviceInfo(
          id: const MidiDeviceId('a:0'),
          name: 'A',
          ports: ports,
          native: native,
        );
        ports.clear();
        native.clear();
        expect(device.ports, [const MidiPortId('a:1')]);
        expect(device.native, {'a': 1});
        expect(device.ports.clear, throwsUnsupportedError);
        expect(device.native.clear, throwsUnsupportedError);
      });
    });

    group('MidiDeviceInfo.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        final decoded = MidiDeviceInfo.fromJson(device.toJson());
        expect(decoded, device);
        expect(decoded.native, device.native);
      });

      for (final key in deviceJson.keys) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiDeviceInfo.fromJson({...deviceJson}..remove(key)),
            throwsFormat('MidiDeviceInfo: "$key" is missing'),
          );
        });

        test('throws when "$key" has the wrong type', () {
          final wrong = deviceJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiDeviceInfo.fromJson({...deviceJson, key: wrong}),
            throwsFormat(startsWith('MidiDeviceInfo: "$key" must be ')),
          );
        });
      }

      test('throws for a port id that is no string', () {
        expect(
          () => MidiDeviceInfo.fromJson({
            ...deviceJson,
            'ports': ['a:1', 2],
          }),
          throwsFormat('MidiDeviceInfo: "ports[1]" must be String, but is int'),
        );
      });
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        final copy = device.copyWith();
        expect(copy, device);
        expect(copy.native, device.native);
      });

      test('replaces the given fields', () {
        final copy = device.copyWith(
          id: other.id,
          name: other.name,
          manufacturer: other.manufacturer,
          product: other.product,
          serialNumber: other.serialNumber,
          transport: other.transport,
          driver: other.driver,
          isOffline: other.isOffline,
          ports: other.ports,
          native: other.native,
        );
        expect(copy, other);
        expect(copy.native, other.native);
      });
    });

    group('toJson()', () {
      test('writes every field, ids as strings', () {
        expect(device.toJson(), deviceJson);
      });
    });

    group('fingerprint', () {
      test('joins manufacturer, product and serial number', () {
        expect(device.fingerprint, 'M-Audio|Keystation 49|SN-1');
      });

      test('ignores the session-bound id', () {
        expect(device.copyWith(id: other.id).fingerprint, device.fingerprint);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiDeviceInfo.fromJson(deviceJson);
        expect(same, device);
        expect(same.hashCode, device.hashCode);
      });

      test('ignore native', () {
        final same = device.copyWith(native: const {'other': true});
        expect(same, device);
        expect(same.hashCode, device.hashCode);
      });

      test('differ in every other field', () {
        expect(
          [
            device.copyWith(id: other.id),
            device.copyWith(name: other.name),
            device.copyWith(manufacturer: other.manufacturer),
            device.copyWith(product: other.product),
            device.copyWith(serialNumber: other.serialNumber),
            device.copyWith(transport: other.transport),
            device.copyWith(driver: other.driver),
            device.copyWith(isOffline: other.isOffline),
            device.copyWith(ports: other.ports),
          ].where((variant) => variant == device),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          device.toString(),
          "MidiDeviceInfo(id: coremidi:7, name: 'Keystation', "
          "manufacturer: 'M-Audio', product: 'Keystation 49', "
          "serialNumber: 'SN-1', transport: usb, "
          "driver: 'com.apple.AppleMIDIUSBDriver', isOffline: true, "
          'ports: [coremidi:8, coremidi:9], native: {uniqueId: 7})',
        );
      });
    });
  });
}
