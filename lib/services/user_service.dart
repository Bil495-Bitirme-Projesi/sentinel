import 'package:sentinel/core/network/dio_client.dart';
import 'package:sentinel/models/user.dart';
import 'package:dio/dio.dart';

/// Kullanıcı ile ilgili API çağrılarını yönetir.
///
/// Kullanım:
///   final user = await UserService.instance.getUser('42');
///   print(user.name);
class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final Dio _dio = DioClient.instance;

  /// GET admin/user/{userId}
  Future<User> getUser(String userId) async {
    final response = await _dio.get('/admin/users/$userId');
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}

