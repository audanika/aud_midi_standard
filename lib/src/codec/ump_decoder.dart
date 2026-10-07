// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:convert';
import 'dart:math';

import '../message/midi_message.dart';
import '../midi2/midi_function_block_direction.dart';
import '../midi2/midi_function_block_midi1.dart';
import '../midi2/midi_function_block_ui_hint.dart';
import '../midi2/ump_message_type.dart';
import '../model/midi_diagnostic_kind.dart';
import '../model/midi_protocol.dart';
import '../model/midi_time.dart';
import '../raw/ump.dart';
import 'midi_short_message.dart';
import 'midi_timed_message.dart';

// #############################################################################
/// A message decoded from Universal MIDI Packets with its group, null for
/// groupless messages, and its time.
typedef UmpDecodedMessage = ({MidiMessage message, int? group, MidiTime time});

// #############################################################################
/// Decodes a stream of Universal MIDI Packets into messages
/// (M2-104-UM 7 and Appendix F).
///
/// The decoder reassembles messages that span several packets — System
/// Exclusive, System Exclusive 8 per stream id, Mixed Data Sets, flex data
/// texts and stream names — per group, with a size limit and a maximum
/// duration. Packets of reserved message types or with undefined status
/// become [MidiUnknownMessage]s.
///
/// It applies these rules:
///
/// - System Exclusive is reassembled per group. Any other packet of the
///   same group except System Exclusive continue and end packets and
///   system real-time messages terminates it (M2-104-UM 7.7.1); the
///   incomplete message is dropped.
/// - System Exclusive 8 is reassembled per group and stream id, Mixed Data
///   Sets per group and MDS id, flex data texts per group, address, status
///   bank and status, and stream names per status and function block.
/// - A Mixed Data Set chunk holds as many payload packets as its header
///   declares valid bytes: the 16 bytes of the header and up to 16 bytes
///   per payload packet, 14 of them data (M2-104-UM 7.9). A set ends with
///   the chunk whose number equals the declared number of chunks.
/// - Flex data packets with a reserved address, status bank or status, and
///   setup messages that are not complete in one packet, become one
///   [MidiUnknownMessage] per packet. Set Tempo, Set Time Signature and Set
///   Metronome always address the group; a channel address is ignored.
/// - Texts are UTF-8 with malformed sequences replaced; trailing zero bytes
///   are removed.
/// - Values a message cannot hold, e.g. a function block spanning more
///   than 16 groups or an unknown protocol, make the packet a
///   [MidiUnknownMessage].
final class UmpDecoder {
  /// Creates a decoder.
  ///
  /// - [maxSysExLength] the largest reassembled message accepted, in data
  ///   bytes.
  /// - [maxSysExDuration] the longest time a message may stay incomplete;
  ///   null for no limit.
  /// - [onIssue] receives the packets the decoder had to drop.
  UmpDecoder({
    this.maxSysExLength = 1 << 20,
    this.maxSysExDuration,
    this.onIssue,
  });

  // ...........................................................................
  /// Decodes [words], a sequence of complete packets received at [time],
  /// and returns the completed messages.
  ///
  /// A message that spans several packets gets the time of its first
  /// packet. A message still incomplete [maxSysExDuration] after its first
  /// packet is dropped when later words arrive; its remaining packets are
  /// skipped. Words of an incomplete last packet are dropped and reported.
  List<UmpDecodedMessage> add(
    List<int> words, {
    MidiTime time = MidiTime.zero,
  }) {
    _now = time;
    _decoded = [];
    _expire();
    for (final ump in _split(words)) {
      _decode(ump);
    }
    return _decoded;
  }

  // ...........................................................................
  /// Drops all partial messages, e.g. after a gap in the stream.
  void reset() => _pending.clear();

  // ...........................................................................
  /// The largest reassembled message accepted, in data bytes.
  final int maxSysExLength;

  /// The longest time a message may stay incomplete.
  final Duration? maxSysExDuration;

  /// Receives the packets the decoder had to drop.
  final MidiIssueCallback? onIssue;

  // ######################
  // Private
  // ######################

  /// The messages being reassembled, by their kind and address.
  final _pending = <Object, _Pending>{};

