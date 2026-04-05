import 'package:dart_mappable/dart_mappable.dart';
import 'package:sentinel/models/user_role.dart';

part 'user.mapper.dart';

/// Kullanıcı bilgilerini temsil eder.
@MappableClass()
class User with UserMappable {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final bool enabled;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.enabled,
  });

  static User fromJson(Map<String, dynamic> map) => UserMapper.fromMap(map);
}
