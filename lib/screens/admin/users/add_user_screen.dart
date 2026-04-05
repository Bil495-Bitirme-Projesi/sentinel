import 'package:flutter/material.dart';
/// Yeni kullanici olusturma ekrani.
/// TODO: POST /admin/users implementasyonu
class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanici Ekle')),
      body: const Center(child: Text('Add user --- yapilacak')),
    );
  }
}
