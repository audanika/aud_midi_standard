// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The opaque identifier of a MIDI port, `'<backend>:<nativeId>'`.
///
/// It is stable for the lifetime of a session only: operating systems
/// reassign native ids when a device is plugged in again. Use the port's
/// fingerprint to find re-plug candidates.
extension type const MidiPortId(String value) {
  // ...........................................................................
  /// Creates the id of the port [nativeId] of [backend].
  MidiPortId.of({required String backend, required String nativeId})
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
