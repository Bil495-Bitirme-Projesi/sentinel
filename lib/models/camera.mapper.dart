// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'camera.dart';

class CameraMapper extends ClassMapperBase<Camera> {
  CameraMapper._();

  static CameraMapper? _instance;
  static CameraMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CameraMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Camera';

  static int _$id(Camera v) => v.id;
  static const Field<Camera, int> _f$id = Field('id', _$id);
  static String _$name(Camera v) => v.name;
  static const Field<Camera, String> _f$name = Field('name', _$name);
  static String _$rtspUrl(Camera v) => v.rtspUrl;
  static const Field<Camera, String> _f$rtspUrl = Field('rtspUrl', _$rtspUrl);
  static bool _$detectionEnabled(Camera v) => v.detectionEnabled;
  static const Field<Camera, bool> _f$detectionEnabled = Field(
    'detectionEnabled',
    _$detectionEnabled,
  );

  @override
  final MappableFields<Camera> fields = const {
    #id: _f$id,
    #name: _f$name,
    #rtspUrl: _f$rtspUrl,
    #detectionEnabled: _f$detectionEnabled,
  };

  static Camera _instantiate(DecodingData data) {
    return Camera(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      rtspUrl: data.dec(_f$rtspUrl),
      detectionEnabled: data.dec(_f$detectionEnabled),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Camera fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Camera>(map);
  }

  static Camera fromJson(String json) {
    return ensureInitialized().decodeJson<Camera>(json);
  }
}

mixin CameraMappable {
  String toJson() {
    return CameraMapper.ensureInitialized().encodeJson<Camera>(this as Camera);
  }

  Map<String, dynamic> toMap() {
    return CameraMapper.ensureInitialized().encodeMap<Camera>(this as Camera);
  }

  CameraCopyWith<Camera, Camera, Camera> get copyWith =>
      _CameraCopyWithImpl<Camera, Camera>(this as Camera, $identity, $identity);
  @override
  String toString() {
    return CameraMapper.ensureInitialized().stringifyValue(this as Camera);
  }

  @override
  bool operator ==(Object other) {
    return CameraMapper.ensureInitialized().equalsValue(this as Camera, other);
  }

  @override
  int get hashCode {
    return CameraMapper.ensureInitialized().hashValue(this as Camera);
  }
}

extension CameraValueCopy<$R, $Out> on ObjectCopyWith<$R, Camera, $Out> {
  CameraCopyWith<$R, Camera, $Out> get $asCamera =>
      $base.as((v, t, t2) => _CameraCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CameraCopyWith<$R, $In extends Camera, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? id, String? name, String? rtspUrl, bool? detectionEnabled});
  CameraCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CameraCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Camera, $Out>
    implements CameraCopyWith<$R, Camera, $Out> {
  _CameraCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Camera> $mapper = CameraMapper.ensureInitialized();
  @override
  $R call({int? id, String? name, String? rtspUrl, bool? detectionEnabled}) =>
      $apply(
        FieldCopyWithData({
          if (id != null) #id: id,
          if (name != null) #name: name,
          if (rtspUrl != null) #rtspUrl: rtspUrl,
          if (detectionEnabled != null) #detectionEnabled: detectionEnabled,
        }),
      );
  @override
  Camera $make(CopyWithData data) => Camera(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    rtspUrl: data.get(#rtspUrl, or: $value.rtspUrl),
    detectionEnabled: data.get(#detectionEnabled, or: $value.detectionEnabled),
  );

  @override
  CameraCopyWith<$R2, Camera, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CameraCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

