// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'alert_summary.dart';

class AlertSummaryMapper extends ClassMapperBase<AlertSummary> {
  AlertSummaryMapper._();

  static AlertSummaryMapper? _instance;
  static AlertSummaryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AlertSummaryMapper._());
      AlertStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AlertSummary';

  static int _$alertId(AlertSummary v) => v.alertId;
  static const Field<AlertSummary, int> _f$alertId = Field(
    'alertId',
    _$alertId,
  );
  static int _$eventId(AlertSummary v) => v.eventId;
  static const Field<AlertSummary, int> _f$eventId = Field(
    'eventId',
    _$eventId,
  );
  static int _$cameraId(AlertSummary v) => v.cameraId;
  static const Field<AlertSummary, int> _f$cameraId = Field(
    'cameraId',
    _$cameraId,
  );
  static String? _$cameraName(AlertSummary v) => v.cameraName;
  static const Field<AlertSummary, String> _f$cameraName = Field(
    'cameraName',
    _$cameraName,
    opt: true,
  );
  static DateTime _$timestamp(AlertSummary v) => v.timestamp;
  static const Field<AlertSummary, DateTime> _f$timestamp = Field(
    'timestamp',
    _$timestamp,
  );
  static String _$type(AlertSummary v) => v.type;
  static const Field<AlertSummary, String> _f$type = Field('type', _$type);
  static double _$score(AlertSummary v) => v.score;
  static const Field<AlertSummary, double> _f$score = Field('score', _$score);
  static String? _$description(AlertSummary v) => v.description;
  static const Field<AlertSummary, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static AlertStatus _$status(AlertSummary v) => v.status;
  static const Field<AlertSummary, AlertStatus> _f$status = Field(
    'status',
    _$status,
  );

  @override
  final MappableFields<AlertSummary> fields = const {
    #alertId: _f$alertId,
    #eventId: _f$eventId,
    #cameraId: _f$cameraId,
    #cameraName: _f$cameraName,
    #timestamp: _f$timestamp,
    #type: _f$type,
    #score: _f$score,
    #description: _f$description,
    #status: _f$status,
  };

  static AlertSummary _instantiate(DecodingData data) {
    return AlertSummary(
      alertId: data.dec(_f$alertId),
      eventId: data.dec(_f$eventId),
      cameraId: data.dec(_f$cameraId),
      cameraName: data.dec(_f$cameraName),
      timestamp: data.dec(_f$timestamp),
      type: data.dec(_f$type),
      score: data.dec(_f$score),
      description: data.dec(_f$description),
      status: data.dec(_f$status),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AlertSummary fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AlertSummary>(map);
  }

  static AlertSummary fromJson(String json) {
    return ensureInitialized().decodeJson<AlertSummary>(json);
  }
}

mixin AlertSummaryMappable {
  String toJson() {
    return AlertSummaryMapper.ensureInitialized().encodeJson<AlertSummary>(
      this as AlertSummary,
    );
  }

  Map<String, dynamic> toMap() {
    return AlertSummaryMapper.ensureInitialized().encodeMap<AlertSummary>(
      this as AlertSummary,
    );
  }

  AlertSummaryCopyWith<AlertSummary, AlertSummary, AlertSummary> get copyWith =>
      _AlertSummaryCopyWithImpl<AlertSummary, AlertSummary>(
        this as AlertSummary,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AlertSummaryMapper.ensureInitialized().stringifyValue(
      this as AlertSummary,
    );
  }

  @override
  bool operator ==(Object other) {
    return AlertSummaryMapper.ensureInitialized().equalsValue(
      this as AlertSummary,
      other,
    );
  }

  @override
  int get hashCode {
    return AlertSummaryMapper.ensureInitialized().hashValue(
      this as AlertSummary,
    );
  }
}

extension AlertSummaryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AlertSummary, $Out> {
  AlertSummaryCopyWith<$R, AlertSummary, $Out> get $asAlertSummary =>
      $base.as((v, t, t2) => _AlertSummaryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AlertSummaryCopyWith<$R, $In extends AlertSummary, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? alertId,
    int? eventId,
    int? cameraId,
    String? cameraName,
    DateTime? timestamp,
    String? type,
    double? score,
    String? description,
    AlertStatus? status,
  });
  AlertSummaryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AlertSummaryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AlertSummary, $Out>
    implements AlertSummaryCopyWith<$R, AlertSummary, $Out> {
  _AlertSummaryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AlertSummary> $mapper =
      AlertSummaryMapper.ensureInitialized();
  @override
  $R call({
    int? alertId,
    int? eventId,
    int? cameraId,
    Object? cameraName = $none,
    DateTime? timestamp,
    String? type,
    double? score,
    Object? description = $none,
    AlertStatus? status,
  }) => $apply(
    FieldCopyWithData({
      if (alertId != null) #alertId: alertId,
      if (eventId != null) #eventId: eventId,
      if (cameraId != null) #cameraId: cameraId,
      if (cameraName != $none) #cameraName: cameraName,
      if (timestamp != null) #timestamp: timestamp,
      if (type != null) #type: type,
      if (score != null) #score: score,
      if (description != $none) #description: description,
      if (status != null) #status: status,
    }),
  );
  @override
  AlertSummary $make(CopyWithData data) => AlertSummary(
    alertId: data.get(#alertId, or: $value.alertId),
    eventId: data.get(#eventId, or: $value.eventId),
    cameraId: data.get(#cameraId, or: $value.cameraId),
    cameraName: data.get(#cameraName, or: $value.cameraName),
    timestamp: data.get(#timestamp, or: $value.timestamp),
    type: data.get(#type, or: $value.type),
    score: data.get(#score, or: $value.score),
    description: data.get(#description, or: $value.description),
    status: data.get(#status, or: $value.status),
  );

  @override
  AlertSummaryCopyWith<$R2, AlertSummary, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AlertSummaryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

