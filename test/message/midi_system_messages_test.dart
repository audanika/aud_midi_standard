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

  group('system messages', () {
    final messages = <(MidiSystemMessage, int, String)>[
      (
        const MidiTimeCodeQuarterFrame(piece: 7, value: 15),
        0xF1,
        'MidiTimeCodeQuarterFrame(piece: 7, value: 15)',
      ),
      (
        const MidiSongPositionPointer(position: 0x3FFF),
        0xF2,
        'MidiSongPositionPointer(position: 16383)',
      ),
      (const MidiSongSelect(song: 127), 0xF3, 'MidiSongSelect(song: 127)'),
      (const MidiTuneRequest(), 0xF6, 'MidiTuneRequest()'),
      (const MidiTimingClock(), 0xF8, 'MidiTimingClock()'),
      (const MidiStart(), 0xFA, 'MidiStart()'),
      (const MidiContinue(), 0xFB, 'MidiContinue()'),
      (const MidiStop(), 0xFC, 'MidiStop()'),
      (const MidiActiveSensing(), 0xFE, 'MidiActiveSensing()'),
      (const MidiSystemReset(), 0xFF, 'MidiSystemReset()'),
    ];

    for (final (message, status, string) in messages) {
      group('${message.runtimeType}', () {
        test('has status 0x${status.toRadixString(16)}', () {
          expect(message.status, status);
        });

        test('is carried by system UMPs', () {
          expect(message.umpMessageType, UmpMessageType.system);
        });

        test('prints its fields', () {
          expect('$message', string);
        });

        test('belongs to its kind of system message', () {
          expect(
            message,
            status >= 0xF8
                ? isA<MidiSystemRealTimeMessage>()
                : isA<MidiSystemCommonMessage>(),
          );
        });
      });
    }
  });

  group('MidiTimeCodeQuarterFrame', () {
    test('holds piece and value', () {
      for (final piece in [0, 7]) {
        final message = MidiTimeCodeQuarterFrame(piece: piece, value: 9);
        expect((message.piece, message.value), (piece, 9));
      }
    });

    test('compares by value', () {
      final piece = runtime(3);
      expect(
        MidiTimeCodeQuarterFrame(piece: piece, value: 4),
        const MidiTimeCodeQuarterFrame(piece: 3, value: 4),
      );
      expect(
        MidiTimeCodeQuarterFrame(piece: piece, value: 4).hashCode,
        const MidiTimeCodeQuarterFrame(piece: 3, value: 4).hashCode,
      );
      expect(
        MidiTimeCodeQuarterFrame(piece: piece, value: 4),
        isNot(const MidiTimeCodeQuarterFrame(piece: 3, value: 5)),
      );
    });

    for (final (piece, value) in [(-1, 0), (8, 0), (0, -1), (0, 16)]) {
      test('asserts piece $piece and value $value', () {
        expectAssert(
          () => MidiTimeCodeQuarterFrame(piece: piece, value: value),
        );
      });
    }
  });

  group('MidiSongPositionPointer', () {
    test('holds the position', () {
      for (final position in [0, 0x3FFF]) {
        expect(MidiSongPositionPointer(position: position).position, position);
      }
    });

    test('compares by value', () {
      final position = runtime(5);
      expect(
        MidiSongPositionPointer(position: position),
        const MidiSongPositionPointer(position: 5),
      );
      expect(
        MidiSongPositionPointer(position: position),
        isNot(const MidiSongPositionPointer(position: 6)),
      );
    });

    for (final position in [-1, 0x4000]) {
      test('asserts position $position', () {
        expectAssert(() => MidiSongPositionPointer(position: position));
      });
    }
  });

  group('MidiSongSelect', () {
    test('holds the song', () {
      for (final song in [0, 127]) {
        expect(MidiSongSelect(song: song).song, song);
      }
    });

    test('compares by value', () {
      final song = runtime(5);
      expect(MidiSongSelect(song: song), const MidiSongSelect(song: 5));
      expect(MidiSongSelect(song: song), isNot(const MidiSongSelect(song: 6)));
    });

    for (final song in [-1, 128]) {
      test('asserts song $song', () {
        expectAssert(() => MidiSongSelect(song: song));
      });
    }
  });

  group('real-time and argument-free messages', () {
    test('equal instances of the same type only', () {
      expect(const MidiTuneRequest(), const MidiTuneRequest());
      expect(const MidiTimingClock(), isNot(const MidiStart()));
      expect(const MidiContinue().hashCode, const MidiContinue().hashCode);
    });
  });
}