  /// The time of the words being decoded.
  MidiTime _now = MidiTime.zero;

  /// The messages decoded from the current words.
  List<UmpDecodedMessage> _decoded = [];

  /// The names of the reassembled message kinds, in keys and causes.
  static const _sysEx7Kind = 'System Exclusive';
  static const _sysEx8Kind = 'System Exclusive 8';
  static const _mdsKind = 'Mixed Data Set';
  static const _flexTextKind = 'Flex data text';
  static const _streamTextKind = 'Stream text';

  // ...........................................................................
  /// Splits [words] into packets and reports an incomplete last packet.
  List<Ump> _split(List<int> words) {
    final packets = <Ump>[];
    var i = 0;
    while (i < words.length) {
      final size = Ump.sizeOf(words[i]);
      if (i + size > words.length) {
        _issue(
          MidiDiagnosticKind.invalidData,
          'Incomplete packet of ${words.length - i} of $size words',
        );
        break;
      }
      packets.add(Ump(words.sublist(i, i + size)));
      i += size;
    }
    return packets;
  }

  /// Decodes [ump].
  void _decode(Ump ump) {
    final group = ump.group;
    if (group != null && !_keepsSysEx7(ump)) _interrupt((_sysEx7Kind, group));
    switch (ump.messageType) {
      case UmpMessageType.utility:
        _utility(ump);
      case UmpMessageType.system:
        _short(ump, system: true);
      case UmpMessageType.midi1ChannelVoice:
        _short(ump, system: false);
      case UmpMessageType.data64:
        _sysEx(ump);
      case UmpMessageType.midi2ChannelVoice:
        _channelVoice2(ump);
      case UmpMessageType.data128:
        _data128(ump);
      case UmpMessageType.flexData:
        _flexData(ump);
      case UmpMessageType.umpStream:
        _stream(ump);
      default:
        _unknown(ump);
    }
  }

  /// Whether [ump] may appear inside a System Exclusive of its group: a
  /// continue or end packet, or a system real-time message.
  static bool _keepsSysEx7(Ump ump) => switch (ump.messageType) {
    UmpMessageType.data64 => const {2, 3}.contains(_status(ump)),
    UmpMessageType.system => _byte(ump, 1) >= 0xF8,
    _ => false,
  };

  // ...........................................................................
  /// Decodes a utility message (M2-104-UM 7.2).
  void _utility(Ump ump) {
    final word = ump.words[0];
    final data = word & 0xFFFF;
    _emit(switch ((word >> 20) & 0xF) {
      0x0 => const MidiNoop(),
      0x1 => MidiJrClock(time: data),
      0x2 => MidiJrTimestamp(time: data),
      0x3 => MidiDeltaClockstampTicksPerQuarterNote(ticksPerQuarterNote: data),
      0x4 => MidiDeltaClockstamp(ticks: word & 0xFFFFF),
      _ => MidiUnknownMessage([ump]),
    }, ump);
  }

  /// Decodes a system message or a MIDI 1.0 channel voice message, which
  /// carry the MIDI 1.0 bytes (M2-104-UM 7.3 and 7.6).
  void _short(Ump ump, {required bool system}) {
    final status = _byte(ump, 1);
    final defined = MidiShortMessage.dataLength(status) != null;
    if (!defined || (status >= 0xF0) != system) return _unknown(ump);
    _emit(
      MidiShortMessage.decode(
        status,
        data1: _byte(ump, 2) & 0x7F,
        data2: _byte(ump, 3) & 0x7F,
      ),
      ump,
    );
  }

