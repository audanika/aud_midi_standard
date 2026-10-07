# aud_midi_standard

Die Standards MIDI 1.0 und MIDI 2.0 (UMP) als Dart ohne jede
Abhängigkeit: Nachrichten, Konstanten, Parser, Codecs, Übersetzung und die
beschreibenden Modelle der aud_midi-Familie.

Teil der aud_midi-Familie, siehe [aud_midi](https://github.com/audmidi/aud_midi).

## Ziele

- Keine Abhängigkeiten, läuft auf der Dart-VM, im Web und in Wasm
- Eine typisierte, versiegelte Nachrichtenhierarchie für MIDI 1.0 und
  MIDI 2.0
- Zwei unabhängige Rohformen: MIDI-1.0-Bytes und Universal MIDI Packets
- Vollständiger UMP-Codec, Übersetzung MIDI 1.0 ↔ 2.0 nach M2-104-UM
- Geräte-, Port-, Capability- und Event-Modelle für alle Backends
- Übernimmt `gg_midi_vars`

## Stand

- Nachrichten: MIDI-1.0-Channel-Voice, System Common und Real-Time,
  SysEx; MIDI-2.0-Channel-Voice inkl. Per-Note-Controllern und
  -Management; Utility, SysEx8, Mixed Data Set, Flex Data und
  UMP-Stream-Nachrichten
- Codecs: Byte-Parser (Running Status, SysEx-Zusammenbau mit Grenzen,
  eingestreute Real-Time-Nachrichten) und Encoder; UMP-Encoder und
  -Decoder für die Message Types 0x0–0xF mit Zusammenbau; Standard-
  Übersetzung nach M2-104-UM Anhang D mit Werteskalierung;
  BLE-MIDI-Paket-Codec
- Konstanten: Statusbytes, Controller und Notennummern (Namen aus
  gg_midi_vars erhalten), RPNs, General MIDI 1 und 2, Hersteller-IDs,
  Universal SysEx, MIDI Time Code, UMP-Statuswerte, Flex Data, Akkorde
- Modelle: Ports, Geräte, Capabilities, virtuelle Ports,
  BLE-Peripheriegeräte, Netzwerk-Hosts und -Sessions, Events, Pakete,
  Diagnosen — unveränderlich, mit JSON und `copyWith`
- 100 % Testabdeckung; Spezifikationsverweise in jedem Doc-Kommentar

## Installation

```yaml
dependencies:
  aud_midi_standard:
    git:
      url: git@github.com:audmidi/aud_midi_standard.git
```

## Dokumentation

- [Plan der aud_midi-Familie](https://github.com/audmidi/aud_midi_pm/blob/main/doc/2026-Q4/tickets/2026-10-06-aud_midi_01-initial-midi-implementation.md)
- [Entscheidungen](https://github.com/audmidi/aud_midi_pm/blob/main/doc/2026-Q4/concepts/decisions/000-index.md),
  z. B. die Übersetzungsregeln
- [Guides](doc/guides/)

## Codebeispiele

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

## Mitwirken

Siehe [doc/guides/develop-guide.md](doc/guides/develop-guide.md).
