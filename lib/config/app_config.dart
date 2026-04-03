/// Uygulama genelinde kullanılan konfigürasyon değerlerine
/// tek bir yerden erişimi sağlar.
///
/// Değerler build sırasında --dart-define-from-file ile enjekte edilir.
/// Örnek:
///   flutter run --dart-define-from-file=config/dev.json
///   flutter build apk --dart-define-from-file=config/prod.json
class AppConfig {
  AppConfig._(); // instantiate edilemez

  /// Backend API'nin base URL'i.
  /// Trailing slash içermez.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://192.168.137.1/api',
  );

  /// Hangi ortamda çalıştığını belirtir: 'development' | 'production'
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
}

