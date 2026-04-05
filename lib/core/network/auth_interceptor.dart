import 'package:dio/dio.dart';
import 'package:sentinel/core/auth/session_storage.dart';

/// Her Dio isteğine otomatik olarak Bearer token ekler.
/// 401 cevabında oturumu temizler.
class AuthInterceptor extends Interceptor {
  /// Her istekten ÖNCE çalışır → Authorization header'ını ekler.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = SessionStorage.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Hata cevabında çalışır → 401'de oturumu temizler.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      SessionStorage.clear();
      // TODO: Global navigator ile login ekranına yönlendirme buraya eklenecek.
    }
    handler.next(err);
  }
}
