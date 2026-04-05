import 'package:dio/dio.dart';
import 'package:sentinel/core/network/cms_client.dart';
import 'package:sentinel/models/create_user_request.dart';
import 'package:sentinel/models/update_user_request.dart';
import 'package:sentinel/models/user.dart';
import 'package:sentinel/models/user_camera_access.dart';

/// Kullanıcı ile ilgili API çağrılarını yönetir.
///
/// Kullanım:
///   final user = await UserService.instance.getUser(42);
///   final users = await UserService.instance.getUsers();
class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final Dio _cms = CmsClient.instance;

  // ---------------------------------------------------------------------------
  // GET /api/admin/users/{id}
  // ---------------------------------------------------------------------------

  /// ID'ye göre tek kullanıcı getirir.
  Future<User> getUser(int userId) async {
    final response = await _cms.get('/admin/users/$userId');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // GET /api/admin/users
  // ---------------------------------------------------------------------------

  /// Tüm kullanıcıları listeler. Hiç yoksa boş liste döner.
  Future<List<User>> getUsers() async {
    final response = await _cms.get('/admin/users');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // POST /api/admin/users  →  201 Created
  // ---------------------------------------------------------------------------

  /// Yeni kullanıcı oluşturur.
  ///
  /// [request.email] sistemde benzersiz olmalıdır; aksi hâlde backend 409 döner.
  Future<User> createUser(CreateUserRequest request) async {
    final response = await _cms.post(
      '/admin/users',
      data: request.toJson(),
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // PUT /api/admin/users/{id}  →  200 OK
  // ---------------------------------------------------------------------------

  /// Kullanıcı bilgilerini kısmi olarak günceller.
  ///
  /// [request] içinde null bırakılan alanlar request body'ye dahil edilmez.
  Future<User> updateUser(int userId, UpdateUserRequest request) async {
    final response = await _cms.put(
      '/admin/users/$userId',
      data: request.toJson(),
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // DELETE /api/admin/users/{id}  →  204 No Content
  // ---------------------------------------------------------------------------

  /// Kullanıcıyı kalıcı olarak siler.
  Future<void> deleteUser(int userId) async {
    await _cms.delete('/admin/users/$userId');
  }

  // ---------------------------------------------------------------------------
  // GET /api/admin/access/{userId}
  // ---------------------------------------------------------------------------

  /// Kullanıcıya atanmış kamera erişim kayıtlarını döner.
  Future<List<UserCameraAccess>> getUserCameraAccess(int userId) async {
    final response = await _cms.get('/admin/access/$userId');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => UserCameraAccess.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // POST /api/admin/access/grant?userId=&cameraId=  →  201 Created
  // ---------------------------------------------------------------------------

  /// Kullanıcıya belirtilen kameraya erişim yetkisi verir.
  ///
  /// Kullanıcı zaten yetkili ise backend 409 döner.
  Future<void> grantCameraAccess({
    required int userId,
    required int cameraId,
  }) async {
    await _cms.post(
      '/admin/access/grant',
      queryParameters: {'userId': userId, 'cameraId': cameraId},
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE /api/admin/access/revoke?userId=&cameraId=  →  204 No Content
  // ---------------------------------------------------------------------------

  /// Kullanıcının belirtilen kameraya erişim yetkisini kaldırır.
  Future<void> revokeCameraAccess({
    required int userId,
    required int cameraId,
  }) async {
    await _cms.delete(
      '/admin/access/revoke',
      queryParameters: {'userId': userId, 'cameraId': cameraId},
    );
  }
}
