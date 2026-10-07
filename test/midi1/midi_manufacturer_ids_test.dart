// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiManufacturerIds', () {
    // The manufacturer constants with their expected names.
    final manufacturers = <List<int>, String>{
      MidiManufacturerIds.sequential: 'Sequential',
      MidiManufacturerIds.moog: 'Moog Music',
      MidiManufacturerIds.kurzweil: 'Kurzweil',
      MidiManufacturerIds.ensoniq: 'Ensoniq',
      MidiManufacturerIds.oberheim: 'Oberheim',
      MidiManufacturerIds.apple: 'Apple',
      MidiManufacturerIds.emu: 'E-mu Systems',
      MidiManufacturerIds.clavia: 'Clavia',
      MidiManufacturerIds.waldorf: 'Waldorf',
      MidiManufacturerIds.kawai: 'Kawai',
      MidiManufacturerIds.roland: 'Roland',
      MidiManufacturerIds.korg: 'Korg',
      MidiManufacturerIds.yamaha: 'Yamaha',
      MidiManufacturerIds.casio: 'Casio',
      MidiManufacturerIds.akai: 'Akai',
      MidiManufacturerIds.alesis: 'Alesis',
      MidiManufacturerIds.markOfTheUnicorn: 'Mark of the Unicorn',
      MidiManufacturerIds.novation: 'Novation',
      MidiManufacturerIds.behringer: 'Behringer',
      MidiManufacturerIds.access: 'Access Music',
      MidiManufacturerIds.elektron: 'Elektron',
      MidiManufacturerIds.arturia: 'Arturia',
      MidiManufacturerIds.nativeInstruments: 'Native Instruments',
      MidiManufacturerIds.ableton: 'Ableton',
      MidiManufacturerIds.bome: 'Bome Software',
    };

    // The example conversions of M2-104-UM 7.10, Table 21.
    final table21 = <List<int>, int>{
      [0x04]: 0x0004,
      [0x09]: 0x0009,
      [0x43]: 0x0043,
      [0x00, 0x00, 0x3B]: 0x803B,
      [0x00, 0x02, 0x13]: 0x8213,
      [0x00, 0x02, 0x1D]: 0x821D,
      [0x00, 0x20, 0x25]: 0xA025,
      [0x00, 0x21, 0x09]: 0xA109,
      [0x00, 0x21, 0x32]: 0xA132,
    };

    // .........................................................................
    group('constants', () {
      test('hold the special ids', () {
        expect([
          MidiManufacturerIds.threeBytePrefix,
          MidiManufacturerIds.nonCommercial,
          MidiManufacturerIds.universalNonRealTime,
          MidiManufacturerIds.universalRealTime,
        ], equals([0x00, 0x7D, 0x7E, 0x7F]));
      });

      test('hold valid one- and three-byte ids', () {
        for (final id in manufacturers.keys) {
          expect(MidiManufacturerIds.idOf(id), equals(id));
          expect(id.length, MidiManufacturerIds.isThreeByte(id) ? 3 : 1);
          expect(id[0], isNot(inInclusiveRange(0x7D, 0x7F)));
        }
      });

      test('are unique', () {
        final ids = manufacturers.keys.map(MidiManufacturerIds.toSixteenBit);
        expect(ids.toSet(), hasLength(manufacturers.length));
      });

      test('match the examples of M2-104-UM Table 21', () {
        expect(MidiManufacturerIds.moog, equals([0x04]));
        expect(MidiManufacturerIds.yamaha, equals([0x43]));
        expect(MidiManufacturerIds.markOfTheUnicorn, equals([0, 0, 0x3B]));
        expect(MidiManufacturerIds.nativeInstruments, equals([0, 0x21, 9]));
        expect(MidiManufacturerIds.bome, equals([0x00, 0x21, 0x32]));
      });

      test('sort the one-byte ids into their regions', () {
        expect(
          [
            MidiManufacturerIds.sequential,
            MidiManufacturerIds.emu,
          ].map((id) => id[0]),
          everyElement(inInclusiveRange(0x01, 0x1F)),
        );
        expect(
          [
            MidiManufacturerIds.clavia,
            MidiManufacturerIds.waldorf,
          ].map((id) => id[0]),
          everyElement(inInclusiveRange(0x20, 0x3F)),
        );
        expect(
          [
            MidiManufacturerIds.kawai,
            MidiManufacturerIds.akai,
          ].map((id) => id[0]),
          everyElement(inInclusiveRange(0x40, 0x5F)),
        );
      });
    });

    // .........................................................................
    group('isThreeByte(data)', () {
      test('checks the first byte', () {
        expect(
          [
            <int>[],
            [0x41],
            [0x41, 0x00],
            [0x00],
            [0x00, 0x21, 0x09],
          ].map(MidiManufacturerIds.isThreeByte),
          equals([false, false, false, true, true]),
        );
      });
    });

    // .........................................................................
    group('idLength(data)', () {
      test('returns 1 or 3', () {
        expect(MidiManufacturerIds.idLength([0x41, 0x10, 0x42]), 1);
        expect(MidiManufacturerIds.idLength([0x00, 0x21, 0x09, 0x01]), 3);
      });

      test('throws for empty data', () {
        expect(
          () => MidiManufacturerIds.idLength([]),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'No manufacturer id',
            ),
          ),
        );
      });
    });

    // .........................................................................
    group('idOf(data)', () {
      test('returns the id at the start of SysEx data', () {
        expect(MidiManufacturerIds.idOf([0x41, 0x10, 0x42]), equals([0x41]));
        expect(
          MidiManufacturerIds.idOf([0x00, 0x21, 0x09, 0x01]),
          equals([0x00, 0x21, 0x09]),
        );
      });

      test('returns an unmodifiable list', () {
        final id = MidiManufacturerIds.idOf([0x41, 0x10]);
        expect(() => id.add(0), throwsUnsupportedError);
      });

      for (final data in [
        [0x00, 0x21],
        [0x80],
        [-1],
        [0x00, 0x80, 0x01],
      ]) {
        test('throws for $data', () {
          expect(
            () => MidiManufacturerIds.idOf(data),
            throwsA(
              isA<ArgumentError>()
                  .having((e) => e.name, 'name', 'data')
                  .having(
                    (e) => e.message,
                    'message',
                    'Invalid manufacturer id',
                  ),
            ),
          );
        });
      }
    });

    // .........................................................................
    group('toSixteenBit(data)', () {
      test('converts the examples of M2-104-UM Table 21', () {
        for (final MapEntry(key: id, value: sixteenBit) in table21.entries) {
          expect(MidiManufacturerIds.toSixteenBit(id), sixteenBit);
        }
      });

      test('converts the special ids of M2-104-UM Table 20', () {
        expect(
          [
            [MidiManufacturerIds.nonCommercial],
            [MidiManufacturerIds.universalNonRealTime],
            [MidiManufacturerIds.universalRealTime],
          ].map(MidiManufacturerIds.toSixteenBit),
          equals([0x007D, 0x007E, 0x007F]),
        );
      });

      test('reads the id at the start of SysEx data', () {
        expect(MidiManufacturerIds.toSixteenBit([0x41, 0x10, 0x42]), 0x41);
      });

      test('throws for an incomplete id', () {
        expect(
          () => MidiManufacturerIds.toSixteenBit([0x00]),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Invalid manufacturer id',
            ),
          ),
        );
      });
    });

    // .........................................................................
    group('fromSixteenBit(id)', () {
      test('converts the examples of M2-104-UM Table 21', () {
        for (final MapEntry(key: id, value: sixteenBit) in table21.entries) {
          expect(MidiManufacturerIds.fromSixteenBit(sixteenBit), equals(id));
        }
      });

      test('reverses toSixteenBit for the constants', () {
        for (final id in manufacturers.keys) {
          final sixteenBit = MidiManufacturerIds.toSixteenBit(id);
          expect(MidiManufacturerIds.fromSixteenBit(sixteenBit), equals(id));
        }
      });

      test('returns the reserved id for 0x0000', () {
        expect(MidiManufacturerIds.fromSixteenBit(0x0000), equals([0x00]));
      });

      for (final id in [-1, 0x10000]) {
        test('throws for $id', () {
          expect(
            () => MidiManufacturerIds.fromSixteenBit(id),
            throwsA(isA<RangeError>().having((e) => e.name, 'name', 'id')),
          );
        });
      }
    });

    // .........................................................................
    group('toThreeBytes(data)', () {
      test('pads one-byte ids with two zeros (M2-104-UM 7.1.3)', () {
        expect(
          MidiManufacturerIds.toThreeBytes(MidiManufacturerIds.roland),
          equals([0x41, 0x00, 0x00]),
        );
        expect(
          MidiManufacturerIds.toThreeBytes([0x43, 0x10, 0x4C]),
          equals([0x43, 0x00, 0x00]),
        );
      });

      test('keeps three-byte ids', () {
        expect(
          MidiManufacturerIds.toThreeBytes(MidiManufacturerIds.arturia),
          equals([0x00, 0x20, 0x6B]),
        );
      });
    });

    // .........................................................................
    group('fromThreeBytes(bytes)', () {
      test('reverses toThreeBytes for the constants', () {
        for (final id in manufacturers.keys) {
          final threeBytes = MidiManufacturerIds.toThreeBytes(id);
          expect(MidiManufacturerIds.fromThreeBytes(threeBytes), equals(id));
        }
      });

      for (final bytes in [
        [0x41],
        [0x41, 0x00, 0x00, 0x00],
      ]) {
        test('throws for $bytes', () {
          expect(
            () => MidiManufacturerIds.fromThreeBytes(bytes),
            throwsA(
              isA<ArgumentError>()
                  .having((e) => e.name, 'name', 'bytes')
                  .having((e) => e.message, 'message', 'Not three bytes'),
            ),
          );
        });
      }
    });

    // .........................................................................
    group('name(data)', () {
      test('names every manufacturer constant', () {
        for (final MapEntry(key: id, value: name) in manufacturers.entries) {
          expect(MidiManufacturerIds.name(id), name);
        }
      });

      test('names the special ids', () {
        expect(
          [
            [MidiManufacturerIds.nonCommercial],
            [MidiManufacturerIds.universalNonRealTime],
            [MidiManufacturerIds.universalRealTime],
          ].map(MidiManufacturerIds.name),
          equals([
            'Non-Commercial',
            'Universal Non-Real Time',
            'Universal Real Time',
          ]),
        );
      });

      test('names the manufacturer of SysEx data', () {
        expect(MidiManufacturerIds.name([0x41, 0x10, 0x42, 0x12]), 'Roland');
      });

      test('returns null for ids not in the selection', () {
        expect(MidiManufacturerIds.name([0x05]), isNull);
        expect(MidiManufacturerIds.name([0x00, 0x7F, 0x7F]), isNull);
      });
    });
  });
}