  /// Decodes a MIDI 2.0 channel voice message (M2-104-UM 7.4).
  void _channelVoice2(Ump ump) {
    final [w0, w1] = ump.words;
    final channel = (w0 >> 16) & 0xF;
    final note = (w0 >> 8) & 0x7F;
    final index = w0 & 0xFF;
    _emit(switch ((w0 >> 20) & 0xF) {
      0x0 => MidiRegisteredPerNoteController(
        channel: channel,
        note: note,
        index: index,
        value: w1,
      ),
      0x1 => MidiAssignablePerNoteController(
        channel: channel,
        note: note,
        index: index,
        value: w1,
      ),
      0x2 => MidiRegisteredController(
        channel: channel,
        bank: note,
        index: index & 0x7F,
        value: w1,
      ),
      0x3 => MidiAssignableController(
        channel: channel,
        bank: note,
        index: index & 0x7F,
        value: w1,
      ),
      0x4 => MidiRelativeRegisteredController(
        channel: channel,
        bank: note,
        index: index & 0x7F,
        value: w1.toSigned(32),
      ),
      0x5 => MidiRelativeAssignableController(
        channel: channel,
        bank: note,
        index: index & 0x7F,
        value: w1.toSigned(32),
      ),
      0x6 => MidiPerNotePitchBend(channel: channel, note: note, value: w1),
      0x8 => MidiNoteOff2(
        channel: channel,
        note: note,
        velocity: w1 >> 16,
        attributeType: index,
        attribute: w1 & 0xFFFF,
      ),
      0x9 => MidiNoteOn2(
        channel: channel,
        note: note,
        velocity: w1 >> 16,
        attributeType: index,
        attribute: w1 & 0xFFFF,
      ),
      0xA => MidiPolyPressure2(channel: channel, note: note, pressure: w1),
      0xB => MidiControlChange2(channel: channel, controller: note, value: w1),
      0xC => MidiProgramChange2(
        channel: channel,
        program: (w1 >> 24) & 0x7F,
        bank: _bit(w0, 0) ? (msb: (w1 >> 8) & 0x7F, lsb: w1 & 0x7F) : null,
      ),
      0xD => MidiChannelPressure2(channel: channel, pressure: w1),
      0xE => MidiPitchBend2(channel: channel, value: w1),
      0xF => MidiPerNoteManagement(
        channel: channel,
        note: note,
        detach: _bit(w0, 1),
        reset: _bit(w0, 0),
      ),
      _ => MidiUnknownMessage([ump]),
    }, ump);
  }

  // ...........................................................................
  /// Decodes a System Exclusive packet (M2-104-UM 7.7).
  void _sysEx(Ump ump) {
    final form = _status(ump);
    if (form > 3) return _unknown(ump);
    final count = _byte(ump, 1) & 0xF;
    final key = (_sysEx7Kind, ump.group);
    if (count > 6) {
      return _invalidPacket(
        _sysEx7Kind,
        key,
        form,
        '$_sysEx7Kind with $count bytes',
      );
    }
    final data = [for (final byte in _data(ump, 2, count)) byte & 0x7F];
    _collect(_sysEx7Kind, key, ump, form, data, (bytes) => MidiSysEx(bytes));
  }

  /// Decodes a 128-bit data packet: System Exclusive 8 or Mixed Data Set.
  void _data128(Ump ump) {
    final status = _status(ump);
    if (status <= 3) return _sysEx8(ump, status);
    if (status == 0x8) return _mdsHeader(ump);
    if (status == 0x9) return _mdsPayload(ump);
    _unknown(ump);
  }

  /// Decodes a System Exclusive 8 packet of [form] (M2-104-UM 7.8).
  void _sysEx8(Ump ump, int form) {
    final count = _byte(ump, 1) & 0xF;
    final streamId = _byte(ump, 2);
    final key = (_sysEx8Kind, ump.group, streamId);
    if (count == 0xF && form == 3) return _abort(_sysEx8Kind, key);
    if (count == 0 || count > 14) {
      return _invalidPacket(
        _sysEx8Kind,
        key,
        form,
        '$_sysEx8Kind with $count bytes',
      );
    }
    _collect(
      _sysEx8Kind,
      key,
      ump,
      form,
      _data(ump, 3, count - 1),
      (bytes) => MidiSysEx8(streamId: streamId, data: bytes),
    );
  }

  /// Decodes a Mixed Data Set header packet (M2-104-UM 7.9).
  void _mdsHeader(Ump ump) {
    final [w0, w1, w2, w3] = ump.words;
    final key = (_mdsKind, ump.group, (w0 >> 16) & 0xF);
    final chunk = w1 & 0xFFFF;
    final pending = _mdsChunk(key, chunk)
      ..chunk = chunk
      ..chunks = w1 >> 16
      ..remaining = max(0, (w0 & 0xFFFF) - 16);
    if (pending.header.isEmpty) {
      pending.header = [w2 >> 16, w2 & 0xFFFF, w3 >> 16, w3 & 0xFFFF];
    }
    if (pending.remaining == 0) _mdsChunkDone(ump, key, pending);
  }

