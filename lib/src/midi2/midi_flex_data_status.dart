// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// The status banks and statuses of flex data messages, UMP message type
/// 0xD (M2-104-UM 7.5, Table 11 and Table 16).
///
/// A flex data message is identified by its status bank and its status
/// within that bank; the same status value means different messages in
/// different banks. The banks 0x03 to 0xFF are reserved.
abstract final class MidiFlexDataStatus {
  // ...........................................................................
  // The status banks (M2-104-UM 7.5.1, Table 11).

  /// The bank of setup and performance events, without text events.
  static const int setupAndPerformanceBank = 0x00;

  /// The bank of metadata texts.
  static const int metadataTextBank = 0x01;

  /// The bank of performance text events, including lyrics.
  static const int performanceTextBank = 0x02;

  // ...........................................................................
  // The statuses of the setup and performance bank (M2-104-UM 7.5.3 to
  // 7.5.8).

  /// Set Tempo.
  static const int setTempo = 0x00;

  /// Set Time Signature.
  static const int setTimeSignature = 0x01;

  /// Set Metronome.
  static const int setMetronome = 0x02;

  /// Set Key Signature.
  static const int setKeySignature = 0x05;

  /// Set Chord Name.
  static const int setChordName = 0x06;

  // ...........................................................................
  // The statuses of the metadata text bank (M2-104-UM 7.5.9, Table 16).

  /// Unknown Metadata Text event.
  static const int unknownMetadataText = 0x00;

  /// Project Name, addressed to the group.
  static const int projectName = 0x01;

  /// Composition (Song) Name.
  static const int compositionName = 0x02;

  /// MIDI Clip Name, addressed to the group.
  static const int midiClipName = 0x03;

  /// Copyright Notice.
  static const int copyrightNotice = 0x04;

  /// Composer Name.
  static const int composerName = 0x05;

  /// Lyricist Name.
  static const int lyricistName = 0x06;

  /// Arranger Name.
  static const int arrangerName = 0x07;

  /// Publisher Name.
  static const int publisherName = 0x08;

  /// Primary Performer Name.
  static const int primaryPerformerName = 0x09;

  /// Accompanying Performer Name.
  static const int accompanyingPerformerName = 0x0A;

  /// Recording/Concert Date, an ISO 8601 date with optional time.
  static const int recordingConcertDate = 0x0B;

  /// Recording/Concert Location.
  static const int recordingConcertLocation = 0x0C;

  // ...........................................................................
  // The statuses of the performance text bank (M2-104-UM 7.5.9 to 7.5.13).

  /// Unknown Performance Text event.
  static const int unknownPerformanceText = 0x00;

  /// Lyrics: one syllable per message.
  static const int lyrics = 0x01;

  /// Lyrics Language, a BCP 47 language tag.
  static const int lyricsLanguage = 0x02;

  /// Ruby: the ruby characters of lyrics, one syllable per message.
  static const int ruby = 0x03;

  /// Ruby Language, a BCP 47 language tag.
  static const int rubyLanguage = 0x04;

  // ...........................................................................
  /// Returns whether messages of [statusBank] carry UTF-8 text in the text
  /// messages common format (M2-104-UM 7.5.9).
  static bool isText(int statusBank) =>
      statusBank == metadataTextBank || statusBank == performanceTextBank;

  /// Returns the name of the constant for [status] in [statusBank], e.g.
  /// `'lyrics'` for status 0x01 in bank 0x02, or null for a reserved
  /// combination.
  static String? name({required int statusBank, required int status}) =>
      switch (statusBank) {
        setupAndPerformanceBank => _setupAndPerformanceNames[status],
        metadataTextBank => _metadataTextNames[status],
        performanceTextBank => _performanceTextNames[status],
        _ => null,
      };

  // ...........................................................................
  /// The names of the statuses of the setup and performance bank.
  static const Map<int, String> _setupAndPerformanceNames = {
    setTempo: 'setTempo',
    setTimeSignature: 'setTimeSignature',
    setMetronome: 'setMetronome',
    setKeySignature: 'setKeySignature',
    setChordName: 'setChordName',
  };

  /// The names of the statuses of the metadata text bank.
  static const Map<int, String> _metadataTextNames = {
    unknownMetadataText: 'unknownMetadataText',
    projectName: 'projectName',
    compositionName: 'compositionName',
    midiClipName: 'midiClipName',
    copyrightNotice: 'copyrightNotice',
    composerName: 'composerName',
    lyricistName: 'lyricistName',
    arrangerName: 'arrangerName',
    publisherName: 'publisherName',
    primaryPerformerName: 'primaryPerformerName',
    accompanyingPerformerName: 'accompanyingPerformerName',
    recordingConcertDate: 'recordingConcertDate',
    recordingConcertLocation: 'recordingConcertLocation',
  };

  /// The names of the statuses of the performance text bank.
  static const Map<int, String> _performanceTextNames = {
    unknownPerformanceText: 'unknownPerformanceText',
    lyrics: 'lyrics',
    lyricsLanguage: 'lyricsLanguage',
    ruby: 'ruby',
    rubyLanguage: 'rubyLanguage',
  };
}
