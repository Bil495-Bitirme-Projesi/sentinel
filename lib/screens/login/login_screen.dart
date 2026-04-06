import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/core/navigation/app_router.dart';
import 'package:sentinel/models/user_role.dart';
import 'package:sentinel/services/auth_service.dart';
import 'package:sentinel/core/auth/session_storage.dart';

/// Giriş ekranı.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();

  bool _loading  = false;
  bool _obscure  = true;
  String? _error;

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
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.instance.login(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      final role = SessionStorage.currentUser?.role;
      context.go(
        role == UserRole.admin ? AppRoutes.adminCameras : AppRoutes.opAlerts,
      );
    } catch (e) {
      setState(() { _error = 'Giriş başarısız. E-posta veya parola hatalı.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlık
                const Icon(Icons.security, size: 72, color: Colors.deepPurple),
                const SizedBox(height: 16),
                Text(
                  'Sentinel',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 40),

                // E-posta
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'E-posta gerekli' : null,
                ),
                const SizedBox(height: 16),

                // Parola
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Parola',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Parola gerekli' : null,
                ),
                const SizedBox(height: 8),

                // Hata mesajı
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 8),

                // Giriş butonu
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Giriş Yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
