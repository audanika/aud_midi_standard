// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:math';

// #############################################################################
/// The MIDI note numbers by note name, with C4 as note 60 (MIDI 1.0
/// Detailed Specification 4.2.1, Note Number), migrated from `gg_midi_vars`
/// with all names and values.
///
/// The names count octaves from -1 (`M1`, minus one) to 9; [c4] is middle C
/// and [a4] the tuning A of 440 Hz. Sharp and flat names exist next to the
/// natural ones, so enharmonic spellings like [eSharp4] and [f4] share a
/// number.
final class MidiNoteNumbers {
  /// Creates an instance; all members are static, the instance only serves
  /// where an object is expected, e.g. [midiNoteNumbersExample].
  MidiNoteNumbers();

  // ...........................................................................
  /// The highest MIDI note number.
  static const int max = 127;

  // ...........................................................................
  // The natural notes C-1 to G9.

  /// C-1, note number 0.
  static const int cM1 = 0;

  /// D-1, note number 2.
  static const int dM1 = 2;

  /// E-1, note number 4.
  static const int eM1 = 4;

  /// F-1, note number 5.
  static const int fM1 = 5;

  /// G-1, note number 7.
  static const int gM1 = 7;

  /// A-1, note number 9.
  static const int aM1 = 9;

  /// B-1, note number 11.
  static const int bM1 = 11;

  /// C0, note number 12.
  static const int c0 = 12;

  /// D0, note number 14.
  static const int d0 = 14;

  /// E0, note number 16.
  static const int e0 = 16;

  /// F0, note number 17.
  static const int f0 = 17;

  /// G0, note number 19.
  static const int g0 = 19;

  /// A0, note number 21.
  static const int a0 = 21;

  /// B0, note number 23.
  static const int b0 = 23;

  /// C1, note number 24.
  static const int c1 = 24;

  /// D1, note number 26.
  static const int d1 = 26;

  /// E1, note number 28.
  static const int e1 = 28;

  /// F1, note number 29.
  static const int f1 = 29;

  /// G1, note number 31.
  static const int g1 = 31;

  /// A1, note number 33.
  static const int a1 = 33;

  /// B1, note number 35.
  static const int b1 = 35;

  /// C2, note number 36.
  static const int c2 = 36;

  /// D2, note number 38.
  static const int d2 = 38;

  /// E2, note number 40.
  static const int e2 = 40;

  /// F2, note number 41.
  static const int f2 = 41;

  /// G2, note number 43.
  static const int g2 = 43;

  /// A2, note number 45.
  static const int a2 = 45;

  /// B2, note number 47.
  static const int b2 = 47;

  /// C3, note number 48.
  static const int c3 = 48;

  /// D3, note number 50.
  static const int d3 = 50;

  /// E3, note number 52.
  static const int e3 = 52;

  /// F3, note number 53.
  static const int f3 = 53;

  /// G3, note number 55.
  static const int g3 = 55;

  /// A3, note number 57.
  static const int a3 = 57;

  /// B3, note number 59.
  static const int b3 = 59;

  /// C4, note number 60.
  static const int c4 = 60;

  /// D4, note number 62.
  static const int d4 = 62;

  /// E4, note number 64.
  static const int e4 = 64;

  /// F4, note number 65.
  static const int f4 = 65;

  /// G4, note number 67.
  static const int g4 = 67;

  /// A4, note number 69.
  static const int a4 = 69;

  /// B4, note number 71.
  static const int b4 = 71;

  /// C5, note number 72.
  static const int c5 = 72;

  /// D5, note number 74.
  static const int d5 = 74;

  /// E5, note number 76.
  static const int e5 = 76;

  /// F5, note number 77.
  static const int f5 = 77;

  /// G5, note number 79.
  static const int g5 = 79;

  /// A5, note number 81.
  static const int a5 = 81;

  /// B5, note number 83.
  static const int b5 = 83;

  /// C6, note number 84.
  static const int c6 = 84;

  /// D6, note number 86.
  static const int d6 = 86;

  /// E6, note number 88.
  static const int e6 = 88;

