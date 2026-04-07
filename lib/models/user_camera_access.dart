import 'package:dart_mappable/dart_mappable.dart';

part 'user_camera_access.mapper.dart';

@MappableClass()
class UserCameraAccess with UserCameraAccessMappable {
  final int id;
  final int userId;
  final String userName;
  final String userEmail;
  final int cameraId;
  final String cameraName;

  UserCameraAccess({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.cameraId,
    required this.cameraName,
  });
}