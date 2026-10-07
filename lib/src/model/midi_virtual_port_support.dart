// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// Whether and how a backend provides virtual ports.
enum MidiVirtualPortSupport {
  /// The app creates and removes virtual ports at runtime.
  dynamicPorts,

  /// Virtual ports are declared statically, e.g. in the Android manifest,
  /// and cannot be created at runtime.
  staticPorts,

  /// The backend has no virtual ports.
  none,
}
