// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// ignore_for_file: avoid_print

import 'package:aud_midi_standard/aud_midi_standard.dart';

void main() {
  // Parse a MIDI 1.0 byte stream with running status
  final parser = MidiByteParser();
  for (final (:message, :time) in parser.add([0x90, 60, 100, 64, 90])) {
    print('$time $message');
  }

  // Translate to the MIDI 2.0 protocol and encode as UMP on group 1
  const noteOn = MidiNoteOn(channel: 0, note: 60, velocity: 100);
  final noteOn2 = noteOn.toMidi2().single;
  print(noteOn2);
  print(noteOn2.toUmp(group: 1));

  // Decode the packets again and translate back to MIDI 1.0 bytes
  final words = noteOn2.toUmp(group: 1).expand((ump) => ump.words).toList();
  final decoded = UmpDecoder().add(words).single;
  print(
    'group ${decoded.group}: ${decoded.message.toMidi1().single.toBytes()}',
  );

  // Use the constants migrated from gg_midi_vars
  print(MidiNoteNumbers.c4);
  print(MidiControllers.toStr(MidiControllers.allNotesOff));
}
