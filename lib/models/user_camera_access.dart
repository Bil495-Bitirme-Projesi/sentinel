import 'package:dart_mappable/dart_mappable.dart';

part 'user_camera_access.mapper.dart';

/// GET /api/admin/access/{userId} yanıtındaki her bir kayıt.
/// Backend şeması: UserCameraAccessResponse
@MappableClass()
class UserCameraAccess with UserCameraAccessMappable {
  final int id;
  final int userId;
  final String userName;
  final String userEmail;
  final int cameraId;
  final String cameraName;

  const UserCameraAccess({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.cameraId,
    required this.cameraName,
  });

  static UserCameraAccess fromJson(Map<String, dynamic> map) =>
      UserCameraAccessMapper.fromMap(map);
}