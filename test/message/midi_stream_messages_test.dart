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

  // Returns [value] unchanged, so that constructors run at run time.
  T runtime<T>(T value) => value;

  MidiDeviceIdentityNotification identity({
    List<int> manufacturerId = const [0, 0x21, 0x09],
    int familyId = 1,
    int modelId = 2,
    List<int> softwareRevision = const [1, 2, 3, 4],
  }) => MidiDeviceIdentityNotification(
    manufacturerId: manufacturerId,
    familyId: familyId,
    modelId: modelId,
    softwareRevision: softwareRevision,
  );

  MidiFunctionBlockInfoNotification block({
    int functionBlock = 1,
    int firstGroup = 0,
    int numberOfGroups = 1,
    int midiCiVersion = 0,
    int maxSysEx8Streams = 0,
  }) => MidiFunctionBlockInfoNotification(
    active: true,
    functionBlock: functionBlock,
    direction: MidiFunctionBlockDirection.bidirectional,
    firstGroup: firstGroup,
    numberOfGroups: numberOfGroups,
    midiCiVersion: midiCiVersion,
    maxSysEx8Streams: maxSysEx8Streams,
  );

  group('MidiStreamMessage', () {
    final messages = <(MidiStreamMessage, int)>[
      (const MidiEndpointDiscovery(), 0x00),
      (
        const MidiEndpointInfoNotification(
          staticFunctionBlocks: true,
          numberOfFunctionBlocks: 1,
          supportsMidi2: true,
          supportsMidi1: false,
        ),
        0x01,
      ),
      (identity(), 0x02),
      (const MidiEndpointNameNotification(name: ''), 0x03),
      (const MidiProductInstanceIdNotification(productInstanceId: ''), 0x04),
      (
        const MidiStreamConfigurationRequest(protocol: MidiProtocol.midi2),
        0x05,
      ),
      (
        const MidiStreamConfigurationNotification(protocol: MidiProtocol.midi2),
        0x06,
      ),
      (const MidiFunctionBlockDiscovery(), 0x10),
      (block(), 0x11),
      (
        const MidiFunctionBlockNameNotification(functionBlock: 0, name: ''),
        0x12,
      ),
      (const MidiStartOfClip(), 0x20),
      (const MidiEndOfClip(), 0x21),
    ];
    for (final (message, status) in messages) {
      group('${message.runtimeType}', () {
        test('has status 0x${status.toRadixString(16)}', () {
          expect(message.status, status);
        });

        test('is carried by UMP stream packets', () {
          expect(message.umpMessageType, UmpMessageType.umpStream);
        });
      });
    }
  });

  group('MidiEndpointDiscovery', () {
    test('holds version and requests', () {
      const discovery = MidiEndpointDiscovery(
        umpVersionMajor: 0xFF,
        umpVersionMinor: 0,
        requestEndpointInfo: true,
        requestDeviceIdentity: true,
        requestEndpointName: true,
        requestProductInstanceId: true,
        requestStreamConfiguration: true,
      );
      expect(
        (
          discovery.umpVersionMajor,
          discovery.umpVersionMinor,
          discovery.requestEndpointInfo,
          discovery.requestDeviceIdentity,
          discovery.requestEndpointName,
          discovery.requestProductInstanceId,
          discovery.requestStreamConfiguration,
        ),
        (0xFF, 0, true, true, true, true, true),
      );
      expect(
        '$discovery',
        'MidiEndpointDiscovery(umpVersionMajor: 255, umpVersionMinor: 0, '
            'requestEndpointInfo: true, requestDeviceIdentity: true, '
            'requestEndpointName: true, requestProductInstanceId: true, '
            'requestStreamConfiguration: true)',
      );
    });

    test('requests nothing with version 1.1 by default', () {
      final discovery = MidiEndpointDiscovery(
        requestEndpointInfo: runtime(false),
      );
      expect(
        (
          discovery.umpVersionMajor,
          discovery.umpVersionMinor,
          discovery.requestDeviceIdentity,
          discovery.requestEndpointName,
          discovery.requestProductInstanceId,
          discovery.requestStreamConfiguration,
        ),
        (1, 1, false, false, false, false),
      );
    });

    test('compares by value', () {
      expect(
        MidiEndpointDiscovery(requestEndpointName: runtime(true)),
        const MidiEndpointDiscovery(requestEndpointName: true),
      );
      expect(
        const MidiEndpointDiscovery(),
        isNot(const MidiEndpointDiscovery(requestEndpointName: true)),
      );
    });

    for (final (major, minor) in [(-1, 0), (256, 0), (0, -1), (0, 256)]) {
      test('asserts version $major.$minor', () {
        expectAssert(
          () => MidiEndpointDiscovery(
            umpVersionMajor: major,
            umpVersionMinor: minor,
          ),
        );
      });
    }
  });

  group('MidiEndpointInfoNotification', () {
    MidiEndpointInfoNotification info({
      int major = 1,
      int minor = 1,
      int blocks = 2,
    }) => MidiEndpointInfoNotification(
      umpVersionMajor: major,
      umpVersionMinor: minor,
      staticFunctionBlocks: false,
      numberOfFunctionBlocks: blocks,
      supportsMidi2: true,
      supportsMidi1: true,
      supportsRxJr: true,
      supportsTxJr: true,
    );

    test('holds its fields', () {
      final notification = info(major: 2, minor: 3, blocks: 0x7F);
      expect(
        (
          notification.umpVersionMajor,
          notification.umpVersionMinor,
          notification.staticFunctionBlocks,
          notification.numberOfFunctionBlocks,
          notification.supportsMidi2,
          notification.supportsMidi1,
          notification.supportsRxJr,
          notification.supportsTxJr,
        ),
        (2, 3, false, 0x7F, true, true, true, true),
      );
      expect(
        '$notification',
        'MidiEndpointInfoNotification(umpVersionMajor: 2, umpVersionMinor: 3, '
            'staticFunctionBlocks: false, numberOfFunctionBlocks: 127, '
            'supportsMidi2: true, supportsMidi1: true, supportsRxJr: true, '
            'supportsTxJr: true)',
      );
    });

    test('uses version 1.1 without JR timestamps by default', () {
      final notification = MidiEndpointInfoNotification(
        staticFunctionBlocks: true,
        numberOfFunctionBlocks: runtime(0),
        supportsMidi2: false,
        supportsMidi1: true,
      );
      expect(
        (
          notification.umpVersionMajor,
          notification.umpVersionMinor,
          notification.supportsRxJr,
          notification.supportsTxJr,
        ),
        (1, 1, false, false),
      );
    });

    test('compares by value', () {
      expect(info(), info());
      expect(info().hashCode, info().hashCode);
      expect(info(), isNot(info(blocks: 3)));
    });

    final invalid = <String, MidiEndpointInfoNotification Function()>{
      'major -1': () => info(major: -1),
      'major 256': () => info(major: 256),
      'minor -1': () => info(minor: -1),
      'minor 256': () => info(minor: 256),
      'blocks -1': () => info(blocks: -1),
      'blocks 128': () => info(blocks: 128),
    };
    for (final MapEntry(key: name, value: create) in invalid.entries) {
      test('asserts $name', () => expectAssert(create));
    }
  });

  group('MidiDeviceIdentityNotification', () {
    test('holds copies of its fields', () {
      final manufacturerId = [0, 0x21, 0x09];
      final softwareRevision = [1, 2, 3, 4];
      final notification = identity(
        manufacturerId: manufacturerId,
        familyId: 0x3FFF,
        modelId: 0,
        softwareRevision: softwareRevision,
      );
      manufacturerId[0] = 0x7F;
      softwareRevision[0] = 0x7F;
      expect(notification.manufacturerId, equals([0, 0x21, 0x09]));
      expect(notification.softwareRevision, equals([1, 2, 3, 4]));
      expect((notification.familyId, notification.modelId), (0x3FFF, 0));
    });

    test('cannot be modified', () {
      expect(
        () => identity().manufacturerId[0] = 1,
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => identity().softwareRevision[0] = 1,
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('prints its fields', () {
      expect(
        '${identity()}',
        'MidiDeviceIdentityNotification(manufacturerId: [0, 33, 9], '
            'familyId: 1, modelId: 2, softwareRevision: [1, 2, 3, 4])',
      );
    });

    test('compares by value, lists included', () {
      expect(identity(), identity(manufacturerId: [0, 0x21, 0x09]));
      expect(
        identity().hashCode,
        identity(softwareRevision: [1, 2, 3, 4]).hashCode,
      );
      expect(identity(), isNot(identity(softwareRevision: const [1, 2, 3, 5])));
    });

    final invalid = <String, MidiDeviceIdentityNotification Function()>{
      'two manufacturer bytes': () => identity(manufacturerId: const [1, 2]),
      'family -1': () => identity(familyId: -1),
      'family 0x4000': () => identity(familyId: 0x4000),
      'model -1': () => identity(modelId: -1),
      'model 0x4000': () => identity(modelId: 0x4000),
      'five revision bytes': () =>
          identity(softwareRevision: const [1, 2, 3, 4, 5]),
    };
    for (final MapEntry(key: name, value: create) in invalid.entries) {
      test('asserts $name', () => expectAssert(create));
    }
  });

  group('MidiEndpointNameNotification', () {
    test('holds the name', () {
      final name = MidiEndpointNameNotification(name: runtime('Synth'));
      expect(name.name, 'Synth');
      expect('$name', "MidiEndpointNameNotification(name: 'Synth')");
    });

    test('compares by value', () {
      expect(
        MidiEndpointNameNotification(name: runtime('a')),
        const MidiEndpointNameNotification(name: 'a'),
      );
      expect(
        const MidiEndpointNameNotification(name: 'a'),
        isNot(const MidiEndpointNameNotification(name: 'b')),
      );
    });
  });

  group('MidiProductInstanceIdNotification', () {
    test('holds the id', () {
      final id = MidiProductInstanceIdNotification(
        productInstanceId: runtime('SN1'),
      );
      expect(id.productInstanceId, 'SN1');
      expect(
        '$id',
        "MidiProductInstanceIdNotification(productInstanceId: 'SN1')",
      );
    });

    test('compares by value', () {
      expect(
        MidiProductInstanceIdNotification(productInstanceId: runtime('a')),
        const MidiProductInstanceIdNotification(productInstanceId: 'a'),
      );
      expect(
        const MidiProductInstanceIdNotification(productInstanceId: 'a'),
        isNot(const MidiProductInstanceIdNotification(productInstanceId: 'b')),
      );
    });
  });

  group('MidiStreamConfigurationRequest', () {
    test('holds protocol and JR timestamps', () {
      final request = MidiStreamConfigurationRequest(
        protocol: runtime(MidiProtocol.midi1),
        receiveJr: true,
        transmitJr: true,
      );
      expect(
        (request.protocol, request.receiveJr, request.transmitJr),
        (MidiProtocol.midi1, true, true),
      );
      expect(
        '$request',
        'MidiStreamConfigurationRequest(protocol: MidiProtocol.midi1, '
            'receiveJr: true, transmitJr: true)',
      );
    });

    test('requests no JR timestamps by default', () {
      final request = MidiStreamConfigurationRequest(
        protocol: runtime(MidiProtocol.midi2),
      );
      expect((request.receiveJr, request.transmitJr), (false, false));
    });

    test('compares by value', () {
      expect(
        const MidiStreamConfigurationRequest(protocol: MidiProtocol.midi1),
        isNot(
          const MidiStreamConfigurationRequest(protocol: MidiProtocol.midi2),
        ),
      );
    });
  });

  group('MidiStreamConfigurationNotification', () {
    test('holds protocol and JR timestamps', () {
      final notification = MidiStreamConfigurationNotification(
        protocol: runtime(MidiProtocol.midi2),
        receiveJr: true,
      );
      expect(
        (
          notification.protocol,
          notification.receiveJr,
          notification.transmitJr,
        ),
        (MidiProtocol.midi2, true, false),
      );
      expect(
        '$notification',
        'MidiStreamConfigurationNotification(protocol: MidiProtocol.midi2, '
            'receiveJr: true, transmitJr: false)',
      );
    });

    test('is not equal to the request of the same configuration', () {
      expect(
        const MidiStreamConfigurationNotification(protocol: MidiProtocol.midi1),
        isNot(
          const MidiStreamConfigurationRequest(protocol: MidiProtocol.midi1),
        ),
      );
    });
  });

  group('MidiFunctionBlockDiscovery', () {
    test('requests everything about all blocks by default', () {
      final discovery = MidiFunctionBlockDiscovery(requestInfo: runtime(true));
      expect(
        (discovery.functionBlock, discovery.requestInfo, discovery.requestName),
        (MidiFunctionBlockDiscovery.allFunctionBlocks, true, true),
      );
      expect(MidiFunctionBlockDiscovery.allFunctionBlocks, 0xFF);
    });

    test('holds its fields', () {
      const discovery = MidiFunctionBlockDiscovery(
        functionBlock: 3,
        requestInfo: false,
        requestName: false,
      );
      expect(
        (discovery.functionBlock, discovery.requestInfo, discovery.requestName),
        (3, false, false),
      );
      expect(
        '$discovery',
        'MidiFunctionBlockDiscovery(functionBlock: 3, requestInfo: false, '
            'requestName: false)',
      );
    });

    for (final functionBlock in [-1, 0x100]) {
      test('asserts function block $functionBlock', () {
        expectAssert(
          () => MidiFunctionBlockDiscovery(functionBlock: functionBlock),
        );
      });
    }
  });

  group('MidiFunctionBlockInfoNotification', () {
    test('holds its fields', () {
      const info = MidiFunctionBlockInfoNotification(
        active: false,
        functionBlock: 0x7F,
        uiHint: MidiFunctionBlockUiHint.receiver,
        midi1: MidiFunctionBlockMidi1.unrestricted,
        direction: MidiFunctionBlockDirection.input,
        firstGroup: 0xF,
        numberOfGroups: 0x10,
        midiCiVersion: 0xFF,
        maxSysEx8Streams: 0xFF,
      );
      expect(
        (
          info.active,
          info.functionBlock,
          info.uiHint,
          info.midi1,
          info.direction,
          info.firstGroup,
          info.numberOfGroups,
          info.midiCiVersion,
          info.maxSysEx8Streams,
        ),
        (
          false,
          0x7F,
          MidiFunctionBlockUiHint.receiver,
          MidiFunctionBlockMidi1.unrestricted,
          MidiFunctionBlockDirection.input,
          0xF,
          0x10,
          0xFF,
          0xFF,
        ),
      );
      expect(
        '$info',
        'MidiFunctionBlockInfoNotification(active: false, functionBlock: 127, '
            'uiHint: MidiFunctionBlockUiHint.receiver, '
            'midi1: MidiFunctionBlockMidi1.unrestricted, '
            'direction: MidiFunctionBlockDirection.input, firstGroup: 15, '
            'numberOfGroups: 16, midiCiVersion: 255, maxSysEx8Streams: 255)',
      );
    });

    test('uses defaults for hint, MIDI 1.0, MIDI-CI and SysEx8', () {
      final info = block();
      expect(
        (info.uiHint, info.midi1, info.midiCiVersion, info.maxSysEx8Streams),
        (
          MidiFunctionBlockUiHint.unknown,
          MidiFunctionBlockMidi1.notMidi1,
          0,
          0,
        ),
      );
    });

    test('compares by value', () {
      expect(block(), block());
      expect(block().hashCode, block().hashCode);
      expect(block(), isNot(block(firstGroup: 1)));
    });

    final invalid = <String, MidiFunctionBlockInfoNotification Function()>{
      'function block -1': () => block(functionBlock: -1),
      'function block 128': () => block(functionBlock: 128),
      'first group -1': () => block(firstGroup: -1),
      'first group 16': () => block(firstGroup: 16),
      'groups -1': () => block(numberOfGroups: -1),
      'groups 17': () => block(numberOfGroups: 17),
      'MIDI-CI version -1': () => block(midiCiVersion: -1),
      'MIDI-CI version 256': () => block(midiCiVersion: 256),
      'SysEx8 streams -1': () => block(maxSysEx8Streams: -1),
      'SysEx8 streams 256': () => block(maxSysEx8Streams: 256),
    };
    for (final MapEntry(key: name, value: create) in invalid.entries) {
      test('asserts $name', () => expectAssert(create));
    }
  });

  group('MidiFunctionBlockNameNotification', () {
    test('holds block and name', () {
      final name = MidiFunctionBlockNameNotification(
        functionBlock: 0xFF,
        name: runtime('Piano'),
      );
      expect((name.functionBlock, name.name), (0xFF, 'Piano'));
      expect(
        '$name',
        "MidiFunctionBlockNameNotification(functionBlock: 255, name: 'Piano')",
      );
    });

    for (final functionBlock in [-1, 0x100]) {
      test('asserts function block $functionBlock', () {
        expectAssert(
          () => MidiFunctionBlockNameNotification(
            functionBlock: functionBlock,
            name: '',
          ),
        );
      });
    }
  });

  group('MidiStartOfClip and MidiEndOfClip', () {
    test('print without fields', () {
      expect([
        '${const MidiStartOfClip()}',
        '${const MidiEndOfClip()}',
      ], equals(['MidiStartOfClip()', 'MidiEndOfClip()']));
    });

    test('differ from each other', () {
      expect(const MidiStartOfClip(), isNot(const MidiEndOfClip()));
    });
  });
}
