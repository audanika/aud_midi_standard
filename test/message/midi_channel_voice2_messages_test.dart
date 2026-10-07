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

  const max32 = 0xFFFFFFFF;

  final creators = <String, MidiChannelVoice2Message Function(int channel)>{
    'MidiNoteOff2': (channel) => MidiNoteOff2(channel: channel, note: 1),
    'MidiNoteOn2': (channel) =>
        MidiNoteOn2(channel: channel, note: 1, velocity: 2),
    'MidiPolyPressure2': (channel) =>
        MidiPolyPressure2(channel: channel, note: 1, pressure: 2),
    'MidiRegisteredPerNoteController': (channel) =>
        MidiRegisteredPerNoteController(
          channel: channel,
          note: 1,
          index: 2,
          value: 3,
        ),
    'MidiAssignablePerNoteController': (channel) =>
        MidiAssignablePerNoteController(
          channel: channel,
          note: 1,
          index: 2,
          value: 3,
        ),
    'MidiPerNoteManagement': (channel) =>
        MidiPerNoteManagement(channel: channel, note: 1),
    'MidiControlChange2': (channel) =>
        MidiControlChange2(channel: channel, controller: 1, value: 2),
    'MidiRegisteredController': (channel) =>
        MidiRegisteredController(channel: channel, bank: 1, index: 2, value: 3),
    'MidiAssignableController': (channel) =>
        MidiAssignableController(channel: channel, bank: 1, index: 2, value: 3),
    'MidiRelativeRegisteredController': (channel) =>
        MidiRelativeRegisteredController(
          channel: channel,
          bank: 1,
          index: 2,
          value: -3,
        ),
    'MidiRelativeAssignableController': (channel) =>
        MidiRelativeAssignableController(
          channel: channel,
          bank: 1,
          index: 2,
          value: -3,
        ),
    'MidiProgramChange2': (channel) =>
        MidiProgramChange2(channel: channel, program: 1),
    'MidiChannelPressure2': (channel) =>
        MidiChannelPressure2(channel: channel, pressure: 1),
    'MidiPitchBend2': (channel) => MidiPitchBend2(channel: channel, value: 1),
    'MidiPerNotePitchBend': (channel) =>
        MidiPerNotePitchBend(channel: channel, note: 1, value: 2),
  };

  group('MidiChannelVoice2Message', () {
    test('defines center and maximum of 32-bit values', () {
      expect(
        (MidiChannelVoice2Message.center32, MidiChannelVoice2Message.max32),
        (0x80000000, 0xFFFFFFFF),
      );
    });

    for (final MapEntry(key: name, value: create) in creators.entries) {
      group(name, () {
        test('holds channels 0 to 15', () {
          expect([create(0).channel, create(15).channel], equals([0, 15]));
        });

        test('is carried by MIDI 2.0 channel voice UMPs', () {
          expect(create(0).umpMessageType, UmpMessageType.midi2ChannelVoice);
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

  group('MidiNoteOff2', () {
    test('holds note, velocity and attribute', () {
      const message = MidiNoteOff2(
        channel: 1,
        note: 127,
        velocity: 0xFFFF,
        attributeType: 0xFF,
        attribute: 0xFFFF,
      );
      expect(
        (
          message.note,
          message.velocity,
          message.attributeType,
          message.attribute,
        ),
        (127, 0xFFFF, 0xFF, 0xFFFF),
      );
      expect(
        '$message',
        'MidiNoteOff2(channel: 1, note: 127, velocity: 65535, '
            'attributeType: 255, attribute: 65535)',
      );
    });

    test('uses velocity 0x8000 and no attribute by default', () {
      final message = MidiNoteOff2(channel: 0, note: creators.length);
      expect(
        (message.velocity, message.attributeType, message.attribute),
        (0x8000, 0, 0),
      );
    });

    for (final (note, velocity, type, attribute) in [
      (-1, 0, 0, 0),
      (128, 0, 0, 0),
      (0, -1, 0, 0),
      (0, 0x10000, 0, 0),
      (0, 0, -1, 0),
      (0, 0, 0x100, 0),
      (0, 0, 0, -1),
      (0, 0, 0, 0x10000),
    ]) {
      test('asserts $note, $velocity, $type, $attribute', () {
        expectAssert(
          () => MidiNoteOff2(
            channel: 0,
            note: note,
            velocity: velocity,
            attributeType: type,
            attribute: attribute,
          ),
        );
      });
    }
  });

  group('MidiNoteOn2', () {
    test('holds note, velocity and attribute', () {
      const message = MidiNoteOn2(
        channel: 2,
        note: 60,
        velocity: 0,
        attributeType: 3,
        attribute: 0x7800,
      );
      expect(
        (
          message.note,
          message.velocity,
          message.attributeType,
          message.attribute,
        ),
        (60, 0, 3, 0x7800),
      );
      expect(
        '$message',
        'MidiNoteOn2(channel: 2, note: 60, velocity: 0, '
            'attributeType: 3, attribute: 30720)',
      );
    });

    test('uses no attribute by default', () {
      final message = MidiNoteOn2(
        channel: 0,
        note: 1,
        velocity: creators.length,
      );
      expect((message.attributeType, message.attribute), (0, 0));
    });

    for (final (note, velocity, type, attribute) in [
      (-1, 0, 0, 0),
      (128, 0, 0, 0),
      (0, -1, 0, 0),
      (0, 0x10000, 0, 0),
      (0, 0, -1, 0),
      (0, 0, 0x100, 0),
      (0, 0, 0, -1),
      (0, 0, 0, 0x10000),
    ]) {
      test('asserts $note, $velocity, $type, $attribute', () {
        expectAssert(
          () => MidiNoteOn2(
            channel: 0,
            note: note,
            velocity: velocity,
            attributeType: type,
            attribute: attribute,
          ),
        );
      });
    }
  });

  group('MidiPolyPressure2', () {
    test('holds note and pressure', () {
      const message = MidiPolyPressure2(channel: 3, note: 5, pressure: max32);
      expect((message.note, message.pressure), (5, max32));
      expect(
        '$message',
        'MidiPolyPressure2(channel: 3, note: 5, pressure: 4294967295)',
      );
    });

    for (final (note, pressure) in [
      (-1, 0),
      (128, 0),
      (0, -1),
      (0, max32 + 1),
    ]) {
      test('asserts note $note and pressure $pressure', () {
        expectAssert(
          () => MidiPolyPressure2(channel: 0, note: note, pressure: pressure),
        );
      });
    }
  });

  final perNoteControllers =
      <String, MidiChannelVoice2Message Function(int, int, int)>{
        'MidiRegisteredPerNoteController': (note, index, value) =>
            MidiRegisteredPerNoteController(
              channel: 4,
              note: note,
              index: index,
              value: value,
            ),
        'MidiAssignablePerNoteController': (note, index, value) =>
            MidiAssignablePerNoteController(
              channel: 4,
              note: note,
              index: index,
              value: value,
            ),
      };
  for (final MapEntry(key: name, value: create) in perNoteControllers.entries) {
    group(name, () {
      test('holds note, index and value', () {
        final message = create(127, 255, max32);
        final (note, index, value) = switch (message) {
          MidiRegisteredPerNoteController(
            :final note,
            :final index,
            :final value,
          ) ||
          MidiAssignablePerNoteController(
            :final note,
            :final index,
            :final value,
          ) => (note, index, value),
          _ => (0, 0, 0),
        };
        expect((note, index, value), (127, 255, max32));
        expect(
          '$message',
          '$name(channel: 4, note: 127, index: 255, value: 4294967295)',
        );
      });

      for (final (note, index, value) in [
        (-1, 0, 0),
        (128, 0, 0),
        (0, -1, 0),
        (0, 256, 0),
        (0, 0, -1),
        (0, 0, max32 + 1),
      ]) {
        test('asserts $note, $index, $value', () {
          expectAssert(() => create(note, index, value));
        });
      }
    });
  }

  group('MidiPerNoteManagement', () {
    test('holds note and option flags', () {
      const message = MidiPerNoteManagement(
        channel: 5,
        note: 64,
        detach: true,
        reset: true,
      );
      expect((message.note, message.detach, message.reset), (64, true, true));
      expect(
        '$message',
        'MidiPerNoteManagement(channel: 5, note: 64, detach: true, '
            'reset: true)',
      );
    });

    test('sets no option flag by default', () {
      final message = MidiPerNoteManagement(channel: 0, note: creators.length);
      expect((message.detach, message.reset), (false, false));
    });

    test('differs by option flags', () {
      expect(
        const MidiPerNoteManagement(channel: 0, note: 1, detach: true),
        isNot(const MidiPerNoteManagement(channel: 0, note: 1, reset: true)),
      );
    });

    for (final note in [-1, 128]) {
      test('asserts note $note', () {
        expectAssert(() => MidiPerNoteManagement(channel: 0, note: note));
      });
    }
  });

  group('MidiControlChange2', () {
    test('holds controller and value', () {
      const message = MidiControlChange2(
        channel: 6,
        controller: 127,
        value: max32,
      );
      expect((message.controller, message.value), (127, max32));
      expect(
        '$message',
        'MidiControlChange2(channel: 6, controller: 127, value: 4294967295)',
      );
    });

    for (final (controller, value) in [
      (-1, 0),
      (128, 0),
      (0, -1),
      (0, max32 + 1),
    ]) {
      test('asserts controller $controller and value $value', () {
        expectAssert(
          () => MidiControlChange2(
            channel: 0,
            controller: controller,
            value: value,
          ),
        );
      });
    }
  });

  final controllers =
      <String, (MidiChannelVoice2Message Function(int, int, int), int, int)>{
        'MidiRegisteredController': (
          (bank, index, value) => MidiRegisteredController(
            channel: 7,
            bank: bank,
            index: index,
            value: value,
          ),
          0,
          max32,
        ),
        'MidiAssignableController': (
          (bank, index, value) => MidiAssignableController(
            channel: 7,
            bank: bank,
            index: index,
            value: value,
          ),
          0,
          max32,
        ),
        'MidiRelativeRegisteredController': (
          (bank, index, value) => MidiRelativeRegisteredController(
            channel: 7,
            bank: bank,
            index: index,
            value: value,
          ),
          -0x80000000,
          0x7FFFFFFF,
        ),
        'MidiRelativeAssignableController': (
          (bank, index, value) => MidiRelativeAssignableController(
            channel: 7,
            bank: bank,
            index: index,
            value: value,
          ),
          -0x80000000,
          0x7FFFFFFF,
        ),
      };
  for (final MapEntry(key: name, value: (create, min, max))
      in controllers.entries) {
    group(name, () {
      test('holds bank, index and value', () {
        final messages = [create(127, 127, min), create(0, 1, max)];
        final fields = [
          for (final message in messages)
            switch (message) {
              MidiRegisteredController(
                :final bank,
                :final index,
                :final value,
              ) ||
              MidiAssignableController(
                :final bank,
                :final index,
                :final value,
              ) ||
              MidiRelativeRegisteredController(
                :final bank,
                :final index,
                :final value,
              ) ||
              MidiRelativeAssignableController(
                :final bank,
                :final index,
                :final value,
              ) => (bank, index, value),
              _ => (-1, -1, -1),
            },
        ];
        expect(fields, equals([(127, 127, min), (0, 1, max)]));
        expect(
          '${messages.first}',
          '$name(channel: 7, bank: 127, index: 127, value: $min)',
        );
      });

      for (final (bank, index, value) in [
        (-1, 0, 0),
        (128, 0, 0),
        (0, -1, 0),
        (0, 128, 0),
        (0, 0, min - 1),
        (0, 0, max + 1),
      ]) {
        test('asserts $bank, $index, $value', () {
          expectAssert(() => create(bank, index, value));
        });
      }
    });
  }

  group('MidiProgramChange2', () {
    test('holds program and bank', () {
      final message = MidiProgramChange2(
        channel: 8,
        program: 127,
        bank: (msb: 1, lsb: creators.length),
      );
      expect(
        (message.program, message.bank, message.bankValid),
        (127, (msb: 1, lsb: 15), true),
      );
      expect(
        '$message',
        'MidiProgramChange2(channel: 8, program: 127, bank: (lsb: 15, msb: 1))',
      );
    });

    test('selects no bank by default', () {
      final message = MidiProgramChange2(channel: 0, program: creators.length);
      expect((message.bank, message.bankValid), (null, false));
    });

    test('differs by bank', () {
      expect(
        const MidiProgramChange2(channel: 0, program: 1),
        isNot(
          const MidiProgramChange2(
            channel: 0,
            program: 1,
            bank: (msb: 0, lsb: 0),
          ),
        ),
      );
    });

    for (final program in [-1, 128]) {
      test('asserts program $program', () {
        expectAssert(() => MidiProgramChange2(channel: 0, program: program));
      });
    }
  });

  group('MidiChannelPressure2', () {
    test('holds the pressure', () {
      const message = MidiChannelPressure2(channel: 9, pressure: max32);
      expect(message.pressure, max32);
      expect(
        '$message',
        'MidiChannelPressure2(channel: 9, pressure: 4294967295)',
      );
    });

    for (final pressure in [-1, max32 + 1]) {
      test('asserts pressure $pressure', () {
        expectAssert(
          () => MidiChannelPressure2(channel: 0, pressure: pressure),
        );
      });
    }
  });

  group('MidiPitchBend2', () {
    test('holds the value', () {
      const message = MidiPitchBend2(
        channel: 10,
        value: MidiChannelVoice2Message.center32,
      );
      expect(message.value, 0x80000000);
      expect('$message', 'MidiPitchBend2(channel: 10, value: 2147483648)');
    });

    for (final value in [-1, max32 + 1]) {
      test('asserts value $value', () {
        expectAssert(() => MidiPitchBend2(channel: 0, value: value));
      });
    }
  });

  group('MidiPerNotePitchBend', () {
    test('holds note and value', () {
      final message = MidiPerNotePitchBend(
        channel: 11,
        note: 127,
        value: creators.length,
      );
      expect((message.note, message.value), (127, 15));
      expect(
        '$message',
        'MidiPerNotePitchBend(channel: 11, note: 127, value: 15)',
      );
    });

    for (final (note, value) in [(-1, 0), (128, 0), (0, -1), (0, max32 + 1)]) {
      test('asserts note $note and value $value', () {
        expectAssert(
          () => MidiPerNotePitchBend(channel: 0, note: note, value: value),
        );
      });
    }
  });
}
