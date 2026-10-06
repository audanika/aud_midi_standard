# aud_midi_standard

The MIDI 1.0 and MIDI 2.0 (UMP) standards as Dart, without any dependency: constants, data models, parsers and codecs.

Part of the aud_midi family, see [aud_midi](https://github.com/audanika/aud_midi).

## Goals

- Zero dependencies, runs on VM, Web and Wasm
- MIDI 1.0 and 2.0 constants, messages and UMP packets
- Byte parser, encoder and complete UMP codec incl. 1.0 and 2.0 translation
- Device, port and capability models shared by all backends
- Absorbs gg_midi_vars

## State

Boilerplate only. The implementation follows in later tickets, see the plan in [aud_midi_pm](https://github.com/audanika/aud_midi_pm/blob/main/doc/2026-Q4/tickets/2026-10-06-aud_midi_01-initial-midi-implementation.md).

## Installation

```bash
dart pub add aud_midi_standard
```

## Contributing

See [doc/guides/develop-guide.md](doc/guides/develop-guide.md).
