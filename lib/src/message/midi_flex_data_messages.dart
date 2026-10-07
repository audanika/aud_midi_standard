// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

part of 'midi_message.dart';

// #############################################################################
/// The base of the flex data messages, UMP message type 0xD
/// (M2-104-UM 7.5).
///
/// A flex data message addresses either one channel of a group or the
/// whole group. It has no MIDI 1.0 byte form.
sealed class MidiFlexDataMessage extends MidiMessage {
  /// Creates a flex data message for [channel], or for the whole group
  /// when [channel] is null.
  const MidiFlexDataMessage({this.channel})
    : assert(channel == null || (channel >= 0 && channel <= 15));

  // ...........................................................................
  /// The channel 0 to 15, or null when the message addresses the group.
  final int? channel;

  /// The status bank of the message (M2-104-UM Table 11).
  int get statusBank;

  /// The status of the message within its status bank.
  int get status;

  @override
  UmpMessageType get umpMessageType => UmpMessageType.flexData;
}

// #############################################################################
/// A Set Tempo message, status bank 0x00, status 0x00 (M2-104-UM 7.5.3).
///
/// It always addresses the whole group.
final class MidiSetTempo extends MidiFlexDataMessage {
  /// Creates a tempo of [tenNanosecondsPerQuarterNote].
  const MidiSetTempo({required this.tenNanosecondsPerQuarterNote})
    : assert(
        tenNanosecondsPerQuarterNote >= 0 &&
            tenNanosecondsPerQuarterNote <= 0xFFFFFFFF,
      ),
      super(channel: null);

  // ...........................................................................
  /// Creates the tempo of [beatsPerMinute] quarter notes per minute.
  factory MidiSetTempo.fromBeatsPerMinute(double beatsPerMinute) =>
      MidiSetTempo(
        tenNanosecondsPerQuarterNote: (6e9 / beatsPerMinute).round(),
      );

  // ...........................................................................
  /// The duration of a quarter note in units of 10 nanoseconds.
  final int tenNanosecondsPerQuarterNote;

  /// The tempo in quarter notes per minute.
  double get beatsPerMinute => 6e9 / tenNanosecondsPerQuarterNote;

  @override
  int get statusBank => 0x00;

  @override
  int get status => 0x00;

  @override
  Map<String, Object?> get _fields => {
    'tenNanosecondsPerQuarterNote': tenNanosecondsPerQuarterNote,
  };
}

// #############################################################################
/// A Set Time Signature message, status bank 0x00, status 0x01
/// (M2-104-UM 7.5.4).
///
/// It always addresses the whole group.
final class MidiSetTimeSignature extends MidiFlexDataMessage {
  /// Creates a time signature of [numerator] beats of the note value
  /// 2^-[denominator].
  const MidiSetTimeSignature({
    required this.numerator,
    required this.denominator,
    this.numberOf32ndNotes = 8,
  }) : assert(numerator >= 0 && numerator <= 0xFF),
       assert(denominator >= 0 && denominator <= 0xFF),
       assert(numberOf32ndNotes >= 0 && numberOf32ndNotes <= 0xFF),
       super(channel: null);

  // ...........................................................................
  /// The number of beats in a bar.
  final int numerator;

  /// The beat as a negative power of two: 2 is a quarter note, 3 an eighth
  /// note; 0 means a non-standard denominator.
  final int denominator;

  /// The number of 1/32 notes in 24 MIDI clocks.
  final int numberOf32ndNotes;

  @override
  int get statusBank => 0x00;

  @override
  int get status => 0x01;

  @override
  Map<String, Object?> get _fields => {
    'numerator': numerator,
    'denominator': denominator,
    'numberOf32ndNotes': numberOf32ndNotes,
  };
}

// #############################################################################
/// A Set Metronome message, status bank 0x00, status 0x02
/// (M2-104-UM 7.5.5).
///
/// It always addresses the whole group.
final class MidiSetMetronome extends MidiFlexDataMessage {
  /// Creates a metronome setting.
  const MidiSetMetronome({
    required this.clocksPerPrimaryClick,
    required this.barAccent1,
    this.barAccent2 = 0,
    this.barAccent3 = 0,
    this.subdivisionClicks1 = 0,
    this.subdivisionClicks2 = 0,
  }) : assert(clocksPerPrimaryClick >= 0 && clocksPerPrimaryClick <= 0xFF),
       assert(barAccent1 >= 0 && barAccent1 <= 0xFF),
       assert(barAccent2 >= 0 && barAccent2 <= 0xFF),
       assert(barAccent3 >= 0 && barAccent3 <= 0xFF),
       assert(subdivisionClicks1 >= 0 && subdivisionClicks1 <= 0xFF),
       assert(subdivisionClicks2 >= 0 && subdivisionClicks2 <= 0xFF),
       super(channel: null);

  // ...........................................................................
  /// The number of MIDI clocks per primary click.
  final int clocksPerPrimaryClick;

  /// The first part of the bar for accents.
  final int barAccent1;

  /// The second part of the bar for accents, 0 if unused.
  final int barAccent2;

  /// The third part of the bar for accents, 0 if unused.
  final int barAccent3;

  /// The number of subdivision clicks per primary click, 0 if unused.
  final int subdivisionClicks1;

  /// A second, overlapping number of subdivision clicks, 0 if unused.
  final int subdivisionClicks2;

  @override
  int get statusBank => 0x00;

  @override
  int get status => 0x02;

  @override
  Map<String, Object?> get _fields => {
    'clocksPerPrimaryClick': clocksPerPrimaryClick,
    'barAccent1': barAccent1,
    'barAccent2': barAccent2,
    'barAccent3': barAccent3,
    'subdivisionClicks1': subdivisionClicks1,
    'subdivisionClicks2': subdivisionClicks2,
  };
}

