// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  const block = MidiFunctionBlockInfo(
    number: 2,
    name: 'Synth',
    isActive: false,
    direction: MidiFunctionBlockDirection.bidirectional,
    firstGroup: 4,
    groupCount: 2,
    midi1: MidiFunctionBlockMidi1.restricted31250,
    uiHint: MidiFunctionBlockUiHint.senderReceiver,
    midiCiVersion: 2,
    maxSysEx8Streams: 8,
  );

  const blockJson = {
    'number': 2,
    'name': 'Synth',
    'isActive': false,
    'direction': 'bidirectional',
    'firstGroup': 4,
    'groupCount': 2,
    'midi1': 'restricted31250',
    'uiHint': 'senderReceiver',
    'midiCiVersion': 2,
    'maxSysEx8Streams': 8,
  };

  const other = MidiFunctionBlockInfo(
    number: 3,
    name: 'Drums',
    direction: MidiFunctionBlockDirection.input,
    firstGroup: 0,
    groupCount: 1,
    midi1: MidiFunctionBlockMidi1.unrestricted,
    uiHint: MidiFunctionBlockUiHint.receiver,
    midiCiVersion: 1,
    maxSysEx8Streams: 1,
  );

  Matcher throwsFormat(Object? message) => throwsA(
    isA<FormatException>().having((e) => e.message, 'message', message),
  );

  group('MidiFunctionBlockInfo', () {
    group('MidiFunctionBlockInfo(...)', () {
      test('applies the defaults', () {
        const block = MidiFunctionBlockInfo(
          number: 0,
          direction: MidiFunctionBlockDirection.output,
          firstGroup: 0,
          groupCount: 16,
        );
        expect(block.toJson(), {
          'number': 0,
          'name': '',
          'isActive': true,
          'direction': 'output',
          'firstGroup': 0,
          'groupCount': 16,
          'midi1': 'notMidi1',
          'uiHint': 'unknown',
          'midiCiVersion': 0,
          'maxSysEx8Streams': 0,
        });
      });

      test('asserts the group range', () {
        for (final (firstGroup, groupCount) in [(-1, 1), (16, 1), (0, -1)]) {
          expect(
            () => MidiFunctionBlockInfo(
              number: 0,
              direction: MidiFunctionBlockDirection.input,
              firstGroup: firstGroup,
              groupCount: groupCount,
            ),
            throwsA(isA<AssertionError>()),
          );
        }
        expect(
          () => block.copyWith(groupCount: 17),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('MidiFunctionBlockInfo.fromNotification(notification, name)', () {
      const notification = MidiFunctionBlockInfoNotification(
        active: false,
        functionBlock: 2,
        uiHint: MidiFunctionBlockUiHint.senderReceiver,
        midi1: MidiFunctionBlockMidi1.restricted31250,
        direction: MidiFunctionBlockDirection.bidirectional,
        firstGroup: 4,
        numberOfGroups: 2,
        midiCiVersion: 2,
        maxSysEx8Streams: 8,
      );

      test('takes every field of the notification', () {
        expect(
          MidiFunctionBlockInfo.fromNotification(notification, name: 'Synth'),
          block,
        );
      });

      test('has an empty name by default', () {
        expect(MidiFunctionBlockInfo.fromNotification(notification).name, '');
      });
    });

    group('MidiFunctionBlockInfo.fromJson(json)', () {
      test('decodes what toJson encodes', () {
        expect(MidiFunctionBlockInfo.fromJson(block.toJson()), block);
        expect(MidiFunctionBlockInfo.fromJson(other.toJson()), other);
      });

      for (final key in blockJson.keys) {
        test('throws when "$key" is missing', () {
          expect(
            () => MidiFunctionBlockInfo.fromJson({...blockJson}..remove(key)),
            throwsFormat('MidiFunctionBlockInfo: "$key" is missing'),
          );
        });

        test('throws when "$key" has the wrong type', () {
          final wrong = blockJson[key] is String ? 1 : 'wrong';
          expect(
            () => MidiFunctionBlockInfo.fromJson({...blockJson, key: wrong}),
            throwsFormat(startsWith('MidiFunctionBlockInfo: "$key" must be ')),
          );
        });
      }

      test('throws for an unknown enum name', () {
        expect(
          () => MidiFunctionBlockInfo.fromJson({...blockJson, 'uiHint': 'x'}),
          throwsFormat(
            'MidiFunctionBlockInfo: "uiHint" must be one of unknown, '
            "receiver, sender, senderReceiver, but is 'x'",
          ),
        );
      });
    });

    group('copyWith(...)', () {
      test('keeps every field without arguments', () {
        expect(block.copyWith(), block);
      });

      test('replaces the given fields', () {
        expect(
          block.copyWith(
            number: other.number,
            name: other.name,
            isActive: other.isActive,
            direction: other.direction,
            firstGroup: other.firstGroup,
            groupCount: other.groupCount,
            midi1: other.midi1,
            uiHint: other.uiHint,
            midiCiVersion: other.midiCiVersion,
            maxSysEx8Streams: other.maxSysEx8Streams,
          ),
          other,
        );
      });
    });

    group('toJson()', () {
      test('writes every field, enums by name', () {
        expect(block.toJson(), blockJson);
      });
    });

    group('==, hashCode', () {
      test('are equal for equal fields', () {
        final same = MidiFunctionBlockInfo.fromJson(blockJson);
        expect(same, block);
        expect(same.hashCode, block.hashCode);
      });

      test('differ in every field', () {
        expect(
          [
            block.copyWith(number: other.number),
            block.copyWith(name: other.name),
            block.copyWith(isActive: other.isActive),
            block.copyWith(direction: other.direction),
            block.copyWith(firstGroup: other.firstGroup),
            block.copyWith(groupCount: other.groupCount),
            block.copyWith(midi1: other.midi1),
            block.copyWith(uiHint: other.uiHint),
            block.copyWith(midiCiVersion: other.midiCiVersion),
            block.copyWith(maxSysEx8Streams: other.maxSysEx8Streams),
          ].where((variant) => variant == block),
          isEmpty,
        );
      });
    });

    group('toString()', () {
      test('lists every field', () {
        expect(
          block.toString(),
          "MidiFunctionBlockInfo(number: 2, name: 'Synth', isActive: false, "
          'direction: bidirectional, firstGroup: 4, groupCount: 2, '
          'midi1: restricted31250, uiHint: senderReceiver, '
          'midiCiVersion: 2, maxSysEx8Streams: 8)',
        );
      });
    });
  });
}
