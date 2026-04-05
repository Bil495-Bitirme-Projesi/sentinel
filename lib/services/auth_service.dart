import 'package:dio/dio.dart';
import 'package:sentinel/core/auth/session_storage.dart';
import 'package:sentinel/core/network/cms_client.dart';
import 'package:sentinel/models/auth_response.dart';
import 'package:sentinel/models/user.dart';

/// Kimlik doğrulama ile ilgili API çağrılarını yönetir.
///
/// Kullanım:
///   await AuthService.instance.login(email: '...', password: '...');
///   // Ardından SessionStorage.currentUser erişilebilir olur.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final Dio _cms = CmsClient.instance;

  /// POST /api/auth/login
  ///
  /// Başarılı girişte token [SessionStorage]'a yazılır, ardından [getMe]
  /// çağrılarak [SessionStorage.currentUser] doldurulur.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _cms.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final authResponse =
        AuthResponse.fromJson(response.data as Map<String, dynamic>);

    // Token'ı kaydet; bundan sonra interceptor her isteğe header ekler.
    SessionStorage.setToken(
      authResponse.token,
      expiresInMs: authResponse.expiresIn,
    );

    // currentUser'ı doldur (token artık SessionStorage'da, interceptor çalışır).
    await getMe();
  }

  /// GET /api/auth/me
  ///
  /// Oturum açmış kullanıcının kendi bilgilerini döner ve
  /// [SessionStorage.currentUser]'ı günceller.
  Future<User> getMe() async {
    final response = await _cms.get('/auth/me');
    final user = User.fromJson(response.data as Map<String, dynamic>);
    SessionStorage.currentUser = user;
    return user;
  }

  /// Oturumu kapatır.
  void logout() => SessionStorage.clear();
}
