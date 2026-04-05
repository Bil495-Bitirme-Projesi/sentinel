import 'package:flutter/material.dart';

/// Uygulama açılışında gösterilen yükleme ekranı.
/// [AppRouter] redirect mantığı burada değil, router'ın redirect guard'ında.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

