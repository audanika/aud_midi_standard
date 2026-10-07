// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'midi_manufacturer_ids.dart';
import 'midi_universal_sys_ex.dart';

// #############################################################################
/// The tables of General MIDI: program and drum names, the percussion
/// channel, the GM2 bank numbers and the system messages that switch GM on
/// and off (General MIDI System Level 1, MMA; General MIDI 2, MMA RP-024).
///
/// Programs and channels are 0-based: program 0 is the Acoustic Grand
/// Piano that GM documents as program 1, channel 9 is MIDI channel 10.
abstract final class MidiGeneralMidi {
  // ...........................................................................
  /// The 0-based channel of the drums, MIDI channel 10.
  static const int percussionChannel = 9;

  /// The Bank Select MSB of the GM2 rhythm (drum) sets.
  static const int rhythmBankMsb = 0x78;

  /// The Bank Select MSB of the GM2 melodic sounds.
  static const int melodyBankMsb = 0x79;

  // ...........................................................................
  /// The SysEx data of General MIDI 1 System On, 7E 7F 09 01, without 0xF0
  /// and 0xF7.
  static const List<int> gm1SystemOn = [
    MidiManufacturerIds.universalNonRealTime,
    MidiUniversalSysEx.allCallDeviceId,
    MidiUniversalSysEx.generalMidi,
    MidiUniversalSysEx.generalMidi1SystemOn,
  ];

  /// The SysEx data of General MIDI System Off, 7E 7F 09 02, without 0xF0
  /// and 0xF7.
  static const List<int> gmSystemOff = [
    MidiManufacturerIds.universalNonRealTime,
    MidiUniversalSysEx.allCallDeviceId,
    MidiUniversalSysEx.generalMidi,
    MidiUniversalSysEx.generalMidiSystemOff,
  ];

  /// The SysEx data of General MIDI 2 System On, 7E 7F 09 03, without 0xF0
  /// and 0xF7.
  static const List<int> gm2SystemOn = [
    MidiManufacturerIds.universalNonRealTime,
    MidiUniversalSysEx.allCallDeviceId,
    MidiUniversalSysEx.generalMidi,
    MidiUniversalSysEx.generalMidi2SystemOn,
  ];

  // ...........................................................................
  /// The names of the 128 GM1 programs (GM1 Sound Set), indexed by the
  /// 0-based program number.
  static const List<String> programNames = [
    // Piano
    'Acoustic Grand Piano',
    'Bright Acoustic Piano',
    'Electric Grand Piano',
    'Honky-tonk Piano',
    'Electric Piano 1',
    'Electric Piano 2',
    'Harpsichord',
    'Clavi',
    // Chromatic Percussion
    'Celesta',
    'Glockenspiel',
    'Music Box',
    'Vibraphone',
    'Marimba',
    'Xylophone',
    'Tubular Bells',
    'Dulcimer',
    // Organ
    'Drawbar Organ',
    'Percussive Organ',
    'Rock Organ',
    'Church Organ',
    'Reed Organ',
    'Accordion',
    'Harmonica',
    'Tango Accordion',
    // Guitar
    'Acoustic Guitar (nylon)',
    'Acoustic Guitar (steel)',
    'Electric Guitar (jazz)',
    'Electric Guitar (clean)',
    'Electric Guitar (muted)',
    'Overdriven Guitar',
    'Distortion Guitar',
    'Guitar harmonics',
    // Bass
    'Acoustic Bass',
    'Electric Bass (finger)',
    'Electric Bass (pick)',
    'Fretless Bass',
    'Slap Bass 1',
    'Slap Bass 2',
    'Synth Bass 1',
    'Synth Bass 2',
    // Strings
    'Violin',
    'Viola',
    'Cello',
    'Contrabass',
    'Tremolo Strings',
    'Pizzicato Strings',
    'Orchestral Harp',
    'Timpani',
    // Ensemble
    'String Ensemble 1',
    'String Ensemble 2',
    'SynthStrings 1',
    'SynthStrings 2',
    'Choir Aahs',
    'Voice Oohs',
    'Synth Voice',
    'Orchestra Hit',
    // Brass
    'Trumpet',
    'Trombone',
    'Tuba',
    'Muted Trumpet',
    'French Horn',
    'Brass Section',
    'SynthBrass 1',
    'SynthBrass 2',
    // Reed
    'Soprano Sax',
    'Alto Sax',
    'Tenor Sax',
    'Baritone Sax',
    'Oboe',
    'English Horn',
    'Bassoon',
    'Clarinet',
    // Pipe
    'Piccolo',
    'Flute',
    'Recorder',
    'Pan Flute',
    'Blown Bottle',
    'Shakuhachi',
    'Whistle',
    'Ocarina',
    // Synth Lead
    'Lead 1 (square)',
    'Lead 2 (sawtooth)',
    'Lead 3 (calliope)',
    'Lead 4 (chiff)',
    'Lead 5 (charang)',
    'Lead 6 (voice)',
    'Lead 7 (fifths)',
    'Lead 8 (bass + lead)',
    // Synth Pad
    'Pad 1 (new age)',
    'Pad 2 (warm)',
    'Pad 3 (polysynth)',
    'Pad 4 (choir)',
    'Pad 5 (bowed)',
    'Pad 6 (metallic)',
    'Pad 7 (halo)',
    'Pad 8 (sweep)',
    // Synth Effects
    'FX 1 (rain)',
    'FX 2 (soundtrack)',
    'FX 3 (crystal)',
    'FX 4 (atmosphere)',
    'FX 5 (brightness)',
    'FX 6 (goblins)',
    'FX 7 (echoes)',
    'FX 8 (sci-fi)',
    // Ethnic
    'Sitar',
    'Banjo',
    'Shamisen',
    'Koto',
    'Kalimba',
    'Bag pipe',
    'Fiddle',
    'Shanai',
    // Percussive
    'Tinkle Bell',
    'Agogo',
    'Steel Drums',
    'Woodblock',
    'Taiko Drum',
    'Melodic Tom',
    'Synth Drum',
    'Reverse Cymbal',
    // Sound Effects
    'Guitar Fret Noise',
    'Breath Noise',
    'Seashore',
    'Bird Tweet',
    'Telephone Ring',
    'Helicopter',
    'Applause',
    'Gunshot',
  ];

