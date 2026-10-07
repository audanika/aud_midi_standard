// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_midi_standard/aud_midi_standard.dart';
import 'package:test/test.dart';

void main() {
  group('MidiFlexDataStatus', () {
    // .........................................................................
    group('constants', () {
      test('number the status banks of M2-104-UM Table 11', () {
        expect([
          MidiFlexDataStatus.setupAndPerformanceBank,
          MidiFlexDataStatus.metadataTextBank,
          MidiFlexDataStatus.performanceTextBank,
        ], equals([0x00, 0x01, 0x02]));
      });

      test('number the setup and performance statuses', () {
        expect([
          MidiFlexDataStatus.setTempo,
          MidiFlexDataStatus.setTimeSignature,
          MidiFlexDataStatus.setMetronome,
          MidiFlexDataStatus.setKeySignature,
          MidiFlexDataStatus.setChordName,
        ], equals([0x00, 0x01, 0x02, 0x05, 0x06]));
      });

      test('number the metadata text statuses 0x00 to 0x0C', () {
        expect([
          MidiFlexDataStatus.unknownMetadataText,
          MidiFlexDataStatus.projectName,
          MidiFlexDataStatus.compositionName,
          MidiFlexDataStatus.midiClipName,
          MidiFlexDataStatus.copyrightNotice,
          MidiFlexDataStatus.composerName,
          MidiFlexDataStatus.lyricistName,
          MidiFlexDataStatus.arrangerName,
          MidiFlexDataStatus.publisherName,
          MidiFlexDataStatus.primaryPerformerName,
          MidiFlexDataStatus.accompanyingPerformerName,
          MidiFlexDataStatus.recordingConcertDate,
          MidiFlexDataStatus.recordingConcertLocation,
        ], equals([for (var s = 0x00; s <= 0x0C; s++) s]));
      });

      test('number the performance text statuses 0x00 to 0x04', () {
        expect([
          MidiFlexDataStatus.unknownPerformanceText,
          MidiFlexDataStatus.lyrics,
          MidiFlexDataStatus.lyricsLanguage,
          MidiFlexDataStatus.ruby,
          MidiFlexDataStatus.rubyLanguage,
        ], equals([0x00, 0x01, 0x02, 0x03, 0x04]));
      });

      test('match the banks and statuses of the flex data messages', () {
        final tempo = MidiSetTempo.fromBeatsPerMinute(120);
        expect(
          [tempo.statusBank, tempo.status],
          equals([
            MidiFlexDataStatus.setupAndPerformanceBank,
            MidiFlexDataStatus.setTempo,
          ]),
        );
        expect(
          [MidiFlexText.metadataTextBank, MidiFlexText.performanceTextBank],
          equals([
            MidiFlexDataStatus.metadataTextBank,
            MidiFlexDataStatus.performanceTextBank,
          ]),
        );
      });
    });

    // .........................................................................
    group('isText(statusBank)', () {
      test('accepts the metadata and performance text banks', () {
        expect(
          [0x00, 0x01, 0x02, 0x03].map(MidiFlexDataStatus.isText),
          equals([false, true, true, false]),
        );
      });
    });

    // .........................................................................
    group('name(statusBank, status)', () {
      // Returns the names of [statuses] in [statusBank].
      List<String?> names(int statusBank, Iterable<int> statuses) => [
        for (final status in statuses)
          MidiFlexDataStatus.name(statusBank: statusBank, status: status),
      ];

      test('names the setup and performance statuses', () {
        expect(
          names(0x00, [0, 1, 2, 3, 4, 5, 6, 7]),
          equals([
            'setTempo',
            'setTimeSignature',
            'setMetronome',
            null,
            null,
            'setKeySignature',
            'setChordName',
            null,
          ]),
        );
      });

      test('names the metadata text statuses', () {
        expect(
          names(0x01, [for (var s = 0x00; s <= 0x0D; s++) s]),
          equals([
            'unknownMetadataText',
            'projectName',
            'compositionName',
            'midiClipName',
            'copyrightNotice',
            'composerName',
            'lyricistName',
            'arrangerName',
            'publisherName',
            'primaryPerformerName',
            'accompanyingPerformerName',
            'recordingConcertDate',
            'recordingConcertLocation',
            null,
          ]),
        );
      });

      test('names the performance text statuses', () {
        expect(
          names(0x02, [0, 1, 2, 3, 4, 5]),
          equals([
            'unknownPerformanceText',
            'lyrics',
            'lyricsLanguage',
            'ruby',
            'rubyLanguage',
            null,
          ]),
        );
      });

      test('returns null for reserved banks', () {
        expect(names(0x03, [0, 1]), equals([null, null]));
        expect(names(0xFF, [0]), equals([null]));
      });
    });
  });
}
