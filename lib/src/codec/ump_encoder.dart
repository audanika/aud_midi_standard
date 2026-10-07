// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:convert';
import 'dart:math';

import '../message/midi_message.dart';
import '../raw/ump.dart';
import 'midi_byte_encoder.dart';

// #############################################################################
/// Encodes messages as Universal MIDI Packets (M2-104-UM 7 and Appendix F).
///
/// Every field keeps only the bits of its width and reserved bits are zero.
/// Messages that span several packets are split as follows:
///
/// - System Exclusive: 6 data bytes per packet (M2-104-UM 7.7).
/// - System Exclusive 8: 13 data bytes per packet after the stream id
///   (M2-104-UM 7.8).
/// - Mixed Data Set: chunks of up to 4094 payload packets with 14 data
///   bytes each; the header of a chunk counts the valid bytes of all its
///   packets, its own 16 bytes and the two leading bytes of every payload
///   packet included, without the zero padding of the last payload packet
///   (M2-104-UM 7.9). An empty set is one chunk without payload packets.
/// - Flex data texts: 12 UTF-8 bytes per packet (M2-104-UM 7.5.9).
/// - Endpoint names and product instance ids: 14 bytes per packet, up to
///   98 and 42 bytes; function block names: 13 bytes per packet, up to 91
///   bytes. Longer UTF-8 texts are cut at the last whole character within
///   the limit (M2-104-UM 7.1.4, 7.1.5 and 7.1.9).
abstract final class UmpEncoder {
  // ...........................................................................
  /// Encodes [message] addressed to [group]; groupless messages ignore
  /// [group]. Long System Exclusive, Mixed Data Set, text and name messages
  /// span several packets. A [MidiUnknownMessage] returns its packets
  /// unchanged.
  static List<Ump> encode(MidiMessage message, {int group = 0}) {
    final g = group & 0xF;
    return switch (message) {
      MidiUtilityMessage() => [_utility(message)],
      MidiSystemMessage() => [_short(0x1, g, message)],
      MidiChannelVoice1Message() => [_short(0x2, g, message)],
      MidiSysEx() => _sysEx7(message, g),
      MidiChannelVoice2Message() => [_channelVoice2(message, g)],
      MidiSysEx8() => _sysEx8(message, g),
      MidiMixedDataSet() => _mixedDataSet(message, g),
      MidiFlexDataMessage() => _flexData(message, g),
      MidiStreamMessage() => _stream(message),
      MidiUnknownMessage() => [...message.umps],
    };
  }

  // ...........................................................................
  /// The largest number of payload bytes in a Mixed Data Set chunk.
  static const int _mdsChunkSize = 4094 * 14;

  // ...........................................................................
  /// Returns the utility [message] (M2-104-UM 7.2).
  static Ump _utility(MidiUtilityMessage message) => Ump([
    switch (message) {
      MidiNoop() => 0x00000000,
      MidiJrClock(:final time) => 0x00100000 | time & 0xFFFF,
      MidiJrTimestamp(:final time) => 0x00200000 | time & 0xFFFF,
      MidiDeltaClockstampTicksPerQuarterNote(:final ticksPerQuarterNote) =>
        0x00300000 | ticksPerQuarterNote & 0xFFFF,
      MidiDeltaClockstamp(:final ticks) => 0x00400000 | ticks & 0xFFFFF,
    },
  ]);

  /// Returns the system or MIDI 1.0 channel voice [message] of message
  /// type [type], which carries the MIDI 1.0 bytes (M2-104-UM 7.3, 7.6).
  static Ump _short(int type, int group, MidiMessage message) {
    final bytes = MidiByteEncoder.encode(message)!.bytes;
    return _packet([type << 4 | group, ...bytes], 1);
  }

