import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/services/user_service.dart';
import 'package:sentinel/models/create_user_request.dart';
import 'package:sentinel/models/update_user_request.dart';
import 'package:sentinel/models/user_role.dart';
import 'package:sentinel/core/navigation/app_router.dart';

class AddUserScreen extends StatefulWidget {
  final int? userId;
  const AddUserScreen({super.key, this.userId});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'OPERATOR';
  bool _isEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) _loadExistingUser();
  }

  Future<void> _loadExistingUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await UserService.instance.getUserById(widget.userId!);
      _nameController.text = user.name;
      _emailController.text = user.email;

      // Backend'den gelen rol formatı ne olursa olsun,
      // Dropdown'ın çökmesini engelleyen güvenli kontrol:
      final roleStr = user.role.toString().toUpperCase();
      if (roleStr.contains('ADMIN')) {
        _selectedRole = 'ADMIN';
      } else {
        _selectedRole = 'OPERATOR';
      }

      _isEnabled = user.enabled;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.userId == null) {
        await UserService.instance.createUser(
          CreateUserRequest(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole == 'ADMIN' ? UserRole.admin : UserRole.operator_,
            enabled: _isEnabled,
          ),
        );
      } else {
        await UserService.instance.updateUser(
          widget.userId!,
          UpdateUserRequest(
            name: _nameController.text.trim(),
            role: _selectedRole == 'ADMIN' ? UserRole.admin : UserRole.operator_,
            enabled: _isEnabled,
          ),
        );
      }
      if (mounted) context.go(AppRoutes.adminUsers);

    } catch (e) {
      // --- AKILLI HATA YAKALAMA BAŞLANGICI ---
      String errorMessage = 'İşlem başarısız oldu.';

      if (e is DioException && e.response != null) {
        final errorData = e.response?.data.toString().toLowerCase() ?? '';
        final statusCode = e.response?.statusCode;

        // Backend 409 Conflict dönerse VEYA hata mesajı email'in var olduğunu söylüyorsa
        if (statusCode == 409 ||
            errorData.contains('email') ||
            errorData.contains('exists') ||
            errorData.contains('unique') ||
            errorData.contains('kullanımda') ||
            errorData.contains('already')) {

          errorMessage = 'Bu e-posta adresi sistemde zaten kayıtlı. Lütfen farklı bir e-posta adresi girin.';

        } else {
          // Farklı bir backend hatasıysa
          errorMessage = 'Sunucu Hatası: ${e.response?.data}';
        }
      } else {
        errorMessage = 'Bağlantı Hatası: $e';
      }

      // Şık, ikonlu ve kırmızı hata bildirimi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage, style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          )
        );
      }
      // --- AKILLI HATA YAKALAMA BİTİŞİ ---

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.userId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Kullanıcıyı Düzenle' : 'Yeni Kullanıcı')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Gerekli alan' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    enabled: !isEditing, // Düzenlerken E-posta değiştirilemez
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-posta', prefixIcon: Icon(Icons.email),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'E-posta gerekli';
                      if (!val.contains('@')) return 'Geçerli bir e-posta girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (!isEditing) ...[
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Şifre', prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (val) => val != null && val.length < 8 ? 'Min. 8 karakter' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Rol', prefixIcon: Icon(Icons.badge),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'OPERATOR', child: Text('Operatör')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('Yönetici')),
                    ],
                    onChanged: (val) => setState(() => _selectedRole = val!),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: SwitchListTile(
                      title: const Text('Hesap Aktifliği', style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(_isEnabled ? 'Sisteme giriş yapabilir' : 'Giriş izni donduruldu'),
                      value: _isEnabled,
                      onChanged: (val) => setState(() => _isEnabled = val),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(isEditing ? 'Değişiklikleri Kaydet' : 'Kullanıcıyı Oluştur', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}