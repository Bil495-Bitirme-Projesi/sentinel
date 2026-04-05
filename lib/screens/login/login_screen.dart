import 'package:flutter/material.dart';
/// Kullanici adi + parola ile giris ekrani.
/// TODO: gercek login formu implementasyonu
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giris')),
      body: const Center(child: Text('Login --- yapilacak')),
    );
  }
}
