// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiUniversalSysEx', () {
    // .........................................................................
    group('constants', () {
      test('address all devices with 0x7F', () {
        expect(MidiUniversalSysEx.allCallDeviceId, 0x7F);
      });

      test('number the non-real-time sub-ids #1', () {
        expect([
          MidiUniversalSysEx.sampleDumpHeader,
          MidiUniversalSysEx.sampleDataPacket,
          MidiUniversalSysEx.sampleDumpRequest,
          MidiUniversalSysEx.timeCodeSetup,
          MidiUniversalSysEx.sampleDumpExtensions,
          MidiUniversalSysEx.generalInformation,
          MidiUniversalSysEx.fileDump,
          MidiUniversalSysEx.tuningStandardNonRealTime,
          MidiUniversalSysEx.generalMidi,
          MidiUniversalSysEx.downloadableSounds,
          MidiUniversalSysEx.fileReference,
          MidiUniversalSysEx.visualControl,
          MidiUniversalSysEx.capabilityInquiry,
        ], equals([for (var i = 0x01; i <= 0x0D; i++) i]));
        expect([
          MidiUniversalSysEx.endOfFile,
          MidiUniversalSysEx.wait,
          MidiUniversalSysEx.cancel,
          MidiUniversalSysEx.nak,
          MidiUniversalSysEx.ack,
        ], equals([0x7B, 0x7C, 0x7D, 0x7E, 0x7F]));
      });

      test('number the non-real-time sub-ids #2', () {
        expect([
          MidiUniversalSysEx.generalInformationIdentityRequest,
          MidiUniversalSysEx.generalInformationIdentityReply,
          MidiUniversalSysEx.generalMidi1SystemOn,
          MidiUniversalSysEx.generalMidiSystemOff,
          MidiUniversalSysEx.generalMidi2SystemOn,
        ], equals([0x01, 0x02, 0x01, 0x02, 0x03]));
      });

      test('number the real-time sub-ids #1', () {
        expect([
          MidiUniversalSysEx.timeCode,
          MidiUniversalSysEx.showControl,
          MidiUniversalSysEx.notationInformation,
          MidiUniversalSysEx.deviceControl,
          MidiUniversalSysEx.timeCodeCueing,
          MidiUniversalSysEx.machineControlCommand,
          MidiUniversalSysEx.machineControlResponse,
          MidiUniversalSysEx.tuningStandardRealTime,
          MidiUniversalSysEx.controllerDestination,
          MidiUniversalSysEx.keyBasedInstrumentControl,
          MidiUniversalSysEx.scalablePolyphony,
          MidiUniversalSysEx.mobilePhoneControl,
        ], equals([for (var i = 0x01; i <= 0x0C; i++) i]));
      });

      test('number the real-time sub-ids #2', () {
        expect([
          MidiUniversalSysEx.timeCodeFullMessage,
          MidiUniversalSysEx.timeCodeUserBits,
          MidiUniversalSysEx.deviceControlMasterVolume,
          MidiUniversalSysEx.deviceControlMasterBalance,
          MidiUniversalSysEx.deviceControlMasterFineTuning,
          MidiUniversalSysEx.deviceControlMasterCoarseTuning,
          MidiUniversalSysEx.deviceControlGlobalParameterControl,
        ], equals([0x01, 0x02, 0x01, 0x02, 0x03, 0x04, 0x05]));
      });
    });

    // .........................................................................
    group('identityRequest(deviceId)', () {
      test('asks all devices by default', () {
        expect(
          MidiUniversalSysEx.identityRequest(),
          MidiSysEx([0x7E, 0x7F, 0x06, 0x01]),
        );
      });

      test('asks one device', () {
        expect(
          MidiUniversalSysEx.identityRequest(deviceId: 0x10),
          MidiSysEx([0x7E, 0x10, 0x06, 0x01]),
        );
      });

      for (final deviceId in [-1, 0x80]) {
        test('throws for the device id $deviceId', () {
          expect(
            () => MidiUniversalSysEx.identityRequest(deviceId: deviceId),
            throwsA(
              isA<RangeError>().having((e) => e.name, 'name', 'deviceId'),
            ),
          );
        });
      }
    });

    // .........................................................................
    group('identityReply(...)', () {
      test('writes a one-byte id, family and model LSB first', () {
        expect(
          MidiUniversalSysEx.identityReply(
            deviceId: 0x10,
            manufacturerId: MidiManufacturerIds.roland,
            familyId: 0x0123,
            modelId: 0x3FFF,
            softwareRevision: [0x01, 0x02, 0x03, 0x04],
          ),
          MidiSysEx([
            0x7E, 0x10, 0x06, 0x02, // identity reply header
            0x41, // manufacturer id
            0x23, 0x02, // family LSB, MSB
            0x7F, 0x7F, // model LSB, MSB
            0x01, 0x02, 0x03, 0x04, // software revision
          ]),
        );
      });

      test('writes a three-byte id', () {
        expect(
          MidiUniversalSysEx.identityReply(
            manufacturerId: MidiManufacturerIds.nativeInstruments,
            familyId: 0,
            modelId: 1,
            softwareRevision: [0, 0, 0, 0],
          ),
          MidiSysEx([
            0x7E, 0x7F, 0x06, 0x02, // identity reply header
            0x00, 0x21, 0x09, // manufacturer id
            0x00, 0x00, // family LSB, MSB
            0x01, 0x00, // model LSB, MSB
            0x00, 0x00, 0x00, 0x00, // software revision
          ]),
        );
      });

      test('accepts the three-byte form of a one-byte id', () {
        expect(
          MidiUniversalSysEx.identityReply(
            manufacturerId: [0x43, 0x00, 0x00],
            familyId: 0,
            modelId: 0,
            softwareRevision: [0, 0, 0, 0],
          ).data.sublist(4, 6),
          equals([0x43, 0x00]),
        );
      });

      for (final (field, call) in <(String, void Function())>[
        (
          'deviceId',
          () => MidiUniversalSysEx.identityReply(
            deviceId: 0x80,
            manufacturerId: [0x41],
            familyId: 0,
            modelId: 0,
            softwareRevision: [0, 0, 0, 0],
          ),
        ),
        (
          'familyId',
          () => MidiUniversalSysEx.identityReply(
            manufacturerId: [0x41],
            familyId: 0x4000,
            modelId: 0,
            softwareRevision: [0, 0, 0, 0],
          ),
        ),
        (
          'modelId',
          () => MidiUniversalSysEx.identityReply(
            manufacturerId: [0x41],
            familyId: 0,
            modelId: -1,
            softwareRevision: [0, 0, 0, 0],
          ),
        ),
        (
          'softwareRevision',
          () => MidiUniversalSysEx.identityReply(
            manufacturerId: [0x41],
            familyId: 0,
            modelId: 0,
            softwareRevision: [0, 0, 0],
          ),
        ),
        (
          'softwareRevision',
          () => MidiUniversalSysEx.identityReply(
            manufacturerId: [0x41],
            familyId: 0,
            modelId: 0,
            softwareRevision: [0, 0, 0, 0x80],
          ),
        ),
        (
          'data',
          () => MidiUniversalSysEx.identityReply(
            manufacturerId: [0x00, 0x21],
            familyId: 0,
            modelId: 0,
            softwareRevision: [0, 0, 0, 0],
          ),
        ),
      ]) {
        test('throws for an invalid $field', () {
          expect(
            call,
            throwsA(isA<ArgumentError>().having((e) => e.name, 'name', field)),
          );
        });
      }
    });

    // .........................................................................
    group('parseIdentityReply(sysEx)', () {
      test('reads a reply with a one-byte id', () {
        final reply = MidiUniversalSysEx.parseIdentityReply(
          MidiSysEx([
            0x7E, 0x00, 0x06, 0x02, // identity reply header
            0x42, // manufacturer id
            0x4F, 0x01, // family LSB, MSB
            0x03, 0x00, // model LSB, MSB
            0x01, 0x00, 0x02, 0x00, // software revision
          ]),
        );
        expect(reply, isNotNull);
        expect(reply!.deviceId, 0x00);
        expect(reply.manufacturerId, equals([0x42, 0x00, 0x00]));
        expect(reply.familyId, 0x4F | 0x01 << 7);
        expect(reply.modelId, 0x03);
        expect(reply.softwareRevision, equals([0x01, 0x00, 0x02, 0x00]));
      });

      test('reads a reply with a three-byte id', () {
        final reply = MidiUniversalSysEx.parseIdentityReply(
          MidiSysEx([
            0x7E, 0x7F, 0x06, 0x02, // identity reply header
            0x00, 0x20, 0x6B, // manufacturer id
            0x02, 0x00, // family LSB, MSB
            0x04, 0x01, // model LSB, MSB
            0x01, 0x02, 0x03, 0x04, // software revision
          ]),
        );
        expect(reply?.manufacturerId, equals(MidiManufacturerIds.arturia));
        expect(reply?.familyId, 0x02);
        expect(reply?.modelId, 0x04 | 0x01 << 7);
      });

      test('reverses identityReply', () {
        for (final id in [MidiManufacturerIds.korg, MidiManufacturerIds.bome]) {
          final reply = MidiUniversalSysEx.parseIdentityReply(
            MidiUniversalSysEx.identityReply(
              deviceId: 0x05,
              manufacturerId: id,
              familyId: 0x1234,
              modelId: 0x0567,
              softwareRevision: [0x7F, 0x00, 0x10, 0x20],
            ),
          );
          final r = reply!;
          expect(
            [
              r.deviceId,
              r.manufacturerId,
              r.familyId,
              r.modelId,
              r.softwareRevision,
            ],
            equals([
              0x05,
              MidiManufacturerIds.toThreeBytes(id),
              0x1234,
              0x0567,
              [0x7F, 0x00, 0x10, 0x20],
            ]),
          );
        }
      });

      test('ignores bytes after the software revision', () {
        final reply = MidiUniversalSysEx.parseIdentityReply(
          MidiSysEx([0x7E, 0x7F, 0x06, 0x02, 0x41, 1, 0, 2, 0, 1, 2, 3, 4, 9]),
        );
        expect(reply?.softwareRevision, equals([1, 2, 3, 4]));
      });

      test('returns an unmodifiable software revision', () {
        final reply = MidiUniversalSysEx.parseIdentityReply(
          MidiSysEx([0x7E, 0x7F, 0x06, 0x02, 0x41, 1, 0, 2, 0, 1, 2, 3, 4]),
        );
        expect(() => reply!.softwareRevision[0] = 0, throwsUnsupportedError);
      });

      for (final (reason, data) in [
        ('too short', [0x7E, 0x7F, 0x06, 0x02]),
        ('real-time', [0x7F, 0x7F, 0x06, 0x02, 0x41, 1, 0, 2, 0, 1, 2, 3, 4]),
        ('a request', [0x7E, 0x7F, 0x06, 0x01, 0x41, 1, 0, 2, 0, 1, 2, 3, 4]),
        ('not general', [0x7E, 0x7F, 0x09, 0x02, 0x41, 1, 0, 2, 0, 1, 2, 3, 4]),
        ('truncated', [0x7E, 0x7F, 0x06, 0x02, 0x41, 1, 0, 2, 0, 1, 2, 3]),
        ('truncated id', [0x7E, 0x7F, 0x06, 0x02, 0x00, 0x21]),
        ('no id', [0x7E, 0x7F, 0x06, 0x02, 0x00, 0x21, 0x09, 1, 0, 2, 0]),
      ]) {
        test('returns null for a reply that is $reason', () {
          expect(MidiUniversalSysEx.parseIdentityReply(MidiSysEx(data)), null);
        });
      }
    });

    // .........................................................................
    group('masterVolume(value14, deviceId)', () {
      test('writes the volume LSB first', () {
        expect(
          MidiUniversalSysEx.masterVolume(0x3FFF),
          MidiSysEx([0x7F, 0x7F, 0x04, 0x01, 0x7F, 0x7F]),
        );
        expect(
          MidiUniversalSysEx.masterVolume(0x2001, deviceId: 0x00),
          MidiSysEx([0x7F, 0x00, 0x04, 0x01, 0x01, 0x40]),
        );
      });

      for (final (value14, deviceId, name) in [
        (-1, 0x7F, 'value14'),
        (0x4000, 0x7F, 'value14'),
        (0, 0x80, 'deviceId'),
      ]) {
        test('throws for $name of volume $value14 and device $deviceId', () {
          expect(
            () => MidiUniversalSysEx.masterVolume(value14, deviceId: deviceId),
            throwsA(isA<RangeError>().having((e) => e.name, 'name', name)),
          );
        });
      }
    });

    // .........................................................................
    group('masterBalance(value14, deviceId)', () {
      test('writes the balance LSB first', () {
        expect(
          MidiUniversalSysEx.masterBalance(0x2000, deviceId: 0x01),
          MidiSysEx([0x7F, 0x01, 0x04, 0x02, 0x00, 0x40]),
        );
      });
    });
  });
}
