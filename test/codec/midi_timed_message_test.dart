// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiTimedMessage', () {
    test('holds a message and its time', () {
      const MidiTimedMessage timed = (message: MidiStart(), time: MidiTime(5));
      expect(timed.message, const MidiStart());
      expect(timed.time, const MidiTime(5));
    });

    test('compares by value', () {
      expect(
        (message: const MidiStop(), time: const MidiTime(1)),
        (message: const MidiStop(), time: const MidiTime(1)),
      );
    });
  });

  group('MidiIssueCallback', () {
    test('receives kind and cause', () {
      final received = <(MidiDiagnosticKind, String)>[];
      void collect(MidiDiagnosticKind kind, String cause) =>
          received.add((kind, cause));
      final MidiIssueCallback callback = collect;
      callback(MidiDiagnosticKind.invalidData, 'stray byte');
      expect(
        received,
        equals([(MidiDiagnosticKind.invalidData, 'stray byte')]),
      );
    });
  });
}
