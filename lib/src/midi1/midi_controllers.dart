// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The 128 MIDI 1.0 control change numbers (MIDI 1.0 Detailed Specification
/// 4.2.1, Table III: Controller Numbers, with its later amendments, and
/// M2-104-UM Appendix B for the channel mode messages).
///
/// The first block keeps every constant of `gg_midi_vars` with its name and
/// value, so code migrating from there keeps working, and [toStr] still
/// returns these names. Some of those names do not match the standard
/// meaning; their documentation says so and points to the standard name.
/// One value is fixed: [polyOperation] is 127, gg_midi_vars defined it as
/// 12.
///
/// The second block adds the standard names. A value with a correct
/// gg_midi_vars name is not repeated, e.g. [bankSelect] and [allNotesOff].
abstract final class MidiControllers {
  // ...........................................................................
  // The constants of gg_midi_vars, controller 0 to 127.

  /// Controller 0, Bank Select MSB; the LSB is [bankSelectFine].
  static const int bankSelect = 0;

  /// Controller 1, Modulation Wheel MSB; the standard name is
  /// [modulationWheel].
  static const int modulationWheelCoarse = 1;

  /// Controller 2, Breath Controller MSB; the standard name is
  /// [breathController].
  static const int breathcontrollerCoarse = 2;

  /// Controller 3, undefined.
  static const int controller3 = 3;

  /// Controller 4, Foot Controller MSB; the standard name is [footController].
  static const int footPedalCoarse = 4;

  /// Controller 5, Portamento Time MSB; the standard name is [portamentoTime].
  static const int portamentoTimeCoarse = 5;

  /// Controller 6, Data Entry MSB; the standard name is [dataEntryMsb].
  static const int dataEntryCoarse = 6;

  /// Controller 7, Channel Volume MSB; the standard name is [channelVolume].
  static const int volumeCoarse = 7;

  /// Controller 8, Balance MSB; the standard name is [balance].
  static const int balanceCoarse = 8;

  /// Controller 9, undefined.
  static const int controller9 = 9;

  /// Controller 10, Pan MSB; the standard name is [pan].
  static const int panpositionCoarse = 10;

  /// Controller 11, Expression Controller MSB; the standard name is
  /// [expression].
  static const int expressionCoarse = 11;

  /// Controller 12, Effect Control 1 MSB; the standard name is
  /// [effectControl1].
  static const int effectControl1Coarse = 12;

  /// Controller 13, Effect Control 2 MSB; the standard name is
  /// [effectControl2].
  static const int effectControl2Coarse = 13;

  /// Controller 14, undefined.
  static const int controller14 = 14;

  /// Controller 15, undefined.
  static const int controller15 = 15;

  /// Controller 16, General Purpose Controller 1 MSB; the standard name is
  /// [generalPurposeController1].
  static const int generalPurposeSlider1 = 16;

  /// Controller 17, General Purpose Controller 2 MSB; the standard name is
  /// [generalPurposeController2].
  static const int generalPurposeSlider2 = 17;

  /// Controller 18, General Purpose Controller 3 MSB; the standard name is
  /// [generalPurposeController3].
  static const int generalPurposeSlider3 = 18;

  /// Controller 19, General Purpose Controller 4 MSB; the standard name is
  /// [generalPurposeController4].
  static const int generalPurposeSlider4 = 19;

  /// Controller 20, undefined.
  static const int controller20 = 20;

  /// Controller 21, undefined.
  static const int controller21 = 21;

  /// Controller 22, undefined.
  static const int controller22 = 22;

  /// Controller 23, undefined.
  static const int controller23 = 23;

  /// Controller 24, undefined.
  static const int controller24 = 24;

  /// Controller 25, undefined.
  static const int controller25 = 25;

  /// Controller 26, undefined.
  static const int controller26 = 26;

  /// Controller 27, undefined.
  static const int controller27 = 27;

  /// Controller 28, undefined.
  static const int controller28 = 28;

  /// Controller 29, undefined.
  static const int controller29 = 29;

  /// Controller 30, undefined.
  static const int controller30 = 30;

