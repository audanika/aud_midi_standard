// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import '../message/midi_message.dart';
import '../model/midi_diagnostic_kind.dart';
import '../model/midi_time.dart';

// #############################################################################
/// A message together with the time it was received or is due.
typedef MidiTimedMessage = ({MidiMessage message, MidiTime time});

// #############################################################################
/// Receives the issues a parser or decoder meets: the [kind] of the loss
/// and a human-readable [cause].
typedef MidiIssueCallback =
    void Function(MidiDiagnosticKind kind, String cause);