  /// F6, note number 89.
  static const int f6 = 89;

  /// G6, note number 91.
  static const int g6 = 91;

  /// A6, note number 93.
  static const int a6 = 93;

  /// B6, note number 95.
  static const int b6 = 95;

  /// C7, note number 96.
  static const int c7 = 96;

  /// D7, note number 98.
  static const int d7 = 98;

  /// E7, note number 100.
  static const int e7 = 100;

  /// F7, note number 101.
  static const int f7 = 101;

  /// G7, note number 103.
  static const int g7 = 103;

  /// A7, note number 105.
  static const int a7 = 105;

  /// B7, note number 107.
  static const int b7 = 107;

  /// C8, note number 108.
  static const int c8 = 108;

  /// D8, note number 110.
  static const int d8 = 110;

  /// E8, note number 112.
  static const int e8 = 112;

  /// F8, note number 113.
  static const int f8 = 113;

  /// G8, note number 115.
  static const int g8 = 115;

  /// A8, note number 117.
  static const int a8 = 117;

  /// B8, note number 119.
  static const int b8 = 119;

  /// C9, note number 120.
  static const int c9 = 120;

  /// D9, note number 122.
  static const int d9 = 122;

  /// E9, note number 124.
  static const int e9 = 124;

  /// F9, note number 125.
  static const int f9 = 125;

  /// G9, note number 127.
  static const int g9 = 127;

  // ...........................................................................
  // The sharp notes D#-1 to G#9.

  /// D#-1, note number 3.
  static const int dSharpM1 = 3;

  /// E#-1, note number 5, the same key as F-1.
  static const int eSharpM1 = 5;

  /// F#-1, note number 6.
  static const int fSharpM1 = 6;

  /// G#-1, note number 8.
  static const int gSharpM1 = 8;

  /// A#-1, note number 10.
  static const int aSharpM1 = 10;

  /// B#-1, note number 12, the same key as C0.
  static const int bSharpM1 = 12;

  /// C#0, note number 13.
  static const int cSharp0 = 13;

  /// D#0, note number 15.
  static const int dSharp0 = 15;

  /// E#0, note number 17, the same key as F0.
  static const int eSharp0 = 17;

  /// F#0, note number 18.
  static const int fSharp0 = 18;

  /// G#0, note number 20.
  static const int gSharp0 = 20;

  /// A#0, note number 22.
  static const int aSharp0 = 22;

  /// B#0, note number 24, the same key as C1.
  static const int bSharp0 = 24;

  /// C#1, note number 25.
  static const int cSharp1 = 25;

  /// D#1, note number 27.
  static const int dSharp1 = 27;

  /// E#1, note number 29, the same key as F1.
  static const int eSharp1 = 29;

  /// F#1, note number 30.
  static const int fSharp1 = 30;

  /// G#1, note number 32.
  static const int gSharp1 = 32;

  /// A#1, note number 34.
  static const int aSharp1 = 34;

  /// B#1, note number 36, the same key as C2.
  static const int bSharp1 = 36;

  /// C#2, note number 37.
  static const int cSharp2 = 37;

  /// D#2, note number 39.
  static const int dSharp2 = 39;

  /// E#2, note number 41, the same key as F2.
  static const int eSharp2 = 41;

  /// F#2, note number 42.
  static const int fSharp2 = 42;

  /// G#2, note number 44.
  static const int gSharp2 = 44;

  /// A#2, note number 46.
  static const int aSharp2 = 46;

  /// B#2, note number 48, the same key as C3.
  static const int bSharp2 = 48;

  /// C#3, note number 49.
  static const int cSharp3 = 49;

  /// D#3, note number 51.
  static const int dSharp3 = 51;

  /// E#3, note number 53, the same key as F3.
  static const int eSharp3 = 53;

  /// F#3, note number 54.
  static const int fSharp3 = 54;

  /// G#3, note number 56.
  static const int gSharp3 = 56;

  /// A#3, note number 58.
  static const int aSharp3 = 58;

  /// B#3, note number 60, the same key as C4.
  static const int bSharp3 = 60;

