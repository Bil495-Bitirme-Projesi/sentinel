import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:sentinel/config/app_config.dart';

/// MinIO nesne depolama servisi için Dio HTTP client singleton'ı.
///
/// CmsClient'tan bilinçli olarak ayrılmıştır:
/// - Auth mekanizması farklıdır (presigned URL → query param tabanlı, Bearer yok)
/// - Timeout değerleri çok daha uzundur (büyük dosya transferleri)
/// - Content-Type varsayılan olarak tanımlanmaz (upload türüne göre değişir)
///
/// Kullanım:
///   await MinioClient.init();   ← main() içinde, runApp'tan önce bir kez çağrılır
///
///   // Backend'den presigned URL alınır, ardından:
///   await MinioClient.instance.put(
///     presignedUrl,
///     data: Stream.fromIterable([bytes]),
///     options: Options(headers: {'Content-Type': 'image/jpeg'}),
///   );
class MinioClient {
  MinioClient._();

  static Dio? _instance;

  static Dio get instance {
    assert(_instance != null, 'MinioClient.init() henüz çağrılmadı!');
    return _instance!;
  }

  /// Sertifikayı assets'ten yükler ve Dio'yu MinIO için yapılandırır.
  /// [main()] içinde [runApp]'tan önce bir kez çağrılmalıdır.
  static Future<void> init() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.minioBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        // Büyük dosya yükleme/indirme için uzun timeout
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
        // Content-Type her operasyonda (upload/download) ayrıca belirtilir;
        // varsayılan header tanımlamıyoruz.
      ),
    );

    // Self-signed sertifikayı Dart TLS katmanına tanıt
    final certBytes = await rootBundle.load('assets/certs/server.crt');
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final context = SecurityContext(withTrustedRoots: true);
      context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
      return HttpClient(context: context);
    };

    // NOT: AuthInterceptor eklenmez.
    // MinIO auth'u presigned URL'deki query param'larla (X-Amz-Signature vb.)
    // ya da backend'den alınan geçici token ile sağlanır.

    // Geliştirme ortamında tüm istek/cevapları konsola yaz
    if (AppConfig.isDevelopment) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,   // binary body'yi loglamak gereksiz
          responseBody: false,
          logPrint: (obj) => print('[MINIO] $obj'),
        ),
      );
    }

    _instance = dio;
  }
}

