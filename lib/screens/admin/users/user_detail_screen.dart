import 'package:flutter/material.dart';
/// Kullanici detay ekrani.
/// Bilgiler, enabled toggle, rol, atanmis kameralar (OPERATOR ise).
/// [userId]: gosterilecek kullanicinin ID'si.
/// TODO: GET/PUT/DELETE /admin/users/{id}, access grant/revoke
class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.userId});
  final String userId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kullanici #$userId')),
      body: const Center(child: Text('User detail --- yapilacak')),
    );
  }
}
