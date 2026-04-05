import 'package:sentinel/models/user.dart';

/// Token yönetimini kapsayan iç (private) sınıf.
/// Dosya dışından erişilemez; yalnızca [SessionStorage] kullanır.
class _TokenStorage {
  _TokenStorage._();

  static String? _token;
  static DateTime? _expiresAt;

  static void set(String token, {required int expiresInMs}) {
    _token = token;
    _expiresAt = DateTime.now().add(Duration(milliseconds: expiresInMs));
  }

  /// Token yoksa veya süresi dolmuşsa null döner ve depoyu temizler.
  static String? get() {
    if (_token == null) return null;
    if (_expiresAt != null && DateTime.now().isAfter(_expiresAt!)) {
      clear();
      return null;
    }
    return _token;
  }

  static void clear() {
    _token = null;
    _expiresAt = null;
  }

  static bool get hasToken => get() != null;

  static Duration? get remainingTime {
    final t = get();
    if (t == null || _expiresAt == null) return null;
    return _expiresAt!.difference(DateTime.now());
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Oturum durumunu tutan merkezi depo.
///
/// Token ve mevcut kullanıcı bilgisi birlikte yönetilir.
///
/// Kullanım:
///   SessionStorage.set(token, expiresInMs: 3600000, user: user)  → login sonrası
///   SessionStorage.clear()                                         → logout sonrası
///   SessionStorage.token          → geçerli token (süresi dolmuşsa null)
///   SessionStorage.currentUser    → oturum açmış kullanıcı
///   SessionStorage.isLoggedIn     → token geçerli VE kullanıcı yüklüyse true
class SessionStorage {
  SessionStorage._();

  /// Oturum açmış kullanıcı (GET /api/auth/me yanıtı). Login yapılmamışsa null.
  static User? currentUser;

  /// true → oturum sunucu tarafından 401 ile sonlandırıldı.
  /// [AuthInterceptor] tarafından set edilir; [LoginScreen] okuyup sıfırlar.
  static bool sessionExpiredByServer = false;

  /// Token'ı, sona erme süresini ve kullanıcı bilgisini birlikte kaydeder.
  static void set(
    String token, {
    required int expiresInMs,
    required User user,
  }) {
    _TokenStorage.set(token, expiresInMs: expiresInMs);
    currentUser = user;
  }

  /// Sadece token'ı kaydeder; [currentUser] değişmez.
  ///
  /// Login akışında: önce bu çağrılır → ardından [AuthService.getMe()] token'ı
  /// kullanarak /me isteği atar → [currentUser] doldurulur.
  static void setToken(String token, {required int expiresInMs}) {
    _TokenStorage.set(token, expiresInMs: expiresInMs);
  }

  /// Oturumu tamamen temizler (logout).
  static void clear() {
    _TokenStorage.clear();
    currentUser = null;
  }

  /// Geçerli Bearer token'ı döner. Süresi dolmuşsa veya token yoksa null.
  static String? get token => _TokenStorage.get();

  /// Token geçerli VE currentUser yüklüyse true.
  static bool get isLoggedIn => _TokenStorage.hasToken && currentUser != null;

  /// Token'ın kalan geçerlilik süresi. Token yoksa null.
  static Duration? get tokenRemainingTime => _TokenStorage.remainingTime;
}


