// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The kinds of data loss and faults a diagnostic reports.
///
/// Streams of the package never error; every loss becomes a diagnostic of
/// one of these kinds instead.
enum MidiDiagnosticKind {
  /// A bounded queue overflowed; the newest batch was dropped.
  queueOverflow,

  /// A parser or decoder dropped its partial state after a gap.
  parserReset,

  /// Bytes or packets did not form a valid message and were skipped, e.g.
  /// stray data bytes, undefined status bytes or malformed packets.
  invalidData,

  /// A System Exclusive message exceeded the size limit and was dropped.
  sysExTooLong,

  /// A System Exclusive message was interrupted or timed out and dropped.
  sysExIncomplete,

  /// A message has no equivalent on the target protocol or transport and
  /// was dropped.
  untranslatable,

  /// Packets of a network session were lost.
  networkLoss,

  /// A call into the operating system failed.
  nativeError,

  /// A scheduled message left later than requested.
  schedulerLate,
}
