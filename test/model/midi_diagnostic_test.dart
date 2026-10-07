// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const diagnostic = MidiDiagnostic(
    kind: MidiDiagnosticKind.queueOverflow,
    port: MidiPortId('coremidi:8'),
    count: 12,
    cause: 'Input queue full',
    time: MidiTime(1000),
  );

  const diagnosticJson = {
    'kind': 'queueOverflow',
    'port': 'coremidi:8',
    'count': 12,
    'cause': 'Input queue full',
    'time': 1000,
  };

  const other = MidiDiagnostic(
    kind: MidiDiagnosticKind.sysExTooLong,
    port: MidiPortId('alsa:20:0'),
    count: 1,
    cause: 'SysEx exceeds 1 MiB',
    time: MidiTime(2000),
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiDiagnostic', () {
    group('MidiDiagnostic(...)', () {
      test('reports one loss of no port by default', () {
        const diagnostic = MidiDiagnostic(
          kind: MidiDiagnosticKind.nativeError,
          cause: 'MIDIClientCreate failed',
          time: MidiTime.zero,
        );
        expect(diagnostic.toJson(), {
          'kind': 'nativeError',
          'port': null,
          'count': 1,
          'cause': 'MIDIClientCreate failed',
          'time': 0,
        });
      });
    });

    group('MidiDiagnostic.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiDiagnostic.fromJson(diagnostic.toJson()), diagnostic);
        final portless = diagnostic.copyWith(clearPort: true);
        expect(MidiDiagnostic.fromJson(portless.toJson()), portless);
      });

      test('reads a missing "port" as null', () {
        expect(
          MidiDiagnostic.fromJson({...diagnosticJson}..remove('port')),
          diagnostic.copyWith(clearPort: true),
        );
      });

      for (final key in diagnosticJson.keys.where((key) => key != 'port')) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiDiagnostic.fromJson({...diagnosticJson}..remove(key)),
            throwsFormat('MidiDiagnostic: "$key" is missing'),
          );
        });
      }

      for (final key in diagnosticJson.keys) {
        test('throws when "$key" has the wrong type', () {
          final wrong = diagnosticJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiDiagnostic.fromJson({...diagnosticJson, key: wrong}),
            throwsFormat(startsWith('MidiDiagnostic: "$key" must be ')),
          );
        });
      }

      test('throws for an unknown kind', () {
        expect(
          () => MidiDiagnostic.fromJson({...diagnosticJson, 'kind': 'x'}),
          throwsFormat(startsWith('MidiDiagnostic: "kind" must be one of ')),
        );
      });
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(diagnostic.copyWith(), diagnostic);
      });

      test('replaces the given fields', () {
        expect(
          diagnostic.copyWith(
            kind: other.kind,
            port: other.port,
            count: other.count,
            cause: other.cause,
            time: other.time,
          ),
          other,
        );
      });

      test('clears the port with clearPort', () {
        expect(diagnostic.copyWith(clearPort: true).port, isNull);
        expect(
          diagnostic.copyWith(port: other.port, clearPort: true).port,
          isNull,
        );
      });
    });

    group('toJson()', () {
      test('writes every field, the time in microseconds', () {
        expect(diagnostic.toJson(), diagnosticJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiDiagnostic.fromJson(diagnosticJson);
        expect(same, diagnostic);
        expect(same.hashCode, diagnostic.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            diagnostic.copyWith(kind: other.kind),
            diagnostic.copyWith(port: other.port),
            diagnostic.copyWith(count: other.count),
            diagnostic.copyWith(cause: other.cause),
            diagnostic.copyWith(time: other.time),
          ].where((variant) => variant == diagnostic),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          diagnostic.toString(),
          'MidiDiagnostic(kind: queueOverflow, port: coremidi:8, count: 12, '
          "cause: 'Input queue full', time: 1000)",
        );
      });
    });
  });
}
