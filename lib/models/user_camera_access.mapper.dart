// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user_camera_access.dart';

class UserCameraAccessMapper extends ClassMapperBase<UserCameraAccess> {
  UserCameraAccessMapper._();

  static UserCameraAccessMapper? _instance;
  static UserCameraAccessMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserCameraAccessMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UserCameraAccess';

  static int _$id(UserCameraAccess v) => v.id;
  static const Field<UserCameraAccess, int> _f$id = Field('id', _$id);
  static int _$userId(UserCameraAccess v) => v.userId;
  static const Field<UserCameraAccess, int> _f$userId = Field(
    'userId',
    _$userId,
  );
  static String _$userName(UserCameraAccess v) => v.userName;
  static const Field<UserCameraAccess, String> _f$userName = Field(
    'userName',
    _$userName,
  );
  static String _$userEmail(UserCameraAccess v) => v.userEmail;
  static const Field<UserCameraAccess, String> _f$userEmail = Field(
    'userEmail',
    _$userEmail,
  );
  static int _$cameraId(UserCameraAccess v) => v.cameraId;
  static const Field<UserCameraAccess, int> _f$cameraId = Field(
    'cameraId',
    _$cameraId,
  );
  static String _$cameraName(UserCameraAccess v) => v.cameraName;
  static const Field<UserCameraAccess, String> _f$cameraName = Field(
    'cameraName',
    _$cameraName,
  );

  @override
  final MappableFields<UserCameraAccess> fields = const {
    #id: _f$id,
    #userId: _f$userId,
    #userName: _f$userName,
    #userEmail: _f$userEmail,
    #cameraId: _f$cameraId,
    #cameraName: _f$cameraName,
  };

  static UserCameraAccess _instantiate(DecodingData data) {
    return UserCameraAccess(
      id: data.dec(_f$id),
      userId: data.dec(_f$userId),
      userName: data.dec(_f$userName),
      userEmail: data.dec(_f$userEmail),
      cameraId: data.dec(_f$cameraId),
      cameraName: data.dec(_f$cameraName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UserCameraAccess fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserCameraAccess>(map);
  }

  static UserCameraAccess fromJson(String json) {
    return ensureInitialized().decodeJson<UserCameraAccess>(json);
  }
}

mixin UserCameraAccessMappable {
  String toJson() {
    return UserCameraAccessMapper.ensureInitialized()
        .encodeJson<UserCameraAccess>(this as UserCameraAccess);
  }

  Map<String, dynamic> toMap() {
    return UserCameraAccessMapper.ensureInitialized()
        .encodeMap<UserCameraAccess>(this as UserCameraAccess);
  }

  UserCameraAccessCopyWith<UserCameraAccess, UserCameraAccess, UserCameraAccess>
  get copyWith =>
      _UserCameraAccessCopyWithImpl<UserCameraAccess, UserCameraAccess>(
        this as UserCameraAccess,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UserCameraAccessMapper.ensureInitialized().stringifyValue(
      this as UserCameraAccess,
    );
  }

  @override
  bool operator ==(Object other) {
    return UserCameraAccessMapper.ensureInitialized().equalsValue(
      this as UserCameraAccess,
      other,
    );
  }

  @override
  int get hashCode {
    return UserCameraAccessMapper.ensureInitialized().hashValue(
      this as UserCameraAccess,
    );
  }
}

extension UserCameraAccessValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UserCameraAccess, $Out> {
  UserCameraAccessCopyWith<$R, UserCameraAccess, $Out>
  get $asUserCameraAccess =>
      $base.as((v, t, t2) => _UserCameraAccessCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserCameraAccessCopyWith<$R, $In extends UserCameraAccess, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    int? userId,
    String? userName,
    String? userEmail,
    int? cameraId,
    String? cameraName,
  });
  UserCameraAccessCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UserCameraAccessCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserCameraAccess, $Out>
    implements UserCameraAccessCopyWith<$R, UserCameraAccess, $Out> {
  _UserCameraAccessCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserCameraAccess> $mapper =
      UserCameraAccessMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    int? userId,
    String? userName,
    String? userEmail,
    int? cameraId,
    String? cameraName,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (userId != null) #userId: userId,
      if (userName != null) #userName: userName,
      if (userEmail != null) #userEmail: userEmail,
      if (cameraId != null) #cameraId: cameraId,
      if (cameraName != null) #cameraName: cameraName,
    }),
  );
  @override
  UserCameraAccess $make(CopyWithData data) => UserCameraAccess(
    id: data.get(#id, or: $value.id),
    userId: data.get(#userId, or: $value.userId),
    userName: data.get(#userName, or: $value.userName),
    userEmail: data.get(#userEmail, or: $value.userEmail),
    cameraId: data.get(#cameraId, or: $value.cameraId),
    cameraName: data.get(#cameraName, or: $value.cameraName),
  );

  @override
  UserCameraAccessCopyWith<$R2, UserCameraAccess, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UserCameraAccessCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

