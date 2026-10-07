// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  void expectAssert(Object? Function() create) =>
      expect(create, throwsA(isA<AssertionError>()));

  MidiMixedDataSet set({
    int mdsId = 1,
    int manufacturerId = 2,
    int deviceId = 3,
    int subId1 = 4,
    int subId2 = 5,
    List<int> data = const [6, 7],
  }) => MidiMixedDataSet(
    mdsId: mdsId,
    manufacturerId: manufacturerId,
    deviceId: deviceId,
    subId1: subId1,
    subId2: subId2,
    data: data,
  );

  group('MidiSysEx', () {
    test('holds a copy of the data', () {
      final data = [0x7E, 0x7F, 0x06, 0x01];
      final message = MidiSysEx(data);
      data[0] = 0;
      expect(message.data, equals([0x7E, 0x7F, 0x06, 0x01]));
    });

    test('cannot be modified', () {
      expect(
        () => MidiSysEx(const [1]).data[0] = 2,
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('is carried by 64-bit data UMPs', () {
      expect(MidiSysEx(const []).umpMessageType, UmpMessageType.data64);
    });

    test('prints its data as hex', () {
      expect('${MidiSysEx(const [0x43, 0x7F])}', 'MidiSysEx(data: [43 7f])');
    });

    test('compares by data', () {
      expect(MidiSysEx(const [1, 2]), MidiSysEx(const [1, 2]));
      expect(
        MidiSysEx(const [1, 2]).hashCode,
        MidiSysEx(const [1, 2]).hashCode,
      );
      expect(MidiSysEx(const [1, 2]), isNot(MidiSysEx(const [1, 3])));
    });

    test('asserts 7-bit data', () {
      expectAssert(() => MidiSysEx(const [0x7F, 0x80]));
    });
  });

  group('MidiSysEx8', () {
    test('holds stream id and a copy of the data', () {
      final data = [0x00, 0x43, 0xFF];
      final message = MidiSysEx8(streamId: 0xFF, data: data);
      data[0] = 1;
      expect(message.streamId, 0xFF);
      expect(message.data, equals([0x00, 0x43, 0xFF]));
    });

    test('cannot be modified', () {
      expect(
        () => MidiSysEx8(streamId: 0, data: const [1]).data[0] = 2,
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('is carried by 128-bit data UMPs', () {
      expect(
        MidiSysEx8(streamId: 0, data: const []).umpMessageType,
        UmpMessageType.data128,
      );
    });

    test('prints its fields', () {
      expect(
        '${MidiSysEx8(streamId: 2, data: const [0xAB])}',
        'MidiSysEx8(streamId: 2, data: [ab])',
      );
    });

    test('compares by stream id and data', () {
      final message = MidiSysEx8(streamId: 1, data: const [2]);
      expect(message, MidiSysEx8(streamId: 1, data: const [2]));
      expect(
        message.hashCode,
        MidiSysEx8(streamId: 1, data: const [2]).hashCode,
      );
      expect(message, isNot(MidiSysEx8(streamId: 2, data: const [2])));
    });

    for (final streamId in [-1, 0x100]) {
      test('asserts stream id $streamId', () {
        expectAssert(() => MidiSysEx8(streamId: streamId, data: const []));
      });
    }
  });

  group('MidiMixedDataSet', () {
    test('holds the header fields and a copy of the data', () {
      final data = [1, 2, 3];
      final message = set(
        mdsId: 15,
        manufacturerId: 0xFFFF,
        deviceId: 0x7F7F,
        subId1: 0x0102,
        subId2: 0,
        data: data,
      );
      data[0] = 9;
      expect(
        (
          message.mdsId,
          message.manufacturerId,
          message.deviceId,
          message.subId1,
          message.subId2,
        ),
        (15, 0xFFFF, 0x7F7F, 0x0102, 0),
      );
      expect(message.data, equals([1, 2, 3]));
    });

    test('cannot be modified', () {
      expect(() => set().data[0] = 2, throwsA(isA<UnsupportedError>()));
    });

    test('is carried by 128-bit data UMPs', () {
      expect(set().umpMessageType, UmpMessageType.data128);
    });

    test('prints its fields', () {
      expect(
        '${set()}',
        'MidiMixedDataSet(mdsId: 1, manufacturerId: 2, deviceId: 3, '
            'subId1: 4, subId2: 5, data: [06 07])',
      );
    });

    test('compares by all fields', () {
      expect(set(), set());
      expect(set().hashCode, set().hashCode);
      expect(set(), isNot(set(subId2: 6)));
      expect(set(), isNot(set(data: const [6])));
    });

    final invalid = <String, MidiMixedDataSet Function()>{
      'mdsId -1': () => set(mdsId: -1),
      'mdsId 16': () => set(mdsId: 16),
      'manufacturerId -1': () => set(manufacturerId: -1),
      'manufacturerId 0x10000': () => set(manufacturerId: 0x10000),
      'deviceId -1': () => set(deviceId: -1),
      'deviceId 0x10000': () => set(deviceId: 0x10000),
      'subId1 -1': () => set(subId1: -1),
      'subId1 0x10000': () => set(subId1: 0x10000),
      'subId2 -1': () => set(subId2: -1),
      'subId2 0x10000': () => set(subId2: 0x10000),
    };
    for (final MapEntry(key: name, value: create) in invalid.entries) {
      test('asserts $name', () => expectAssert(create));
    }
  });
}
