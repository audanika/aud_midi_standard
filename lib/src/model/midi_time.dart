// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// A point in time on the monotonic package clock, in microseconds.
///
/// All timestamps of the package use this clock: input events carry the
/// operating system's receive time converted to it, and outputs schedule
/// against it. The epoch is arbitrary; only differences carry meaning.
extension type const MidiTime(int microseconds) {
  // ...........................................................................
  /// The epoch of the clock.
  static const MidiTime zero = MidiTime(0);

  // ...........................................................................
  /// Returns this time moved forward by [duration].
  MidiTime operator +(Duration duration) =>
      MidiTime(microseconds + duration.inMicroseconds);

  /// Returns this time moved back by [duration].
  MidiTime operator -(Duration duration) =>
      MidiTime(microseconds - duration.inMicroseconds);

  // ...........................................................................
  /// Returns the duration from [other] to this time; negative when [other]
  /// is later.
  Duration difference(MidiTime other) =>
      Duration(microseconds: microseconds - other.microseconds);

  // ...........................................................................
  /// Whether this time is earlier than [other].
  bool isBefore(MidiTime other) => microseconds < other.microseconds;

  /// Whether this time is later than [other].
  bool isAfter(MidiTime other) => microseconds > other.microseconds;

  /// Compares this time with [other] like [Comparable.compareTo].
  int compareTo(MidiTime other) => microseconds.compareTo(other.microseconds);
}
