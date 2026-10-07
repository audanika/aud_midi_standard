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
    familyId: 0x1234,
    modelId: 0x0567,
    softwareRevision: const [1, 2, 3, 4],
  );

  const identityJson = {
    'manufacturerId': [0x00, 0x21, 0x09],
    'familyId': 0x1234,
    'modelId': 0x0567,
    'softwareRevision': [1, 2, 3, 4],
  };

  final other = MidiDeviceIdentity(
    manufacturerId: const [0x41, 0x00, 0x00],
    familyId: 1,
    modelId: 2,
    softwareRevision: const [0, 0, 0, 1],
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiDeviceIdentity', () {
    group('MidiDeviceIdentity(...)', () {
      test('keeps copies of the byte lists', () {
        final manufacturerId = [0x00, 0x21, 0x09];
        final softwareRevision = [1, 2, 3, 4];
        final identity = MidiDeviceIdentity(
          manufacturerId: manufacturerId,
          familyId: 1,
          modelId: 2,
          softwareRevision: softwareRevision,
        );
        manufacturerId[0] = 0x7F;
        softwareRevision[0] = 0x7F;
        expect(identity.manufacturerId, [0x00, 0x21, 0x09]);
        expect(identity.softwareRevision, [1, 2, 3, 4]);
      });

      test('makes the byte lists unmodifiable', () {
        expect(() => identity.manufacturerId[0] = 1, throwsUnsupportedError);
        expect(() => identity.softwareRevision[0] = 1, throwsUnsupportedError);
      });

      test('asserts three manufacturer and four revision bytes', () {
        expect(
          () => identity.copyWith(manufacturerId: [0x41]),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => identity.copyWith(softwareRevision: [1, 2, 3]),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('MidiDeviceIdentity.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiDeviceIdentity.fromJson(identity.toJson()), identity);
      });

      for (final key in identityJson.keys) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiDeviceIdentity.fromJson({...identityJson}..remove(key)),
            throwsFormat('MidiDeviceIdentity: "$key" is missing'),
          );
        });

        test('throws when "$key" has the wrong type', () {
          expect(
            () => MidiDeviceIdentity.fromJson({...identityJson, key: 'x'}),
            throwsFormat(startsWith('MidiDeviceIdentity: "$key" must be ')),
          );
        });
      }

      test('throws for a byte that is no int', () {
        expect(
          () => MidiDeviceIdentity.fromJson({
            ...identityJson,
            'softwareRevision': [1, 2, '3', 4],
          }),
          throwsFormat(
            'MidiDeviceIdentity: "softwareRevision[2]" must be int, '
            'but is String',
          ),
        );
      });
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(identity.copyWith(), identity);
      });

      test('replaces the given fields', () {
        expect(
          identity.copyWith(
            manufacturerId: other.manufacturerId,
            familyId: other.familyId,
            modelId: other.modelId,
            softwareRevision: other.softwareRevision,
          ),
          other,
        );
      });
    });

    group('toJson()', () {
      test('writes every field, the bytes as lists of ints', () {
        expect(identity.toJson(), identityJson);
      });

      test('writes lists the caller may modify', () {
        final json = identity.toJson();
        (json['manufacturerId']! as List<int>)[0] = 0x7F;
        expect(identity.manufacturerId, [0x00, 0x21, 0x09]);
      });
    });

    group('==, hashCode', () {
      test('compare the bytes element by element', () {
        final same = MidiDeviceIdentity.fromJson(identityJson);
        expect(same, identity);
        expect(same.hashCode, identity.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            identity.copyWith(manufacturerId: other.manufacturerId),
            identity.copyWith(familyId: other.familyId),
            identity.copyWith(modelId: other.modelId),
            identity.copyWith(softwareRevision: other.softwareRevision),
          ].where((variant) => variant == identity),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          identity.toString(),
          'MidiDeviceIdentity(manufacturerId: [0, 33, 9], familyId: 4660, '
          'modelId: 1383, softwareRevision: [1, 2, 3, 4])',
        );
      });
    });
  });
}
