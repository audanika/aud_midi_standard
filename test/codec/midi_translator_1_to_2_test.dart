// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  late MidiTranslator1To2 translator;

  setUp(() => translator = MidiTranslator1To2());

  MidiControlChange cc(int controller, int value, {int channel = 0}) =>
      MidiControlChange(channel: channel, controller: controller, value: value);

  List<MidiMessage> translateAll(List<MidiMessage> messages, {int group = 0}) =>
      [
        for (final message in messages)
          ...translator.translate(message, group: group),
      ];

  int up14(int value) =>
      MidiValueScaling.scaleUp(value, fromBits: 14, toBits: 32);

  group('MidiTranslator1To2', () {
    group('MidiTranslator1To2(flushDataEntryMsb)', () {
      test('does not flush by default', () {
        expect(MidiTranslator1To2().flushDataEntryMsb, isFalse);
      });
    });

    group('translate(message, group)', () {
      group('translates', () {
        final cases = <(MidiMessage, MidiMessage)>[
          (
            const MidiNoteOn(channel: 1, note: 60, velocity: 0),
            const MidiNoteOff2(channel: 1, note: 60, velocity: 0),
          ),
          (
            const MidiNoteOn(channel: 1, note: 60, velocity: 1),
            const MidiNoteOn2(channel: 1, note: 60, velocity: 0x0200),
          ),
          (
            const MidiNoteOn(channel: 2, note: 61, velocity: 0x57),
            const MidiNoteOn2(channel: 2, note: 61, velocity: 0xAEBA),
          ),
          (
            const MidiNoteOn(channel: 3, note: 127, velocity: 127),
            const MidiNoteOn2(channel: 3, note: 127, velocity: 0xFFFF),
          ),
          (
            const MidiNoteOff(channel: 4, note: 0),
            const MidiNoteOff2(channel: 4, note: 0),
          ),
          (
            const MidiNoteOff(channel: 4, note: 0, velocity: 0),
            const MidiNoteOff2(channel: 4, note: 0, velocity: 0),
          ),
          (
            const MidiPolyPressure(channel: 5, note: 10, pressure: 127),
            const MidiPolyPressure2(channel: 5, note: 10, pressure: 0xFFFFFFFF),
          ),
          (
            const MidiControlChange(channel: 6, controller: 7, value: 64),
            const MidiControlChange2(
              channel: 6,
              controller: 7,
              value: 0x80000000,
            ),
          ),
          (
            const MidiControlChange(channel: 6, controller: 96, value: 1),
            const MidiControlChange2(
              channel: 6,
              controller: 96,
              value: 0x02000000,
            ),
          ),
          (
            const MidiControlChange(channel: 6, controller: 97, value: 0),
            const MidiControlChange2(channel: 6, controller: 97, value: 0),
          ),
          (
            const MidiControlChange(channel: 6, controller: 123, value: 0),
            const MidiControlChange2(channel: 6, controller: 123, value: 0),
          ),
          (
            const MidiChannelPressure(channel: 7, pressure: 0x40),
            const MidiChannelPressure2(channel: 7, pressure: 0x80000000),
          ),
          (
            const MidiPitchBend(channel: 8, value: 0x2000),
            const MidiPitchBend2(channel: 8, value: 0x80000000),
          ),
          (
            const MidiPitchBend(channel: 8, value: 0x3FFF),
            const MidiPitchBend2(channel: 8, value: 0xFFFFFFFF),
          ),
          (
            const MidiPitchBend(channel: 8, value: 0),
            const MidiPitchBend2(channel: 8, value: 0),
          ),
          (
            const MidiProgramChange(channel: 9, program: 5),
            const MidiProgramChange2(channel: 9, program: 5),
          ),
        ];
        for (final (input, output) in cases) {
          test('$input to $output', () {
            expect(translator.translate(input), equals([output]));
          });
        }

        test('14-bit controller pairs as two controllers', () {
          expect(
            translateAll([cc(1, 0x10), cc(33, 0x20)]),
            equals([
              const MidiControlChange2(
                channel: 0,
                controller: 1,
                value: 0x10 << 25,
              ),
              const MidiControlChange2(
                channel: 0,
                controller: 33,
                value: 0x20 << 25,
              ),
            ]),
          );
        });
      });

      group('returns unchanged', () {
        final messages = <MidiMessage>[
          const MidiTimingClock(),
          const MidiSongSelect(song: 3),
          MidiSysEx(const [0x7E, 0x7F]),
          const MidiNoop(),
          const MidiNoteOn2(channel: 0, note: 1, velocity: 2),
          const MidiPerNotePitchBend(channel: 0, note: 1, value: 2),
          MidiSysEx8(streamId: 1, data: const [1]),
          MidiMixedDataSet(
            mdsId: 0,
            manufacturerId: 0,
            deviceId: 0,
            subId1: 0,
            subId2: 0,
            data: const [],
          ),
          const MidiSetTempo(tenNanosecondsPerQuarterNote: 1),
          const MidiEndOfClip(),
          MidiUnknownMessage([Ump.fromHex('60000000')]),
        ];
        for (final message in messages) {
          test('$message', () {
            expect(translator.translate(message), equals([message]));
          });
        }
      });

      group('with Bank Select', () {
        test('holds both values until the next Program Change', () {
          expect(
            translateAll([
              cc(0, 1),
              cc(32, 2),
              const MidiProgramChange(channel: 0, program: 3),
            ]),
            equals([
              const MidiProgramChange2(
                channel: 0,
                program: 3,
                bank: (msb: 1, lsb: 2),
              ),
            ]),
          );
        });

        test('keeps the values for later Program Changes', () {
          translateAll([cc(0, 1), cc(32, 2)]);
          translateAll([const MidiProgramChange(channel: 0, program: 3)]);
          expect(
            translator.translate(
              const MidiProgramChange(channel: 0, program: 4),
            ),
            equals([
              const MidiProgramChange2(
                channel: 0,
                program: 4,
                bank: (msb: 1, lsb: 2),
              ),
            ]),
          );
        });

        test('counts a missing LSB as 0', () {
          expect(
            translateAll([
              cc(0, 5),
              const MidiProgramChange(channel: 0, program: 3),
            ]),
            equals([
              const MidiProgramChange2(
                channel: 0,
                program: 3,
                bank: (msb: 5, lsb: 0),
              ),
            ]),
          );
        });

        test('counts a missing MSB as 0', () {
          expect(
            translateAll([
              cc(32, 5),
              const MidiProgramChange(channel: 0, program: 3),
            ]),
            equals([
              const MidiProgramChange2(
                channel: 0,
                program: 3,
                bank: (msb: 0, lsb: 5),
              ),
            ]),
          );
        });

        test('keeps the context of each group and channel apart', () {
          translateAll([cc(0, 1), cc(32, 2)]);
          expect(
            [
              ...translator.translate(
                const MidiProgramChange(channel: 1, program: 3),
              ),
              ...translator.translate(
                const MidiProgramChange(channel: 0, program: 3),
                group: 1,
              ),
            ],
            equals([
              const MidiProgramChange2(channel: 1, program: 3),
              const MidiProgramChange2(channel: 0, program: 3),
            ]),
          );
        });
      });

      group('with RPN and NRPN', () {
        test('sends a Registered Controller on Data Entry LSB', () {
          expect(
            translateAll([cc(101, 0), cc(100, 0), cc(6, 2), cc(38, 0)]),
            equals([
              const MidiRegisteredController(
                channel: 0,
                bank: 0,
                index: 0,
                value: 0x04000000,
              ),
            ]),
          );
        });

        test('sends an Assignable Controller on Data Entry LSB', () {
          expect(
            translateAll([cc(99, 1), cc(98, 2), cc(6, 0x7F), cc(38, 0x7F)]),
            equals([
              const MidiAssignableController(
                channel: 0,
                bank: 1,
                index: 2,
                value: 0xFFFFFFFF,
              ),
            ]),
          );
        });

        test('accepts the selection in any order', () {
          expect(
            translateAll([cc(98, 2), cc(99, 1), cc(6, 3), cc(38, 4)]),
            equals([
              MidiAssignableController(
                channel: 0,
                bank: 1,
                index: 2,
                value: up14(3 << 7 | 4),
              ),
            ]),
          );
        });

        test('keeps the Data Entry MSB for further LSBs', () {
          translateAll([cc(101, 0), cc(100, 0), cc(6, 2), cc(38, 0)]);
          expect(
            translator.translate(cc(38, 50)),
            equals([
              MidiRegisteredController(
                channel: 0,
                bank: 0,
                index: 0,
                value: up14(2 << 7 | 50),
              ),
            ]),
          );
        });

        test('uses the latest Data Entry MSB', () {
          expect(
            translateAll([
              cc(101, 0),
              cc(100, 1),
              cc(6, 2),
              cc(6, 3),
              cc(38, 4),
            ]),
            equals([
              MidiRegisteredController(
                channel: 0,
                bank: 0,
                index: 1,
                value: up14(3 << 7 | 4),
              ),
            ]),
          );
        });

        test('switches between RPN and NRPN with the last selection', () {
          expect(
            translateAll([
              cc(101, 0),
              cc(100, 1),
              cc(99, 2),
              cc(98, 3),
              cc(6, 4),
              cc(38, 5),
              cc(100, 6),
              cc(6, 7),
              cc(38, 8),
            ]),
            equals([
              MidiAssignableController(
                channel: 0,
                bank: 2,
                index: 3,
                value: up14(4 << 7 | 5),
              ),
              MidiRegisteredController(
                channel: 0,
                bank: 0,
                index: 6,
                value: up14(7 << 7 | 8),
              ),
            ]),
          );
        });

        final dropped = <String, List<MidiMessage>>{
          'without selection': [cc(6, 1), cc(38, 2)],
          'with half a selection': [cc(101, 0), cc(6, 1), cc(38, 2)],
          'without Data Entry MSB': [cc(101, 0), cc(100, 0), cc(38, 2)],
          'for the null function': [
            cc(101, 0x7F),
            cc(100, 0x7F),
            cc(6, 1),
            cc(38, 2),
          ],
          'after a new selection forgot the MSB': [
            cc(101, 0),
            cc(100, 0),
            cc(6, 1),
            cc(100, 1),
            cc(38, 2),
          ],
          'for Data Entry MSB alone': [cc(101, 0), cc(100, 0), cc(6, 1)],
        };
        for (final MapEntry(key: name, value: messages) in dropped.entries) {
          test('sends nothing $name', () {
            expect(translateAll(messages), isEmpty);
          });
        }

        test('keeps the context of each group apart', () {
          translateAll([cc(101, 0), cc(100, 0), cc(6, 2)]);
          expect(translateAll([cc(38, 0)], group: 1), isEmpty);
          expect(translateAll([cc(38, 0)]), hasLength(1));
        });
      });

      group('with flushDataEntryMsb', () {
        setUp(() => translator = MidiTranslator1To2(flushDataEntryMsb: true));

        test('sends a pending Data Entry MSB on a new selection', () {
          expect(
            translateAll([
              cc(101, 0),
              cc(100, 0),
              cc(6, 12),
              cc(101, 0x7F),
              cc(100, 0x7F),
            ]),
            equals([
              MidiRegisteredController(
                channel: 0,
                bank: 0,
                index: 0,
                value: up14(12 << 7),
              ),
            ]),
          );
        });

        test('sends nothing when Data Entry LSB already sent it', () {
          expect(
            translateAll([
              cc(99, 1),
              cc(98, 1),
              cc(6, 12),
              cc(38, 0),
              cc(99, 2),
            ]),
            hasLength(1),
          );
        });

        test('sends nothing without a valid selection', () {
          expect(translateAll([cc(6, 12), cc(101, 0)]), isEmpty);
        });
      });
    });

    group('reset()', () {
      test('forgets Bank Select', () {
        translateAll([cc(0, 1), cc(32, 2)]);
        translator.reset();
        expect(
          translator.translate(const MidiProgramChange(channel: 0, program: 3)),
          equals([const MidiProgramChange2(channel: 0, program: 3)]),
        );
      });

      test('forgets RPN selection and Data Entry MSB', () {
        translateAll([cc(101, 0), cc(100, 0), cc(6, 2)]);
        translator.reset();
        expect(translator.translate(cc(38, 0)), isEmpty);
      });
    });

    group('round trip with MidiTranslator2To1', () {
      final back = MidiTranslator2To1();

      List<MidiMessage> roundTrip(List<MidiMessage> messages) => [
        for (final message in translateAll(messages))
          ...back.translate(message),
      ];

      test('restores all note, pressure and pitch bend values', () {
        final messages = <MidiMessage>[
          for (var value = 0; value < 128; value++) ...[
            if (value > 0)
              MidiNoteOn(channel: value & 0xF, note: value, velocity: value),
            MidiNoteOff(
              channel: value & 0xF,
              note: 127 - value,
              velocity: value,
            ),
            MidiPolyPressure(channel: 3, note: value, pressure: value),
            MidiChannelPressure(channel: 4, pressure: value),
            MidiProgramChange(channel: 5, program: value),
          ],
          for (var value = 0; value < 0x4000; value++)
            MidiPitchBend(channel: value & 0xF, value: value),
        ];
        expect(roundTrip(messages), equals(messages));
      });

      test('restores Note On with velocity 0 as Note Off', () {
        expect(
          roundTrip([const MidiNoteOn(channel: 0, note: 60, velocity: 0)]),
          equals([const MidiNoteOff(channel: 0, note: 60, velocity: 0)]),
        );
      });

      test('restores all values of all plain controllers', () {
        const held = {0, 6, 32, 38, 98, 99, 100, 101};
        final messages = [
          for (var controller = 0; controller < 128; controller++)
            if (!held.contains(controller))
              for (var value = 0; value < 128; value++) cc(controller, value),
        ];
        expect(roundTrip(messages), equals(messages));
      });

      test('restores all 14-bit RPN and NRPN values', () {
        for (var value = 0; value < 0x4000; value += 3) {
          final registered = value.isEven;
          final messages = [
            cc(registered ? 101 : 99, (value * 7) & 0x7F),
            cc(registered ? 100 : 98, value % 100),
            cc(6, value >> 7),
            cc(38, value & 0x7F),
          ];
          expect(roundTrip(messages), equals(messages), reason: '$value');
        }
      });

      test('restores Bank Select with Program Change', () {
        final messages = [
          cc(0, 0x7F),
          cc(32, 0x40),
          const MidiProgramChange(channel: 0, program: 0x7F),
        ];
        expect(roundTrip(messages), equals(messages));
      });
    });
  });
}
