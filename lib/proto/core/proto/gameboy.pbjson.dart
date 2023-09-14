//
//  Generated code. Do not modify.
//  source: core/proto/gameboy.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use loadGameReqDescriptor instead')
const LoadGameReq$json = {
  '1': 'LoadGameReq',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
  ],
};

/// Descriptor for `LoadGameReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loadGameReqDescriptor = $convert.base64Decode(
    'CgtMb2FkR2FtZVJlcRISCgRwYXRoGAEgASgJUgRwYXRo');

@$core.Deprecated('Use baseRespDescriptor instead')
const BaseResp$json = {
  '1': 'BaseResp',
  '2': [
    {'1': 'msg', '3': 1, '4': 1, '5': 9, '10': 'msg'},
    {'1': 'code', '3': 2, '4': 1, '5': 5, '10': 'code'},
  ],
};

/// Descriptor for `BaseResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baseRespDescriptor = $convert.base64Decode(
    'CghCYXNlUmVzcBIQCgNtc2cYASABKAlSA21zZxISCgRjb2RlGAIgASgFUgRjb2Rl');

@$core.Deprecated('Use buttonEventDescriptor instead')
const ButtonEvent$json = {
  '1': 'ButtonEvent',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'mode', '3': 2, '4': 1, '5': 5, '10': 'mode'},
  ],
};

/// Descriptor for `ButtonEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buttonEventDescriptor = $convert.base64Decode(
    'CgtCdXR0b25FdmVudBIQCgNrZXkYASABKAVSA2tleRISCgRtb2RlGAIgASgFUgRtb2Rl');

@$core.Deprecated('Use eventToCDescriptor instead')
const EventToC$json = {
  '1': 'EventToC',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'value', '3': 2, '4': 1, '5': 12, '10': 'value'},
  ],
};

/// Descriptor for `EventToC`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventToCDescriptor = $convert.base64Decode(
    'CghFdmVudFRvQxISCgR0eXBlGAEgASgFUgR0eXBlEhQKBXZhbHVlGAIgASgMUgV2YWx1ZQ==');