  /// C#4, note number 61.
  static const int cSharp4 = 61;

  /// D#4, note number 63.
  static const int dSharp4 = 63;

  /// E#4, note number 65, the same key as F4.
  static const int eSharp4 = 65;

  /// F#4, note number 66.
  static const int fSharp4 = 66;

  /// G#4, note number 68.
  static const int gSharp4 = 68;

  /// A#4, note number 70.
  static const int aSharp4 = 70;

  /// B#4, note number 72, the same key as C5.
  static const int bSharp4 = 72;

  /// C#5, note number 73.
  static const int cSharp5 = 73;

  /// D#5, note number 75.
  static const int dSharp5 = 75;

  /// E#5, note number 77, the same key as F5.
  static const int eSharp5 = 77;

  /// F#5, note number 78.
  static const int fSharp5 = 78;

  /// G#5, note number 80.
  static const int gSharp5 = 80;

  /// A#5, note number 82.
  static const int aSharp5 = 82;

  /// B#5, note number 84, the same key as C6.
  static const int bSharp5 = 84;

  /// C#6, note number 85.
  static const int cSharp6 = 85;

  /// D#6, note number 87.
  static const int dSharp6 = 87;

  /// E#6, note number 89, the same key as F6.
  static const int eSharp6 = 89;

  /// F#6, note number 90.
  static const int fSharp6 = 90;

  /// G#6, note number 92.
  static const int gSharp6 = 92;

  /// A#6, note number 94.
  static const int aSharp6 = 94;

  /// B#6, note number 96, the same key as C7.
  static const int bSharp6 = 96;

  /// C#7, note number 97.
  static const int cSharp7 = 97;

  /// D#7, note number 99.
  static const int dSharp7 = 99;

  /// E#7, note number 101, the same key as F7.
  static const int eSharp7 = 101;

  /// F#7, note number 102.
  static const int fSharp7 = 102;

  /// G#7, note number 104.
  static const int gSharp7 = 104;

  /// A#7, note number 106.
  static const int aSharp7 = 106;

  /// B#7, note number 108, the same key as C8.
  static const int bSharp7 = 108;

  /// C#8, note number 109.
  static const int cSharp8 = 109;

  /// D#8, note number 111.
  static const int dSharp8 = 111;

  /// E#8, note number 113, the same key as F8.
  static const int eSharp8 = 113;

  /// F#8, note number 114.
  static const int fSharp8 = 114;

  /// G#8, note number 116.
  static const int gSharp8 = 116;

  /// A#8, note number 118.
  static const int aSharp8 = 118;

  /// B#8, note number 120, the same key as C9.
  static const int bSharp8 = 120;

  /// C#9, note number 121.
  static const int cSharp9 = 121;

  /// D#9, note number 123.
  static const int dSharp9 = 123;

  /// E#9, note number 125, the same key as F9.
  static const int eSharp9 = 125;

  /// F#9, note number 126.
  static const int fSharp9 = 126;

  /// G#9, note number 128, one above the MIDI range of 0 to 127.
  static const int gSharp9 = 128;

  // ...........................................................................
  // The flat notes Db-1 to Gb9.

  /// Db-1, note number 1.
  static const int dFlatM1 = 1;

  /// Eb-1, note number 3.
  static const int eFlatM1 = 3;

  /// Fb-1, note number 4, the same key as E-1.
  static const int fFlatM1 = 4;

  /// Gb-1, note number 6.
  static const int gFlatM1 = 6;

  /// Ab-1, note number 8.
  static const int aFlatM1 = 8;

  /// Bb-1, note number 10.
  static const int bFlatM1 = 10;

  /// Cb0, note number 11, the same key as B-1.
  static const int cFlat0 = 11;

  /// Db0, note number 13.
  static const int dFlat0 = 13;

  /// Eb0, note number 15.
  static const int eFlat0 = 15;

  /// Fb0, note number 16, the same key as E0.
  static const int fFlat0 = 16;

  /// Gb0, note number 18.
  static const int gFlat0 = 18;

