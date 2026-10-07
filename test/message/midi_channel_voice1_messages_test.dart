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

  final creators = <String, MidiChannelVoice1Message Function(int channel)>{
    'MidiNoteOff': (channel) => MidiNoteOff(channel: channel, note: 1),
    'MidiNoteOn': (channel) =>
        MidiNoteOn(channel: channel, note: 1, velocity: 2),
    'MidiPolyPressure': (channel) =>
        MidiPolyPressure(channel: channel, note: 1, pressure: 2),
    'MidiControlChange': (channel) =>
        MidiControlChange(channel: channel, controller: 1, value: 2),
    'MidiProgramChange': (channel) =>
        MidiProgramChange(channel: channel, program: 1),
    'MidiChannelPressure': (channel) =>
        MidiChannelPressure(channel: channel, pressure: 1),
    'MidiPitchBend': (channel) => MidiPitchBend(channel: channel, value: 1),
  };

  group('MidiChannelVoice1Message', () {
    for (final MapEntry(key: name, value: create) in creators.entries) {
      group(name, () {
        test('holds channels 0 to 15', () {
          expect([create(0).channel, create(15).channel], equals([0, 15]));
        });

        test('is carried by MIDI 1.0 channel voice UMPs', () {
          expect(create(0).umpMessageType, UmpMessageType.midi1ChannelVoice);
        });

        for (final channel in [-1, 16]) {
          test('asserts channel $channel', () {
            expectAssert(() => create(channel));
          });
        }

        test('compares by value', () {
          expect(create(3), create(3));
          expect(create(3).hashCode, create(3).hashCode);
          expect(create(3), isNot(create(4)));
        });
      });
    }
  });

  group('MidiNoteOff', () {
    test('holds note and velocity', () {
      final message = MidiNoteOff(channel: 2, note: runtime(127), velocity: 0);
      expect((message.note, message.velocity), (127, 0));
      expect('$message', 'MidiNoteOff(channel: 2, note: 127, velocity: 0)');
    });

    test('uses velocity 64 by default', () {
      expect(MidiNoteOff(channel: 0, note: runtime(1)).velocity, 64);
    });

    test('differs by velocity', () {
      expect(
        const MidiNoteOff(channel: 0, note: 1),
        isNot(const MidiNoteOff(channel: 0, note: 1, velocity: 1)),
      );
    });

    for (final (note, velocity) in [(-1, 0), (128, 0), (0, -1), (0, 128)]) {
      test('asserts note $note and velocity $velocity', () {
        expectAssert(
          () => MidiNoteOff(channel: 0, note: note, velocity: velocity),
        );
      });
    }
  });

  group('MidiNoteOn', () {
    test('holds note and velocity', () {
      final message = MidiNoteOn(channel: 1, note: runtime(60), velocity: 100);
      expect((message.note, message.velocity), (60, 100));
      expect('$message', 'MidiNoteOn(channel: 1, note: 60, velocity: 100)');
    });

    test('acts as Note Off with velocity 0 only', () {
      expect([
        for (final velocity in [0, 1, 127])
          MidiNoteOn(channel: 0, note: 1, velocity: velocity).isNoteOff,
      ], equals([true, false, false]));
    });

    test('differs by velocity', () {
      expect(
        const MidiNoteOn(channel: 0, note: 1, velocity: 2),
        isNot(const MidiNoteOn(channel: 0, note: 1, velocity: 3)),
      );
    });

    for (final (note, velocity) in [(-1, 0), (128, 0), (0, -1), (0, 128)]) {
      test('asserts note $note and velocity $velocity', () {
        expectAssert(
          () => MidiNoteOn(channel: 0, note: note, velocity: velocity),
        );
      });
    }
  });

  group('MidiPolyPressure', () {
    test('holds note and pressure', () {
      final message = MidiPolyPressure(
        channel: 3,
        note: runtime(0),
        pressure: 127,
      );
      expect((message.note, message.pressure), (0, 127));
      expect(
        '$message',
        'MidiPolyPressure(channel: 3, note: 0, pressure: 127)',
      );
    });

    for (final (note, pressure) in [(-1, 0), (128, 0), (0, -1), (0, 128)]) {
      test('asserts note $note and pressure $pressure', () {
        expectAssert(
          () => MidiPolyPressure(channel: 0, note: note, pressure: pressure),
        );
      });
    }
  });

  group('MidiControlChange', () {
    test('holds controller and value', () {
      final message = MidiControlChange(
        channel: 4,
        controller: runtime(7),
        value: 100,
      );
      expect((message.controller, message.value), (7, 100));
      expect(
        '$message',
        'MidiControlChange(channel: 4, controller: 7, value: 100)',
      );
    });

    test('is a channel mode message for controllers 120 to 127', () {
      expect([
        for (final controller in [0, 119, 120, 127])
          MidiControlChange(
            channel: 0,
            controller: controller,
            value: 0,
          ).isChannelMode,
      ], equals([false, false, true, true]));
    });

    for (final (controller, value) in [(-1, 0), (128, 0), (0, -1), (0, 128)]) {
      test('asserts controller $controller and value $value', () {
        expectAssert(
          () => MidiControlChange(
            channel: 0,
            controller: controller,
            value: value,
          ),
        );
      });
    }
  });

  group('MidiProgramChange', () {
    test('holds the program', () {
      final message = MidiProgramChange(channel: 5, program: runtime(127));
      expect(message.program, 127);
      expect('$message', 'MidiProgramChange(channel: 5, program: 127)');
    });

    for (final program in [-1, 128]) {
      test('asserts program $program', () {
        expectAssert(() => MidiProgramChange(channel: 0, program: program));
      });
    }
  });

  group('MidiChannelPressure', () {
    test('holds the pressure', () {
      final message = MidiChannelPressure(channel: 6, pressure: runtime(64));
      expect(message.pressure, 64);
      expect('$message', 'MidiChannelPressure(channel: 6, pressure: 64)');
    });

    for (final pressure in [-1, 128]) {
      test('asserts pressure $pressure', () {
        expectAssert(() => MidiChannelPressure(channel: 0, pressure: pressure));
      });
    }
  });

  group('MidiPitchBend', () {
    test('holds the 14-bit value', () {
      final message = MidiPitchBend(channel: 7, value: runtime(0x3FFF));
      expect(message.value, 0x3FFF);
      expect('$message', 'MidiPitchBend(channel: 7, value: 16383)');
    });

    test('has its center at 0x2000', () {
      expect(MidiPitchBend.center, 0x2000);
    });

    for (final value in [-1, 0x4000]) {
      test('asserts value $value', () {
        expectAssert(() => MidiPitchBend(channel: 0, value: value));
      });
    }
  });
}
