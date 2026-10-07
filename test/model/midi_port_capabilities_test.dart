// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const all = MidiPortCapabilities(
    timestampsIn: true,
    scheduledSend: true,
    cancelPending: true,
    ump: true,
    sysEx8: true,
  );

  const allJson = {
    'timestampsIn': true,
    'scheduledSend': true,
    'cancelPending': true,
    'ump': true,
    'sysEx8': true,
  };

  Matcher throwsFormat(String message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiPortCapabilities', () {
    group('MidiPortCapabilities()', () {
      test('sets every flag to false by default', () {
        expect(const MidiPortCapabilities().toJson(), {
          for (final key in allJson.keys) key: false,
        });
      });
    });

    group('MidiPortCapabilities.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiPortCapabilities.fromJson(all.toJson()), all);
        const none = MidiPortCapabilities();
        expect(MidiPortCapabilities.fromJson(none.toJson()), none);
      });

      for (final key in allJson.keys) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiPortCapabilities.fromJson({...allJson}..remove(key)),
            throwsFormat('MidiPortCapabilities: "$key" is missing'),
          );
        });

        test('throws when "$key" is no bool', () {
          expect(
            () => MidiPortCapabilities.fromJson({...allJson, key: 1}),
            throwsFormat(
              'MidiPortCapabilities: "$key" must be bool, but is int',
            ),
          );
        });
      }
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(all.copyWith(), all);
      });

      test('replaces the given fields', () {
        expect(
          all.copyWith(
            timestampsIn: false,
            scheduledSend: false,
            cancelPending: false,
            ump: false,
            sysEx8: false,
          ),
          const MidiPortCapabilities(),
        );
      });
    });

    group('toJson()', () {
      test('writes every flag', () {
        expect(all.toJson(), allJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal flags', () {
        final same = MidiPortCapabilities.fromJson(allJson);
        expect(same, all);
        expect(same.hashCode, all.hashCode);
      });

      test('differ in every flag', () {
        expect(
          [
            all.copyWith(timestampsIn: false),
            all.copyWith(scheduledSend: false),
            all.copyWith(cancelPending: false),
            all.copyWith(ump: false),
            all.copyWith(sysEx8: false),
          ].where((other) => other == all),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every flag', () {
        expect(
          const MidiPortCapabilities(ump: true).toString(),
          'MidiPortCapabilities(timestampsIn: false, scheduledSend: false, '
          'cancelPending: false, ump: true, sysEx8: false)',
        );
      });
    });
  });
}
