import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:sentinel/config/app_config.dart';
import 'package:sentinel/core/network/auth_interceptor.dart';

/// Backend CMS REST API için Dio HTTP client singleton'ı.
///
/// - Bearer token'ı otomatik ekler ([AuthInterceptor])
/// - Self-signed TLS sertifikasını doğrular
///
/// Kullanım:
///   await CmsClient.init();   ← main() içinde, runApp'tan önce bir kez çağrılır
///   CmsClient.instance.get('/users');
class CmsClient {
  CmsClient._();

  static Dio? _instance;

  static Dio get instance {
    assert(_instance != null, 'CmsClient.init() henüz çağrılmadı!');
    return _instance!;
  }

  /// Sertifikayı assets'ten yükler ve Dio'yu CMS API için yapılandırır.
  /// [main()] içinde [runApp]'tan önce bir kez çağrılmalıdır.
  static Future<void> init() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Self-signed sertifikayı Dart TLS katmanına tanıt
    final certBytes = await rootBundle.load('assets/certs/server.crt');
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final context = SecurityContext(withTrustedRoots: true);
      context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
      return HttpClient(context: context);
    };

    // Auth interceptor: her isteğe otomatik Bearer token ekler, 401'de temizler
    dio.interceptors.add(AuthInterceptor());

    // Geliştirme ortamında tüm istek/cevapları konsola yaz
    if (AppConfig.isDevelopment) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => print('[CMS] $obj'),
        ),
      );
    }

    _instance = dio;
  }
}

