import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sentinel/core/network/dio_client.dart';
import 'package:sentinel/models/user.dart';
import 'package:sentinel/services/auth_service.dart';
import 'package:sentinel/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioClient.init(); // sertifikayı yükler, Dio'yu yapılandırır
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentinel API Test',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const ApiTestPage(),
    );
  }
}

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  // --- Login ---
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _token;
  String? _loginError;

  // --- Get User ---
  final _userIdCtrl = TextEditingController(text: '1');
  User?   _user;
  String? _userError;

  bool _loading = false;

  // ------------------------------------------------------------------ login
  Future<void> _login() async {
    setState(() { _loading = true; _loginError = null; _token = null; });
    try {
      final resp = await AuthService.instance.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      // TokenStorage.set() auth_service içinde yapılıyor;
      // AuthInterceptor bundan sonraki her isteğe otomatik header ekler.
      setState(() { _token = resp.token; });
    } on DioException catch (e) {
      setState(() { _loginError = '${e.response?.statusCode} – ${e.response?.data}'; });
    } catch (e) {
      setState(() { _loginError = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  // --------------------------------------------------------------- get user
  Future<void> _getUser() async {
    setState(() { _loading = true; _userError = null; _user = null; });
    try {
      final user = await UserService.instance.getUser(_userIdCtrl.text.trim());
      setState(() { _user = user; });
    } on DioException catch (e) {
      setState(() { _userError = '${e.response?.statusCode} – ${e.response?.data}'; });
    } catch (e) {
      setState(() { _userError = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Login bölümü ──────────────────────────────────────────────
            const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _emailCtrl,    decoration: const InputDecoration(labelText: 'E-posta'), keyboardType: TextInputType.emailAddress),
            TextField(controller: _passwordCtrl, decoration: const InputDecoration(labelText: 'Parola'), obscureText: true),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loading ? null : _login, child: const Text('Login')),
            if (_loginError != null)
              Text('Hata: $_loginError', style: const TextStyle(color: Colors.red)),
            if (_token != null)
              Text('Token alındı ✅\n${_token!.substring(0, _token!.length.clamp(0, 40))}...'),

            const Divider(height: 32),

            // ── Get User bölümü ───────────────────────────────────────────
            const Text('Get User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _userIdCtrl, decoration: const InputDecoration(labelText: 'User ID')),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: (_loading || _token == null) ? null : _getUser,
              child: const Text('Get User'),
            ),
            if (_token == null) const Text('Önce login yapılmalı', style: TextStyle(color: Colors.orange)),
            if (_userError != null)
              Text('Hata: $_userError', style: const TextStyle(color: Colors.red)),
            if (_user != null) ...[
              const SizedBox(height: 8),
              const Text('Kullanıcı bilgisi ✅', style: TextStyle(color: Colors.green)),
              Text('ID:    ${_user!.id}'),
              Text('Ad:    ${_user!.name}'),
              Text('Email: ${_user!.email}'),
            ],
          ],
        ),
      ),
    );
  }
}
