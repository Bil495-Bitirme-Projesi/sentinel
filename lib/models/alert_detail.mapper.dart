// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'alert_detail.dart';

class AlertDetailMapper extends ClassMapperBase<AlertDetail> {
  AlertDetailMapper._();

  static AlertDetailMapper? _instance;
  static AlertDetailMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AlertDetailMapper._());
      AlertStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AlertDetail';

  static int _$id(AlertDetail v) => v.id;
  static const Field<AlertDetail, int> _f$id = Field('id', _$id);
  static int _$eventId(AlertDetail v) => v.eventId;
  static const Field<AlertDetail, int> _f$eventId = Field('eventId', _$eventId);
  static int _$cameraId(AlertDetail v) => v.cameraId;
  static const Field<AlertDetail, int> _f$cameraId = Field(
    'cameraId',
    _$cameraId,
  );
  static String? _$cameraName(AlertDetail v) => v.cameraName;
  static const Field<AlertDetail, String> _f$cameraName = Field(
    'cameraName',
    _$cameraName,
    opt: true,
  );
  static DateTime _$timestamp(AlertDetail v) => v.timestamp;
  static const Field<AlertDetail, DateTime> _f$timestamp = Field(
    'timestamp',
    _$timestamp,
  );
  static double _$score(AlertDetail v) => v.score;
  static const Field<AlertDetail, double> _f$score = Field('score', _$score);
  static String _$type(AlertDetail v) => v.type;
  static const Field<AlertDetail, String> _f$type = Field('type', _$type);
  static String? _$description(AlertDetail v) => v.description;
  static const Field<AlertDetail, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static String? _$clipObjectKey(AlertDetail v) => v.clipObjectKey;
  static const Field<AlertDetail, String> _f$clipObjectKey = Field(
    'clipObjectKey',
    _$clipObjectKey,
    opt: true,
  );
  static AlertStatus _$status(AlertDetail v) => v.status;
  static const Field<AlertDetail, AlertStatus> _f$status = Field(
    'status',
    _$status,
  );

  @override
  final MappableFields<AlertDetail> fields = const {
    #id: _f$id,
    #eventId: _f$eventId,
    #cameraId: _f$cameraId,
    #cameraName: _f$cameraName,
    #timestamp: _f$timestamp,
    #score: _f$score,
    #type: _f$type,
    #description: _f$description,
    #clipObjectKey: _f$clipObjectKey,
    #status: _f$status,
  };

  static AlertDetail _instantiate(DecodingData data) {
    return AlertDetail(
      id: data.dec(_f$id),
      eventId: data.dec(_f$eventId),
      cameraId: data.dec(_f$cameraId),
      cameraName: data.dec(_f$cameraName),
      timestamp: data.dec(_f$timestamp),
      score: data.dec(_f$score),
      type: data.dec(_f$type),
      description: data.dec(_f$description),
      clipObjectKey: data.dec(_f$clipObjectKey),
      status: data.dec(_f$status),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AlertDetail fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AlertDetail>(map);
  }

  static AlertDetail fromJson(String json) {
    return ensureInitialized().decodeJson<AlertDetail>(json);
  }
}

mixin AlertDetailMappable {
  String toJson() {
    return AlertDetailMapper.ensureInitialized().encodeJson<AlertDetail>(
      this as AlertDetail,
    );
  }

  Map<String, dynamic> toMap() {
    return AlertDetailMapper.ensureInitialized().encodeMap<AlertDetail>(
      this as AlertDetail,
    );
  }

  AlertDetailCopyWith<AlertDetail, AlertDetail, AlertDetail> get copyWith =>
      _AlertDetailCopyWithImpl<AlertDetail, AlertDetail>(
        this as AlertDetail,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AlertDetailMapper.ensureInitialized().stringifyValue(
      this as AlertDetail,
    );
  }

  @override
  bool operator ==(Object other) {
    return AlertDetailMapper.ensureInitialized().equalsValue(
      this as AlertDetail,
      other,
    );
  }

  @override
  int get hashCode {
    return AlertDetailMapper.ensureInitialized().hashValue(this as AlertDetail);
  }
}

extension AlertDetailValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AlertDetail, $Out> {
  AlertDetailCopyWith<$R, AlertDetail, $Out> get $asAlertDetail =>
      $base.as((v, t, t2) => _AlertDetailCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AlertDetailCopyWith<$R, $In extends AlertDetail, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    int? eventId,
    int? cameraId,
    String? cameraName,
    DateTime? timestamp,
    double? score,
    String? type,
    String? description,
    String? clipObjectKey,
    AlertStatus? status,
  });
  AlertDetailCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AlertDetailCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AlertDetail, $Out>
    implements AlertDetailCopyWith<$R, AlertDetail, $Out> {
  _AlertDetailCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AlertDetail> $mapper =
      AlertDetailMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    int? eventId,
    int? cameraId,
    Object? cameraName = $none,
    DateTime? timestamp,
    double? score,
    String? type,
    Object? description = $none,
    Object? clipObjectKey = $none,
    AlertStatus? status,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (eventId != null) #eventId: eventId,
      if (cameraId != null) #cameraId: cameraId,
      if (cameraName != $none) #cameraName: cameraName,
      if (timestamp != null) #timestamp: timestamp,
      if (score != null) #score: score,
      if (type != null) #type: type,
      if (description != $none) #description: description,
      if (clipObjectKey != $none) #clipObjectKey: clipObjectKey,
      if (status != null) #status: status,
    }),
  );
  @override
  AlertDetail $make(CopyWithData data) => AlertDetail(
    id: data.get(#id, or: $value.id),
    eventId: data.get(#eventId, or: $value.eventId),
    cameraId: data.get(#cameraId, or: $value.cameraId),
    cameraName: data.get(#cameraName, or: $value.cameraName),
    timestamp: data.get(#timestamp, or: $value.timestamp),
    score: data.get(#score, or: $value.score),
    type: data.get(#type, or: $value.type),
    description: data.get(#description, or: $value.description),
    clipObjectKey: data.get(#clipObjectKey, or: $value.clipObjectKey),
    status: data.get(#status, or: $value.status),
  );

  @override
  AlertDetailCopyWith<$R2, AlertDetail, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AlertDetailCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

