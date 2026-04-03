/// Bearer token'ı ve sona erme zamanını bellekte tutan merkezi yer.
///
/// Kullanım:
///   TokenStorage.set(token, expiresIn: 3600000)  → login sonrası
///   TokenStorage.clear()                          → logout sonrası
///   TokenStorage.get()    → geçerli token (süresi dolmuşsa null döner)
///   TokenStorage.hasToken → token var ve süresi dolmamış mı?
class TokenStorage {
  TokenStorage._();

  static String? _token;
  static DateTime? _expiresAt;

  /// Token'ı ve sona erme süresini kaydeder.
  /// [expiresInMs] milisaniye cinsindendir (API'nin döndürdüğü expiresIn değeri).
  static void set(String token, {required int expiresInMs}) {
    _token = token;
    _expiresAt = DateTime.now().add(Duration(milliseconds: expiresInMs));
  }

  /// Geçerli token'ı döndürür.
  /// Token yoksa veya süresi dolmuşsa null döner ve depoyu temizler.
  static String? get() {
    if (_token == null) return null;
    if (_expiresAt != null && DateTime.now().isAfter(_expiresAt!)) {
      clear(); // süresi geçmiş → temizle
      return null;
    }
    return _token;
  }

  static void clear() {
    _token = null;
    _expiresAt = null;
  }

  /// Token var ve süresi dolmamışsa true döner.
  static bool get hasToken => get() != null;

  /// Token'ın ne kadar süresi kaldığını döndürür (null ise token yok/geçersiz).
  static Duration? get remainingTime {
    final token = get();
    if (token == null || _expiresAt == null) return null;
    return _expiresAt!.difference(DateTime.now());
  }
}

