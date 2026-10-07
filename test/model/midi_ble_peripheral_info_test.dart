// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final peripheral = MidiBlePeripheralInfo(
    id: '6E400001-B5A3-F393-E0A9-E50E24DCCA9E',
    name: 'WIDI Master',
    rssi: -60,
    isConnectable: false,
    state: MidiBlePeripheralState.connected,
    portIds: const [MidiPortId('ble:1:in'), MidiPortId('ble:1:out')],
  );

  const peripheralJson = {
    'id': '6E400001-B5A3-F393-E0A9-E50E24DCCA9E',
    'name': 'WIDI Master',
    'rssi': -60,
    'isConnectable': false,
    'state': 'connected',
    'portIds': ['ble:1:in', 'ble:1:out'],
  };

  final other = MidiBlePeripheralInfo(
    id: '00:11:22:33:44:55',
    name: 'Other',
    rssi: -80,
    state: MidiBlePeripheralState.connecting,
    portIds: const [MidiPortId('ble:2:in')],
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiBlePeripheralInfo', () {
    group('MidiBlePeripheralInfo(...)', () {
      test('applies the defaults', () {
        expect(MidiBlePeripheralInfo(id: 'a').toJson(), {
          'id': 'a',
          'name': '',
          'rssi': null,
          'isConnectable': true,
          'state': 'advertising',
          'portIds': <Object?>[],
        });
      });

      test('keeps an unmodifiable copy of the port ids', () {
        final portIds = [const MidiPortId('ble:1')];
        final peripheral = MidiBlePeripheralInfo(id: 'a', portIds: portIds);
        portIds.clear();
        expect(peripheral.portIds, [const MidiPortId('ble:1')]);
        expect(peripheral.portIds.clear, throwsUnsupportedError);
      });
    });

    group('MidiBlePeripheralInfo.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiBlePeripheralInfo.fromJson(peripheral.toJson()), peripheral);
        final silent = peripheral.copyWith(clearRssi: true);
        expect(MidiBlePeripheralInfo.fromJson(silent.toJson()), silent);
      });

      test('reads a missing "rssi" as null', () {
        expect(
          MidiBlePeripheralInfo.fromJson({...peripheralJson}..remove('rssi')),
          peripheral.copyWith(clearRssi: true),
        );
      });

      for (final key in peripheralJson.keys.where((key) => key != 'rssi')) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiBlePeripheralInfo.fromJson(
              {...peripheralJson}..remove(key),
            ),
            throwsFormat('MidiBlePeripheralInfo: "$key" is missing'),
          );
        });
      }

      for (final key in peripheralJson.keys) {
        test('throws when "$key" has the wrong type', () {
          final wrong = peripheralJson[key] is String ? 1 : 'wrong';
          expect(
            () =>
                MidiBlePeripheralInfo.fromJson({...peripheralJson, key: wrong}),
            throwsFormat(startsWith('MidiBlePeripheralInfo: "$key" must be ')),
          );
        });
      }
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(peripheral.copyWith(), peripheral);
      });

      test('replaces the given fields', () {
        expect(
          peripheral.copyWith(
            id: other.id,
            name: other.name,
            rssi: other.rssi,
            isConnectable: other.isConnectable,
            state: other.state,
            portIds: other.portIds,
          ),
          other,
        );
      });

      test('clears the signal strength with clearRssi', () {
        expect(peripheral.copyWith(clearRssi: true).rssi, isNull);
        expect(peripheral.copyWith(rssi: -1, clearRssi: true).rssi, isNull);
      });
    });

    group('toJson()', () {
      test('writes every field, port ids as strings', () {
        expect(peripheral.toJson(), peripheralJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiBlePeripheralInfo.fromJson(peripheralJson);
        expect(same, peripheral);
        expect(same.hashCode, peripheral.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            peripheral.copyWith(id: other.id),
            peripheral.copyWith(name: other.name),
            peripheral.copyWith(rssi: other.rssi),
            peripheral.copyWith(isConnectable: other.isConnectable),
            peripheral.copyWith(state: other.state),
            peripheral.copyWith(portIds: other.portIds),
          ].where((variant) => variant == peripheral),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          other.toString(),
          "MidiBlePeripheralInfo(id: '00:11:22:33:44:55', name: 'Other', "
          'rssi: -80, isConnectable: true, state: connecting, '
          'portIds: [ble:2:in])',
        );
      });
    });
  });
}
