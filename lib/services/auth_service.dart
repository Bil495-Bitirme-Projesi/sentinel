import 'package:dio/dio.dart';
import 'package:sentinel/core/auth/secure_token_store.dart';
import 'package:sentinel/core/auth/session_notifier.dart';
import 'package:sentinel/core/auth/session_storage.dart';
import 'package:sentinel/core/network/cms_client.dart';
import 'package:sentinel/models/auth_response.dart';
import 'package:sentinel/models/user.dart';
import 'package:sentinel/services/notification_service.dart';

/// Kimlik doğrulama ile ilgili API çağrılarını yönetir.
///
/// Kullanım:
///   await AuthService.instance.login(email: '...', password: '...');
///   // Ardından SessionStorage.currentUser erişilebilir olur.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final Dio _cms = CmsClient.instance;

  // ---------------------------------------------------------------------------
  // POST /api/auth/login
  // ---------------------------------------------------------------------------

  /// Başarılı girişte token [SecureTokenStore]'a ve [SessionStorage]'a yazılır,
  /// ardından [getMe] çağrılarak [SessionStorage.currentUser] doldurulur.
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

    // Kalıcı depoya yaz (uygulama kapatılsa da token korunur).
    await SecureTokenStore.save(
      authResponse.token,
      expiresInMs: authResponse.expiresIn,
    );

    // In-memory oturumu başlat.
    SessionStorage.setToken(
      authResponse.token,
      expiresInMs: authResponse.expiresIn,
    );

    // currentUser'ı doldur (token artık SessionStorage'da, interceptor çalışır).
    await getMe();

    // FCM token'ını al ve backend'e kaydet.
    // Hata durumunda sessizce geç — FCM başarısızlığı login'i bloklamaz.
    try {
      await NotificationService.instance.init();
    } catch (_) {
      // Bildirim servisi başlatılamadı; uygulama kullanılabilir olmaya devam eder.
    }
  }

  // ---------------------------------------------------------------------------
  // GET /api/auth/me
  // ---------------------------------------------------------------------------

  /// Oturum açmış kullanıcının kendi bilgilerini döner ve
  /// [SessionStorage.currentUser]'ı günceller.
  Future<User> getMe() async {
    final response = await _cms.get('/auth/me');
    final user = User.fromJson(response.data as Map<String, dynamic>);
    SessionStorage.currentUser = user;
    return user;
  }

  // ---------------------------------------------------------------------------
  // Uygulama başlangıcı: oturumu geri yükle
  // ---------------------------------------------------------------------------

  /// Uygulama açılışında kalıcı depodan token okur ve geçerliyse oturumu
  /// geri yükler.
  ///
  /// Dönüş değeri:
  /// - `true`  → token geçerli, [SessionStorage] dolu, kullanıcı direkt içeriye alınabilir.
  /// - `false` → token yok/geçersiz/401, login ekranı gösterilmeli.
  ///
  /// [CmsClient.init()] çağrısından SONRA, [runApp()] çağrısından ÖNCE
  /// çağrılmalıdır.
  static Future<bool> tryRestoreSession() async {
    final token = await SecureTokenStore.read();
    if (token == null) return false;

    // Kalan süreyi hesapla.
    final expiresAt = await SecureTokenStore.readExpiresAt();
    final remainingMs = expiresAt != null
        ? expiresAt.difference(DateTime.now()).inMilliseconds
        : 0;

    if (remainingMs <= 0) {
      await SecureTokenStore.delete();
      return false;
    }

    // Token'ı in-memory'e yükle; interceptor artık çalışır.
    SessionStorage.setToken(token, expiresInMs: remainingMs);

    try {
      // /me ile hem token geçerliliğini doğrula hem de currentUser'ı doldur.
      await AuthService.instance.getMe();

      // Session geri yüklendi → FCM token'ını al ve backend'e kaydet.
      await NotificationService.instance.init();

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token sunucu tarafında geçersiz → her yeri temizle.
        await SecureTokenStore.delete();
        SessionStorage.clear();
      }
      return false;
    } catch (_) {
      // Ağ hatası vs. — token geçerli olabilir, ama şu an ulaşılamıyor.
      // Oturumu bellekte tutuyoruz, ama login ekranına yönlendirebilirsin.
      SessionStorage.clear();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Oturumu hem bellekten hem kalıcı depodan temizler.
  Future<void> logout() async {
    // FCM token'ını backend'den ve FCM sunucusundan sil.
    // Hata durumunda sessizce geçer — logout bloklanmaz.
    try {
      await NotificationService.instance.unregister();
    } catch (_) {
      // ignore: avoid_print
      print('[Auth] logout: unregister başarısız (sessizce geçildi)');
    }

    await SecureTokenStore.delete();
    SessionStorage.clear();
    SessionNotifier.instance.onSessionChanged(); // redirect guard login'e yönlendirir
  }
}