  /// Controller 31, undefined.
  static const int controller31 = 31;

  /// Controller 32, Bank Select LSB; the standard name is [bankSelectLsb].
  static const int bankSelectFine = 32;

  /// Controller 33, Modulation Wheel LSB; the standard name is
  /// [modulationWheelLsb].
  static const int modulationWheelFine = 33;

  /// Controller 34, Breath Controller LSB; the standard name is
  /// [breathControllerLsb].
  static const int breathcontrollerFine = 34;

  /// Controller 35, the LSB of the undefined controller 3.
  static const int controller35 = 35;

  /// Controller 36, Foot Controller LSB; the standard name is
  /// [footControllerLsb].
  static const int footPedalFine = 36;

  /// Controller 37, Portamento Time LSB; the standard name is
  /// [portamentoTimeLsb].
  static const int portamentoTimeFine = 37;

  /// Controller 38, Data Entry LSB; the standard name is [dataEntryLsb].
  static const int dataEntryFine = 38;

  /// Controller 39, Channel Volume LSB; the standard name is
  /// [channelVolumeLsb].
  static const int volumeFine = 39;

  /// Controller 40, Balance LSB; the standard name is [balanceLsb].
  static const int balanceFine = 40;

  /// Controller 41, the LSB of the undefined controller 9.
  static const int controller41 = 41;

  /// Controller 42, Pan LSB; the standard name is [panLsb].
  static const int panpositionFine = 42;

  /// Controller 43, Expression Controller LSB; the standard name is
  /// [expressionLsb].
  static const int expressionFine = 43;

  /// Controller 44, Effect Control 1 LSB; the standard name is
  /// [effectControl1Lsb].
  static const int effectControl1Fine = 44;

  /// Controller 45, Effect Control 2 LSB; the standard name is
  /// [effectControl2Lsb].
  static const int effectControl2Fine = 45;

  /// Controller 46, the LSB of the undefined controller 14.
  static const int controller46 = 46;

  /// Controller 47, the LSB of the undefined controller 15.
  static const int controller47 = 47;

  /// Controller 48, General Purpose Controller 1 LSB; the standard name is
  /// [generalPurposeController1Lsb].
  static const int controller48 = 48;

  /// Controller 49, General Purpose Controller 2 LSB; the standard name is
  /// [generalPurposeController2Lsb].
  static const int controller49 = 49;

  /// Controller 50, General Purpose Controller 3 LSB; the standard name is
  /// [generalPurposeController3Lsb].
  static const int controller50 = 50;

  /// Controller 51, General Purpose Controller 4 LSB; the standard name is
  /// [generalPurposeController4Lsb].
  static const int controller51 = 51;

  /// Controller 52, the LSB of the undefined controller 20.
  static const int controller52 = 52;

  /// Controller 53, the LSB of the undefined controller 21.
  static const int controller53 = 53;

  /// Controller 54, the LSB of the undefined controller 22.
  static const int controller54 = 54;

  /// Controller 55, the LSB of the undefined controller 23.
  static const int controller55 = 55;

  /// Controller 56, the LSB of the undefined controller 24.
  static const int controller56 = 56;

  /// Controller 57, the LSB of the undefined controller 25.
  static const int controller57 = 57;

  /// Controller 58, the LSB of the undefined controller 26.
  static const int controller58 = 58;

  /// Controller 59, the LSB of the undefined controller 27.
  static const int controller59 = 59;

  /// Controller 60, the LSB of the undefined controller 28.
  static const int controller60 = 60;

  /// Controller 61, the LSB of the undefined controller 29.
  static const int controller61 = 61;

  /// Controller 62, the LSB of the undefined controller 30.
  static const int controller62 = 62;

  /// Controller 63, the LSB of the undefined controller 31.
  static const int controller63 = 63;

  /// Controller 64, Damper Pedal (Sustain) on/off; the standard name is
  /// [sustainPedal].
  static const int holdPedalOnOff = 64;

  /// Controller 65, Portamento on/off; the standard name is [portamento].
  static const int portamentoOnOff = 65;

