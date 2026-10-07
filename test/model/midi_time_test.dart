// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const time = MidiTime(1000);
  const later = MidiTime(1500);

  group('MidiTime', () {
    group('MidiTime(microseconds)', () {
      test('keeps the microseconds', () {
        expect(time.microseconds, 1000);
      });
    });

    group('zero', () {
      test('is the epoch of the clock', () {
        expect(MidiTime.zero.microseconds, 0);
      });
    });

    group('operator +(duration)', () {
      test('moves the time forward', () {
        expect(time + const Duration(microseconds: 500), later);
      });
    });

    group('operator -(duration)', () {
      test('moves the time back', () {
        expect(later - const Duration(microseconds: 500), time);
      });
    });

    group('difference(other)', () {
      test('returns the duration from other to this time', () {
        expect(later.difference(time), const Duration(microseconds: 500));
        expect(time.difference(later), const Duration(microseconds: -500));
      });
    });

    group('isBefore(other)', () {
      test('is true only for an earlier time', () {
        expect(time.isBefore(later), isTrue);
        expect(later.isBefore(time), isFalse);
        expect(time.isBefore(time), isFalse);
      });
    });

    group('isAfter(other)', () {
      test('is true only for a later time', () {
        expect(later.isAfter(time), isTrue);
        expect(time.isAfter(later), isFalse);
        expect(time.isAfter(time), isFalse);
      });
    });

    group('compareTo(other)', () {
      test('orders by microseconds', () {
        expect(time.compareTo(later), -1);
        expect(later.compareTo(time), 1);
        expect(time.compareTo(time), 0);
        expect([later, MidiTime.zero, time]..sort((a, b) => a.compareTo(b)), [
          MidiTime.zero,
          time,
          later,
        ]);
      });
    });
  });
}
