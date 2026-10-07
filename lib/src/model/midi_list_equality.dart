// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// Compares lists element by element; the models use it for their value
/// equality.
///
/// The extension is deliberately not exported: it is a detail of the
/// models.
extension MidiListEquality<T> on List<T> {
  // ...........................................................................
  /// Returns whether [other] holds equal elements in the same order.
  bool equals(List<T> other) {
    if (identical(this, other)) return true;
    if (length != other.length) return false;
    for (var i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }
}
