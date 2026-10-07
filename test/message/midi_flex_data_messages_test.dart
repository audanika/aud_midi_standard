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

  // Returns [value] unchanged, so that constructors run at run time.
  T runtime<T>(T value) => value;

  MidiSetChordName chord({
    int? channel,
    int tonicSharpsFlats = 0,
    int chordTonic = 3,
    int chordType = 1,
    List<MidiChordAlteration> alterations = const [],
    int bassSharpsFlats = -8,
    int bassNote = 0,
    int bassChordType = 0,
    List<MidiChordAlteration> bassAlterations = const [],
  }) => MidiSetChordName(
    channel: channel,
    tonicSharpsFlats: tonicSharpsFlats,
    chordTonic: chordTonic,
    chordType: chordType,
    alterations: alterations,
    bassSharpsFlats: bassSharpsFlats,
    bassNote: bassNote,
    bassChordType: bassChordType,
    bassAlterations: bassAlterations,
  );

  const add9 = MidiChordAlteration(type: 1, degree: 9);

  group('MidiFlexDataMessage', () {
    final messages = <(MidiFlexDataMessage, int, int)>[
      (const MidiSetTempo(tenNanosecondsPerQuarterNote: 1), 0, 0),
      (const MidiSetTimeSignature(numerator: 4, denominator: 2), 0, 1),
      (const MidiSetMetronome(clocksPerPrimaryClick: 24, barAccent1: 4), 0, 2),
      (const MidiSetKeySignature(sharpsFlats: 0, tonicNote: 3), 0, 5),
      (chord(), 0, 6),
      (const MidiFlexText(statusBank: 1, status: 3, text: ''), 1, 3),
      (const MidiFlexText(statusBank: 2, status: 1, text: ''), 2, 1),
    ];
    for (final (message, statusBank, status) in messages) {
      group('${message.runtimeType}', () {
        test('has status bank $statusBank and status $status', () {
          expect((message.statusBank, message.status), (statusBank, status));
        });

        test('is carried by flex data UMPs', () {
          expect(message.umpMessageType, UmpMessageType.flexData);
        });
      });
    }

    for (final channel in [-1, 16]) {
      test('asserts channel $channel', () {
        expectAssert(
          () => MidiSetKeySignature(
            channel: channel,
            sharpsFlats: 0,
            tonicNote: 0,
          ),
        );
      });
    }
  });

  group('MidiSetTempo', () {
    test('holds the duration of a quarter note', () {
      const tempo = MidiSetTempo(tenNanosecondsPerQuarterNote: 0xFFFFFFFF);
      expect(
        (tempo.tenNanosecondsPerQuarterNote, tempo.channel),
        (0xFFFFFFFF, null),
      );
      expect(
        '$tempo',
        'MidiSetTempo(tenNanosecondsPerQuarterNote: 4294967295)',
      );
    });

    test('converts from and to beats per minute', () {
      final tempo = MidiSetTempo.fromBeatsPerMinute(120);
      expect(tempo.tenNanosecondsPerQuarterNote, 50000000);
      expect(tempo.beatsPerMinute, 120);
    });

    test('compares by value', () {
      expect(
        MidiSetTempo.fromBeatsPerMinute(60),
        MidiSetTempo.fromBeatsPerMinute(60),
      );
      expect(
        MidiSetTempo.fromBeatsPerMinute(60).hashCode,
        MidiSetTempo.fromBeatsPerMinute(60).hashCode,
      );
      expect(
        MidiSetTempo.fromBeatsPerMinute(60),
        isNot(MidiSetTempo.fromBeatsPerMinute(61)),
      );
    });

    for (final value in [-1, 0x100000000]) {
      test('asserts $value', () {
        expectAssert(() => MidiSetTempo(tenNanosecondsPerQuarterNote: value));
      });
    }
  });

  group('MidiSetTimeSignature', () {
    test('holds its fields', () {
      const signature = MidiSetTimeSignature(
        numerator: 255,
        denominator: 3,
        numberOf32ndNotes: 255,
      );
      expect(
        (
          signature.numerator,
          signature.denominator,
          signature.numberOf32ndNotes,
          signature.channel,
        ),
        (255, 3, 255, null),
      );
      expect(
        '$signature',
        'MidiSetTimeSignature(numerator: 255, denominator: 3, '
            'numberOf32ndNotes: 255)',
      );
    });

    test('uses eight 32nd notes by default', () {
      final signature = MidiSetTimeSignature(
        numerator: 3,
        denominator: runtime(2),
      );
      expect(signature.numberOf32ndNotes, 8);
    });

    for (final (numerator, denominator, notes) in [
      (-1, 0, 0),
      (256, 0, 0),
      (0, -1, 0),
      (0, 256, 0),
      (0, 0, -1),
      (0, 0, 256),
    ]) {
      test('asserts $numerator, $denominator, $notes', () {
        expectAssert(
          () => MidiSetTimeSignature(
            numerator: numerator,
            denominator: denominator,
            numberOf32ndNotes: notes,
          ),
        );
      });
    }
  });

  group('MidiSetMetronome', () {
    test('holds its fields', () {
      const metronome = MidiSetMetronome(
        clocksPerPrimaryClick: 24,
        barAccent1: 3,
        barAccent2: 2,
        barAccent3: 255,
        subdivisionClicks1: 2,
        subdivisionClicks2: 4,
      );
      expect(
        (
          metronome.clocksPerPrimaryClick,
          metronome.barAccent1,
          metronome.barAccent2,
          metronome.barAccent3,
          metronome.subdivisionClicks1,
          metronome.subdivisionClicks2,
          metronome.channel,
        ),
        (24, 3, 2, 255, 2, 4, null),
      );
      expect(
        '$metronome',
        'MidiSetMetronome(clocksPerPrimaryClick: 24, barAccent1: 3, '
            'barAccent2: 2, barAccent3: 255, subdivisionClicks1: 2, '
            'subdivisionClicks2: 4)',
      );
    });

    test('leaves the optional fields 0 by default', () {
      final metronome = MidiSetMetronome(
        clocksPerPrimaryClick: 24,
        barAccent1: runtime(4),
      );
      expect(
        (
          metronome.barAccent2,
          metronome.barAccent3,
          metronome.subdivisionClicks1,
          metronome.subdivisionClicks2,
        ),
        (0, 0, 0, 0),
      );
    });

    final invalid = <String, MidiSetMetronome Function()>{
      'clocks -1': () =>
          MidiSetMetronome(clocksPerPrimaryClick: runtime(-1), barAccent1: 0),
      'clocks 256': () =>
          MidiSetMetronome(clocksPerPrimaryClick: runtime(256), barAccent1: 0),
      'accent 1 256': () =>
          MidiSetMetronome(clocksPerPrimaryClick: 0, barAccent1: runtime(256)),
      'accent 2 256': () => MidiSetMetronome(
        clocksPerPrimaryClick: 0,
        barAccent1: 0,
        barAccent2: runtime(256),
      ),
      'accent 3 256': () => MidiSetMetronome(
        clocksPerPrimaryClick: 0,
        barAccent1: 0,
        barAccent3: runtime(256),
      ),
      'subdivision 1 256': () => MidiSetMetronome(
        clocksPerPrimaryClick: 0,
        barAccent1: 0,
        subdivisionClicks1: runtime(256),
      ),
      'subdivision 2 -1': () => MidiSetMetronome(
        clocksPerPrimaryClick: 0,
        barAccent1: 0,
        subdivisionClicks2: runtime(-1),
      ),
    };
    for (final MapEntry(key: name, value: create) in invalid.entries) {
      test('asserts $name', () => expectAssert(create));
    }
  });

  group('MidiSetKeySignature', () {
    test('holds its fields', () {
      const signature = MidiSetKeySignature(
        channel: 15,
        sharpsFlats: -8,
        tonicNote: 15,
      );
      expect(
        (signature.channel, signature.sharpsFlats, signature.tonicNote),
        (15, -8, 15),
      );
      expect(
        '$signature',
        'MidiSetKeySignature(channel: 15, sharpsFlats: -8, tonicNote: 15)',
      );
    });

    test('addresses the group by default', () {
      expect(
        MidiSetKeySignature(sharpsFlats: 7, tonicNote: runtime(0)).channel,
        isNull,
      );
    });

    for (final (sharpsFlats, tonicNote) in [
      (-9, 0),
      (8, 0),
      (0, -1),
      (0, 16),
    ]) {
      test('asserts $sharpsFlats and $tonicNote', () {
        expectAssert(
          () => MidiSetKeySignature(
            sharpsFlats: sharpsFlats,
            tonicNote: tonicNote,
          ),
        );
      });
    }
  });

  group('MidiChordAlteration', () {
    test('holds type and degree', () {
      final alteration = MidiChordAlteration(type: 15, degree: runtime(15));
      expect((alteration.type, alteration.degree), (15, 15));
      expect('$alteration', 'MidiChordAlteration(type: 15, degree: 15)');
    });

    test('compares by value', () {
      final degree = runtime(9);
      expect(MidiChordAlteration(type: 1, degree: degree), add9);
      expect(
        MidiChordAlteration(type: 1, degree: degree).hashCode,
        add9.hashCode,
      );
      expect(add9, isNot(const MidiChordAlteration(type: 2, degree: 9)));
      expect(add9, isNot(const MidiChordAlteration(type: 1, degree: 8)));
      expect(add9 == Object(), isFalse);
    });

    for (final (type, degree) in [(-1, 0), (16, 0), (0, -1), (0, 16)]) {
      test('asserts $type and $degree', () {
        expectAssert(() => MidiChordAlteration(type: type, degree: degree));
      });
    }
  });

  group('MidiSetChordName', () {
    test('holds its fields', () {
      final name = chord(
        channel: 2,
        tonicSharpsFlats: -2,
        chordTonic: 15,
        chordType: 0xFF,
        alterations: const [add9, add9, add9, add9],
        bassSharpsFlats: 7,
        bassNote: 15,
        bassChordType: 0xFF,
        bassAlterations: const [add9, add9],
      );
      expect(
        (
          name.channel,
          name.tonicSharpsFlats,
          name.chordTonic,
          name.chordType,
          name.alterations.length,
          name.bassSharpsFlats,
          name.bassNote,
          name.bassChordType,
          name.bassAlterations.length,
        ),
        (2, -2, 15, 0xFF, 4, 7, 15, 0xFF, 2),
      );
    });

    test('uses the chord tonic as bass by default', () {
      final name = MidiSetChordName(
        tonicSharpsFlats: 0,
        chordTonic: runtime(1),
        chordType: 1,
      );
      expect(
        (name.bassSharpsFlats, name.bassNote, name.bassChordType),
        (-8, 0, 0),
      );
      expect(name.alterations, isEmpty);
      expect(name.bassAlterations, isEmpty);
    });

    test('holds copies of the alterations that cannot be modified', () {
      final alterations = [add9];
      final name = chord(
        alterations: alterations,
        bassAlterations: alterations,
      );
      alterations.clear();
      expect(name.alterations, equals([add9]));
      expect(name.bassAlterations, equals([add9]));
      expect(
        () => name.alterations.add(add9),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('prints its fields', () {
      expect(
        '${chord(alterations: const [add9])}',
        'MidiSetChordName(channel: null, tonicSharpsFlats: 0, chordTonic: 3, '
            'chordType: 1, '
            'alterations: [MidiChordAlteration(type: 1, degree: 9)], '
            'bassSharpsFlats: -8, bassNote: 0, bassChordType: 0, '
            'bassAlterations: [])',
      );
    });

    test('compares by value, alterations included', () {
      expect(chord(alterations: const [add9]), chord(alterations: [add9]));
      expect(
        chord(alterations: const [add9]).hashCode,
        chord(alterations: [add9]).hashCode,
      );
      expect(chord(alterations: const [add9]), isNot(chord()));
    });

    final invalid = <String, MidiSetChordName Function()>{
      'tonic sharps/flats -9': () => chord(tonicSharpsFlats: -9),
      'tonic sharps/flats 8': () => chord(tonicSharpsFlats: 8),
      'chord tonic -1': () => chord(chordTonic: -1),
      'chord tonic 16': () => chord(chordTonic: 16),
      'chord type -1': () => chord(chordType: -1),
      'chord type 256': () => chord(chordType: 256),
      'five alterations': () => chord(alterations: List.filled(5, add9)),
      'bass sharps/flats -9': () => chord(bassSharpsFlats: -9),
      'bass sharps/flats 8': () => chord(bassSharpsFlats: 8),
      'bass note -1': () => chord(bassNote: -1),
      'bass note 16': () => chord(bassNote: 16),
      'bass chord type -1': () => chord(bassChordType: -1),
      'bass chord type 256': () => chord(bassChordType: 256),
      'three bass alterations': () =>
          chord(bassAlterations: List.filled(3, add9)),
    };
    for (final MapEntry(key: name, value: create) in invalid.entries) {
      test('asserts $name', () => expectAssert(create));
    }
  });

  group('MidiFlexText', () {
    test('defines the text status banks', () {
      expect(
        (MidiFlexText.metadataTextBank, MidiFlexText.performanceTextBank),
        (1, 2),
      );
    });

    test('holds its fields', () {
      const text = MidiFlexText(
        channel: 4,
        statusBank: MidiFlexText.performanceTextBank,
        status: 0xFF,
        text: 'Lyrics',
      );
      expect(
        (text.channel, text.statusBank, text.status, text.text),
        (4, 2, 0xFF, 'Lyrics'),
      );
      expect(
        '$text',
        "MidiFlexText(channel: 4, statusBank: 2, status: 255, text: 'Lyrics')",
      );
    });

    test('compares by value', () {
      final status = runtime(1);
      expect(
        MidiFlexText(statusBank: 1, status: status, text: 'a'),
        const MidiFlexText(statusBank: 1, status: 1, text: 'a'),
      );
      expect(
        MidiFlexText(statusBank: 1, status: status, text: 'a').hashCode,
        const MidiFlexText(statusBank: 1, status: 1, text: 'a').hashCode,
      );
      expect(
        const MidiFlexText(statusBank: 1, status: 1, text: 'a'),
        isNot(const MidiFlexText(statusBank: 1, status: 1, text: 'b')),
      );
    });

    for (final (statusBank, status) in [(0, 0), (3, 0), (1, -1), (1, 256)]) {
      test('asserts status bank $statusBank and status $status', () {
        expectAssert(
          () => MidiFlexText(statusBank: statusBank, status: status, text: ''),
        );
      });
    }
  });
}