  /// Controller 66, Sostenuto on/off; the name keeps the spelling of
  /// gg_midi_vars, the standard name is [sostenuto].
  static const int sustenutoPedalOnOff = 66;

  /// Controller 67, Soft Pedal on/off; the standard name is [softPedal].
  static const int softPedalOnOff = 67;

  /// Controller 68, Legato Footswitch; the standard name is [legatoFootswitch].
  static const int legatoPedalOnOff = 68;

  /// Controller 69, Hold 2; the standard name is [hold2].
  static const int hold2PedalOnOff = 69;

  /// Controller 70, Sound Controller 1, by default Sound Variation; the
  /// standard name is [soundController1].
  static const int soundVariation = 70;

  /// Controller 71, Sound Controller 2, by default Timbre/Harmonic Intensity;
  /// the standard name is [soundController2].
  static const int soundTimbre = 71;

  /// Controller 72, Sound Controller 3, by default Release Time; the standard
  /// name is [soundController3].
  static const int soundReleaseTime = 72;

  /// Controller 73, Sound Controller 4, by default Attack Time; the standard
  /// name is [soundController4].
  static const int soundAttackTime = 73;

  /// Controller 74, Sound Controller 5, by default Brightness; the standard
  /// name is [soundController5].
  static const int soundBrightness = 74;

  /// Controller 75, Sound Controller 6, by default Decay Time; the standard
  /// names are [soundController6] and [soundDecayTime].
  static const int soundControl6 = 75;

  /// Controller 76, Sound Controller 7, by default Vibrato Rate; the standard
  /// names are [soundController7] and [soundVibratoRate].
  static const int soundControl7 = 76;

  /// Controller 77, Sound Controller 8, by default Vibrato Depth; the standard
  /// names are [soundController8] and [soundVibratoDepth].
  static const int soundControl8 = 77;

  /// Controller 78, Sound Controller 9, by default Vibrato Delay; the standard
  /// names are [soundController9] and [soundVibratoDelay].
  static const int soundControl9 = 78;

  /// Controller 79, Sound Controller 10, without default; the standard name is
  /// [soundController10].
  static const int soundControl10 = 79;

  /// Controller 80, General Purpose Controller 5; the standard name is
  /// [generalPurposeController5].
  static const int generalPurposeButton1OnOff = 80;

  /// Controller 81, General Purpose Controller 6; the standard name is
  /// [generalPurposeController6].
  static const int generalPurposeButton2OnOff = 81;

  /// Controller 82, General Purpose Controller 7; the standard name is
  /// [generalPurposeController7].
  static const int generalPurposeButton3OnOff = 82;

  /// Controller 83, General Purpose Controller 8; the standard name is
  /// [generalPurposeController8].
  static const int generalPurposeButton4OnOff = 83;

  /// Controller 84, Portamento Control; the name does not match the number and
  /// is kept from gg_midi_vars, the standard name is [portamentoControl].
  static const int controller64 = 84;

  /// Controller 85, undefined; the name does not match the number and is kept
  /// from gg_midi_vars.
  static const int controller65 = 85;

  /// Controller 86, undefined; the name does not match the number and is kept
  /// from gg_midi_vars.
  static const int controller66 = 86;

  /// Controller 87, undefined; the name does not match the number and is kept
  /// from gg_midi_vars.
  static const int controller67 = 87;

  /// Controller 88, High Resolution Velocity Prefix; the name does not match
  /// the number and is kept from gg_midi_vars, the standard name is
  /// [highResolutionVelocityPrefix].
  static const int controller68 = 88;

  /// Controller 89, undefined; the name does not match the number and is kept
  /// from gg_midi_vars.
  static const int controller69 = 89;

  /// Controller 90, undefined; the name does not match the number and is kept
  /// from gg_midi_vars.
  static const int controller70 = 90;

  /// Controller 91, Effects 1 Depth, by default Reverb Send Level; the standard
  /// names are [effects1Depth] and [reverbSendLevel].
  static const int effectsLevel = 91;

  /// Controller 92, Effects 2 Depth, formerly Tremolo Depth; the name keeps the
  /// spelling of gg_midi_vars, the standard name is [effects2Depth].
  static const int tremuloLevel = 92;

