import 'package:sentinel/models/user_role.dart';

/// POST /api/admin/users request body.
///
/// [password] en az 8 karakter olmalıdır.
/// [enabled] verilmezse backend varsayılan değeri kullanır.
class CreateUserRequest {
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final bool? enabled;

  const CreateUserRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.enabled,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'role': role == UserRole.admin ? 'ADMIN' : 'OPERATOR',
        if (enabled != null) 'enabled': enabled,
      };
}

