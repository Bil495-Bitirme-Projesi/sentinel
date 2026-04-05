import 'package:sentinel/models/user_role.dart';

/// PUT /api/admin/users/{id} request body.
///
/// Tüm alanlar opsiyoneldir; null bırakılan alanlar request body'ye dahil edilmez.
class UpdateUserRequest {
  final String? name;
  final bool? enabled;
  final UserRole? role;

  const UpdateUserRequest({this.name, this.enabled, this.role});

  /// Sadece null olmayan alanları içeren map döner.
  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (enabled != null) 'enabled': enabled,
        if (role != null)
          'role': role == UserRole.admin ? 'ADMIN' : 'OPERATOR',
      };
}

