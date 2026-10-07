# aud_midi_standard

The MIDI 1.0 and MIDI 2.0 (UMP) standards as Dart without any dependency:
messages, constants, parsers, codecs, translation and the descriptive
models of the aud_midi family.

Part of the aud_midi family, see [aud_midi](https://github.com/audanika/aud_midi).

## Goals

- Zero dependencies, runs on the Dart VM, Web and Wasm
- One typed, sealed message hierarchy for MIDI 1.0 and MIDI 2.0
- Two independent raw forms: MIDI 1.0 bytes and Universal MIDI Packets
- Complete UMP codec, MIDI 1.0 ↔ 2.0 translation per M2-104-UM
- Device, port, capability and event models shared by all backends
- Absorbs `gg_midi_vars`

## State

- Messages: MIDI 1.0 channel voice, system common and real-time, SysEx;
  MIDI 2.0 channel voice incl. per-note controllers and management;
  utility, SysEx8, Mixed Data Set, flex data and UMP stream messages
- Codecs: byte parser (running status, SysEx reassembly with limits,
  real-time interleaving) and encoder; UMP encoder and decoder for
  message types 0x0–0xF with reassembly; default translation of
  M2-104-UM Appendix D with value scaling; BLE-MIDI packet codec
- Constants: status bytes, controllers and note numbers (gg_midi_vars
  names kept), RPNs, General MIDI 1 and 2, manufacturer ids, universal
  SysEx, MIDI time code, UMP status values, flex data, chords
- Models: ports, devices, capabilities, virtual ports, BLE peripherals,
  network hosts and sessions, events, packets, diagnostics — immutable,
  with JSON and `copyWith`
- 100 % test coverage; specification references in every doc comment

## Installation

```yaml
dependencies:
  aud_midi_standard:
    git:
      url: git@github.com:audanika/aud_midi_standard.git
```

## Documentation

- [Plan of the aud_midi family](https://github.com/audanika/aud_midi_pm/blob/main/doc/2026-Q4/tickets/2026-10-06-aud_midi_01-initial-midi-implementation.md)
- [Decisions](https://github.com/audanika/aud_midi_pm/blob/main/doc/2026-Q4/concepts/decisions/000-index.md),
  e.g. the translation rules
- [Guides](doc/guides/)

## Code Examples

```dart
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
```

## Contributing

See [doc/guides/develop-guide.md](doc/guides/develop-guide.md).
