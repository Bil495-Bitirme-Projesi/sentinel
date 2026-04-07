import 'dart:async';

import 'package:dio/dio.dart';
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
  /// Başlangıçta true: ilk ping dönene kadar buton kilitli.
  /// Ping başarılıysa direkt false olur (banner açılmaz).
  /// Ping başarısızsa banner açılır, polling biter biter false olur.
  bool _polling  = true;
  bool _obscure  = true;
  String? _error;

  Timer? _pollTimer;

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
    // Ekran açılır açılmaz sunucuya erişilebilir mi kontrol et.
    _checkServerOnInit();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Sunucu bağlantı bekleme (polling)
  // ---------------------------------------------------------------------------

  /// Her [_kPollInterval]'de bir [AuthService.pingServer()] çağırır.
  /// Sunucu cevap verdiğinde banner'ı kapatır ve butonu açar.
  static const _kPollInterval = Duration(seconds: 5);

  /// Ekran ilk açıldığında tek bir ping atar; sunucuya ulaşılamazsa
  /// banner'ı gösterip polling'i başlatır. Böylece kullanıcı submit'e
  /// basmadan sorundan haberdar olur.
  Future<void> _checkServerOnInit() async {
    final reachable = await AuthService.instance.pingServer();
    if (!mounted) return;
    if (reachable) {
      // Server açık → banner göstermeden butonu serbest bırak.
      setState(() { _polling = false; });
    } else {
      // Server kapalı → banner aç, polling başlat.
      _showServerUnreachableBanner();
      _startPolling();
    }
  }

  /// Ekranın üstüne kalıcı "bağlantı bekleniyor" banner'ı basar.
  void _showServerUnreachableBanner() {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: const Text('Sunucuya ulaşılamıyor. Bağlantı bekleniyor…'),
        leading: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        actions: [
          TextButton(
            onPressed: _stopPolling,
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) async {
      final reachable = await AuthService.instance.pingServer();
      if (reachable && mounted) _stopPolling();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    setState(() { _polling = false; });
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
      if (!mounted) return;
      final isConnError =
          e.type == DioExceptionType.connectionError   ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout    ||
          e.type == DioExceptionType.sendTimeout;

      if (isConnError) {
        // Buton açıkken (init ping başarılıydı) submit bağlantı hatası aldı.
        // Polling döngüsüne gerek yok — init ping zaten kontrolü yapıyor.
        // TODO(Seçenek-A): global "sunucu erişilemiyor" mekanizmasını tetikle.
        setState(() { _error = 'Sunucuya ulaşılamıyor. Lütfen tekrar deneyin.'; });
      } else {
        setState(() { _error = 'Giriş başarısız. E-posta veya parola hatalı.'; });
      }
    } catch (_) {
      if (!mounted) return;
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
                  onPressed: (_loading || _polling) ? null : _submit,
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