  /// Controller 93, Effects 3 Depth, by default Chorus Send Level; the standard
  /// name is [effects3Depth].
  static const int chorusLevel = 93;

  /// Controller 94, Effects 4 Depth, formerly Celeste (Detune) Depth; the
  /// standard name is [effects4Depth].
  static const int celesteLevel = 94;

  /// Controller 95, Effects 5 Depth, formerly Phaser Depth; the standard name
  /// is [effects5Depth].
  static const int phaserLevel = 95;

  /// Controller 96, Data Increment; the standard name is [dataIncrement].
  static const int dataButtonincrement = 96;

  /// Controller 97, Data Decrement; the standard name is [dataDecrement].
  static const int dataButtondecrement = 97;

  /// Controller 98, the NRPN LSB; despite its name it selects the fine part,
  /// the standard name is [nrpnLsb].
  static const int nonRegisteredParameterCoarse = 98;

  /// Controller 99, the NRPN MSB; despite its name it selects the coarse part,
  /// the standard name is [nrpnMsb].
  static const int nonRegisteredParameterFine = 99;

  /// Controller 100, the RPN LSB; despite its name it selects the fine part,
  /// the standard name is [rpnLsb].
  static const int registeredParameterCoarse = 100;

  /// Controller 101, the RPN MSB; despite its name it selects the coarse part,
  /// the standard name is [rpnMsb].
  static const int registeredParameterFine = 101;

  /// Controller 102, undefined.
  static const int controller102 = 102;

  /// Controller 103, undefined.
  static const int controller103 = 103;

  /// Controller 104, undefined.
  static const int controller104 = 104;

  /// Controller 105, undefined.
  static const int controller105 = 105;

  /// Controller 106, undefined.
  static const int controller106 = 106;

  /// Controller 107, undefined.
  static const int controller107 = 107;

  /// Controller 108, undefined.
  static const int controller108 = 108;

  /// Controller 109, undefined.
  static const int controller109 = 109;

  /// Controller 110, undefined.
  static const int controller110 = 110;

  /// Controller 111, undefined.
  static const int controller111 = 111;

  /// Controller 112, undefined.
  static const int controller112 = 112;

  /// Controller 113, undefined.
  static const int controller113 = 113;

  /// Controller 114, undefined.
  static const int controller114 = 114;

  /// Controller 115, undefined.
  static const int controller115 = 115;

  /// Controller 116, undefined.
  static const int controller116 = 116;

  /// Controller 117, undefined.
  static const int controller117 = 117;

  /// Controller 118, undefined.
  static const int controller118 = 118;

  /// Controller 119, undefined.
  static const int controller119 = 119;

  /// Controller 120, the channel mode message All Sound Off.
  static const int allSoundOff = 120;

  /// Controller 121, the channel mode message Reset All Controllers; the
  /// standard name is [resetAllControllers].
  static const int allControllersOff = 121;

  /// Controller 122, the channel mode message Local Control on/off; the
  /// standard name is [localControl].
  static const int localKeyboardOnOff = 122;

  /// Controller 123, the channel mode message All Notes Off.
  static const int allNotesOff = 123;

  /// Controller 124, the channel mode message Omni Mode Off; the standard name
  /// is [omniOff].
  static const int omniModeOff = 124;

  /// Controller 125, the channel mode message Omni Mode On; the standard name
  /// is [omniOn].
  static const int omniModeOn = 125;

  /// Controller 126, the channel mode message Mono Mode On; the standard name
  /// is [monoOn].
  static const int monoOperation = 126;

  /// Controller 127, the channel mode message Poly Mode On; the standard name
  /// is [polyOn].
  ///
  /// gg_midi_vars defined it as 12, which collided with [effectControl1Coarse];
  /// this package fixes it to 127.
  static const int polyOperation = 127;

  // ...........................................................................
  // Standard names of the most significant bytes (MSB) of 14-bit controllers.

  /// Controller 1, Modulation Wheel or Lever MSB.
  static const int modulationWheel = 1;

