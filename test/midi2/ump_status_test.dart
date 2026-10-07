// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('UmpStatus', () {
    // .........................................................................
    group('constants', () {
      test('number the utility statuses 0 to 4 (Table 26)', () {
        expect([
          UmpStatus.noop,
          UmpStatus.jrClock,
          UmpStatus.jrTimestamp,
          UmpStatus.deltaClockstampTicksPerQuarterNote,
          UmpStatus.deltaClockstamp,
        ], equals([0, 1, 2, 3, 4]));
      });

      test('number the System Exclusive statuses 0 to 3 (Table 18)', () {
        expect([
          UmpStatus.sysExComplete,
          UmpStatus.sysExStart,
          UmpStatus.sysExContinue,
          UmpStatus.sysExEnd,
        ], equals([0, 1, 2, 3]));
      });

      test('number the data 128 statuses (Tables 19 and 31)', () {
        expect([
          UmpStatus.sysEx8Complete,
          UmpStatus.sysEx8Start,
          UmpStatus.sysEx8Continue,
          UmpStatus.sysEx8End,
          UmpStatus.mixedDataSetHeader,
          UmpStatus.mixedDataSetPayload,
        ], equals([0x0, 0x1, 0x2, 0x3, 0x8, 0x9]));
      });

      test('number the channel voice statuses (Table 30)', () {
        expect([
          UmpStatus.registeredPerNoteController,
          UmpStatus.assignablePerNoteController,
          UmpStatus.registeredController,
          UmpStatus.assignableController,
          UmpStatus.relativeRegisteredController,
          UmpStatus.relativeAssignableController,
          UmpStatus.perNotePitchBend,
          UmpStatus.noteOff,
          UmpStatus.noteOn,
          UmpStatus.polyPressure,
          UmpStatus.controlChange,
          UmpStatus.programChange,
          UmpStatus.channelPressure,
          UmpStatus.pitchBend,
          UmpStatus.perNoteManagement,
        ], equals([0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15]));
      });

      test('share the MIDI 1.0 channel voice nibbles (Table 28)', () {
        expect(
          [
            UmpStatus.noteOff,
            UmpStatus.noteOn,
            UmpStatus.polyPressure,
            UmpStatus.controlChange,
            UmpStatus.programChange,
            UmpStatus.channelPressure,
            UmpStatus.pitchBend,
          ],
          equals(
            [
              MidiStatus.noteOff,
              MidiStatus.noteOn,
              MidiStatus.polyPressure,
              MidiStatus.controlChange,
              MidiStatus.programChange,
              MidiStatus.channelPressure,
              MidiStatus.pitchBend,
            ].map((status) => status >> 4),
          ),
        );
      });

      test('number the format and address fields (Tables 9 and 10)', () {
        expect([
          UmpStatus.formatComplete,
          UmpStatus.formatStart,
          UmpStatus.formatContinue,
          UmpStatus.formatEnd,
          UmpStatus.flexAddressChannel,
          UmpStatus.flexAddressGroup,
        ], equals([0, 1, 2, 3, 0, 1]));
      });

      test('number the UMP stream statuses (Table 33)', () {
        expect([
          UmpStatus.endpointDiscovery,
          UmpStatus.endpointInfoNotification,
          UmpStatus.deviceIdentityNotification,
          UmpStatus.endpointNameNotification,
          UmpStatus.productInstanceIdNotification,
          UmpStatus.streamConfigurationRequest,
          UmpStatus.streamConfigurationNotification,
          UmpStatus.functionBlockDiscovery,
          UmpStatus.functionBlockInfoNotification,
          UmpStatus.functionBlockNameNotification,
          UmpStatus.startOfClip,
          UmpStatus.endOfClip,
        ], equals([0, 1, 2, 3, 4, 5, 6, 0x10, 0x11, 0x12, 0x20, 0x21]));
      });
    });

    // .........................................................................
    group('name(status, type)', () {
      // Returns the names of [statuses] in packets of [type].
      List<String?> names(List<int> statuses, UmpMessageType type) => [
        for (final status in statuses) UmpStatus.name(status, type: type),
      ];

      test('names the utility statuses', () {
        expect(
          names([0, 1, 2, 3, 4, 5], UmpMessageType.utility),
          equals([
            'noop',
            'jrClock',
            'jrTimestamp',
            'deltaClockstampTicksPerQuarterNote',
            'deltaClockstamp',
            null,
          ]),
        );
      });

      test('names the system statuses defined in UMP', () {
        expect(
          names([for (var s = 0xF0; s <= 0xFF; s++) s], UmpMessageType.system),
          equals([
            null,
            'timeCode',
            'songPosition',
            'songSelect',
            null,
            null,
            'tuneRequest',
            null,
            'timingClock',
            null,
            'start',
            'continueSequence',
            'stop',
            null,
            'activeSensing',
            'systemReset',
          ]),
        );
        expect(names([0x90, 0x00], UmpMessageType.system), [null, null]);
      });

      test('names the MIDI 1.0 channel voice statuses', () {
        expect(
          names([
            for (var s = 0x0; s <= 0xF; s++) s,
          ], UmpMessageType.midi1ChannelVoice),
          equals([
            ...List<String?>.filled(8, null),
            'noteOff',
            'noteOn',
            'polyPressure',
            'controlChange',
            'programChange',
            'channelPressure',
            'pitchBend',
            null,
          ]),
        );
      });

      test('names the MIDI 2.0 channel voice statuses', () {
        expect(
          names([
            for (var s = 0x0; s <= 0xF; s++) s,
          ], UmpMessageType.midi2ChannelVoice),
          equals([
            'registeredPerNoteController',
            'assignablePerNoteController',
            'registeredController',
            'assignableController',
            'relativeRegisteredController',
            'relativeAssignableController',
            'perNotePitchBend',
            null,
            'noteOff',
            'noteOn',
            'polyPressure',
            'controlChange',
            'programChange',
            'channelPressure',
            'pitchBend',
            'perNoteManagement',
          ]),
        );
      });

      test('names the System Exclusive statuses', () {
        expect(
          names([0, 1, 2, 3, 4], UmpMessageType.data64),
          equals([
            'sysExComplete',
            'sysExStart',
            'sysExContinue',
            'sysExEnd',
            null,
          ]),
        );
      });

      test('names the data 128 statuses', () {
        expect(
          names([0, 1, 2, 3, 4, 8, 9, 10], UmpMessageType.data128),
          equals([
            'sysEx8Complete',
            'sysEx8Start',
            'sysEx8Continue',
            'sysEx8End',
            null,
            'mixedDataSetHeader',
            'mixedDataSetPayload',
            null,
          ]),
        );
      });

      test('names the UMP stream statuses', () {
        expect(
          names([
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            0x10,
            0x11,
            0x12,
            0x20,
            0x21,
            0x22,
          ], UmpMessageType.umpStream),
          equals([
            'endpointDiscovery',
            'endpointInfoNotification',
            'deviceIdentityNotification',
            'endpointNameNotification',
            'productInstanceIdNotification',
            'streamConfigurationRequest',
            'streamConfigurationNotification',
            null,
            'functionBlockDiscovery',
            'functionBlockInfoNotification',
            'functionBlockNameNotification',
            'startOfClip',
            'endOfClip',
            null,
          ]),
        );
      });

      test('returns null for flex data and reserved message types', () {
        for (final type in [
          UmpMessageType.flexData,
          UmpMessageType.reserved6,
          UmpMessageType.reservedE,
        ]) {
          expect(names([0, 1, 2, 3], type), everyElement(isNull));
        }
      });
    });
  });
}
