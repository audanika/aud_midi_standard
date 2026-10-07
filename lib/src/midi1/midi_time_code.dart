// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../message/midi_message.dart';
import 'midi_manufacturer_ids.dart';
import 'midi_universal_sys_ex.dart';

// #############################################################################
/// MIDI Time Code: the frame rates, the eight quarter frame messages that
/// carry the time while running, and the full message that sets the time
/// while stopped or locating (MIDI Time Code specification, part of the
/// MIDI 1.0 Detailed Specification 4.2.1).
///
/// A time consists of hours 0 to 23, minutes and seconds 0 to 59, frames
/// from 0 to one less than the [frameCount] of its rate, and one of the rate
/// codes [rate24], [rate25], [rate2997Drop] and [rate30].
abstract final class MidiTimeCode {
  // ...........................................................................
  /// The rate code of 24 frames per second, used for film.
  static const int rate24 = 0;

  /// The rate code of 25 frames per second, used for PAL video.
  static const int rate25 = 1;

  /// The rate code of 29.97 frames per second, numbered as 30 frames with
  /// SMPTE drop frame numbering, used for NTSC color video.
  static const int rate2997Drop = 2;

  /// The rate code of 30 frames per second without dropped frames.
  static const int rate30 = 3;

  // ...........................................................................
  /// The quarter frame piece with the low nibble of the frames.
  static const int pieceFramesLow = 0;

  /// The quarter frame piece with the high bit of the frames.
  static const int pieceFramesHigh = 1;

  /// The quarter frame piece with the low nibble of the seconds.
  static const int pieceSecondsLow = 2;

  /// The quarter frame piece with the two high bits of the seconds.
  static const int pieceSecondsHigh = 3;

  /// The quarter frame piece with the low nibble of the minutes.
  static const int pieceMinutesLow = 4;

  /// The quarter frame piece with the two high bits of the minutes.
  static const int pieceMinutesHigh = 5;

  /// The quarter frame piece with the low nibble of the hours.
  static const int pieceHoursLow = 6;

  /// The quarter frame piece with the rate code in bits 1 and 2 and the
  /// high bit of the hours in bit 0.
  static const int pieceHoursHighAndRate = 7;

  // ...........................................................................
  /// Returns the frames per second of [rate]: 24, 25, 29.97 (exactly
  /// 30000 / 1001) or 30.
  ///
  /// Throws a [RangeError] when [rate] is no rate code.
  static double framesPerSecond(int rate) => _framesPerSecond[_checkRate(rate)];

  /// Returns the number of frame numbers per second of [rate]: 24, 25 or
  /// 30; drop frame time code numbers 30 frames per second as well.
  ///
  /// Throws a [RangeError] when [rate] is no rate code.
  static int frameCount(int rate) => _frameCounts[_checkRate(rate)];

  // ...........................................................................
  /// Returns the eight quarter frames that transmit a time, piece 0 first.
  ///
  /// A sender spreads them over two frames; a receiver knows the time after
  /// the last piece, when it is two frames old.
  ///
  /// Throws a [RangeError] when a field is outside its range.
  static List<MidiTimeCodeQuarterFrame> quarterFrames({
    required int hours,
    required int minutes,
    required int seconds,
    required int frames,
    required int rate,
  }) {
    _checkTime(hours, minutes, seconds, frames, rate);
    final values = [
      frames & 0x0F,
      frames >> 4,
      seconds & 0x0F,
      seconds >> 4,
      minutes & 0x0F,
      minutes >> 4,
      hours & 0x0F,
      (rate << 1) | (hours >> 4),
    ];
    return List.unmodifiable([
      for (var piece = 0; piece < 8; piece++)
        MidiTimeCodeQuarterFrame(piece: piece, value: values[piece]),
    ]);
  }