  /// Ab0, note number 20.
  static const int aFlat0 = 20;

  /// Bb0, note number 22.
  static const int bFlat0 = 22;

  /// Cb1, note number 23, the same key as B0.
  static const int cFlat1 = 23;

  /// Db1, note number 25.
  static const int dFlat1 = 25;

  /// Eb1, note number 27.
  static const int eFlat1 = 27;

  /// Fb1, note number 28, the same key as E1.
  static const int fFlat1 = 28;

  /// Gb1, note number 30.
  static const int gFlat1 = 30;

  /// Ab1, note number 32.
  static const int aFlat1 = 32;

  /// Bb1, note number 34.
  static const int bFlat1 = 34;

  /// Cb2, note number 35, the same key as B1.
  static const int cFlat2 = 35;

  /// Db2, note number 37.
  static const int dFlat2 = 37;

  /// Eb2, note number 39.
  static const int eFlat2 = 39;

  /// Fb2, note number 40, the same key as E2.
  static const int fFlat2 = 40;

  /// Gb2, note number 42.
  static const int gFlat2 = 42;

  /// Ab2, note number 44.
  static const int aFlat2 = 44;

  /// Bb2, note number 46.
  static const int bFlat2 = 46;

  /// Cb3, note number 47, the same key as B2.
  static const int cFlat3 = 47;

  /// Db3, note number 49.
  static const int dFlat3 = 49;

  /// Eb3, note number 51.
  static const int eFlat3 = 51;

  /// Fb3, note number 52, the same key as E3.
  static const int fFlat3 = 52;

  /// Gb3, note number 54.
  static const int gFlat3 = 54;

  /// Ab3, note number 56.
  static const int aFlat3 = 56;

  /// Bb3, note number 58.
  static const int bFlat3 = 58;

  /// Cb4, note number 59, the same key as B3.
  static const int cFlat4 = 59;

  /// Db4, note number 61.
  static const int dFlat4 = 61;

  /// Eb4, note number 63.
  static const int eFlat4 = 63;

  /// Fb4, note number 64, the same key as E4.
  static const int fFlat4 = 64;

  /// Gb4, note number 66.
  static const int gFlat4 = 66;

  /// Ab4, note number 68.
  static const int aFlat4 = 68;

  /// Bb4, note number 70.
  static const int bFlat4 = 70;

  /// Cb5, note number 71, the same key as B4.
  static const int cFlat5 = 71;

  /// Db5, note number 73.
  static const int dFlat5 = 73;

  /// Eb5, note number 75.
  static const int eFlat5 = 75;

  /// Fb5, note number 76, the same key as E5.
  static const int fFlat5 = 76;

  /// Gb5, note number 78.
  static const int gFlat5 = 78;

  /// Ab5, note number 80.
  static const int aFlat5 = 80;

  /// Bb5, note number 82.
  static const int bFlat5 = 82;

  /// Cb6, note number 83, the same key as B5.
  static const int cFlat6 = 83;

  /// Db6, note number 85.
  static const int dFlat6 = 85;

  /// Eb6, note number 87.
  static const int eFlat6 = 87;

  /// Fb6, note number 88, the same key as E6.
  static const int fFlat6 = 88;

  /// Gb6, note number 90.
  static const int gFlat6 = 90;

  /// Ab6, note number 92.
  static const int aFlat6 = 92;

  /// Bb6, note number 94.
  static const int bFlat6 = 94;

  /// Cb7, note number 95, the same key as B6.
  static const int cFlat7 = 95;

  /// Db7, note number 97.
  static const int dFlat7 = 97;

  /// Eb7, note number 99.
  static const int eFlat7 = 99;

  /// Fb7, note number 100, the same key as E7.
  static const int fFlat7 = 100;

  /// Gb7, note number 102.
  static const int gFlat7 = 102;

  /// Ab7, note number 104.
  static const int aFlat7 = 104;

  /// Bb7, note number 106.
  static const int bFlat7 = 106;

  /// Cb8, note number 107, the same key as B7.
  static const int cFlat8 = 107;