  /// Controller 2, Breath Controller MSB.
  static const int breathController = 2;

  /// Controller 4, Foot Controller MSB.
  static const int footController = 4;

  /// Controller 5, Portamento Time MSB.
  static const int portamentoTime = 5;

  /// Controller 6, Data Entry MSB: the value of the selected RPN or NRPN.
  static const int dataEntryMsb = 6;

  /// Controller 7, Channel Volume MSB, formerly Main Volume.
  static const int channelVolume = 7;

  /// Controller 8, Balance MSB.
  static const int balance = 8;

  /// Controller 10, Pan MSB.
  static const int pan = 10;

  /// Controller 11, Expression Controller MSB.
  static const int expression = 11;

  /// Controller 12, Effect Control 1 MSB.
  static const int effectControl1 = 12;

  /// Controller 13, Effect Control 2 MSB.
  static const int effectControl2 = 13;

  /// Controller 16, General Purpose Controller 1 MSB.
  static const int generalPurposeController1 = 16;

  /// Controller 17, General Purpose Controller 2 MSB.
  static const int generalPurposeController2 = 17;

  /// Controller 18, General Purpose Controller 3 MSB.
  static const int generalPurposeController3 = 18;

  /// Controller 19, General Purpose Controller 4 MSB.
  static const int generalPurposeController4 = 19;

  // ...........................................................................
  // Standard names of the least significant bytes (LSB), controller 32
  // to 63 for the MSB controllers 0 to 31.

  /// Controller 32, Bank Select LSB.
  static const int bankSelectLsb = 32;

  /// Controller 33, Modulation Wheel LSB.
  static const int modulationWheelLsb = 33;

  /// Controller 34, Breath Controller LSB.
  static const int breathControllerLsb = 34;

  /// Controller 36, Foot Controller LSB.
  static const int footControllerLsb = 36;

  /// Controller 37, Portamento Time LSB.
  static const int portamentoTimeLsb = 37;

  /// Controller 38, Data Entry LSB.
  static const int dataEntryLsb = 38;

  /// Controller 39, Channel Volume LSB.
  static const int channelVolumeLsb = 39;

  /// Controller 40, Balance LSB.
  static const int balanceLsb = 40;

  /// Controller 42, Pan LSB.
  static const int panLsb = 42;

  /// Controller 43, Expression Controller LSB.
  static const int expressionLsb = 43;

  /// Controller 44, Effect Control 1 LSB.
  static const int effectControl1Lsb = 44;

  /// Controller 45, Effect Control 2 LSB.
  static const int effectControl2Lsb = 45;

  /// Controller 48, General Purpose Controller 1 LSB.
  static const int generalPurposeController1Lsb = 48;

  /// Controller 49, General Purpose Controller 2 LSB.
  static const int generalPurposeController2Lsb = 49;

  /// Controller 50, General Purpose Controller 3 LSB.
  static const int generalPurposeController3Lsb = 50;

  /// Controller 51, General Purpose Controller 4 LSB.
  static const int generalPurposeController4Lsb = 51;

  // ...........................................................................
  // Standard names of the switches: values up to 63 are off, 64 and
  // above on.

  /// Controller 64, Damper Pedal (Sustain) on/off.
  static const int sustainPedal = 64;

  /// Controller 65, Portamento on/off.
  static const int portamento = 65;

  /// Controller 66, Sostenuto on/off.
  static const int sostenuto = 66;

  /// Controller 67, Soft Pedal on/off.
  static const int softPedal = 67;

  /// Controller 68, Legato Footswitch.
  static const int legatoFootswitch = 68;

  /// Controller 69, Hold 2.
  static const int hold2 = 69;

  // ...........................................................................
  // Standard names of the sound controllers and their defaults (MMA
  // RP-021).

  /// Controller 70, Sound Controller 1, by default Sound Variation.
  static const int soundController1 = 70;

  /// Controller 71, Sound Controller 2, by default Timbre/Harmonic Intensity.
  static const int soundController2 = 71;

  /// Controller 72, Sound Controller 3, by default Release Time.
  static const int soundController3 = 72;

