import 'package:sentinel/core/network/dio_client.dart';
import 'package:sentinel/core/auth/token_storage.dart';
import 'package:sentinel/models/auth_response.dart';
import 'package:dio/dio.dart';

/// Kimlik doğrulama ile ilgili API çağrılarını yönetir.
///
/// Kullanım:
///   final authResponse = await AuthService.instance.login(
///     email: 'user@example.com',
///     password: '123456',
///   );
///   print(authResponse.token);
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final Dio _dio = DioClient.instance;

  /// POST auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    TokenStorage.set(authResponse.token, expiresInMs: authResponse.expiresIn);
    return authResponse;
  }
}

