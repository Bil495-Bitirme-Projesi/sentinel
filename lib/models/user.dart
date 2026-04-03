import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart'; // build_runner tarafından otomatik üretilecek

/// Kullanıcı bilgilerini temsil eder.
/// GET admin/user/{userId} cevabına karşılık gelir.
@MappableClass()
class User with UserMappable {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  static User fromJson(Map<String, dynamic> map) => UserMapper.fromMap(map);
}

