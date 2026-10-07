// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// Scales data values between the resolutions of MIDI 1.0 and MIDI 2.0
/// (M2-104-UM Appendix D.1).
///
/// Both directions keep only the low `fromBits` bits of the value. Scaling
/// up and then down again returns the original value.
abstract final class MidiValueScaling {
  // ...........................................................................
  /// Scales [value] of [fromBits] up to [toBits] with the min-center-max
  /// bit-repeat algorithm (M2-104-UM D.1.3).
  ///
  /// Values up to the center are shifted; values above the center fill the
  /// new low bits with repetitions of their own low bits, so that the
  /// maximum becomes the maximum. For example 7 to 16 bits: 0x0A becomes
  /// 0x1400, 0x40 becomes 0x8000, 0x57 becomes 0xAEBA and 0x7F becomes
  /// 0xFFFF.
  ///
  /// - [value] the value to scale; only its low [fromBits] bits are used
  /// - [fromBits] the resolution of [value], 2 to [toBits]
  /// - [toBits] the resolution of the result, up to 32
  static int scaleUp(int value, {required int fromBits, required int toBits}) {
    assert(fromBits >= 2 && fromBits <= toBits && toBits <= 32);
    final source = value & _mask(fromBits);
    final scaleBits = toBits - fromBits;
    final shifted = source << scaleBits;
    if (source <= 1 << (fromBits - 1)) return shifted;
    return shifted | _repeat(source, fromBits - 1, scaleBits);
  }

  // ...........................................................................
  /// Scales [value] of [fromBits] down to [toBits] by cutting off the low
  /// bits (M2-104-UM D.1.4).
  ///
  /// - [value] the value to scale; only its low [fromBits] bits are used
  /// - [fromBits] the resolution of [value], up to 32
  /// - [toBits] the resolution of the result, 1 to [fromBits]
  static int scaleDown(
    int value, {
    required int fromBits,
    required int toBits,
  }) {
    assert(toBits >= 1 && toBits <= fromBits && fromBits <= 32);
    return (value & _mask(fromBits)) >> (fromBits - toBits);
  }

  // ...........................................................................
  /// Returns the bits that fill the [scaleBits] new low bits: the low
  /// [repeatBits] bits of [source], repeated from the top down.
  static int _repeat(int source, int repeatBits, int scaleBits) {
    final pattern = source & _mask(repeatBits);
    var repeat = scaleBits > repeatBits
        ? pattern << (scaleBits - repeatBits)
        : pattern >> (repeatBits - scaleBits);
    var result = 0;
    while (repeat != 0) {
      result |= repeat;
      repeat >>= repeatBits;
    }
    return result;
  }

  /// Returns a mask of the low [bits] bits.
  static int _mask(int bits) => bits >= 32 ? 0xFFFFFFFF : (1 << bits) - 1;
}