  /// Returns the set the header of [chunk] continues, or starts a new one.
  _Pending _mdsChunk(Object key, int chunk) {
    final previous = _pending[key];
    if (previous != null &&
        previous.remaining == 0 &&
        chunk == previous.chunk + 1) {
      return previous;
    }
    if (chunk == 0) {
      _abort(_mdsKind, key);
    } else if (chunk == 1) {
      _interrupt(key);
    } else {
      _pending.remove(key);
      _issue(
        MidiDiagnosticKind.invalidData,
        '$_mdsKind chunk $chunk out of order',
      );
    }
    return _pending[key] = _Pending(_mdsKind, _now)..skip = chunk != 1;
  }

  /// Decodes a Mixed Data Set payload packet (M2-104-UM 7.9).
  void _mdsPayload(Ump ump) {
    final key = (_mdsKind, ump.group, (ump.words[0] >> 16) & 0xF);
    final pending = _pending[key];
    if (pending == null || pending.remaining == 0) {
      return _issue(
        MidiDiagnosticKind.invalidData,
        '$_mdsKind payload without header',
      );
    }
    final count = (pending.remaining - 2).clamp(0, 14);
    pending.remaining = max(0, pending.remaining - 16);
    _append(pending, _data(ump, 2, count));
    if (pending.remaining == 0) _mdsChunkDone(ump, key, pending);
  }

  /// Delivers the set of [pending] when its last chunk is complete.
  void _mdsChunkDone(Ump ump, Object key, _Pending pending) {
    if (pending.chunk != 0 && pending.chunk != pending.chunks) return;
    _pending.remove(key);
    if (pending.skip) return;
    final [manufacturerId, deviceId, subId1, subId2] = pending.header;
    _emit(
      MidiMixedDataSet(
        mdsId: (ump.words[0] >> 16) & 0xF,
        manufacturerId: manufacturerId,
        deviceId: deviceId,
        subId1: subId1,
        subId2: subId2,
        data: pending.bytes,
      ),
      ump,
      pending.time,
    );
  }

  // ...........................................................................
  /// Decodes a flex data packet (M2-104-UM 7.5).
  void _flexData(Ump ump) {
    final address = (_byte(ump, 1) >> 4) & 0x3;
    if (address > 1) return _unknown(ump);
    final channel = address == 0 ? _byte(ump, 1) & 0xF : null;
    final bank = _byte(ump, 2);
    final status = _byte(ump, 3);
    final form = _form(ump, 22);
    if (bank == 1 || bank == 2) {
      return _collect(
        _flexTextKind,
        (_flexTextKind, ump.group, channel, bank, status),
        ump,
        form,
        _data(ump, 4, 12),
        (bytes) => MidiFlexText(
          channel: channel,
          statusBank: bank,
          status: status,
          text: _text(bytes),
        ),
      );
    }
    final message = bank == 0 && form == 0 ? _setup(ump, channel) : null;
    _emit(message ?? MidiUnknownMessage([ump]), ump);
  }