  // ...........................................................................
  /// Returns the MIDI 2.0 channel voice [message] (M2-104-UM 7.4).
  static Ump _channelVoice2(MidiChannelVoice2Message message, int group) {
    final (opcode, index, data) = switch (message) {
      MidiRegisteredPerNoteController(
        :final note,
        :final index,
        :final value,
      ) =>
        (0x0, _note(note) | index & 0xFF, value),
      MidiAssignablePerNoteController(
        :final note,
        :final index,
        :final value,
      ) =>
        (0x1, _note(note) | index & 0xFF, value),
      MidiRegisteredController(:final bank, :final index, :final value) => (
        0x2,
        _bankIndex(bank, index),
        value,
      ),
      MidiAssignableController(:final bank, :final index, :final value) => (
        0x3,
        _bankIndex(bank, index),
        value,
      ),
      MidiRelativeRegisteredController(
        :final bank,
        :final index,
        :final value,
      ) =>
        (0x4, _bankIndex(bank, index), value),
      MidiRelativeAssignableController(
        :final bank,
        :final index,
        :final value,
      ) =>
        (0x5, _bankIndex(bank, index), value),
      MidiPerNotePitchBend(:final note, :final value) => (
        0x6,
        _note(note),
        value,
      ),
      MidiNoteOff2(
        :final note,
        :final velocity,
        :final attributeType,
        :final attribute,
      ) ||
      MidiNoteOn2(
        :final note,
        :final velocity,
        :final attributeType,
        :final attribute,
      ) => (
        message is MidiNoteOn2 ? 0x9 : 0x8,
        _note(note) | attributeType & 0xFF,
        (velocity & 0xFFFF) << 16 | attribute & 0xFFFF,
      ),
      MidiPolyPressure2(:final note, :final pressure) => (
        0xA,
        _note(note),
        pressure,
      ),
      MidiControlChange2(:final controller, :final value) => (
        0xB,
        (controller & 0x7F) << 8,
        value,
      ),
      MidiProgramChange2(:final program, :final bank) => (
        0xC,
        bank == null ? 0 : 1,
        (program & 0x7F) << 24 | _bank(bank),
      ),
      MidiChannelPressure2(:final pressure) => (0xD, 0, pressure),
      MidiPitchBend2(:final value) => (0xE, 0, value),
      MidiPerNoteManagement(:final note, :final detach, :final reset) => (
        0xF,
        _note(note) | (detach ? 0x2 : 0) | (reset ? 0x1 : 0),
        0,
      ),
    };
    final channel = message.channel & 0xF;
    return Ump([
      0x4 << 28 | group << 24 | opcode << 20 | channel << 16 | index,
      data & 0xFFFFFFFF,
    ]);
  }

  /// Returns the note field of the index of a MIDI 2.0 message.
  static int _note(int note) => (note & 0x7F) << 8;

  /// Returns the index of a registered or assignable controller.
  static int _bankIndex(int bank, int index) =>
      (bank & 0x7F) << 8 | index & 0x7F;

  /// Returns the bank fields of a MIDI 2.0 Program Change data word.
  static int _bank(({int msb, int lsb})? bank) =>
      bank == null ? 0 : (bank.msb & 0x7F) << 8 | bank.lsb & 0x7F;

  // ...........................................................................
  /// Returns the System Exclusive [message] (M2-104-UM 7.7).
  static List<Ump> _sysEx7(MidiSysEx message, int group) => _chunked(
    message.data,
    6,
    (form, chunk) => _packet([
      0x30 | group,
      form << 4 | chunk.length,
      for (final byte in chunk) byte & 0x7F,
    ], 2),
  );

  /// Returns the System Exclusive 8 [message] (M2-104-UM 7.8).
  static List<Ump> _sysEx8(MidiSysEx8 message, int group) => _chunked(
    message.data,
    13,
    (form, chunk) => _packet([
      0x50 | group,
      form << 4 | chunk.length + 1,
      message.streamId & 0xFF,
      ...chunk,
    ], 4),
  );

  /// Returns the chunks of the Mixed Data Set [message] (M2-104-UM 7.9).
  static List<Ump> _mixedDataSet(MidiMixedDataSet message, int group) {
    final data = message.data;
    final count = max(1, (data.length + _mdsChunkSize - 1) ~/ _mdsChunkSize);
    return [
      for (var chunk = 0; chunk < count; chunk++)
        ..._mdsChunk(
          message,
          group,
          number: chunk + 1,
          count: count,
          payload: data.sublist(
            chunk * _mdsChunkSize,
            min((chunk + 1) * _mdsChunkSize, data.length),
          ),
        ),
    ];
  }

  /// Returns chunk [number] of [count] of [message] with [payload].
  static List<Ump> _mdsChunk(
    MidiMixedDataSet message,
    int group, {
    required int number,
    required int count,
    required List<int> payload,
  }) {
    final id = message.mdsId & 0xF;
    final packets = (payload.length + 13) ~/ 14;
    final validBytes = 16 + payload.length + 2 * packets;
    return [
      Ump([
        0x5 << 28 | group << 24 | 0x8 << 20 | id << 16 | validBytes,
        (count & 0xFFFF) << 16 | number & 0xFFFF,
        (message.manufacturerId & 0xFFFF) << 16 | message.deviceId & 0xFFFF,
        (message.subId1 & 0xFFFF) << 16 | message.subId2 & 0xFFFF,
      ]),
      for (var i = 0; i < payload.length; i += 14)
        _packet([
          0x50 | group,
          0x90 | id,
          ...payload.sublist(i, min(i + 14, payload.length)),
        ], 4),
    ];
  }

