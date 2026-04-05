import 'package:dio/dio.dart';
import 'package:sentinel/core/auth/session_notifier.dart';
import 'package:sentinel/core/auth/session_storage.dart';

/// Her Dio isteğine otomatik olarak Bearer token ekler.
/// 401 cevabında oturumu temizler ve GoRouter'ı login'e yönlendirir.
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

  /// Hata cevabında çalışır → 401'de oturumu temizler, login'e yönlendirir.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      SessionStorage.sessionExpiredByServer = true; // login ekranı snackbar göstersin
      SessionStorage.clear();
      SessionNotifier.instance.onSessionChanged(); // GoRouter redirect'i tetikler
    }
    handler.next(err);
  }
}
