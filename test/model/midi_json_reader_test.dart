// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:aud_midi_standard/src/model/midi_json_reader.dart';
import 'package:test/test.dart';

void main() {
  MidiJsonReader reader(Map<String, Object?> json) =>
      MidiJsonReader(json, type: 'Model');

  Matcher throwsFormat(String message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiJsonReader', () {
    group('MidiJsonReader(json, type: type)', () {
      test('keeps the map and the type', () {
        const json = {'a': 1};
        const reader = MidiJsonReader(json, type: 'Model');
        expect(reader.json, same(json));
        expect(reader.type, 'Model');
      });
    });

    group('value<T>(key)', () {
      test('returns values of the type', () {
        final json = <String, Object?>{
          'int': 1,
          'string': 'a',
          'bool': true,
          'map': {'k': 1},
          'list': [1],
        };
        final r = reader(json);
        expect(r.value<int>('int'), 1);
        expect(r.value<String>('string'), 'a');
        expect(r.value<bool>('bool'), isTrue);
        expect(r.value<Map<String, Object?>>('map'), {'k': 1});
        expect(r.value<List<Object?>>('list'), [1]);
      });

      test('reads extension types by their representation type', () {
        final r = reader({'port': 'a:b', 'time': 5});
        expect(r.value<MidiPortId>('port'), const MidiPortId('a:b'));
        expect(r.value<MidiTime>('time'), const MidiTime(5));
      });

      test('returns null for a nullable type when missing or null', () {
        final r = reader({'null': null});
        expect(r.value<int?>('null'), isNull);
        expect(r.value<int?>('missing'), isNull);
        expect(r.value<Object?>('missing'), isNull);
      });

      test('throws when a key of a non-nullable type is missing', () {
        expect(
          () => reader({}).value<int>('int'),
          throwsFormat('Model: "int" is missing'),
        );
      });

      test('throws when the value has another type', () {
        expect(
          () => reader({'int': 'a'}).value<int>('int'),
          throwsFormat('Model: "int" must be int, but is String'),
        );
        expect(
          () => reader({'int': null}).value<int>('int'),
          throwsFormat('Model: "int" must be int, but is Null'),
        );
        expect(
          () => reader({'int': 'a'}).value<int?>('int'),
          throwsFormat('Model: "int" must be int?, but is String'),
        );
      });

      test('passes the map as the source of the error', () {
        final json = <String, Object?>{'int': 'a'};
        expect(
          () => reader(json).value<int>('int'),
          throwsA(
            isA<FormatException>().having((e) => e.source, 'source', json),
          ),
        );
      });
    });

    group('optional<T, R>(key, convert)', () {
      test('returns the converted value', () {
        final r = reader({'us': 5});
        expect(
          r.optional('us', (int us) => Duration(microseconds: us)),
          const Duration(microseconds: 5),
        );
      });

      test('returns null when the key is missing or null', () {
        final r = reader({'us': null});
        expect(r.optional('us', (int us) => us + 1), isNull);
        expect(r.optional('missing', (int us) => us + 1), isNull);
      });

      test('throws when the value has another type', () {
        expect(
          () => reader({'us': 'a'}).optional('us', (int us) => us),
          throwsFormat('Model: "us" must be int?, but is String'),
        );
      });
    });

    group('object<T>(key, fromJson)', () {
      test('decodes the map of the key', () {
        final r = reader({
          'group': {'group': 1, 'name': 'A', 'isActive': true},
        });
        expect(
          r.object('group', MidiGroupInfo.fromJson),
          const MidiGroupInfo(group: 1, name: 'A'),
        );
      });

      test('throws when the value is no map', () {
        expect(
          () => reader({'group': 1}).object('group', MidiGroupInfo.fromJson),
          throwsFormat(
            'Model: "group" must be Map<String, Object?>, but is int',
          ),
        );
      });
    });

    group('list<T>(key)', () {
      test('returns the items of the type', () {
        expect(
          reader({
            'list': const [1, 2],
          }).list<int>('list'),
          [1, 2],
        );
        expect(
          reader({
            'ports': const ['a:1', 'a:2'],
          }).list<MidiPortId>('ports'),
          const [MidiPortId('a:1'), MidiPortId('a:2')],
        );
      });

      test('throws when the value is no list', () {
        expect(
          () => reader({'list': 'a'}).list<int>('list'),
          throwsFormat('Model: "list" must be List<Object?>, but is String'),
        );
      });

      test('throws naming the index of an item of another type', () {
        expect(
          () => reader({
            'list': const [1, 'a'],
          }).list<int>('list'),
          throwsFormat('Model: "list[1]" must be int, but is String'),
        );
      });
    });

    group('objects<T>(key, fromJson)', () {
      test('decodes every map of the list', () {
        final r = reader({
          'groups': [
            {'group': 1, 'name': 'A', 'isActive': true},
            {'group': 2, 'name': 'B', 'isActive': false},
          ],
        });
        expect(r.objects('groups', MidiGroupInfo.fromJson), [
          const MidiGroupInfo(group: 1, name: 'A'),
          const MidiGroupInfo(group: 2, name: 'B', isActive: false),
        ]);
      });

      test('throws naming the index of an item that is no map', () {
        expect(
          () => reader({
            'groups': const [1],
          }).objects('groups', MidiGroupInfo.fromJson),
          throwsFormat(
            'Model: "groups[0]" must be Map<String, Object?>, but is int',
          ),
        );
      });
    });

    group('oneOf(key, names)', () {
      test('returns the string when it is one of the names', () {
        expect(reader({'type': 'b'}).oneOf('type', const ['a', 'b']), 'b');
      });

      test('throws when the string is none of the names', () {
        expect(
          () => reader({'type': 'c'}).oneOf('type', const ['a', 'b']),
          throwsFormat("Model: \"type\" must be one of a, b, but is 'c'"),
        );
      });

      test('throws when the value is no string', () {
        expect(
          () => reader({'type': 1}).oneOf('type', const ['a']),
          throwsFormat('Model: "type" must be String, but is int'),
        );
      });
    });

    group('enumValue<E>(key, values)', () {
      test('returns the value of the name', () {
        expect(
          reader({
            'direction': 'output',
          }).enumValue('direction', MidiDirection.values),
          MidiDirection.output,
        );
      });

      test('throws when the name is unknown', () {
        expect(
          () => reader({
            'direction': 'up',
          }).enumValue('direction', MidiDirection.values),
          throwsFormat(
            "Model: \"direction\" must be one of input, output, but is 'up'",
          ),
        );
      });
    });

    group('enumSet<E>(key, values)', () {
      test('returns the values of the names', () {
        expect(
          reader({
            'set': const ['output', 'input'],
          }).enumSet('set', MidiDirection.values),
          {MidiDirection.output, MidiDirection.input},
        );
      });

      test('throws when a name is unknown', () {
        expect(
          () => reader({
            'set': const ['input', 'up'],
          }).enumSet('set', MidiDirection.values),
          throwsFormat(
            "Model: \"set\" must be one of input, output, but is 'up'",
          ),
        );
      });

      test('throws naming the index of an item that is no string', () {
        expect(
          () => reader({
            'set': const [1],
          }).enumSet('set', MidiDirection.values),
          throwsFormat('Model: "set[0]" must be String, but is int'),
        );
      });
    });
  });
}