  /// Returns the setup and performance message of [ump] addressed to
  /// [channel], or null for an undefined status (M2-104-UM 7.5.3 to 7.5.8).
  static MidiMessage? _setup(Ump ump, int? channel) {
    final [_, w1, w2, w3] = ump.words;
    return switch (_byte(ump, 3)) {
      0x00 => MidiSetTempo(tenNanosecondsPerQuarterNote: w1),
      0x01 => MidiSetTimeSignature(
        numerator: _byte(ump, 4),
        denominator: _byte(ump, 5),
        numberOf32ndNotes: _byte(ump, 6),
      ),
      0x02 => MidiSetMetronome(
        clocksPerPrimaryClick: _byte(ump, 4),
        barAccent1: _byte(ump, 5),
        barAccent2: _byte(ump, 6),
        barAccent3: _byte(ump, 7),
        subdivisionClicks1: _byte(ump, 8),
        subdivisionClicks2: _byte(ump, 9),
      ),
      0x05 => MidiSetKeySignature(
        channel: channel,
        sharpsFlats: (w1 >> 28).toSigned(4),
        tonicNote: (w1 >> 24) & 0xF,
      ),
      0x06 => MidiSetChordName(
        channel: channel,
        tonicSharpsFlats: (w1 >> 28).toSigned(4),
        chordTonic: (w1 >> 24) & 0xF,
        chordType: (w1 >> 16) & 0xFF,
        alterations: _alterations([w1 >> 8, w1, w2 >> 24, w2 >> 16]),
        bassSharpsFlats: (w3 >> 28).toSigned(4),
        bassNote: (w3 >> 24) & 0xF,
        bassChordType: (w3 >> 16) & 0xFF,
        bassAlterations: _alterations([w3 >> 8, w3]),
      ),
      _ => null,
    };
  }

  /// Returns the chord alterations of the low bytes of [values], without
  /// the trailing empty ones.
  static List<MidiChordAlteration> _alterations(List<int> values) {
    final bytes = [for (final value in values) value & 0xFF];
    while (bytes.isNotEmpty && bytes.last == 0) {
      bytes.removeLast();
    }
    return [
      for (final byte in bytes)
        MidiChordAlteration(type: byte >> 4, degree: byte & 0xF),
    ];
  }

  // ...........................................................................
  /// Decodes a UMP stream message (M2-104-UM 7.1).
  void _stream(Ump ump) {
    final form = _form(ump, 26);
    final status = (ump.words[0] >> 16) & 0x3FF;
    if (status == 0x03 || status == 0x04) {
      return _collect(
        _streamTextKind,
        (_streamTextKind, status),
        ump,
        form,
        _data(ump, 2, 14),
        (bytes) => status == 0x03
            ? MidiEndpointNameNotification(name: _text(bytes))
            : MidiProductInstanceIdNotification(
                productInstanceId: _text(bytes),
              ),
      );
    }
    if (status == 0x12) return _functionBlockName(ump, form);
    final message = form == 0 ? _streamMessage(ump, status) : null;
    _emit(message ?? MidiUnknownMessage([ump]), ump);
  }

  /// Decodes a Function Block Name Notification packet of [form].
  void _functionBlockName(Ump ump, int form) {
    final functionBlock = _byte(ump, 2);
    _collect(
      _streamTextKind,
      (_streamTextKind, 0x12, functionBlock),
      ump,
      form,
      _data(ump, 3, 13),
      (bytes) => MidiFunctionBlockNameNotification(
        functionBlock: functionBlock,
        name: _text(bytes),
      ),
    );
  }

  /// Returns the single-packet stream message of [status], or null for an
  /// undefined status or values the message cannot hold.
  static MidiMessage? _streamMessage(Ump ump, int status) {
    final [w0, w1, ...] = ump.words;
    return switch (status) {
      0x00 => MidiEndpointDiscovery(
        umpVersionMajor: _byte(ump, 2),
        umpVersionMinor: _byte(ump, 3),
        requestEndpointInfo: _bit(w1, 0),
        requestDeviceIdentity: _bit(w1, 1),
        requestEndpointName: _bit(w1, 2),
        requestProductInstanceId: _bit(w1, 3),
        requestStreamConfiguration: _bit(w1, 4),
      ),
      0x01 => MidiEndpointInfoNotification(
        umpVersionMajor: _byte(ump, 2),
        umpVersionMinor: _byte(ump, 3),
        staticFunctionBlocks: _bit(w1, 31),
        numberOfFunctionBlocks: (w1 >> 24) & 0x7F,
        supportsMidi2: _bit(w1, 9),
        supportsMidi1: _bit(w1, 8),
        supportsRxJr: _bit(w1, 1),
        supportsTxJr: _bit(w1, 0),
      ),
      0x02 => MidiDeviceIdentityNotification(
        manufacturerId: [for (var i = 5; i < 8; i++) _byte(ump, i) & 0x7F],
        familyId: _fourteenBits(lsb: _byte(ump, 8), msb: _byte(ump, 9)),
        modelId: _fourteenBits(lsb: _byte(ump, 10), msb: _byte(ump, 11)),
        softwareRevision: [for (var i = 12; i < 16; i++) _byte(ump, i) & 0x7F],
      ),
      0x05 || 0x06 => _streamConfiguration(ump, request: status == 0x05),
      0x10 => MidiFunctionBlockDiscovery(
        functionBlock: _byte(ump, 2),
        requestInfo: _bit(w0, 0),
        requestName: _bit(w0, 1),
      ),
      0x11 => _functionBlockInfo(ump),
      0x20 => const MidiStartOfClip(),
      0x21 => const MidiEndOfClip(),
      _ => null,
    };
  }

