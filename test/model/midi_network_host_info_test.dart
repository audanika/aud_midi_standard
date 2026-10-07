// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const host = MidiNetworkHostInfo(
    name: 'Studio Mac',
    address: '192.168.1.20',
    port: 5004,
    source: MidiNetworkHostSource.bonjour,
    serviceType: MidiNetworkHostInfo.networkMidi2ServiceType,
  );

  const hostJson = {
    'name': 'Studio Mac',
    'address': '192.168.1.20',
    'port': 5004,
    'source': 'bonjour',
    'serviceType': '_midi2._udp',
  };

  const other = MidiNetworkHostInfo(
    name: 'Laptop',
    address: 'laptop.local',
    port: 5008,
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiNetworkHostInfo', () {
    group('MidiNetworkHostInfo(...)', () {
      test('is a manual AppleMIDI host by default', () {
        expect(other.toJson(), {
          'name': 'Laptop',
          'address': 'laptop.local',
          'port': 5008,
          'source': 'manual',
          'serviceType': '_apple-midi._udp',
        });
      });
    });

    group('MidiNetworkHostInfo.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiNetworkHostInfo.fromJson(host.toJson()), host);
      });

      for (final key in hostJson.keys) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiNetworkHostInfo.fromJson({...hostJson}..remove(key)),
            throwsFormat('MidiNetworkHostInfo: "$key" is missing'),
          );
        });

        test('throws when "$key" has the wrong type', () {
          final wrong = hostJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiNetworkHostInfo.fromJson({...hostJson, key: wrong}),
            throwsFormat(startsWith('MidiNetworkHostInfo: "$key" must be ')),
          );
        });
      }
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(host.copyWith(), host);
      });

      test('replaces the given fields', () {
        expect(
          host.copyWith(
            name: other.name,
            address: other.address,
            port: other.port,
            source: other.source,
            serviceType: other.serviceType,
          ),
          other,
        );
      });
    });

    group('toJson()', () {
      test('writes every field', () {
        expect(host.toJson(), hostJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiNetworkHostInfo.fromJson(hostJson);
        expect(same, host);
        expect(same.hashCode, host.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            host.copyWith(name: other.name),
            host.copyWith(address: other.address),
            host.copyWith(port: other.port),
            host.copyWith(source: other.source),
            host.copyWith(serviceType: other.serviceType),
          ].where((variant) => variant == host),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          host.toString(),
          "MidiNetworkHostInfo(name: 'Studio Mac', address: '192.168.1.20', "
          "port: 5004, source: bonjour, serviceType: '_midi2._udp')",
        );
      });
    });

    group('appleMidiServiceType, networkMidi2ServiceType', () {
      test('are the DNS-SD service types', () {
        expect(MidiNetworkHostInfo.appleMidiServiceType, '_apple-midi._udp');
        expect(MidiNetworkHostInfo.networkMidi2ServiceType, '_midi2._udp');
      });
    });
  });
}
