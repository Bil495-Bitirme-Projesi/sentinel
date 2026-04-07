import 'package:dio/dio.dart';
import 'package:sentinel/core/network/cms_client.dart';
import 'package:sentinel/models/user.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final Dio _cms = CmsClient.instance;

  Future<List<User>> getUsers() async {
    final response = await _cms.get('/admin/users');
    return (response.data as List).map((json) => UserMapper.fromMap(json as Map<String, dynamic>)).toList();
  }

  Future<User> getUserById(int id) async {
    final response = await _cms.get('/admin/users/$id');
    return UserMapper.fromMap(response.data as Map<String, dynamic>);
  }

  Future<void> createUser(String name, String email, String password, String role) async {
    await _cms.post('/admin/users', data: {
      "name": name,
      "email": email,
      "password": password,
      "role": role,
      "enabled": true
    });
  }

  // Email parametresini de ekledik
    Future<void> updateUser(int id, String name, String email, String role, bool enabled) async {
      await _cms.put('/admin/users/$id', data: {
        "name": name,
        "email": email, // Backend muhtemelen bunu eksik bulduğu için hata veriyordu
        "role": role,
        "enabled": enabled
      });
    }

  Future<void> deleteUser(int id) async {
    await _cms.delete('/admin/users/$id');
  }
}