  /// Controller 73, Sound Controller 4, by default Attack Time.
  static const int soundController4 = 73;

  /// Controller 74, Sound Controller 5, by default Brightness.
  static const int soundController5 = 74;

  /// Controller 75, Sound Controller 6, by default Decay Time.
  static const int soundController6 = 75;

  /// Controller 76, Sound Controller 7, by default Vibrato Rate.
  static const int soundController7 = 76;

  /// Controller 77, Sound Controller 8, by default Vibrato Depth.
  static const int soundController8 = 77;

  /// Controller 78, Sound Controller 9, by default Vibrato Delay.
  static const int soundController9 = 78;

  /// Controller 79, Sound Controller 10, without default.
  static const int soundController10 = 79;

  /// Controller 75, Decay Time, the default of Sound Controller 6.
  static const int soundDecayTime = 75;

  /// Controller 76, Vibrato Rate, the default of Sound Controller 7.
  static const int soundVibratoRate = 76;

  /// Controller 77, Vibrato Depth, the default of Sound Controller 8.
  static const int soundVibratoDepth = 77;

  /// Controller 78, Vibrato Delay, the default of Sound Controller 9.
  static const int soundVibratoDelay = 78;

  // ...........................................................................
  // Standard names of the general purpose and portamento controllers.

  /// Controller 80, General Purpose Controller 5.
  static const int generalPurposeController5 = 80;

  /// Controller 81, General Purpose Controller 6.
  static const int generalPurposeController6 = 81;

  /// Controller 82, General Purpose Controller 7.
  static const int generalPurposeController7 = 82;

  /// Controller 83, General Purpose Controller 8.
  static const int generalPurposeController8 = 83;

  /// Controller 84, Portamento Control: the note the next note glides from.
  static const int portamentoControl = 84;

  /// Controller 88, High Resolution Velocity Prefix: the low seven bits of
  /// the velocity of the next note (MMA CA-031).
  static const int highResolutionVelocityPrefix = 88;

  // ...........................................................................
  // Standard names of the effects depths (MMA RP-023 for the defaults).

  /// Controller 91, Effects 1 Depth, by default Reverb Send Level.
  static const int effects1Depth = 91;

  /// Controller 92, Effects 2 Depth, formerly Tremolo Depth.
  static const int effects2Depth = 92;

  /// Controller 93, Effects 3 Depth, by default Chorus Send Level.
  static const int effects3Depth = 93;

  /// Controller 94, Effects 4 Depth, formerly Celeste (Detune) Depth.
  static const int effects4Depth = 94;

  /// Controller 95, Effects 5 Depth, formerly Phaser Depth.
  static const int effects5Depth = 95;

  /// Controller 91, Reverb Send Level, the default of Effects 1 Depth.
  static const int reverbSendLevel = 91;

  // ...........................................................................
  // Standard names of data entry and the parameter number selection.

  /// Controller 96, Data Increment: adds one to the selected parameter
  /// (MMA RP-018).
  static const int dataIncrement = 96;

  /// Controller 97, Data Decrement: subtracts one from the selected
  /// parameter (MMA RP-018).
  static const int dataDecrement = 97;

  /// Controller 98, Non-Registered Parameter Number LSB.
  static const int nrpnLsb = 98;

  /// Controller 99, Non-Registered Parameter Number MSB.
  static const int nrpnMsb = 99;

  /// Controller 100, Registered Parameter Number LSB.
  static const int rpnLsb = 100;

  /// Controller 101, Registered Parameter Number MSB.
  static const int rpnMsb = 101;

  // ...........................................................................
  // Standard names of the channel mode messages (M2-104-UM Appendix B).
  // [allSoundOff] and [allNotesOff] keep their gg_midi_vars names.

  /// Controller 121, Reset All Controllers (MMA RP-015).
  static const int resetAllControllers = 121;

  /// Controller 122, Local Control: 0 off, 127 on.
  static const int localControl = 122;

  /// Controller 124, Omni Off; it also turns all notes off.
  static const int omniOff = 124;

