//
//  Generated code. Do not modify.
//  source: core/proto/gameboy.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class LoadGameReq extends $pb.GeneratedMessage {
  factory LoadGameReq({
    $core.String? path,
  }) {
    final $result = create();
    if (path != null) {
      $result.path = path;
    }
    return $result;
  }
  LoadGameReq._() : super();
  factory LoadGameReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoadGameReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoadGameReq', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LoadGameReq clone() => LoadGameReq()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LoadGameReq copyWith(void Function(LoadGameReq) updates) => super.copyWith((message) => updates(message as LoadGameReq)) as LoadGameReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoadGameReq create() => LoadGameReq._();
  LoadGameReq createEmptyInstance() => create();
  static $pb.PbList<LoadGameReq> createRepeated() => $pb.PbList<LoadGameReq>();
  @$core.pragma('dart2js:noInline')
  static LoadGameReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoadGameReq>(create);
  static LoadGameReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => clearField(1);
}

class BaseResp extends $pb.GeneratedMessage {
  factory BaseResp({
    $core.String? msg,
    $core.int? code,
  }) {
    final $result = create();
    if (msg != null) {
      $result.msg = msg;
    }
    if (code != null) {
      $result.code = code;
    }
    return $result;
  }
  BaseResp._() : super();
  factory BaseResp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BaseResp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BaseResp', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msg')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'code', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BaseResp clone() => BaseResp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BaseResp copyWith(void Function(BaseResp) updates) => super.copyWith((message) => updates(message as BaseResp)) as BaseResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BaseResp create() => BaseResp._();
  BaseResp createEmptyInstance() => create();
  static $pb.PbList<BaseResp> createRepeated() => $pb.PbList<BaseResp>();
  @$core.pragma('dart2js:noInline')
  static BaseResp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BaseResp>(create);
  static BaseResp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msg => $_getSZ(0);
  @$pb.TagNumber(1)
  set msg($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsg() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get code => $_getIZ(1);
  @$pb.TagNumber(2)
  set code($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => clearField(2);
}

class ButtonEvent extends $pb.GeneratedMessage {
  factory ButtonEvent({
    $core.int? key,
    $core.int? mode,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (mode != null) {
      $result.mode = mode;
    }
    return $result;
  }
  ButtonEvent._() : super();
  factory ButtonEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ButtonEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ButtonEvent', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'key', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'mode', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ButtonEvent clone() => ButtonEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ButtonEvent copyWith(void Function(ButtonEvent) updates) => super.copyWith((message) => updates(message as ButtonEvent)) as ButtonEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ButtonEvent create() => ButtonEvent._();
  ButtonEvent createEmptyInstance() => create();
  static $pb.PbList<ButtonEvent> createRepeated() => $pb.PbList<ButtonEvent>();
  @$core.pragma('dart2js:noInline')
  static ButtonEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ButtonEvent>(create);
  static ButtonEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get key => $_getIZ(0);
  @$pb.TagNumber(1)
  set key($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get mode => $_getIZ(1);
  @$pb.TagNumber(2)
  set mode($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearMode() => clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
