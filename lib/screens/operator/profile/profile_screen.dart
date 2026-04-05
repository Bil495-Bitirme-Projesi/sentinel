import 'package:flutter/material.dart';
/// Operator profil ekrani.
/// Kullanici adi, rol, logout butonu.
/// TODO: gercek profil implementasyonu
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(child: Text('Profile --- yapilacak')),
    );
  }
}
