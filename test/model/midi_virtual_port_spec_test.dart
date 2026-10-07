// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final spec = MidiVirtualPortSpec(
    name: 'My Synth',
    direction: MidiDirection.input,
    protocol: MidiProtocol.midi2,
    uniqueId: 4711,
    groups: const [0, 1],
    manufacturer: 'Audanika',
    model: 'SoundPrism',
  );

  const specJson = {
    'name': 'My Synth',
    'direction': 'input',
    'protocol': 'midi2',
    'uniqueId': 4711,
    'groups': [0, 1],
    'manufacturer': 'Audanika',
    'model': 'SoundPrism',
  };

  final other = MidiVirtualPortSpec(
    name: 'My Controller',
    direction: MidiDirection.output,
    uniqueId: 815,
    groups: const [2],
    manufacturer: 'Other',
    model: 'Other',
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiVirtualPortSpec', () {
    group('MidiVirtualPortSpec(...)', () {
      test('applies the defaults', () {
        final spec = MidiVirtualPortSpec(
          name: 'Out',
          direction: MidiDirection.output,
        );
        expect(spec.toJson(), {
          'name': 'Out',
          'direction': 'output',
          'protocol': 'midi1',
          'uniqueId': null,
          'groups': <Object?>[],
          'manufacturer': '',
          'model': '',
        });
      });

      test('keeps an unmodifiable copy of the groups', () {
        final groups = [0, 1];
        final spec = MidiVirtualPortSpec(
          name: 'In',
          direction: MidiDirection.input,
          groups: groups,
        );
        groups.add(2);
        expect(spec.groups, [0, 1]);
        expect(spec.groups.clear, throwsUnsupportedError);
      });

      test('asserts groups from 0 to 15', () {
        for (final group in [-1, 16]) {
          expect(
            () => spec.copyWith(groups: [0, group]),
            throwsA(isA<AssertionError>()),
          );
        }
      });
    });

    group('MidiVirtualPortSpec.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiVirtualPortSpec.fromJson(spec.toJson()), spec);
        final unnamed = spec.copyWith(clearUniqueId: true);
        expect(MidiVirtualPortSpec.fromJson(unnamed.toJson()), unnamed);
      });

      test('reads a missing "uniqueId" as null', () {
        expect(
          MidiVirtualPortSpec.fromJson({...specJson}..remove('uniqueId')),
          spec.copyWith(clearUniqueId: true),
        );
      });

      for (final key in specJson.keys.where((key) => key != 'uniqueId')) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiVirtualPortSpec.fromJson({...specJson}..remove(key)),
            throwsFormat('MidiVirtualPortSpec: "$key" is missing'),
          );
        });
      }

      for (final key in specJson.keys) {
        test('throws when "$key" has the wrong type', () {
          final wrong = specJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiVirtualPortSpec.fromJson({...specJson, key: wrong}),
            throwsFormat(startsWith('MidiVirtualPortSpec: "$key" must be ')),
          );
        });
      }
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(spec.copyWith(), spec);
      });

      test('replaces the given fields', () {
        expect(
          spec.copyWith(
            name: other.name,
            direction: other.direction,
            protocol: other.protocol,
            uniqueId: other.uniqueId,
            groups: other.groups,
            manufacturer: other.manufacturer,
            model: other.model,
          ),
          other,
        );
      });

      test('clears the unique id with clearUniqueId', () {
        expect(spec.copyWith(clearUniqueId: true).uniqueId, isNull);
        expect(
          spec.copyWith(uniqueId: 1, clearUniqueId: true).uniqueId,
          isNull,
        );
      });
    });

    group('toJson()', () {
      test('writes every field', () {
        expect(spec.toJson(), specJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiVirtualPortSpec.fromJson(specJson);
        expect(same, spec);
        expect(same.hashCode, spec.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            spec.copyWith(name: other.name),
            spec.copyWith(direction: other.direction),
            spec.copyWith(protocol: other.protocol),
            spec.copyWith(uniqueId: other.uniqueId),
            spec.copyWith(groups: other.groups),
            spec.copyWith(manufacturer: other.manufacturer),
            spec.copyWith(model: other.model),
          ].where((variant) => variant == spec),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          spec.toString(),
          "MidiVirtualPortSpec(name: 'My Synth', direction: input, "
          'protocol: midi2, uniqueId: 4711, groups: [0, 1], '
          "manufacturer: 'Audanika', model: 'SoundPrism')",
        );
      });
    });
  });
}