  /// Returns the Stream Configuration Request or Notification of [ump], or
  /// null for an unknown protocol.
  static MidiMessage? _streamConfiguration(Ump ump, {required bool request}) {
    final protocol = MidiProtocol.fromValue(_byte(ump, 2));
    if (protocol == null) return null;
    final word = ump.words[0];
    return request
        ? MidiStreamConfigurationRequest(
            protocol: protocol,
            receiveJr: _bit(word, 1),
            transmitJr: _bit(word, 0),
          )
        : MidiStreamConfigurationNotification(
            protocol: protocol,
            receiveJr: _bit(word, 1),
            transmitJr: _bit(word, 0),
          );
  }

  /// Returns the Function Block Info Notification of [ump], or null when
  /// its groups are out of range.
  static MidiMessage? _functionBlockInfo(Ump ump) {
    final firstGroup = _byte(ump, 4);
    final numberOfGroups = _byte(ump, 5);
    if (firstGroup > 0xF || numberOfGroups > 0x10) return null;
    final word = ump.words[0];
    return MidiFunctionBlockInfoNotification(
      active: _bit(word, 15),
      functionBlock: (word >> 8) & 0x7F,
      uiHint: MidiFunctionBlockUiHint.fromValue(word >> 4),
      midi1: MidiFunctionBlockMidi1.fromValue(word >> 2),
      direction: MidiFunctionBlockDirection.fromValue(word),
      firstGroup: firstGroup,
      numberOfGroups: numberOfGroups,
      midiCiVersion: _byte(ump, 6),
      maxSysEx8Streams: _byte(ump, 7),
    );
  }

  // ...........................................................................
  /// Collects [data] of the packet [ump] of [form] for the message of
  /// [kind] under [key], and delivers the message [build] creates from the
  /// collected bytes when it is complete.
  void _collect(
    String kind,
    Object key,
    Ump ump,
    int form,
    List<int> data,
    MidiMessage Function(List<int> bytes) build,
  ) {
    if (form <= 1) {
      _interrupt(key);
      final pending = _Pending(kind, _now);
      if (form == 1) _pending[key] = pending;
      _append(pending, data);
      if (form == 0 && !pending.skip) _emit(build(pending.bytes), ump);
      return;
    }
    final pending = _pending[key];
    if (pending == null) {
      final state = form == 2 ? 'continued' : 'ended';
      return _issue(
        MidiDiagnosticKind.invalidData,
        '$kind $state without start',
      );
    }
    _append(pending, data);
    if (form == 2) return;
    _pending.remove(key);
    if (!pending.skip) _emit(build(pending.bytes), ump, pending.time);
  }

  /// Appends [data] to [pending], or drops it when it gets too long.
  void _append(_Pending pending, List<int> data) {
    if (pending.skip) return;
    if (pending.bytes.length + data.length <= maxSysExLength) {
      return pending.bytes.addAll(data);
    }
    pending.drop();
    _issue(
      MidiDiagnosticKind.sysExTooLong,
      '${pending.kind} longer than $maxSysExLength bytes',
    );
  }

  /// Drops the message pending under [key] because another packet
  /// interrupted it.
  void _interrupt(Object key) {
    final pending = _pending.remove(key);
    if (pending == null || pending.skip) return;
    _issue(
      MidiDiagnosticKind.sysExIncomplete,
      '${pending.kind} incomplete, interrupted',
    );
  }