  /// The names of the GM1 percussion keys 35 to 81 on the
  /// [percussionChannel] (GM1 Percussion Key Map).
  static const Map<int, String> gm1DrumNames = {
    35: 'Acoustic Bass Drum',
    36: 'Bass Drum 1',
    37: 'Side Stick',
    38: 'Acoustic Snare',
    39: 'Hand Clap',
    40: 'Electric Snare',
    41: 'Low Floor Tom',
    42: 'Closed Hi Hat',
    43: 'High Floor Tom',
    44: 'Pedal Hi-Hat',
    45: 'Low Tom',
    46: 'Open Hi-Hat',
    47: 'Low-Mid Tom',
    48: 'Hi-Mid Tom',
    49: 'Crash Cymbal 1',
    50: 'High Tom',
    51: 'Ride Cymbal 1',
    52: 'Chinese Cymbal',
    53: 'Ride Bell',
    54: 'Tambourine',
    55: 'Splash Cymbal',
    56: 'Cowbell',
    57: 'Crash Cymbal 2',
    58: 'Vibraslap',
    59: 'Ride Cymbal 2',
    60: 'Hi Bongo',
    61: 'Low Bongo',
    62: 'Mute Hi Conga',
    63: 'Open Hi Conga',
    64: 'Low Conga',
    65: 'High Timbale',
    66: 'Low Timbale',
    67: 'High Agogo',
    68: 'Low Agogo',
    69: 'Cabasa',
    70: 'Maracas',
    71: 'Short Whistle',
    72: 'Long Whistle',
    73: 'Short Guiro',
    74: 'Long Guiro',
    75: 'Claves',
    76: 'Hi Wood Block',
    77: 'Low Wood Block',
    78: 'Mute Cuica',
    79: 'Open Cuica',
    80: 'Mute Triangle',
    81: 'Open Triangle',
  };

  /// The names of the percussion keys GM2 adds below and above the GM1
  /// keys: 27 to 34 and 82 to 87 (GM2 Standard Drum Set).
  static const Map<int, String> gm2DrumAdditions = {
    27: 'High Q',
    28: 'Slap',
    29: 'Scratch Push',
    30: 'Scratch Pull',
    31: 'Sticks',
    32: 'Square Click',
    33: 'Metronome Click',
    34: 'Metronome Bell',
    82: 'Shaker',
    83: 'Jingle Bell',
    84: 'Belltree',
    85: 'Castanets',
    86: 'Mute Surdo',
    87: 'Open Surdo',
  };

  // ...........................................................................
  /// Returns the GM1 name of the 0-based [program].
  ///
  /// Throws a [RangeError] when [program] is outside 0 to 127.
  static String programName(int program) {
    RangeError.checkValueInInterval(program, 0, 127, 'program');
    return programNames[program];
  }

  /// Returns the name of the percussion [key], or null when the key has
  /// no drum.
  ///
  /// - [key] the note number on the [percussionChannel]
  /// - [gm2] whether the keys added by GM2 count as well
  static String? drumName(int key, {bool gm2 = true}) =>
      gm1DrumNames[key] ?? (gm2 ? gm2DrumAdditions[key] : null);
}
