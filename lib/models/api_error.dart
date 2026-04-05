import 'package:dart_mappable/dart_mappable.dart';
import 'package:sentinel/core/network/http_error.dart';

part 'api_error.mapper.dart'; // build_runner tarafından otomatik üretilecek

/// Backend'in tüm hata cevaplarında döndürdüğü standart JSON şemasına karşılık gelir.
/// [HttpError]'dan türer → her zaman [status] field'ına garantili erişim sağlar.
///
/// Örnek JSON:
/// ```json
/// {
///   "timestamp": "2026-04-05T10:30:00Z",
///   "status":    403,
///   "error":     "Forbidden",
///   "message":   "Access denied",
///   "path":      "/admin/users/42"
/// }
/// ```
@MappableClass()
class ApiError extends HttpError with ApiErrorMappable {
  /// Hatanın sunucuda oluştuğu an (ISO-8601, UTC).
  final DateTime timestamp;

  /// HTTP durum kodu (ör. 400, 401, 403, 404, 500).
  @override
  final int status;

  /// Durum kodunun kısa açıklaması (ör. "Bad Request", "Unauthorized").
  final String error;

  /// Hatanın ayrıntılı açıklaması.
  @override
  final String message;

  /// İsteğin yapıldığı URL yolu (ör. "/admin/users/42").
  final String path;

  const ApiError({
    required this.timestamp,
    required this.status,
    required this.error,
    required this.message,
    required this.path,
  });

  /// Dio'nun döndürdüğü [response.data] map'inden modeli üretir.
  static ApiError fromJson(Map<String, dynamic> map) =>
      ApiErrorMapper.fromMap(map);

  @override
  String toString() =>
      'ApiError(status: $status, error: $error, message: $message, path: $path)';
}