  // ...........................................................................
  /// Returns the flex data [message] (M2-104-UM 7.5).
  static List<Ump> _flexData(MidiFlexDataMessage message, int group) =>
      switch (message) {
        MidiFlexText(:final text) => _chunked(
          utf8.encode(text),
          12,
          (form, chunk) => _flexPacket(message, group, form, chunk),
        ),
        MidiSetTempo(:final tenNanosecondsPerQuarterNote) => [
          _flexPacket(message, group, 0, _uint32(tenNanosecondsPerQuarterNote)),
        ],
        MidiSetTimeSignature() => [
          _flexPacket(message, group, 0, [
            message.numerator,
            message.denominator,
            message.numberOf32ndNotes,
          ]),
        ],
        MidiSetMetronome() => [
          _flexPacket(message, group, 0, [
            message.clocksPerPrimaryClick,
            message.barAccent1,
            message.barAccent2,
            message.barAccent3,
            message.subdivisionClicks1,
            message.subdivisionClicks2,
          ]),
        ],
        MidiSetKeySignature(:final sharpsFlats, :final tonicNote) => [
          _flexPacket(message, group, 0, [_nibbles(sharpsFlats, tonicNote)]),
        ],
        MidiSetChordName() => [
          _flexPacket(message, group, 0, _chordPayload(message)),
        ],
      };

  /// Returns a flex data packet of [message] with [form] and [payload].
  static Ump _flexPacket(
    MidiFlexDataMessage message,
    int group,
    int form,
    List<int> payload,
  ) {
    final channel = message.channel;
    final address = channel == null ? 0x10 : channel & 0xF;
    return _packet([
      0xD0 | group,
      form << 6 | address,
      message.statusBank & 0xFF,
      message.status & 0xFF,
      ...payload,
    ], 4);
  }

  /// Returns the twelve data bytes of a Set Chord Name [message].
  static List<int> _chordPayload(MidiSetChordName message) {
    final alterations = message.alterations;
    final bassAlterations = message.bassAlterations;
    return [
      _nibbles(message.tonicSharpsFlats, message.chordTonic),
      message.chordType,
      for (var i = 0; i < 4; i++) _alteration(alterations, i),
      0,
      0,
      _nibbles(message.bassSharpsFlats, message.bassNote),
      message.bassChordType,
      for (var i = 0; i < 2; i++) _alteration(bassAlterations, i),
    ];
  }

  /// Returns the byte of alteration [index] of [alterations], 0 if none.
  static int _alteration(List<MidiChordAlteration> alterations, int index) =>
      index < alterations.length
      ? _nibbles(alterations[index].type, alterations[index].degree)
      : 0;

  /// Returns a byte of the four-bit fields [high] and [low]; negative
  /// values are stored as two's complement.
  static int _nibbles(int high, int low) => (high & 0xF) << 4 | low & 0xF;

  // ...........................................................................
  /// Returns the UMP stream [message] (M2-104-UM 7.1).
  static List<Ump> _stream(MidiStreamMessage message) => switch (message) {
    MidiEndpointDiscovery() => [
      _streamPacket(message, 0, [
        message.umpVersionMajor,
        message.umpVersionMinor,
        0,
        0,
        0,
        _flags([
          message.requestStreamConfiguration,
          message.requestProductInstanceId,
          message.requestEndpointName,
          message.requestDeviceIdentity,
          message.requestEndpointInfo,
        ]),
      ]),
    ],
    MidiEndpointInfoNotification() => [
      _streamPacket(message, 0, [
        message.umpVersionMajor,
        message.umpVersionMinor,
        _flags([message.staticFunctionBlocks]) << 7 |
            message.numberOfFunctionBlocks & 0x7F,
        0,
        _flags([message.supportsMidi2, message.supportsMidi1]),
        _flags([message.supportsRxJr, message.supportsTxJr]),
      ]),
    ],
    MidiDeviceIdentityNotification() => [
      _streamPacket(message, 0, _identityPayload(message)),
    ],
    MidiEndpointNameNotification(:final name) => _streamText(
      message,
      name,
      maxLength: 98,
    ),
    MidiProductInstanceIdNotification(:final productInstanceId) => _streamText(
      message,
      productInstanceId,
      maxLength: 42,
    ),
    MidiStreamConfigurationRequest(
      :final protocol,
      :final receiveJr,
      :final transmitJr,
    ) ||
    MidiStreamConfigurationNotification(
      :final protocol,
      :final receiveJr,
      :final transmitJr,
    ) => [
      _streamPacket(message, 0, [
        protocol.value,
        _flags([receiveJr, transmitJr]),
      ]),
    ],
    MidiFunctionBlockDiscovery() => [
      _streamPacket(message, 0, [
        message.functionBlock,
        _flags([message.requestName, message.requestInfo]),
      ]),
    ],
    MidiFunctionBlockInfoNotification() => [
      _streamPacket(message, 0, _functionBlockPayload(message)),
    ],
    MidiFunctionBlockNameNotification(:final functionBlock, :final name) =>
      _streamText(message, name, maxLength: 91, prefix: [functionBlock]),
    MidiStartOfClip() || MidiEndOfClip() => [_streamPacket(message, 0, [])],
  };