  /// Db8, note number 109.
  static const int dFlat8 = 109;

  /// Eb8, note number 111.
  static const int eFlat8 = 111;

  /// Fb8, note number 112, the same key as E8.
  static const int fFlat8 = 112;

  /// Gb8, note number 114.
  static const int gFlat8 = 114;

  /// Ab8, note number 116.
  static const int aFlat8 = 116;

  /// Bb8, note number 118.
  static const int bFlat8 = 118;

  /// Cb9, note number 119, the same key as B8.
  static const int cFlat9 = 119;

  /// Db9, note number 121.
  static const int dFlat9 = 121;

  /// Eb9, note number 123.
  static const int eFlat9 = 123;

  /// Fb9, note number 124, the same key as E9.
  static const int fFlat9 = 124;

  /// Gb9, note number 126.
  static const int gFlat9 = 126;

  // ...........................................................................
  /// The note numbers of the G minor scale from C0 to C9: the white keys
  /// with E flat and B flat.
  static const List<int> gMinor = <int>[
    // Octave 0
    c0,
    d0,
    eFlat0,
    f0,
    g0,
    a0,
    bFlat0,

    // Octave 1
    c1,
    d1,
    eFlat1,
    f1,
    g1,
    a1,
    bFlat1,

    // Octave 2
    c2,
    d2,
    eFlat2,
    f2,
    g2,
    a2,
    bFlat2,

    // Octave 3
    c3,
    d3,
    eFlat3,
    f3,
    g3,
    a3,
    bFlat3,

    // Octave 4
    c4,
    d4,
    eFlat4,
    f4,
    g4,
    a4,
    bFlat4,

    // Octave 5
    c5,
    d5,
    eFlat5,
    f5,
    g5,
    a5,
    bFlat5,

    // Octave 6
    c6,
    d6,
    eFlat6,
    f6,
    g6,
    a6,
    bFlat6,

    // Octave 7
    c7,
    d7,
    eFlat7,
    f7,
    g7,
    a7,
    bFlat7,

    // Octave 8
    c8,
    d8,
    eFlat8,
    f8,
    g8,
    a8,
    bFlat8,

    // Octave 9
    c9,
  ];

  /// The note numbers of the C major scale from C0 to C9.
  static const List<int> cMajor = <int>[
    // Octave 0
    c0,
    d0,
    e0,
    f0,
    g0,
    a0,
    b0,

    // Octave 1
    c1,
    d1,
    e1,
    f1,
    g1,
    a1,
    b1,

    // Octave 2
    c2,
    d2,
    e2,
    f2,
    g2,
    a2,
    b2,

    // Octave 3
    c3,
    d3,
    e3,
    f3,
    g3,
    a3,
    b3,

    // Octave 4
    c4,
    d4,
    e4,
    f4,
    g4,
    a4,
    b4,

    // Octave 5
    c5,
    d5,
    e5,
    f5,
    g5,
    a5,
    b5,

    // Octave 6
    c6,
    d6,
    e6,
    f6,
    g6,
    a6,
    b6,

    // Octave 7
    c7,
    d7,
    e7,
    f7,
    g7,
    a7,
    b7,

    // Octave 8
    c8,
    d8,
    e8,
    f8,
    g8,
    a8,
    b8,

    // Octave 9
    c9,
  ];

