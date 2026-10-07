// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The Registered Parameter Numbers (RPN) of MIDI 1.0, which are also the
/// Registered Controllers of MIDI 2.0 (MIDI 1.0 Detailed Specification
/// 4.2.1, Registered Parameter Numbers, with its amendments; M2-104-UM
/// 7.4.7).
///
/// The constants are 14-bit parameter numbers: the MSB in the upper seven
/// bits, the LSB in the lower seven bits. In MIDI 1.0 the MSB is sent with
/// controller 101 and the LSB with controller 100; in MIDI 2.0 the MSB is
/// the bank and the LSB the index of a Registered Controller message.
/// [numberOf] and [msbLsbOf] convert between both forms.
abstract final class MidiRegisteredParameters {
  // ...........................................................................
  // Bank 0: the parameters of the MIDI 1.0 Detailed Specification, its
  // amendments and M2-104-UM.

  /// Pitch Bend Sensitivity, MSB 0x00, LSB 0x00: semitones in the data
  /// entry MSB, cents in the data entry LSB.
  static const int pitchBendSensitivity = 0x00 << 7 | 0x00;

  /// Channel Fine Tuning, MSB 0x00, LSB 0x01, formerly Fine Tuning (MMA
  /// RP-022).
  static const int channelFineTuning = 0x00 << 7 | 0x01;

  /// Channel Coarse Tuning, MSB 0x00, LSB 0x02, formerly Coarse Tuning (MMA
  /// RP-022).
  static const int channelCoarseTuning = 0x00 << 7 | 0x02;

  /// Tuning Program Change, also called Tuning Program Select, MSB 0x00,
  /// LSB 0x03, of the MIDI Tuning Standard.
  static const int tuningProgramChange = 0x00 << 7 | 0x03;

  /// Tuning Bank Select, MSB 0x00, LSB 0x04, of the MIDI Tuning Standard.
  static const int tuningBankSelect = 0x00 << 7 | 0x04;

  /// Modulation Depth Range, MSB 0x00, LSB 0x05 (General MIDI 2, MMA
  /// CA-026).
  static const int modulationDepthRange = 0x00 << 7 | 0x05;

  /// MPE Configuration Message (MCM), MSB 0x00, LSB 0x06: the number of
  /// member channels of an MPE zone (MMA RP-053).
  static const int mpeConfiguration = 0x00 << 7 | 0x06;

  /// Per-Note Pitch Bend Sensitivity, MSB 0x00, LSB 0x07, a MIDI 2.0
  /// Registered Controller without function in MIDI 1.0 (M2-104-UM 7.4.13).
  static const int perNotePitchBendSensitivity = 0x00 << 7 | 0x07;

  // ...........................................................................
  // Bank 0x3D: the Three Dimensional Sound Controllers (MMA RP-049).

  /// The MSB 0x3D of the Three Dimensional Sound Controllers.
  static const int threeDSoundBank = 0x3D;

  /// Azimuth Angle, MSB 0x3D, LSB 0x00.
  static const int threeDAzimuthAngle = threeDSoundBank << 7 | 0x00;

  /// Elevation Angle, MSB 0x3D, LSB 0x01.
  static const int threeDElevationAngle = threeDSoundBank << 7 | 0x01;

  /// Gain, MSB 0x3D, LSB 0x02.
  static const int threeDGain = threeDSoundBank << 7 | 0x02;

  /// Distance Ratio, MSB 0x3D, LSB 0x03.
  static const int threeDDistanceRatio = threeDSoundBank << 7 | 0x03;

  /// Maximum Distance, MSB 0x3D, LSB 0x04.
  static const int threeDMaximumDistance = threeDSoundBank << 7 | 0x04;

  /// Gain at Maximum Distance, MSB 0x3D, LSB 0x05.
  static const int threeDGainAtMaximumDistance = threeDSoundBank << 7 | 0x05;

  /// Reference Distance Ratio, MSB 0x3D, LSB 0x06.
  static const int threeDReferenceDistanceRatio = threeDSoundBank << 7 | 0x06;

  /// Pan Spread Angle, MSB 0x3D, LSB 0x07.
  static const int threeDPanSpreadAngle = threeDSoundBank << 7 | 0x07;

  /// Roll Angle, MSB 0x3D, LSB 0x08.
  static const int threeDRollAngle = threeDSoundBank << 7 | 0x08;

  // ...........................................................................
  /// The null function number, MSB 0x7F, LSB 0x7F: it deselects the
  /// current RPN or NRPN, so that later data entry changes nothing.
  static const int nullFunction = 0x7F << 7 | 0x7F;

  // ...........................................................................
  /// Returns the 14-bit parameter number of [msb] and [lsb].
  ///
  /// - [msb] the MSB 0 to 127, sent with controller 101
  /// - [lsb] the LSB 0 to 127, sent with controller 100
  ///
  /// Throws a [RangeError] when a part is outside 0 to 127.
  static int numberOf({required int msb, required int lsb}) {
    RangeError.checkValueInInterval(msb, 0, 0x7F, 'msb');
    RangeError.checkValueInInterval(lsb, 0, 0x7F, 'lsb');
    return msb << 7 | lsb;
  }

  /// Returns the MSB and the LSB of the 14-bit parameter [number].
  ///
  /// Throws a [RangeError] when [number] is outside 0 to 0x3FFF.
  static ({int msb, int lsb}) msbLsbOf(int number) {
    RangeError.checkValueInInterval(number, 0, 0x3FFF, 'number');
    return (msb: number >> 7, lsb: number & 0x7F);
  }

  /// Returns the name of the constant for the parameter [number], e.g.
  /// `'pitchBendSensitivity'` for 0, or null for an unknown number.
  static String? name(int number) => _names[number];

  // ...........................................................................
  /// The constant names by parameter number.
  static const Map<int, String> _names = {
    pitchBendSensitivity: 'pitchBendSensitivity',
    channelFineTuning: 'channelFineTuning',
    channelCoarseTuning: 'channelCoarseTuning',
    tuningProgramChange: 'tuningProgramChange',
    tuningBankSelect: 'tuningBankSelect',
    modulationDepthRange: 'modulationDepthRange',
    mpeConfiguration: 'mpeConfiguration',
    perNotePitchBendSensitivity: 'perNotePitchBendSensitivity',
    threeDAzimuthAngle: 'threeDAzimuthAngle',
    threeDElevationAngle: 'threeDElevationAngle',
    threeDGain: 'threeDGain',
    threeDDistanceRatio: 'threeDDistanceRatio',
    threeDMaximumDistance: 'threeDMaximumDistance',
    threeDGainAtMaximumDistance: 'threeDGainAtMaximumDistance',
    threeDReferenceDistanceRatio: 'threeDReferenceDistanceRatio',
    threeDPanSpreadAngle: 'threeDPanSpreadAngle',
    threeDRollAngle: 'threeDRollAngle',
    nullFunction: 'nullFunction',
  };
}
