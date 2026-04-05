import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token'ı ve son kullanma zamanını cihazın güvenli deposuna (Android Keystore /
/// iOS Keychain) yazar.
///
/// Bu sınıf yalnızca kalıcı depolama katmanıdır; in-memory oturum durumu için
/// [SessionStorage] kullanılır.
class SecureTokenStore {
  SecureTokenStore._();

  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_token';
  static const _keyExpiresAt = 'auth_expires_at'; // ISO 8601

  /// Token ve son kullanma zamanını kalıcı olarak kaydeder.
  ///
  /// [expiresInMs]: token'ın [DateTime.now()]'dan itibaren geçerlilik süresi (ms).
  static Future<void> save(String token, {required int expiresInMs}) async {
    final expiresAt = DateTime.now().add(Duration(milliseconds: expiresInMs));
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyExpiresAt, value: expiresAt.toIso8601String());
  }

  /// Depodan token'ı okur.
  ///
  /// Token yoksa veya süresi dolmuşsa null döner ve depoyu temizler.
  static Future<String?> read() async {
    final token = await _storage.read(key: _keyToken);
    if (token == null) return null;

    final expiresAtRaw = await _storage.read(key: _keyExpiresAt);
    if (expiresAtRaw != null) {
      final expiresAt = DateTime.tryParse(expiresAtRaw);
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        await delete(); // süresi geçmiş → temizle
        return null;
      }
    }
    return token;
  }

  /// Son kullanma zamanını okur. Yoksa null döner.
  static Future<DateTime?> readExpiresAt() async {
    final raw = await _storage.read(key: _keyExpiresAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Token ve son kullanma zamanını depodan siler (logout).
  static Future<void> delete() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyExpiresAt);
  }
}

