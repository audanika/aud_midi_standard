// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// Who honours the due time of messages sent for a later time.
enum MidiSchedulingSupport {
  /// The operating system or the driver schedules timed sends.
  hardware,

  /// The software scheduler of the package holds messages until they are
  /// due.
  software,
}
