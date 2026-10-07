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

  final creators = <String, (MidiUtilityMessage Function(int), int)>{
    'MidiJrClock': ((value) => MidiJrClock(time: value), 0xFFFF),
    'MidiJrTimestamp': ((value) => MidiJrTimestamp(time: value), 0xFFFF),
    'MidiDeltaClockstampTicksPerQuarterNote': (
      (value) =>
          MidiDeltaClockstampTicksPerQuarterNote(ticksPerQuarterNote: value),
      0xFFFF,
    ),
    'MidiDeltaClockstamp': (
      (value) => MidiDeltaClockstamp(ticks: value),
      0xFFFFF,
    ),
  };

  group('MidiNoop', () {
    test('is carried by utility UMPs', () {
      expect(const MidiNoop().umpMessageType, UmpMessageType.utility);
    });

    test('prints without fields', () {
      expect('${const MidiNoop()}', 'MidiNoop()');
    });

    test('equals every NOOP', () {
      expect(const MidiNoop(), const MidiNoop());
      expect(const MidiNoop(), isNot(const MidiJrClock(time: 0)));
    });
  });

  for (final MapEntry(key: name, value: (create, max)) in creators.entries) {
    group(name, () {
      test('is carried by utility UMPs', () {
        expect(create(0).umpMessageType, UmpMessageType.utility);
      });

      test('compares by value', () {
        expect(create(max), create(max));
        expect(create(max).hashCode, create(max).hashCode);
        expect(create(max), isNot(create(0)));
      });

      for (final value in [-1, max + 1]) {
        test('asserts $value', () => expectAssert(() => create(value)));
      }
    });
  }

  group('fields', () {
    test('hold their values', () {
      expect([
        MidiJrClock(time: creators.length).time,
        MidiJrTimestamp(time: creators.length).time,
        MidiDeltaClockstampTicksPerQuarterNote(
          ticksPerQuarterNote: creators.length,
        ).ticksPerQuarterNote,
        MidiDeltaClockstamp(ticks: creators.length).ticks,
      ], equals([4, 4, 4, 4]));
    });

    test('print with their names', () {
      expect(
        [
          '${const MidiJrClock(time: 1)}',
          '${const MidiJrTimestamp(time: 2)}',
          const MidiDeltaClockstampTicksPerQuarterNote(
            ticksPerQuarterNote: 3,
          ).toString(),
          '${const MidiDeltaClockstamp(ticks: 4)}',
        ],
        equals([
          'MidiJrClock(time: 1)',
          'MidiJrTimestamp(time: 2)',
          'MidiDeltaClockstampTicksPerQuarterNote(ticksPerQuarterNote: 3)',
          'MidiDeltaClockstamp(ticks: 4)',
        ]),
      );
    });
  });
}
