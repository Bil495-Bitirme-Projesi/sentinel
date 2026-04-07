import 'package:dio/dio.dart';
import 'package:sentinel/core/network/cms_client.dart';
import 'package:sentinel/models/user_camera_access.dart';

/// Kullanıcı-kamera erişim işlemlerini yönetir.
/// GET /api/admin/access/{userId}
/// POST /api/admin/access/grant
/// DELETE /api/admin/access/revoke
class UserCameraAccessService {
  UserCameraAccessService._();

  static final UserCameraAccessService instance = UserCameraAccessService._();

  final Dio _cms = CmsClient.instance;

  /// Kullanıcıya atanmış kamera erişim kayıtlarını döner.
  Future<List<UserCameraAccess>> getUserAccessList(int userId) async {
    final response = await _cms.get('/admin/access/$userId');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => UserCameraAccess.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Kullanıcıya belirtilen kameraya erişim yetkisi verir.
  Future<void> grantAccess(int userId, int cameraId) async {
    await _cms.post(
      '/admin/access/grant',
      queryParameters: {'userId': userId, 'cameraId': cameraId},
    );
  }

  /// Kullanıcının belirtilen kameraya erişim yetkisini kaldırır.
  Future<void> revokeAccess(int userId, int cameraId) async {
    await _cms.delete(
      '/admin/access/revoke',
      queryParameters: {'userId': userId, 'cameraId': cameraId},
    );
  }
}

