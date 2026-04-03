import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:sentinel/config/app_config.dart';
import 'package:sentinel/core/network/auth_interceptor.dart';

/// Uygulama genelinde kullanılan Dio HTTP client singleton'ı.
///
/// Kullanım:
///   await DioClient.init();   ← main() içinde, runApp'tan önce bir kez çağrılır
///   DioClient.instance.get('/users');
class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio get instance {
    assert(_instance != null, 'DioClient.init() henüz çağrılmadı!');
    return _instance!;
  }

  /// Sertifikayı assets'ten yükler ve Dio'yu yapılandırır.
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
          logPrint: (obj) => print('[DIO] $obj'),
        ),
      );
    }

    _instance = dio;
  }
}

