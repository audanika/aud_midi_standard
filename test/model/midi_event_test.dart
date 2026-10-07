// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const noteOn = MidiNoteOn(channel: 1, note: 60, velocity: 100);

  const event = MidiEvent(
    message: noteOn,
    time: MidiTime(1000),
    port: MidiPortId('coremidi:8'),
    group: 3,
    senderTime: 0x1234,
  );

  const eventJson = {
    'ump': [0x23913C64],
    'group': 3,
    'time': 1000,
    'port': 'coremidi:8',
    'senderTime': 0x1234,
  };

  const other = MidiEvent(
    message: MidiControlChange(channel: 0, controller: 7, value: 100),
    time: MidiTime(2000),
    port: MidiPortId('alsa:20:0'),
    group: 4,
    senderTime: 1,
  );

  const optionalKeys = ['group', 'port', 'senderTime'];

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiEvent', () {
    group('MidiEvent(...)', () {
      test('has no port, group and sender time by default', () {
        const event = MidiEvent(message: noteOn, time: MidiTime.zero);
        expect([event.port, event.group, event.senderTime], [null, null, null]);
      });

      test('asserts a group from 0 to 15', () {
        for (final group in [-1, 16]) {
          expect(
            () => event.copyWith(group: group),
            throwsA(isA<AssertionError>()),
          );
        }
      });

      test('asserts a 16-bit sender time', () {
        for (final senderTime in [-1, 0x10000]) {
          expect(
            () => event.copyWith(senderTime: senderTime),
            throwsA(isA<AssertionError>()),
          );
        }
      });
    });

    group('MidiEvent.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiEvent.fromJson(event.toJson()), event);
        expect(MidiEvent.fromJson(other.toJson()), other);
      });

      test('decodes messages of every kind', () {
        final events = [
          MidiEvent(
            message: MidiSysEx(const [0x7E, 0x7F, 0x06, 0x01, 0x10, 0x11]),
            time: const MidiTime(1),
            group: 2,
          ),
          const MidiEvent(
            message: MidiNoteOn2(channel: 3, note: 64, velocity: 0x8000),
            time: MidiTime(2),
            group: 15,
          ),
          const MidiEvent(
            message: MidiEndpointDiscovery(requestEndpointInfo: true),
            time: MidiTime(3),
          ),
          const MidiEvent(message: MidiTimingClock(), time: MidiTime(4)),
        ];
        for (final event in events) {
          expect(MidiEvent.fromJson(event.toJson()), event);
        }
      });

      test('decodes System Exclusive above the default decoder limit', () {
        final event = MidiEvent(
          message: MidiSysEx(List.filled((1 << 20) + 1, 0x55)),
          time: const MidiTime(5),
          group: 0,
        );
        expect(MidiEvent.fromJson(event.toJson()), event);
      });

      for (final key in optionalKeys) {
        test('reads a missing "$key" as null', () {
          final json = {...eventJson}..remove(key);
          expect(MidiEvent.fromJson(json).toJson()[key], isNull);
        });
      }

      for (final key in ['ump', 'time']) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiEvent.fromJson({...eventJson}..remove(key)),
            throwsFormat('MidiEvent: "$key" is missing'),
          );
        });
      }

      for (final key in eventJson.keys) {
        test('throws when "$key" has the wrong type', () {
          final wrong = eventJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiEvent.fromJson({...eventJson, key: wrong}),
            throwsFormat(startsWith('MidiEvent: "$key" must be ')),
          );
        });
      }

      test('throws when "ump" holds no complete message', () {
        for (final words in [
          <Object?>[],
          [0x40913C00],
          [0x30160102, 0x03040000],
        ]) {
          expect(
            () => MidiEvent.fromJson({...eventJson, 'ump': words}),
            throwsFormat('MidiEvent: "ump" holds no complete message'),
          );
        }
      });
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(event.copyWith(), event);
      });

      test('replaces the given fields', () {
        expect(
          event.copyWith(
            message: other.message,
            time: other.time,
            port: other.port,
            group: other.group,
            senderTime: other.senderTime,
          ),
          other,
        );
      });

      test('clears the nullable fields with the clear flags', () {
        final cleared = event.copyWith(
          port: other.port,
          clearPort: true,
          group: other.group,
          clearGroup: true,
          senderTime: other.senderTime,
          clearSenderTime: true,
        );
        expect(cleared, const MidiEvent(message: noteOn, time: MidiTime(1000)));
      });
    });

    group('toJson()', () {
      test('writes the message as the words of its packets', () {
        expect(event.toJson(), eventJson);
      });

      test('encodes the message to group 0 without a group', () {
        expect(event.copyWith(clearGroup: true).toJson(), {
          ...eventJson,
          'ump': [0x20913C64],
          'group': null,
        });
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        const same = MidiEvent(
          message: MidiNoteOn(channel: 1, note: 60, velocity: 100),
          time: MidiTime(1000),
          port: MidiPortId('coremidi:8'),
          group: 3,
          senderTime: 0x1234,
        );
        expect(same, event);
        expect(same.hashCode, event.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            event.copyWith(message: other.message),
            event.copyWith(time: other.time),
            event.copyWith(port: other.port),
            event.copyWith(group: other.group),
            event.copyWith(senderTime: other.senderTime),
          ].where((variant) => variant == event),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          event.toString(),
          'MidiEvent(message: $noteOn, time: 1000, port: coremidi:8, '
          'group: 3, senderTime: 4660)',
        );
      });
    });
  });
}
