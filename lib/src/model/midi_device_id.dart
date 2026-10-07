// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The opaque identifier of a MIDI device, `'<backend>:<nativeId>'`.
///
/// Devices group ports; the port is the primary entity of the package.
/// The id is stable for the lifetime of a session only.
extension type const MidiDeviceId(String value) {
  // ...........................................................................
  /// Creates the id of the device [nativeId] of [backend].
  MidiDeviceId.of({required String backend, required String nativeId})
    : value = '$backend:$nativeId';

  // ...........................................................................
  /// The name of the backend that created the id, e.g. `coremidi`.
  String get backend {
    final colon = value.indexOf(':');
    return colon < 0 ? '' : value.substring(0, colon);
  }

  /// The identifier the backend uses natively.
  String get nativeId {
    final colon = value.indexOf(':');
    return colon < 0 ? value : value.substring(colon + 1);
  }
}
