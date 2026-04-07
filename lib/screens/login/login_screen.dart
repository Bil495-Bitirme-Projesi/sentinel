import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/core/navigation/app_router.dart';
import 'package:sentinel/core/network/dio_exception_ext.dart';
import 'package:sentinel/models/api_error.dart';
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
          SnackBar(
            content: const Text('Oturumunuz sona erdi. Lütfen tekrar giriş yapın.'),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    } on DioException catch (e) {
      final httpErr = e.toHttpError();
      String errorMessage;
      if (httpErr is ApiError) {
        if (httpErr.status == 401 || httpErr.status == 403) {
          errorMessage = 'E-posta adresi veya şifre hatalı.';
        } else {
          errorMessage = 'Sunucu hatası: ${httpErr.message}';
        }
      } else {
        // NetworkError: bağlantı yok, timeout vb.
        errorMessage = 'Sunucuya ulaşılamadı. Bağlantınızı kontrol edin.';
      }
      setState(() { _error = errorMessage; });
    } catch (_) {
      setState(() { _error = 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Arka plana şık bir kurumsal gradient (renk geçişi) ekliyoruz
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade600,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420), // Tablet/Web görünümü için form genişliğini sınırla
              child: Card(
                elevation: 12,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo ve Başlık
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.security, size: 56, color: Colors.deepPurple.shade700),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Sentinel',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sisteme giriş yapmak için bilgilerinizi girin',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        const SizedBox(height: 40),

                        // E-posta
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'E-posta Adresi',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'E-posta gerekli' : null,
                        ),
                        const SizedBox(height: 20),

                        // Parola
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(), // Enter'a basınca giriş yap
                          decoration: InputDecoration(
                            labelText: 'Parola',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                          (v == null || v.isEmpty) ? 'Parola gerekli' : null,
                        ),
                        const SizedBox(height: 24),

                        // Hata mesajı (Kırmızı düz metin yerine modern kutu)
                        if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_error == null) const SizedBox(height: 8),

                        // Giriş butonu
                        FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: _loading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                                  'Giriş Yap',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