  /// Returns the payload of a Device Identity Notification [message].
  static List<int> _identityPayload(MidiDeviceIdentityNotification message) => [
    0,
    0,
    0,
    for (final byte in message.manufacturerId) byte & 0x7F,
    message.familyId & 0x7F,
    (message.familyId >> 7) & 0x7F,
    message.modelId & 0x7F,
    (message.modelId >> 7) & 0x7F,
    for (final byte in message.softwareRevision) byte & 0x7F,
  ];

  /// Returns the payload of a Function Block Info Notification [message].
  static List<int> _functionBlockPayload(
    MidiFunctionBlockInfoNotification message,
  ) => [
    _flags([message.active]) << 7 | message.functionBlock & 0x7F,
    message.uiHint.value << 4 |
        message.midi1.value << 2 |
        message.direction.value,
    message.firstGroup,
    message.numberOfGroups,
    message.midiCiVersion,
    message.maxSysEx8Streams,
  ];

  /// Returns the packets of [text] for the stream [message], cut to
  /// [maxLength] UTF-8 bytes; [prefix] precedes the text in every packet.
  static List<Ump> _streamText(
    MidiStreamMessage message,
    String text, {
    required int maxLength,
    List<int> prefix = const [],
  }) => _chunked(
    _truncate(utf8.encode(text), maxLength),
    14 - prefix.length,
    (form, chunk) => _streamPacket(message, form, [...prefix, ...chunk]),
  );

  /// Returns a stream packet of [message] with [form] and [payload], the
  /// bytes after the status.
  static Ump _streamPacket(
    MidiStreamMessage message,
    int form,
    List<int> payload,
  ) {
    final status = message.status & 0x3FF;
    return _packet([0xF0 | form << 2 | status >> 8, status, ...payload], 4);
  }

  /// Returns the bits of [flags], the first flag the most significant.
  static int _flags(List<bool> flags) =>
      flags.fold(0, (bits, flag) => bits << 1 | (flag ? 1 : 0));

  /// Returns the first [maxLength] of the UTF-8 [bytes], cut before an
  /// incomplete character.
  static List<int> _truncate(List<int> bytes, int maxLength) {
    if (bytes.length <= maxLength) return bytes;
    var end = maxLength;
    while (end > 0 && bytes[end] & 0xC0 == 0x80) {
      end--;
    }
    return bytes.sublist(0, end);
  }

  // ...........................................................................
  /// Splits [data] into chunks of [size] bytes and returns one packet per
  /// chunk with the form complete (0), start (1), continue (2) or end (3).
  static List<Ump> _chunked(
    List<int> data,
    int size,
    Ump Function(int form, List<int> chunk) packet,
  ) {
    if (data.length <= size) return [packet(0, data)];
    return [
      for (var start = 0; start < data.length; start += size)
        packet(
          start == 0 ? 1 : (start + size >= data.length ? 3 : 2),
          data.sublist(start, min(start + size, data.length)),
        ),
    ];
  }

  /// Returns the big-endian 32-bit [value] as four bytes.
  static List<int> _uint32(int value) => [
    for (var shift = 24; shift >= 0; shift -= 8) (value >> shift) & 0xFF,
  ];

  /// Returns a packet of [wordCount] words from [bytes], most significant
  /// byte first, padded with zeros.
  static Ump _packet(List<int> bytes, int wordCount) => Ump([
    for (var i = 0; i < wordCount * 4; i += 4)
      _byte(bytes, i) << 24 |
          _byte(bytes, i + 1) << 16 |
          _byte(bytes, i + 2) << 8 |
          _byte(bytes, i + 3),
  ]);

  /// Returns the low eight bits of [bytes] at [index], or 0 behind the end.
  static int _byte(List<int> bytes, int index) =>
      index < bytes.length ? bytes[index] & 0xFF : 0;
}
