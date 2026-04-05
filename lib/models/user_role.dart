import 'package:dart_mappable/dart_mappable.dart';

part 'user_role.mapper.dart';

/// API'den dönen kullanıcı rolü.
/// JSON değerleri: "ADMIN", "OPERATOR"
@MappableEnum()
enum UserRole {
  @MappableValue('ADMIN')
  admin,

  /// Dart'ta 'operator' reserved keyword olduğundan trailing underscore kullanılır.
  @MappableValue('OPERATOR')
  operator_,
}

