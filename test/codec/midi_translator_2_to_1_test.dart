// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  late List<(MidiDiagnosticKind, String)> issues;
  late MidiTranslator2To1 translator;

  setUp(() {
    issues = [];
    translator = MidiTranslator2To1(
      onIssue: (kind, cause) => issues.add((kind, cause)),
    );
  });

  MidiControlChange cc(int controller, int value, {int channel = 0}) =>
      MidiControlChange(channel: channel, controller: controller, value: value);

  group('MidiTranslator2To1', () {
    group('MidiTranslator2To1(onIssue)', () {
      test('has no callback by default', () {
        expect(MidiTranslator2To1().onIssue, isNull);
      });
    });

    group('translate(message)', () {
      group('translates', () {
        final cases = <(MidiMessage, List<MidiMessage>)>[
          (
            const MidiNoteOff2(channel: 1, note: 60),
            [const MidiNoteOff(channel: 1, note: 60)],
          ),
          (
            const MidiNoteOff2(channel: 1, note: 60, velocity: 0x01FF),
            [const MidiNoteOff(channel: 1, note: 60, velocity: 0)],
          ),
          (
            const MidiNoteOn2(
              channel: 2,
              note: 61,
              velocity: 0xAEBA,
              attributeType: 3,
              attribute: 0x1234,
            ),
            [const MidiNoteOn(channel: 2, note: 61, velocity: 0x57)],
          ),
          (
            const MidiNoteOn2(channel: 2, note: 61, velocity: 0x01FF),
            [const MidiNoteOn(channel: 2, note: 61, velocity: 1)],
          ),
          (
            const MidiNoteOn2(channel: 2, note: 61, velocity: 0),
            [const MidiNoteOn(channel: 2, note: 61, velocity: 1)],
          ),
          (
            const MidiNoteOn2(channel: 2, note: 61, velocity: 0xFFFF),
            [const MidiNoteOn(channel: 2, note: 61, velocity: 127)],
          ),
          (
            const MidiPolyPressure2(channel: 3, note: 5, pressure: 0xFFFFFFFF),
            [const MidiPolyPressure(channel: 3, note: 5, pressure: 127)],
          ),
          (
            const MidiControlChange2(
              channel: 4,
              controller: 74,
              value: 0x81FFFFFF,
            ),
            [cc(74, 0x40, channel: 4)],
          ),
          (
            const MidiRegisteredController(
              channel: 5,
              bank: 0,
              index: 0,
              value: 0x04000000,
            ),
            [
              cc(101, 0, channel: 5),
              cc(100, 0, channel: 5),
              cc(6, 2, channel: 5),
              cc(38, 0, channel: 5),
            ],
          ),
          (
            const MidiAssignableController(
              channel: 6,
              bank: 0x12,
              index: 0x34,
              value: 0xFFFFFFFF,
            ),
            [
              cc(99, 0x12, channel: 6),
              cc(98, 0x34, channel: 6),
              cc(6, 0x7F, channel: 6),
              cc(38, 0x7F, channel: 6),
            ],
          ),
          (
            const MidiProgramChange2(channel: 7, program: 9),
            [const MidiProgramChange(channel: 7, program: 9)],
          ),
          (
            const MidiProgramChange2(
              channel: 7,
              program: 9,
              bank: (msb: 1, lsb: 2),
            ),
            [
              cc(0, 1, channel: 7),
              cc(32, 2, channel: 7),
              const MidiProgramChange(channel: 7, program: 9),
            ],
          ),
          (
            const MidiProgramChange2(
              channel: 7,
              program: 9,
              bank: (msb: 0x81, lsb: 0x82),
            ),
            [
              cc(0, 1, channel: 7),
              cc(32, 2, channel: 7),
              const MidiProgramChange(channel: 7, program: 9),
            ],
          ),
          (
            const MidiChannelPressure2(channel: 8, pressure: 0x80000000),
            [const MidiChannelPressure(channel: 8, pressure: 0x40)],
          ),
          (
            const MidiPitchBend2(channel: 9, value: 0x80000000),
            [const MidiPitchBend(channel: 9, value: 0x2000)],
          ),
          (
            const MidiPitchBend2(channel: 9, value: 0xFFFFFFFF),
            [const MidiPitchBend(channel: 9, value: 0x3FFF)],
          ),
        ];
        for (final (input, output) in cases) {
          test('$input', () {
            expect(translator.translate(input), equals(output));
            expect(issues, isEmpty);
          });
        }
      });

      group('drops and reports', () {
        final messages = <MidiMessage>[
          const MidiRegisteredPerNoteController(
            channel: 0,
            note: 1,
            index: 3,
            value: 4,
          ),
          const MidiAssignablePerNoteController(
            channel: 0,
            note: 1,
            index: 3,
            value: 4,
          ),
          const MidiPerNoteManagement(channel: 0, note: 1, detach: true),
          const MidiRelativeRegisteredController(
            channel: 0,
            bank: 0,
            index: 0,
            value: -1,
          ),
          const MidiRelativeAssignableController(
            channel: 0,
            bank: 0,
            index: 0,
            value: 1,
          ),
          const MidiPerNotePitchBend(channel: 0, note: 1, value: 2),
        ];
        for (final message in messages) {
          test('$message', () {
            expect(translator.translate(message), isEmpty);
            expect(
              issues,
              equals([
                (
                  MidiDiagnosticKind.untranslatable,
                  '$message has no MIDI 1.0 equivalent',
                ),
              ]),
            );
          });
        }

        test('without callback', () {
          expect(MidiTranslator2To1().translate(messages.first), isEmpty);
        });
      });

      group('returns unchanged', () {
        final messages = <MidiMessage>[
          const MidiNoteOn(channel: 0, note: 1, velocity: 0),
          const MidiPitchBend(channel: 0, value: 1),
          const MidiStart(),
          const MidiTimeCodeQuarterFrame(piece: 1, value: 2),
          MidiSysEx(const [0x7D, 0x01]),
          const MidiJrTimestamp(time: 5),
          MidiSysEx8(streamId: 0, data: const [1, 2, 3]),
          MidiMixedDataSet(
            mdsId: 1,
            manufacturerId: 2,
            deviceId: 3,
            subId1: 4,
            subId2: 5,
            data: const [6],
          ),
          const MidiFlexText(statusBank: 2, status: 1, text: 'la'),
          const MidiStreamConfigurationRequest(protocol: MidiProtocol.midi1),
          MidiUnknownMessage([Ump.fromHex('70000000')]),
        ];
        for (final message in messages) {
          test('$message', () {
            expect(translator.translate(message), equals([message]));
            expect(issues, isEmpty);
          });
        }
      });
    });
  });
}