  /// Controller 125, Omni On; it also turns all notes off.
  static const int omniOn = 125;

  /// Controller 126, Mono On (Poly Off); the value is the number of
  /// channels, 0 for as many as there are voices.
  static const int monoOn = 126;

  /// Controller 127, Poly On (Mono Off); it also turns all notes off.
  static const int polyOn = 127;

  // ...........................................................................
  /// Returns the gg_midi_vars name of [controller], e.g.
  /// `'allControllersOff'` for 121.
  ///
  /// Throws a [RangeError] when [controller] is outside 0 to 127.
  static String toStr(int controller) {
    RangeError.checkValueInInterval(controller, 0, 127, 'controller');
    return _names[controller];
  }

  /// Returns whether [controller] is a channel mode message, 120 to 127.
  static bool isChannelMode(int controller) =>
      controller >= allSoundOff && controller <= polyOperation;

  // ...........................................................................
  /// The gg_midi_vars names of the controllers 0 to 127.
  static const List<String> _names = [
    'bankSelect',
    'modulationWheelCoarse',
    'breathcontrollerCoarse',
    'controller3',
    'footPedalCoarse',
    'portamentoTimeCoarse',
    'dataEntryCoarse',
    'volumeCoarse',
    'balanceCoarse',
    'controller9',
    'panpositionCoarse',
    'expressionCoarse',
    'effectControl1Coarse',
    'effectControl2Coarse',
    'controller14',
    'controller15',
    'generalPurposeSlider1',
    'generalPurposeSlider2',
    'generalPurposeSlider3',
    'generalPurposeSlider4',
    'controller20',
    'controller21',
    'controller22',
    'controller23',
    'controller24',
    'controller25',
    'controller26',
    'controller27',
    'controller28',
    'controller29',
    'controller30',
    'controller31',
    'bankSelectFine',
    'modulationWheelFine',
    'breathcontrollerFine',
    'controller35',
    'footPedalFine',
    'portamentoTimeFine',
    'dataEntryFine',
    'volumeFine',
    'balanceFine',
    'controller41',
    'panpositionFine',
    'expressionFine',
    'effectControl1Fine',
    'effectControl2Fine',
    'controller46',
    'controller47',
    'controller48',
    'controller49',
    'controller50',
    'controller51',
    'controller52',
    'controller53',
    'controller54',
    'controller55',
    'controller56',
    'controller57',
    'controller58',
    'controller59',
    'controller60',
    'controller61',
    'controller62',
    'controller63',
    'holdPedalOnOff',
    'portamentoOnOff',
    'sustenutoPedalOnOff',
    'softPedalOnOff',
    'legatoPedalOnOff',
    'hold2PedalOnOff',
    'soundVariation',
    'soundTimbre',
    'soundReleaseTime',
    'soundAttackTime',
    'soundBrightness',
    'soundControl6',
    'soundControl7',
    'soundControl8',
    'soundControl9',
    'soundControl10',
    'generalPurposeButton1OnOff',
    'generalPurposeButton2OnOff',
    'generalPurposeButton3OnOff',
    'generalPurposeButton4OnOff',
    'controller64',
    'controller65',
    'controller66',
    'controller67',
    'controller68',
    'controller69',
    'controller70',
    'effectsLevel',
    'tremuloLevel',
    'chorusLevel',
    'celesteLevel',
    'phaserLevel',
    'dataButtonincrement',
    'dataButtondecrement',
    'nonRegisteredParameterCoarse',
    'nonRegisteredParameterFine',
    'registeredParameterCoarse',
    'registeredParameterFine',
    'controller102',
    'controller103',
    'controller104',
    'controller105',
    'controller106',
    'controller107',
    'controller108',
    'controller109',
    'controller110',
    'controller111',
    'controller112',
    'controller113',
    'controller114',
    'controller115',
    'controller116',
    'controller117',
    'controller118',
    'controller119',
    'allSoundOff',
    'allControllersOff',
    'localKeyboardOnOff',
    'allNotesOff',
    'omniModeOff',
    'omniModeOn',
    'monoOperation',
    'polyOperation',
  ];
}
