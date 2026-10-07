// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

/// The MIDI 1.0 and MIDI 2.0 (UMP) standards as dependency-free Dart:
/// constants, messages, raw forms, codecs and the descriptive models of
/// the aud_midi family.
library;

export 'src/codec/midi_ble_decoder.dart';
export 'src/codec/midi_ble_encoder.dart';
export 'src/codec/midi_byte_encoder.dart';
export 'src/codec/midi_byte_parser.dart';
export 'src/codec/midi_timed_message.dart';
export 'src/codec/midi_translator_1_to_2.dart';
export 'src/codec/midi_translator_2_to_1.dart';
export 'src/codec/midi_value_scaling.dart';
export 'src/codec/ump_decoder.dart';
export 'src/codec/ump_encoder.dart';
export 'src/message/midi_message.dart';
export 'src/midi1/midi_controllers.dart';
export 'src/midi1/midi_general_midi.dart';
export 'src/midi1/midi_manufacturer_ids.dart';
export 'src/midi1/midi_note_numbers.dart';
export 'src/midi1/midi_registered_parameters.dart';
export 'src/midi1/midi_status.dart';
export 'src/midi1/midi_time_code.dart';
export 'src/midi1/midi_universal_sys_ex.dart';
export 'src/midi2/midi_chord_types.dart';
export 'src/midi2/midi_flex_data_status.dart';
export 'src/midi2/midi_function_block_direction.dart';
export 'src/midi2/midi_function_block_midi1.dart';
export 'src/midi2/midi_function_block_ui_hint.dart';
export 'src/midi2/midi_note_attribute_types.dart';
export 'src/midi2/midi_per_note_controllers.dart';
export 'src/midi2/ump_message_type.dart';
export 'src/midi2/ump_status.dart';
export 'src/model/midi_ble_peripheral_info.dart';
export 'src/model/midi_ble_peripheral_state.dart';
export 'src/model/midi_capabilities.dart';
export 'src/model/midi_device_id.dart';
export 'src/model/midi_device_identity.dart';
export 'src/model/midi_device_info.dart';
export 'src/model/midi_diagnostic.dart';
export 'src/model/midi_diagnostic_kind.dart';
export 'src/model/midi_direction.dart';
export 'src/model/midi_endpoint_info.dart';
export 'src/model/midi_event.dart';
export 'src/model/midi_function_block_info.dart';
export 'src/model/midi_group_info.dart';
export 'src/model/midi_network_connection_info.dart';
export 'src/model/midi_network_connection_policy.dart';
export 'src/model/midi_network_connection_state.dart';
export 'src/model/midi_network_host_info.dart';
export 'src/model/midi_network_host_source.dart';
export 'src/model/midi_network_loss_stats.dart';
export 'src/model/midi_network_protocol.dart';
export 'src/model/midi_network_session_info.dart';
export 'src/model/midi_network_support.dart';
export 'src/model/midi_packet.dart';
export 'src/model/midi_permission.dart';
export 'src/model/midi_port_capabilities.dart';
export 'src/model/midi_port_event.dart';
export 'src/model/midi_port_id.dart';
export 'src/model/midi_port_info.dart';
export 'src/model/midi_port_state.dart';
export 'src/model/midi_protocol.dart';
export 'src/model/midi_scheduling_support.dart';
export 'src/model/midi_time.dart';
export 'src/model/midi_transport.dart';
export 'src/model/midi_virtual_port_spec.dart';
export 'src/model/midi_virtual_port_support.dart';
export 'src/raw/midi_bytes.dart';
export 'src/raw/ump.dart';