  /// Returns the time carried by [quarterFrames], or null unless they hold
  /// each piece 0 to 7 exactly once and a valid time.
  ///
  /// The order of the pieces does not matter, so the frames of forward and
  /// of reverse playback both assemble. Reserved bits are ignored.
  static ({int hours, int minutes, int seconds, int frames, int rate})?
  assemble(Iterable<MidiTimeCodeQuarterFrame> quarterFrames) {
    final values = List<int>.filled(8, -1);
    for (final frame in quarterFrames) {
      if (values[frame.piece] >= 0) return null;
      values[frame.piece] = frame.value;
    }
    if (values.contains(-1)) return null;
    final hoursHighAndRate = values[pieceHoursHighAndRate];
    return _validTime(
      hours: values[pieceHoursLow] | ((hoursHighAndRate & 1) << 4),
      minutes: values[pieceMinutesLow] | ((values[pieceMinutesHigh] & 3) << 4),
      seconds: values[pieceSecondsLow] | ((values[pieceSecondsHigh] & 3) << 4),
      frames: values[pieceFramesLow] | ((values[pieceFramesHigh] & 1) << 4),
      rate: (hoursHighAndRate >> 1) & 3,
    );
  }

  // ...........................................................................
  /// Returns the full message that sets a time at once, a Universal
  /// Real Time SysEx: 7F, device, 01 01, rate and hours, minutes, seconds,
  /// frames.
  ///
  /// - [deviceId] the device id, by default all devices
  ///
  /// Throws a [RangeError] when a field is outside its range.
  static MidiSysEx fullMessage({
    required int hours,
    required int minutes,
    required int seconds,
    required int frames,
    required int rate,
    int deviceId = MidiUniversalSysEx.allCallDeviceId,
  }) {
    _checkTime(hours, minutes, seconds, frames, rate);
    RangeError.checkValueInInterval(deviceId, 0, 0x7F, 'deviceId');
    return MidiSysEx([
      MidiManufacturerIds.universalRealTime,
      deviceId,
      MidiUniversalSysEx.timeCode,
      MidiUniversalSysEx.timeCodeFullMessage,
      (rate << 5) | hours,
      minutes,
      seconds,
      frames,
    ]);
  }

  /// Returns the time of the full message [sysEx], or null when [sysEx] is
  /// no full message or carries an invalid time.
  static ({int hours, int minutes, int seconds, int frames, int rate})?
  parseFullMessage(MidiSysEx sysEx) {
    final data = sysEx.data;
    if (data.length != 8 ||
        data[0] != MidiManufacturerIds.universalRealTime ||
        data[2] != MidiUniversalSysEx.timeCode ||
        data[3] != MidiUniversalSysEx.timeCodeFullMessage) {
      return null;
    }
    return _validTime(
      hours: data[4] & 0x1F,
      minutes: data[5],
      seconds: data[6],
      frames: data[7],
      rate: (data[4] >> 5) & 0x03,
    );
  }

  // ...........................................................................
  /// The frames per second by rate code.
  static const List<double> _framesPerSecond = [24, 25, 30000 / 1001, 30];

  /// The frame numbers per second by rate code.
  static const List<int> _frameCounts = [24, 25, 30, 30];

  /// Returns [rate] or throws a [RangeError] when it is no rate code.
  static int _checkRate(int rate) =>
      RangeError.checkValueInInterval(rate, rate24, rate30, 'rate');

  /// Returns the fields of a time with the highest value each may have.
  static List<(String, int, int)> _fields(
    int hours,
    int minutes,
    int seconds,
    int frames,
    int rate,
  ) => [
    ('rate', rate, rate30),
    ('hours', hours, 23),
    ('minutes', minutes, 59),
    ('seconds', seconds, 59),
    ('frames', frames, _frameCounts[rate & 0x03] - 1),
  ];

  /// Throws a [RangeError] for the first field outside its range.
  static void _checkTime(
    int hours,
    int minutes,
    int seconds,
    int frames,
    int rate,
  ) {
    for (final (name, value, max) in _fields(
      hours,
      minutes,
      seconds,
      frames,
      rate,
    )) {
      RangeError.checkValueInInterval(value, 0, max, name);
    }
  }

  /// Returns the time, or null when a field is outside its range.
  static ({int hours, int minutes, int seconds, int frames, int rate})?
  _validTime({
    required int hours,
    required int minutes,
    required int seconds,
    required int frames,
    required int rate,
  }) {
    final fields = _fields(hours, minutes, seconds, frames, rate);
    if (fields.any((f) => f.$2 < 0 || f.$2 > f.$3)) return null;
    return (
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      frames: frames,
      rate: rate,
    );
  }
}
