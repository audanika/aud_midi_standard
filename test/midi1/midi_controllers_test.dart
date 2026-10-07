// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiControllers', () {
    // The constants of gg_midi_vars in their declaration order.
    final legacy = <String, int>{
      'bankSelect': MidiControllers.bankSelect,
      'modulationWheelCoarse': MidiControllers.modulationWheelCoarse,
      'breathcontrollerCoarse': MidiControllers.breathcontrollerCoarse,
      'controller3': MidiControllers.controller3,
      'footPedalCoarse': MidiControllers.footPedalCoarse,
      'portamentoTimeCoarse': MidiControllers.portamentoTimeCoarse,
      'dataEntryCoarse': MidiControllers.dataEntryCoarse,
      'volumeCoarse': MidiControllers.volumeCoarse,
      'balanceCoarse': MidiControllers.balanceCoarse,
      'controller9': MidiControllers.controller9,
      'panpositionCoarse': MidiControllers.panpositionCoarse,
      'expressionCoarse': MidiControllers.expressionCoarse,
      'effectControl1Coarse': MidiControllers.effectControl1Coarse,
      'effectControl2Coarse': MidiControllers.effectControl2Coarse,
      'controller14': MidiControllers.controller14,
      'controller15': MidiControllers.controller15,
      'generalPurposeSlider1': MidiControllers.generalPurposeSlider1,
      'generalPurposeSlider2': MidiControllers.generalPurposeSlider2,
      'generalPurposeSlider3': MidiControllers.generalPurposeSlider3,
      'generalPurposeSlider4': MidiControllers.generalPurposeSlider4,
      'controller20': MidiControllers.controller20,
      'controller21': MidiControllers.controller21,
      'controller22': MidiControllers.controller22,
      'controller23': MidiControllers.controller23,
      'controller24': MidiControllers.controller24,
      'controller25': MidiControllers.controller25,
      'controller26': MidiControllers.controller26,
      'controller27': MidiControllers.controller27,
      'controller28': MidiControllers.controller28,
      'controller29': MidiControllers.controller29,
      'controller30': MidiControllers.controller30,
      'controller31': MidiControllers.controller31,
      'bankSelectFine': MidiControllers.bankSelectFine,
      'modulationWheelFine': MidiControllers.modulationWheelFine,
      'breathcontrollerFine': MidiControllers.breathcontrollerFine,
      'controller35': MidiControllers.controller35,
      'footPedalFine': MidiControllers.footPedalFine,
      'portamentoTimeFine': MidiControllers.portamentoTimeFine,
      'dataEntryFine': MidiControllers.dataEntryFine,
      'volumeFine': MidiControllers.volumeFine,
      'balanceFine': MidiControllers.balanceFine,
      'controller41': MidiControllers.controller41,
      'panpositionFine': MidiControllers.panpositionFine,
      'expressionFine': MidiControllers.expressionFine,
      'effectControl1Fine': MidiControllers.effectControl1Fine,
      'effectControl2Fine': MidiControllers.effectControl2Fine,
      'controller46': MidiControllers.controller46,
      'controller47': MidiControllers.controller47,
      'controller48': MidiControllers.controller48,
      'controller49': MidiControllers.controller49,
      'controller50': MidiControllers.controller50,
      'controller51': MidiControllers.controller51,
      'controller52': MidiControllers.controller52,
      'controller53': MidiControllers.controller53,
      'controller54': MidiControllers.controller54,
      'controller55': MidiControllers.controller55,
      'controller56': MidiControllers.controller56,
      'controller57': MidiControllers.controller57,
      'controller58': MidiControllers.controller58,
      'controller59': MidiControllers.controller59,
      'controller60': MidiControllers.controller60,
      'controller61': MidiControllers.controller61,
      'controller62': MidiControllers.controller62,
      'controller63': MidiControllers.controller63,
      'holdPedalOnOff': MidiControllers.holdPedalOnOff,
      'portamentoOnOff': MidiControllers.portamentoOnOff,
      'sustenutoPedalOnOff': MidiControllers.sustenutoPedalOnOff,
      'softPedalOnOff': MidiControllers.softPedalOnOff,
      'legatoPedalOnOff': MidiControllers.legatoPedalOnOff,
      'hold2PedalOnOff': MidiControllers.hold2PedalOnOff,
      'soundVariation': MidiControllers.soundVariation,
      'soundTimbre': MidiControllers.soundTimbre,
      'soundReleaseTime': MidiControllers.soundReleaseTime,
      'soundAttackTime': MidiControllers.soundAttackTime,
      'soundBrightness': MidiControllers.soundBrightness,
      'soundControl6': MidiControllers.soundControl6,
      'soundControl7': MidiControllers.soundControl7,
      'soundControl8': MidiControllers.soundControl8,
      'soundControl9': MidiControllers.soundControl9,
      'soundControl10': MidiControllers.soundControl10,
      'generalPurposeButton1OnOff': MidiControllers.generalPurposeButton1OnOff,
      'generalPurposeButton2OnOff': MidiControllers.generalPurposeButton2OnOff,
      'generalPurposeButton3OnOff': MidiControllers.generalPurposeButton3OnOff,
      'generalPurposeButton4OnOff': MidiControllers.generalPurposeButton4OnOff,
      'controller64': MidiControllers.controller64,
      'controller65': MidiControllers.controller65,
      'controller66': MidiControllers.controller66,
      'controller67': MidiControllers.controller67,
      'controller68': MidiControllers.controller68,
      'controller69': MidiControllers.controller69,
      'controller70': MidiControllers.controller70,
      'effectsLevel': MidiControllers.effectsLevel,
      'tremuloLevel': MidiControllers.tremuloLevel,
      'chorusLevel': MidiControllers.chorusLevel,
      'celesteLevel': MidiControllers.celesteLevel,
      'phaserLevel': MidiControllers.phaserLevel,
      'dataButtonincrement': MidiControllers.dataButtonincrement,
      'dataButtondecrement': MidiControllers.dataButtondecrement,
      'nonRegisteredParameterCoarse':
          MidiControllers.nonRegisteredParameterCoarse,
      'nonRegisteredParameterFine': MidiControllers.nonRegisteredParameterFine,
      'registeredParameterCoarse': MidiControllers.registeredParameterCoarse,
      'registeredParameterFine': MidiControllers.registeredParameterFine,
      'controller102': MidiControllers.controller102,
      'controller103': MidiControllers.controller103,
      'controller104': MidiControllers.controller104,
      'controller105': MidiControllers.controller105,
      'controller106': MidiControllers.controller106,
      'controller107': MidiControllers.controller107,
      'controller108': MidiControllers.controller108,
      'controller109': MidiControllers.controller109,
      'controller110': MidiControllers.controller110,
      'controller111': MidiControllers.controller111,
      'controller112': MidiControllers.controller112,
      'controller113': MidiControllers.controller113,
      'controller114': MidiControllers.controller114,
      'controller115': MidiControllers.controller115,
      'controller116': MidiControllers.controller116,
      'controller117': MidiControllers.controller117,
      'controller118': MidiControllers.controller118,
      'controller119': MidiControllers.controller119,
      'allSoundOff': MidiControllers.allSoundOff,
      'allControllersOff': MidiControllers.allControllersOff,
      'localKeyboardOnOff': MidiControllers.localKeyboardOnOff,
      'allNotesOff': MidiControllers.allNotesOff,
      'omniModeOff': MidiControllers.omniModeOff,
      'omniModeOn': MidiControllers.omniModeOn,
      'monoOperation': MidiControllers.monoOperation,
      'polyOperation': MidiControllers.polyOperation,
    };

    // .........................................................................
    group('gg_midi_vars constants', () {
      test('number the controllers 0 to 127 in declaration order', () {
        expect(
          legacy.values.toList(),
          equals([for (var i = 0; i < 128; i++) i]),
        );
      });

      test('fix polyOperation to 127', () {
        expect(MidiControllers.polyOperation, 127);
        expect(MidiControllers.effectControl1Coarse, 12);
      });

      test('keep the names that do not match their numbers', () {
        expect([
          MidiControllers.controller64,
          MidiControllers.controller68,
          MidiControllers.controller70,
          MidiControllers.nonRegisteredParameterCoarse,
          MidiControllers.registeredParameterFine,
        ], equals([84, 88, 90, 98, 101]));
      });
    });

    // .........................................................................
    group('standard names', () {
      test('number the MSB controllers', () {
        expect([
          MidiControllers.modulationWheel,
          MidiControllers.breathController,
          MidiControllers.footController,
          MidiControllers.portamentoTime,
          MidiControllers.dataEntryMsb,
          MidiControllers.channelVolume,
          MidiControllers.balance,
          MidiControllers.pan,
          MidiControllers.expression,
          MidiControllers.effectControl1,
          MidiControllers.effectControl2,
          MidiControllers.generalPurposeController1,
          MidiControllers.generalPurposeController2,
          MidiControllers.generalPurposeController3,
          MidiControllers.generalPurposeController4,
        ], equals([1, 2, 4, 5, 6, 7, 8, 10, 11, 12, 13, 16, 17, 18, 19]));
      });

      test('number the LSB controllers 32 above their MSB', () {
        expect([
          MidiControllers.bankSelectLsb - MidiControllers.bankSelect,
          MidiControllers.modulationWheelLsb - MidiControllers.modulationWheel,
          MidiControllers.breathControllerLsb -
              MidiControllers.breathController,
          MidiControllers.footControllerLsb - MidiControllers.footController,
          MidiControllers.portamentoTimeLsb - MidiControllers.portamentoTime,
          MidiControllers.dataEntryLsb - MidiControllers.dataEntryMsb,
          MidiControllers.channelVolumeLsb - MidiControllers.channelVolume,
          MidiControllers.balanceLsb - MidiControllers.balance,
          MidiControllers.panLsb - MidiControllers.pan,
          MidiControllers.expressionLsb - MidiControllers.expression,
          MidiControllers.effectControl1Lsb - MidiControllers.effectControl1,
          MidiControllers.effectControl2Lsb - MidiControllers.effectControl2,
          MidiControllers.generalPurposeController1Lsb -
              MidiControllers.generalPurposeController1,
          MidiControllers.generalPurposeController2Lsb -
              MidiControllers.generalPurposeController2,
          MidiControllers.generalPurposeController3Lsb -
              MidiControllers.generalPurposeController3,
          MidiControllers.generalPurposeController4Lsb -
              MidiControllers.generalPurposeController4,
        ], everyElement(32));
        expect([
          MidiControllers.bankSelectLsb,
          MidiControllers.dataEntryLsb,
        ], equals([32, 38]));
      });

      test('number the switches', () {
        expect([
          MidiControllers.sustainPedal,
          MidiControllers.portamento,
          MidiControllers.sostenuto,
          MidiControllers.softPedal,
          MidiControllers.legatoFootswitch,
          MidiControllers.hold2,
        ], equals([64, 65, 66, 67, 68, 69]));
      });

      test('number the sound controllers and their defaults', () {
        expect([
          MidiControllers.soundController1,
          MidiControllers.soundController2,
          MidiControllers.soundController3,
          MidiControllers.soundController4,
          MidiControllers.soundController5,
          MidiControllers.soundController6,
          MidiControllers.soundController7,
          MidiControllers.soundController8,
          MidiControllers.soundController9,
          MidiControllers.soundController10,
        ], equals([70, 71, 72, 73, 74, 75, 76, 77, 78, 79]));
        expect([
          MidiControllers.soundDecayTime,
          MidiControllers.soundVibratoRate,
          MidiControllers.soundVibratoDepth,
          MidiControllers.soundVibratoDelay,
        ], equals([75, 76, 77, 78]));
      });

      test('number the general purpose and portamento controllers', () {
        expect([
          MidiControllers.generalPurposeController5,
          MidiControllers.generalPurposeController6,
          MidiControllers.generalPurposeController7,
          MidiControllers.generalPurposeController8,
          MidiControllers.portamentoControl,
          MidiControllers.highResolutionVelocityPrefix,
        ], equals([80, 81, 82, 83, 84, 88]));
      });

      test('number the effects depths', () {
        expect([
          MidiControllers.effects1Depth,
          MidiControllers.effects2Depth,
          MidiControllers.effects3Depth,
          MidiControllers.effects4Depth,
          MidiControllers.effects5Depth,
          MidiControllers.reverbSendLevel,
        ], equals([91, 92, 93, 94, 95, 91]));
      });

      test('number data entry and the parameter number selection', () {
        expect([
          MidiControllers.dataIncrement,
          MidiControllers.dataDecrement,
          MidiControllers.nrpnLsb,
          MidiControllers.nrpnMsb,
          MidiControllers.rpnLsb,
          MidiControllers.rpnMsb,
        ], equals([96, 97, 98, 99, 100, 101]));
      });

      test('number the channel mode messages (M2-104-UM Appendix B)', () {
        expect([
          MidiControllers.allSoundOff,
          MidiControllers.resetAllControllers,
          MidiControllers.localControl,
          MidiControllers.allNotesOff,
          MidiControllers.omniOff,
          MidiControllers.omniOn,
          MidiControllers.monoOn,
          MidiControllers.polyOn,
        ], equals([120, 121, 122, 123, 124, 125, 126, 127]));
      });
    });

    // .........................................................................
    group('toStr(controller)', () {
      test('returns the gg_midi_vars name of every controller', () {
        for (final MapEntry(key: name, value: controller) in legacy.entries) {
          expect(MidiControllers.toStr(controller), name);
        }
      });

      test('returns the gg_midi_vars names for the standard names', () {
        expect(
          [
            MidiControllers.sustainPedal,
            MidiControllers.nrpnLsb,
            MidiControllers.polyOn,
          ].map(MidiControllers.toStr).toList(),
          equals([
            'holdPedalOnOff',
            'nonRegisteredParameterCoarse',
            'polyOperation',
          ]),
        );
      });

      test('returns effectControl1Coarse for 12 after the fix', () {
        expect(MidiControllers.toStr(12), 'effectControl1Coarse');
        expect(MidiControllers.toStr(127), 'polyOperation');
      });

      test('should work fine (gg_midi_vars)', () {
        expect(
          MidiControllers.toStr(MidiControllers.allControllersOff),
          'allControllersOff',
        );
      });

      for (final controller in [-1, 128]) {
        test('throws for $controller', () {
          expect(
            () => MidiControllers.toStr(controller),
            throwsA(
              isA<RangeError>().having((e) => e.name, 'name', 'controller'),
            ),
          );
        });
      }
    });

    // .........................................................................
    group('isChannelMode(controller)', () {
      test('accepts 120 to 127', () {
        expect(
          [0, 119, 120, 123, 127, 128].map(MidiControllers.isChannelMode),
          equals([false, false, true, true, true, false]),
        );
      });
    });
  });
}
