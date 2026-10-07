// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const info = MidiGroupInfo(group: 3, name: 'Keys', isActive: false);
  const infoJson = {'group': 3, 'name': 'Keys', 'isActive': false};

  Matcher throwsFormat(String message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiGroupInfo', () {
    group('MidiGroupInfo(group: group, ...)', () {
      test('has an empty name and is active by default', () {
        expect(const MidiGroupInfo(group: 0).toJson(), {
          'group': 0,
          'name': '',
          'isActive': true,
        });
      });

      test('asserts a group from 0 to 15', () {
        for (final group in [-1, 16]) {
          expect(
            () => MidiGroupInfo(group: group),
            throwsA(isA<AssertionError>()),
          );
        }
      });
    });

    group('MidiGroupInfo.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiGroupInfo.fromJson(info.toJson()), info);
      });

      for (final key in infoJson.keys) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiGroupInfo.fromJson({...infoJson}..remove(key)),
            throwsFormat('MidiGroupInfo: "$key" is missing'),
          );
        });

        test('throws when "$key" has the wrong type', () {
          expect(
            () => MidiGroupInfo.fromJson({...infoJson, key: <Object?>[]}),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'message',
                startsWith('MidiGroupInfo: "$key" must be '),
              ),
            ),
          );
        });
      }
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(info.copyWith(), info);
      });

      test('replaces the given fields', () {
        expect(
          info.copyWith(group: 4, name: 'Pads', isActive: true),
          const MidiGroupInfo(group: 4, name: 'Pads'),
        );
      });
    });

    group('toJson()', () {
      test('writes every field', () {
        expect(info.toJson(), infoJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiGroupInfo.fromJson(infoJson);
        expect(same, info);
        expect(same.hashCode, info.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            info.copyWith(group: 4),
            info.copyWith(name: 'Pads'),
            info.copyWith(isActive: true),
          ].where((other) => other == info),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          info.toString(),
          "MidiGroupInfo(group: 3, name: 'Keys', isActive: false)",
        );
      });
    });
  });
}
