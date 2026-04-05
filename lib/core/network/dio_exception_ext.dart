import 'package:dio/dio.dart';
import 'package:sentinel/core/network/http_error.dart';
import 'package:sentinel/models/api_error.dart';

/// [DioException] üzerinde kolaylık sağlayan extension'lar.
extension DioExceptionX on DioException {
  /// Her durumda bir [HttpError] türevi döndürür; asla null dönmez.
  ///
  /// - Backend beklenen JSON şemasında cevap verdiyse → [ApiError]
  /// - Ağ hatası / zaman aşımı / farklı format → [NetworkError]
  ///
  /// Kullanım (State / ViewModel):
  /// ```dart
  /// on DioException catch (e) {
  ///   final err = e.toHttpError();
  ///   if (err is ApiError) {
  ///     // Yapılandırılmış hata: err.path, err.error, err.timestamp...
  ///   }
  ///   showSnackbar(err.message);   // Her iki durumda da çalışır
  ///   print(err.status);           // Her iki durumda da erişilebilir (null olabilir)
  /// }
  /// ```
  HttpError toHttpError() {
    // Önce backend'den gelen yapılandırılmış hatayı parse etmeye çalış
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      try {
        return ApiError.fromJson(data);
      } catch (_) {
        // Parse başarısız → NetworkError'a düş
      }
    }

    // Ağ hatası, zaman aşımı veya parse edilemeyen yanıt
    return NetworkError(
      status:  response?.statusCode,
      dioType: type,
    );
  }
}