// #############################################################################
/// A Set Key Signature message, status bank 0x00, status 0x05
/// (M2-104-UM 7.5.7).
final class MidiSetKeySignature extends MidiFlexDataMessage {
  /// Creates a key signature with [sharpsFlats] and [tonicNote].
  const MidiSetKeySignature({
    super.channel,
    required this.sharpsFlats,
    required this.tonicNote,
  }) : assert(sharpsFlats >= -8 && sharpsFlats <= 7),
       assert(tonicNote >= 0 && tonicNote <= 15);

  // ...........................................................................
  /// The number of sharps (positive) or flats (negative); -8 means unknown
  /// or non-standard.
  final int sharpsFlats;

  /// The tonic note: 0 unknown, 1 = A to 7 = G.
  final int tonicNote;

  @override
  int get statusBank => 0x00;

  @override
  int get status => 0x05;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'sharpsFlats': sharpsFlats,
    'tonicNote': tonicNote,
  };
}

// #############################################################################
/// One alteration of a chord: an alteration type and a degree
/// (M2-104-UM 7.5.8).
final class MidiChordAlteration {
  /// Creates an alteration of [type] applied to [degree].
  const MidiChordAlteration({required this.type, required this.degree})
    : assert(type >= 0 && type <= 15),
      assert(degree >= 0 && degree <= 15);

  // ...........................................................................
  /// The alteration type: 0 none, 1 add, 2 subtract, 3 raise, 4 lower.
  final int type;

  /// The altered degree of the chord, 1 for the root, 3 for the third.
  final int degree;

  // ...........................................................................
  @override
  bool operator ==(Object other) =>
      other is MidiChordAlteration &&
      other.type == type &&
      other.degree == degree;

  @override
  int get hashCode => Object.hash(type, degree);

  @override
  String toString() => 'MidiChordAlteration(type: $type, degree: $degree)';
}

// #############################################################################
/// A Set Chord Name message, status bank 0x00, status 0x06
/// (M2-104-UM 7.5.8).
final class MidiSetChordName extends MidiFlexDataMessage {
  /// Creates a chord name with an optional bass note and bass chord; the
  /// alterations are copied.
  MidiSetChordName({
    super.channel,
    required this.tonicSharpsFlats,
    required this.chordTonic,
    required this.chordType,
    List<MidiChordAlteration> alterations = const [],
    this.bassSharpsFlats = -8,
    this.bassNote = 0,
    this.bassChordType = 0,
    List<MidiChordAlteration> bassAlterations = const [],
  }) : alterations = List.unmodifiable(alterations),
       bassAlterations = List.unmodifiable(bassAlterations),
       assert(tonicSharpsFlats >= -8 && tonicSharpsFlats <= 7),
       assert(chordTonic >= 0 && chordTonic <= 15),
       assert(chordType >= 0 && chordType <= 0xFF),
       assert(alterations.length <= 4),
       assert(bassSharpsFlats >= -8 && bassSharpsFlats <= 7),
       assert(bassNote >= 0 && bassNote <= 15),
       assert(bassChordType >= 0 && bassChordType <= 0xFF),
       assert(bassAlterations.length <= 2);

  // ...........................................................................
  /// The sharps (positive) or flats (negative) applied to the tonic.
  final int tonicSharpsFlats;

  /// The tonic note of the chord: 0 unknown or no chord, 1 = A to 7 = G.
  final int chordTonic;

  /// The chord type, e.g. 0x01 major, 0x07 minor (M2-104-UM Table 14).
  final int chordType;

  /// Up to four alterations of the chord; cannot be modified.
  final List<MidiChordAlteration> alterations;

  /// The sharps or flats of the bass note; -8 means the bass note is the
  /// chord tonic.
  final int bassSharpsFlats;

  /// The bass note: 0 the chord tonic, 1 = A to 7 = G.
  final int bassNote;

  /// The type of the bass chord, 0 for none.
  final int bassChordType;

  /// Up to two alterations of the bass chord; cannot be modified.
  final List<MidiChordAlteration> bassAlterations;

  @override
  int get statusBank => 0x00;

  @override
  int get status => 0x06;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'tonicSharpsFlats': tonicSharpsFlats,
    'chordTonic': chordTonic,
    'chordType': chordType,
    'alterations': alterations,
    'bassSharpsFlats': bassSharpsFlats,
    'bassNote': bassNote,
    'bassChordType': bassChordType,
    'bassAlterations': bassAlterations,
  };
}

// #############################################################################
/// A text message of the metadata text (0x01) or performance text (0x02)
/// status bank, e.g. a song name or lyrics (M2-104-UM 7.5.9 to 7.5.13).
///
/// Long texts span several packets; the decoder reassembles them.
final class MidiFlexText extends MidiFlexDataMessage {
  /// Creates a text of [status] in [statusBank].
  const MidiFlexText({
    super.channel,
    required this.statusBank,
    required this.status,
    required this.text,
  }) : assert(statusBank == 0x01 || statusBank == 0x02),
       assert(status >= 0 && status <= 0xFF);

  // ...........................................................................
  /// The status bank for metadata texts.
  static const int metadataTextBank = 0x01;

  /// The status bank for performance text events.
  static const int performanceTextBank = 0x02;

  // ...........................................................................
  @override
  final int statusBank;

  @override
  final int status;

  /// The text, sent as UTF-8.
  final String text;

  @override
  Map<String, Object?> get _fields => {
    'channel': channel,
    'statusBank': statusBank,
    'status': status,
    'text': text,
  };
}
