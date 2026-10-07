// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final capabilities = MidiCapabilities(
    virtualPorts: MidiVirtualPortSupport.dynamicPorts,
    bleScan: true,
    blePeripheral: true,
    network: const {MidiNetworkSupport.osSession, MidiNetworkSupport.appleMidi},
    ump: true,
    scheduling: MidiSchedulingSupport.hardware,
    missingPermissions: const {MidiPermission.bluetooth},
  );

  const capabilitiesJson = {
    'virtualPorts': 'dynamicPorts',
    'bleScan': true,
    'blePeripheral': true,
    'network': ['appleMidi', 'osSession'],
    'ump': true,
    'scheduling': 'hardware',
    'missingPermissions': ['bluetooth'],
  };

  const noneJson = {
    'virtualPorts': 'none',
    'bleScan': false,
    'blePeripheral': false,
    'network': <Object?>[],
    'ump': false,
    'scheduling': 'software',
    'missingPermissions': <Object?>[],
  };

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiCapabilities', () {
    group('MidiCapabilities(...)', () {
      test('equals MidiCapabilities.none() without arguments', () {
        final defaults = MidiCapabilities();
        expect(defaults, const MidiCapabilities.none());
        expect(defaults.toJson(), noneJson);
      });

      test('keeps unmodifiable copies of the sets', () {
        final network = {MidiNetworkSupport.appleMidi};
        final missing = {MidiPermission.localNetwork};
        final capabilities = MidiCapabilities(
          network: network,
          missingPermissions: missing,
        );
        network.clear();
        missing.clear();
        expect(capabilities.network, {MidiNetworkSupport.appleMidi});
        expect(capabilities.missingPermissions, {MidiPermission.localNetwork});
        expect(capabilities.network.clear, throwsUnsupportedError);
        expect(capabilities.missingPermissions.clear, throwsUnsupportedError);
      });
    });

    group('MidiCapabilities.none()', () {
      test('supports nothing beyond plain ports', () {
        expect(const MidiCapabilities.none().toJson(), noneJson);
      });
    });

    group('MidiCapabilities.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiCapabilities.fromJson(capabilities.toJson()), capabilities);
        expect(
          MidiCapabilities.fromJson(noneJson),
          const MidiCapabilities.none(),
        );
      });

      for (final key in capabilitiesJson.keys) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiCapabilities.fromJson({...capabilitiesJson}..remove(key)),
            throwsFormat('MidiCapabilities: "$key" is missing'),
          );
        });

        test('throws when "$key" has the wrong type', () {
          final wrong = capabilitiesJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiCapabilities.fromJson({...capabilitiesJson, key: wrong}),
            throwsFormat(startsWith('MidiCapabilities: "$key" must be ')),
          );
        });
      }

      test('throws for an unknown permission', () {
        expect(
          () => MidiCapabilities.fromJson({
            ...capabilitiesJson,
            'missingPermissions': ['camera'],
          }),
          throwsFormat(
            'MidiCapabilities: "missingPermissions" must be one of '
            "bluetooth, localNetwork, sysEx, midi, but is 'camera'",
          ),
        );
      });
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(capabilities.copyWith(), capabilities);
      });

      test('replaces the given fields', () {
        expect(
          capabilities.copyWith(
            virtualPorts: MidiVirtualPortSupport.none,
            bleScan: false,
            blePeripheral: false,
            network: const {},
            ump: false,
            scheduling: MidiSchedulingSupport.software,
            missingPermissions: const {},
          ),
          const MidiCapabilities.none(),
        );
      });
    });

    group('toJson()', () {
      test('writes the sets as names in declaration order', () {
        expect(capabilities.toJson(), capabilitiesJson);
      });
    });

    group('==, hashCode', () {
      test('ignore the order of the sets', () {
        final same = capabilities.copyWith(
          network: const {
            MidiNetworkSupport.appleMidi,
            MidiNetworkSupport.osSession,
          },
        );
        expect(same, capabilities);
        expect(same.hashCode, capabilities.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            capabilities.copyWith(virtualPorts: MidiVirtualPortSupport.none),
            capabilities.copyWith(bleScan: false),
            capabilities.copyWith(blePeripheral: false),
            capabilities.copyWith(
              network: const {MidiNetworkSupport.appleMidi},
            ),
            capabilities.copyWith(
              network: const {
                MidiNetworkSupport.appleMidi,
                MidiNetworkSupport.networkMidi2,
              },
            ),
            capabilities.copyWith(ump: false),
            capabilities.copyWith(scheduling: MidiSchedulingSupport.software),
            capabilities.copyWith(missingPermissions: const {}),
            capabilities.copyWith(
              missingPermissions: const {MidiPermission.sysEx},
            ),
          ].where((variant) => variant == capabilities),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          capabilities.toString(),
          'MidiCapabilities(virtualPorts: dynamicPorts, bleScan: true, '
          'blePeripheral: true, network: [appleMidi, osSession], ump: true, '
          'scheduling: hardware, missingPermissions: [bluetooth])',
        );
      });
    });
  });
}
