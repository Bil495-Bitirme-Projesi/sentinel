import 'package:flutter/material.dart';
/// Tum kullanicilarin listesi.
/// TODO: GET /admin/users implementasyonu
class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanicilar')),
      body: const Center(child: Text('Users list --- yapilacak')),
    );
  }
}
