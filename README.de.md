# aud_midi_standard

Die MIDI-1.0- und MIDI-2.0-Standards (UMP) als Dart, ohne jede Abhängigkeit: Konstanten, Datenmodelle, Parser und Codecs.

Teil der aud_midi-Familie, siehe [aud_midi](https://github.com/audanika/aud_midi).

## Ziele

- Keine Abhängigkeiten, läuft auf VM, Web und Wasm
- MIDI-1.0- und 2.0-Konstanten, Nachrichten und UMP-Pakete
- Byte-Parser, Encoder und vollständiger UMP-Codec inkl. Übersetzung 1.0 und 2.0
- Geräte-, Port- und Capability-Modelle für alle Backends
- Übernimmt gg_midi_vars

## Stand

Nur Boilerplate. Die Implementierung folgt in späteren Tickets, siehe den Plan in [audanika_midi_pm](https://github.com/audanika/audanika_midi_pm/blob/main/doc/2026-Q4/tickets/2026-10-06-aud_midi_01-initial-midi-implementation.md).

## Installation

```bash
dart pub add aud_midi_standard
```

## Mitwirken

Siehe [doc/guides/develop-guide.md](doc/guides/develop-guide.md).