  /// The note numbers of the C sharp major scale from C#0 to C#9.
  static const List<int> cSharpMajor = <int>[
    // Octave 0
    cSharp0,
    dSharp0,
    eSharp0,
    fSharp0,
    gSharp0,
    aSharp0,
    bSharp0,

    // Octave 1
    cSharp1,
    dSharp1,
    eSharp1,
    fSharp1,
    gSharp1,
    aSharp1,
    bSharp1,

    // Octave 2
    cSharp2,
    dSharp2,
    eSharp2,
    fSharp2,
    gSharp2,
    aSharp2,
    bSharp2,

    // Octave 3
    cSharp3,
    dSharp3,
    eSharp3,
    fSharp3,
    gSharp3,
    aSharp3,
    bSharp3,

    // Octave 4
    cSharp4,
    dSharp4,
    eSharp4,
    fSharp4,
    gSharp4,
    aSharp4,
    bSharp4,

    // Octave 5
    cSharp5,
    dSharp5,
    eSharp5,
    fSharp5,
    gSharp5,
    aSharp5,
    bSharp5,

    // Octave 6
    cSharp6,
    dSharp6,
    eSharp6,
    fSharp6,
    gSharp6,
    aSharp6,
    bSharp6,

    // Octave 7
    cSharp7,
    dSharp7,
    eSharp7,
    fSharp7,
    gSharp7,
    aSharp7,
    bSharp7,

    // Octave 8
    cSharp8,
    dSharp8,
    eSharp8,
    fSharp8,
    gSharp8,
    aSharp8,
    bSharp8,

    // Octave 9
    cSharp9,
  ];

  /// The note numbers of the C flat major scale from Cb0 to Cb9.
  static const List<int> cFlatMajor = <int>[
    // Octave 0
    cFlat0,
    dFlat0,
    eFlat0,
    fFlat0,
    gFlat0,
    aFlat0,
    bFlat0,

    // Octave 1
    cFlat1,
    dFlat1,
    eFlat1,
    fFlat1,
    gFlat1,
    aFlat1,
    bFlat1,

    // Octave 2
    cFlat2,
    dFlat2,
    eFlat2,
    fFlat2,
    gFlat2,
    aFlat2,
    bFlat2,

    // Octave 3
    cFlat3,
    dFlat3,
    eFlat3,
    fFlat3,
    gFlat3,
    aFlat3,
    bFlat3,

    // Octave 4
    cFlat4,
    dFlat4,
    eFlat4,
    fFlat4,
    gFlat4,
    aFlat4,
    bFlat4,

    // Octave 5
    cFlat5,
    dFlat5,
    eFlat5,
    fFlat5,
    gFlat5,
    aFlat5,
    bFlat5,

    // Octave 6
    cFlat6,
    dFlat6,
    eFlat6,
    fFlat6,
    gFlat6,
    aFlat6,
    bFlat6,

    // Octave 7
    cFlat7,
    dFlat7,
    eFlat7,
    fFlat7,
    gFlat7,
    aFlat7,
    bFlat7,

    // Octave 8
    cFlat8,
    dFlat8,
    eFlat8,
    fFlat8,
    gFlat8,
    aFlat8,
    bFlat8,

    // Octave 9
    cFlat9,
  ];

  // ...........................................................................
  /// Returns the name of [note] with its octave, e.g. `'C4'` for 60 and
  /// `'C#4'` or, with [sharps] false, `'Db4'` for 61.
  ///
  /// - [note] the note number 0 to 127
  /// - [sharps] whether black keys are named as sharps or as flats
  ///
  /// Throws a [RangeError] when [note] is outside 0 to 127.
  static String name(int note, {bool sharps = true}) {
    RangeError.checkValueInInterval(note, 0, max, 'note');
    final names = sharps ? _sharpNames : _flatNames;
    return '${names[note % 12]}${note ~/ 12 - 1}';
  }

  /// Returns the frequency of [note] in Hz in twelve-tone equal temperament.
  ///
  /// - [note] the note number; fractions address pitches between the keys
  /// - [a4] the frequency of A4, note 69, in Hz
  static double frequency(num note, {double a4 = 440}) =>
      a4 * pow(2, (note - MidiNoteNumbers.a4) / 12);

  // ...........................................................................
  /// The names of the twelve pitch classes with sharps.
  static const List<String> _sharpNames = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];

  /// The names of the twelve pitch classes with flats.
  static const List<String> _flatNames = [
    'C',
    'Db',
    'D',
    'Eb',
    'E',
    'F',
    'Gb',
    'G',
    'Ab',
    'A',
    'Bb',
    'B',
  ];
}

// #############################################################################
/// Returns an example instance of [MidiNoteNumbers], kept from gg_midi_vars.
MidiNoteNumbers get midiNoteNumbersExample => MidiNoteNumbers();
