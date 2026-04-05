import 'package:dio/dio.dart';

/// Network katmanından gelen tüm hataların ortak tabanı.
///
/// Backend yapılandırılmış [ApiError] dönse de, bağlantı kopması /
/// zaman aşımı / farklı format gibi durumlarda [NetworkError] döner.
/// Her iki durumda da en azından [status] ve [message]'a erişebilirsin.
abstract class HttpError {
  const HttpError();

  /// HTTP durum kodu (ör. 403, 404). Ağ hatasında null olabilir.
  int? get status;

  /// Kullanıcıya / loglara gösterilebilecek hata açıklaması.
  /// Her alt sınıf kendi kaynağından üretir; asla null değildir.
  String get message;
}

/// Bağlantı hatası, zaman aşımı veya backend'in beklenen formattan farklı
/// bir yanıt döndürdüğü durumlarda kullanılır.
class NetworkError extends HttpError {
  @override
  final int? status;

  /// Dio'nun hata tipi (connectionTimeout, receiveTimeout, cancel, vb.)
  final DioExceptionType dioType;

  const NetworkError({
    this.status,
    required this.dioType,
  });

  /// [dioType]'tan türetilen insan-okunabilir açıklama.
  /// Dio'nun private `toPrettyDescription()` metodunun açık karşılığıdır.
  @override
  String get message => switch (dioType) {
    DioExceptionType.connectionTimeout => 'Connection timeout',
    DioExceptionType.sendTimeout       => 'Send timeout',
    DioExceptionType.receiveTimeout    => 'Receive timeout',
    DioExceptionType.badCertificate    => 'Bad certificate',
    DioExceptionType.badResponse       => 'Bad response',
    DioExceptionType.cancel            => 'Request cancelled',
    DioExceptionType.connectionError   => 'Connection error',
    DioExceptionType.unknown           => 'Unknown error',
  };

  @override
  String toString() =>
      'NetworkError(status: $status, dioType: $dioType)';
}
