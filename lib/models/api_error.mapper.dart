// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'api_error.dart';

class ApiErrorMapper extends ClassMapperBase<ApiError> {
  ApiErrorMapper._();

  static ApiErrorMapper? _instance;
  static ApiErrorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ApiErrorMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ApiError';

  static DateTime _$timestamp(ApiError v) => v.timestamp;
  static const Field<ApiError, DateTime> _f$timestamp = Field(
    'timestamp',
    _$timestamp,
  );
  static int _$status(ApiError v) => v.status;
  static const Field<ApiError, int> _f$status = Field('status', _$status);
  static String _$error(ApiError v) => v.error;
  static const Field<ApiError, String> _f$error = Field('error', _$error);
  static String _$message(ApiError v) => v.message;
  static const Field<ApiError, String> _f$message = Field('message', _$message);
  static String _$path(ApiError v) => v.path;
  static const Field<ApiError, String> _f$path = Field('path', _$path);

  @override
  final MappableFields<ApiError> fields = const {
    #timestamp: _f$timestamp,
    #status: _f$status,
    #error: _f$error,
    #message: _f$message,
    #path: _f$path,
  };

  static ApiError _instantiate(DecodingData data) {
    return ApiError(
      timestamp: data.dec(_f$timestamp),
      status: data.dec(_f$status),
      error: data.dec(_f$error),
      message: data.dec(_f$message),
      path: data.dec(_f$path),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ApiError fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ApiError>(map);
  }

  static ApiError fromJson(String json) {
    return ensureInitialized().decodeJson<ApiError>(json);
  }
}

mixin ApiErrorMappable {
  String toJson() {
    return ApiErrorMapper.ensureInitialized().encodeJson<ApiError>(
      this as ApiError,
    );
  }

  Map<String, dynamic> toMap() {
    return ApiErrorMapper.ensureInitialized().encodeMap<ApiError>(
      this as ApiError,
    );
  }

  ApiErrorCopyWith<ApiError, ApiError, ApiError> get copyWith =>
      _ApiErrorCopyWithImpl<ApiError, ApiError>(
        this as ApiError,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ApiErrorMapper.ensureInitialized().stringifyValue(this as ApiError);
  }

  @override
  bool operator ==(Object other) {
    return ApiErrorMapper.ensureInitialized().equalsValue(
      this as ApiError,
      other,
    );
  }

  @override
  int get hashCode {
    return ApiErrorMapper.ensureInitialized().hashValue(this as ApiError);
  }
}

extension ApiErrorValueCopy<$R, $Out> on ObjectCopyWith<$R, ApiError, $Out> {
  ApiErrorCopyWith<$R, ApiError, $Out> get $asApiError =>
      $base.as((v, t, t2) => _ApiErrorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ApiErrorCopyWith<$R, $In extends ApiError, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    DateTime? timestamp,
    int? status,
    String? error,
    String? message,
    String? path,
  });
  ApiErrorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ApiErrorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ApiError, $Out>
    implements ApiErrorCopyWith<$R, ApiError, $Out> {
  _ApiErrorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ApiError> $mapper =
      ApiErrorMapper.ensureInitialized();
  @override
  $R call({
    DateTime? timestamp,
    int? status,
    String? error,
    String? message,
    String? path,
  }) => $apply(
    FieldCopyWithData({
      if (timestamp != null) #timestamp: timestamp,
      if (status != null) #status: status,
      if (error != null) #error: error,
      if (message != null) #message: message,
      if (path != null) #path: path,
    }),
  );
  @override
  ApiError $make(CopyWithData data) => ApiError(
    timestamp: data.get(#timestamp, or: $value.timestamp),
    status: data.get(#status, or: $value.status),
    error: data.get(#error, or: $value.error),
    message: data.get(#message, or: $value.message),
    path: data.get(#path, or: $value.path),
  );

  @override
  ApiErrorCopyWith<$R2, ApiError, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ApiErrorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

