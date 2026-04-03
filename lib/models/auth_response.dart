import 'package:dart_mappable/dart_mappable.dart';

part 'auth_response.mapper.dart';

/// Login isteğinin (POST auth/login) cevabını temsil eder.
@MappableClass()
class AuthResponse with AuthResponseMappable {
  final String token;

  /// Token'ın geçerlilik süresi (milisaniye).
  /// Örnek: 3600000 → 1 saat
  @MappableField(key: 'expiresIn')
  final int expiresIn;

  const AuthResponse({required this.token, required this.expiresIn});

  static AuthResponse fromJson(Map<String, dynamic> map) =>
      AuthResponseMapper.fromMap(map);
}