  /// Drops the message pending under [key] because its sender aborted it.
  void _abort(String kind, Object key) {
    final pending = _pending.remove(key);
    if (pending?.skip ?? false) return;
    _issue(MidiDiagnosticKind.sysExIncomplete, '$kind aborted by the sender');
  }

  /// Reports a packet of [form] with an invalid size and skips the rest of
  /// the message it belongs to.
  void _invalidPacket(String kind, Object key, int form, String cause) {
    _issue(MidiDiagnosticKind.invalidData, cause);
    if (form <= 1) _interrupt(key);
    if (form == 1) _pending[key] = _Pending(kind, _now)..skip = true;
    if (form == 2) _pending[key]?.drop();
    if (form == 3) _pending.remove(key);
  }

  /// Drops messages still incomplete [maxSysExDuration] after their first
  /// packet.
  void _expire() {
    final maxDuration = maxSysExDuration;
    if (maxDuration == null) return;
    for (final pending in _pending.values) {
      if (pending.skip || _now.difference(pending.time) <= maxDuration) {
        continue;
      }
      pending.drop();
      _issue(
        MidiDiagnosticKind.sysExIncomplete,
        '${pending.kind} incomplete after $maxDuration',
      );
    }
  }

  // ...........................................................................
  /// Delivers [message] decoded from [ump], at [time] or now.
  void _emit(MidiMessage message, Ump ump, [MidiTime? time]) =>
      _decoded.add((message: message, group: ump.group, time: time ?? _now));

  /// Delivers [ump] as a [MidiUnknownMessage].
  void _unknown(Ump ump) => _emit(MidiUnknownMessage([ump]), ump);

  /// Reports an issue of [kind] with [cause].
  void _issue(MidiDiagnosticKind kind, String cause) =>
      onIssue?.call(kind, cause);

  /// Returns the byte of [ump] at [index], counted from the most
  /// significant byte of the first word.
  static int _byte(Ump ump, int index) =>
      (ump.words[index >> 2] >> (24 - 8 * (index & 3))) & 0xFF;

  /// Returns [count] bytes of [ump] from [start] on.
  static List<int> _data(Ump ump, int start, int count) => [
    for (var i = start; i < start + count; i++) _byte(ump, i),
  ];

  /// Returns the four-bit status of the data message [ump].
  static int _status(Ump ump) => (ump.words[0] >> 20) & 0xF;

  /// Returns the two-bit form field of [ump] at bit [shift] of its first
  /// word.
  static int _form(Ump ump, int shift) => (ump.words[0] >> shift) & 0x3;

  /// Whether bit [index] of [word] is set.
  static bool _bit(int word, int index) => (word >> index) & 1 == 1;

  /// Returns the 14-bit value of the 7-bit [lsb] and [msb].
  static int _fourteenBits({required int lsb, required int msb}) =>
      (msb & 0x7F) << 7 | lsb & 0x7F;

  /// Returns the UTF-8 text of [bytes] without trailing zero bytes.
  static String _text(List<int> bytes) {
    var end = bytes.length;
    while (end > 0 && bytes[end - 1] == 0) {
      end--;
    }
    return utf8.decode(bytes.sublist(0, end), allowMalformed: true);
  }
}

// #############################################################################
/// A message being reassembled from several packets.
final class _Pending {
  /// Creates the state of a message of [kind] whose first packet arrived
  /// at [time].
  _Pending(this.kind, this.time);

  /// Forgets the collected bytes and skips the rest of the message.
  void drop() {
    skip = true;
    bytes.clear();
  }

  /// The name of the message kind, for diagnostics.
  final String kind;

  /// The time of the first packet.
  final MidiTime time;

  /// The data collected so far.
  final bytes = <int>[];

  /// Whether the remaining packets of a dropped message are skipped.
  bool skip = false;

  /// The bytes of the current Mixed Data Set chunk still expected.
  int remaining = 0;

  /// The number of the current Mixed Data Set chunk.
  int chunk = 0;

  /// The declared number of Mixed Data Set chunks, 0 if unknown.
  int chunks = 0;

  /// The manufacturer id, device id and sub ids of a Mixed Data Set.
  List<int> header = const [];
}
