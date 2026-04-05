import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/core/auth/session_storage.dart';

/// Giriş ekranı.
/// TODO: Form, AuthService.login, rol bazlı yönlendirme
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // İlk frame render'landıktan sonra query param'ı kontrol et.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reason = GoRouterState.of(context).uri.queryParameters['reason'];
      if (reason == 'expired') {
        SessionStorage.sessionExpiredByServer = false; // bayrağı sıfırla
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oturumunuz sona erdi. Lütfen tekrar giriş yapın.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş')),
      body: const Center(child: Text('Login --- yapilacak')),
    );
  }
}