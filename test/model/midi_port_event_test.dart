// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  final port = MidiPortInfo(
    id: const MidiPortId('coremidi:8'),
    name: 'Keys',
    direction: MidiDirection.input,
  );
  final renamed = port.copyWith(name: 'Keys 2');

  final added = MidiPortAdded(port: port);
  final removed = MidiPortRemoved(port: port);
  final changed = MidiPortChanged(port: renamed, previous: port);

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiPortEvent', () {
    group('MidiPortEvent.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        for (final event in [added, removed, changed]) {
          expect(MidiPortEvent.fromJson(event.toJson()), event);
        }
      });

      test('throws for an unknown type', () {
        expect(
          () => MidiPortEvent.fromJson({...added.toJson(), 'type': 'moved'}),
          throwsFormat(
            'MidiPortEvent: "type" must be one of added, removed, changed, '
            "but is 'moved'",
          ),
        );
      });

      for (final key in ['type', 'port']) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiPortEvent.fromJson(added.toJson()..remove(key)),
            throwsFormat('MidiPortEvent: "$key" is missing'),
          );
        });
      }

      test('throws when "previous" of a change is missing', () {
        expect(
          () => MidiPortEvent.fromJson(changed.toJson()..remove('previous')),
          throwsFormat('MidiPortEvent: "previous" is missing'),
        );
      });

      test('throws for an invalid port', () {
        expect(
          () => MidiPortEvent.fromJson({
            'type': 'added',
            'port': <String, Object?>{},
          }),
          throwsFormat('MidiPortInfo: "id" is missing'),
        );
      });
    });

    group('port', () {
      test('is the port after the change', () {
        expect([added.port, removed.port, changed.port], [port, port, renamed]);
      });
    });
  });

  group('MidiPortAdded', () {
    group('copyWith(port: port)', () {
      test('keeps or replaces the port', () {
        expect(added.copyWith(), added);
        expect(added.copyWith(port: renamed), MidiPortAdded(port: renamed));
      });
    });

    group('toJson()', () {
      test('writes the type and the port', () {
        expect(added.toJson(), {'type': 'added', 'port': port.toJson()});
      });
    });

    group('==, hashCode', () {
      test('compare the port and the kind of event', () {
        expect(MidiPortAdded(port: port.copyWith()), added);
        expect(MidiPortAdded(port: port.copyWith()).hashCode, added.hashCode);
        expect(added, isNot(MidiPortAdded(port: renamed)));
        expect(added, isNot(removed));
      });
    });

    group('toString()', () {
      test('shows the port', () {
        expect(added.toString(), 'MidiPortAdded(port: $port)');
      });
    });
  });

  group('MidiPortRemoved', () {
    group('copyWith(port: port)', () {
      test('keeps or replaces the port', () {
        expect(removed.copyWith(), removed);
        expect(removed.copyWith(port: renamed), MidiPortRemoved(port: renamed));
      });
    });

    group('toJson()', () {
      test('writes the type and the port', () {
        expect(removed.toJson(), {'type': 'removed', 'port': port.toJson()});
      });
    });

    group('==, hashCode', () {
      test('compare the port and the kind of event', () {
        expect(MidiPortRemoved(port: port.copyWith()), removed);
        expect(
          MidiPortRemoved(port: port.copyWith()).hashCode,
          removed.hashCode,
        );
        expect(removed, isNot(MidiPortRemoved(port: renamed)));
        expect(removed, isNot(added));
      });
    });

    group('toString()', () {
      test('shows the port', () {
        expect(removed.toString(), 'MidiPortRemoved(port: $port)');
      });
    });
  });

  group('MidiPortChanged', () {
    group('copyWith(port: port, previous: previous)', () {
      test('keeps or replaces the ports', () {
        expect(changed.copyWith(), changed);
        expect(
          changed.copyWith(port: port, previous: renamed),
          MidiPortChanged(port: port, previous: renamed),
        );
      });
    });

    group('toJson()', () {
      test('writes the type and both ports', () {
        expect(changed.toJson(), {
          'type': 'changed',
          'port': renamed.toJson(),
          'previous': port.toJson(),
        });
      });
    });

    group('previous', () {
      test('is the port before the change', () {
        expect(changed.previous, port);
      });
    });

    group('==, hashCode', () {
      test('compare both ports', () {
        final same = MidiPortChanged(port: renamed, previous: port);
        expect(same, changed);
        expect(same.hashCode, changed.hashCode);
        expect(changed, isNot(changed.copyWith(port: port)));
        expect(changed, isNot(changed.copyWith(previous: renamed)));
        expect(changed, isNot(added));
      });
    });

    group('toString()', () {
      test('shows both ports', () {
        expect(
          changed.toString(),
          'MidiPortChanged(port: $renamed, previous: $port)',
        );
      });
    });
  });
}
