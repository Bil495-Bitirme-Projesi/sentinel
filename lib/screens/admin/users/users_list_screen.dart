import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/core/navigation/app_router.dart';
import 'package:sentinel/models/user.dart';
import 'package:sentinel/models/user_role.dart';
import 'package:sentinel/services/auth_service.dart';
import 'package:sentinel/services/user_service.dart';

/// Tüm kullanıcıları listeleyen ekran.
/// Her satıra tıklanınca [UserDetailScreen]'e geçilir.
class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<User> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final users = await UserService.instance.getUsers();
      setState(() { _users = users; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcılar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadUsers,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Kullanıcı Ekle',
            onPressed: () => context.go(AppRoutes.adminUserNew),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış',
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUsers, child: const Text('Yeniden Dene')),
          ],
        ),
      );
    }
    if (_users.isEmpty) {
      return const Center(child: Text('Henüz kullanıcı yok.'));
    }
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) => _UserTile(
          user: _users[index],
          onTap: () => context.go(
            AppRoutes.adminUserDetail(_users[index].id.toString()),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == UserRole.admin;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isAdmin ? Colors.deepPurple : Colors.blueGrey,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rol etiketi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isAdmin ? Colors.deepPurple.shade50 : Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAdmin ? Colors.deepPurple.shade200 : Colors.blueGrey.shade200,
              ),
            ),
            child: Text(
              isAdmin ? 'ADMIN' : 'OPERATOR',
              style: TextStyle(
                fontSize: 11,
                color: isAdmin ? Colors.deepPurple : Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Aktif/pasif göstergesi
          Icon(
            user.enabled ? Icons.check_circle : Icons.cancel,
            color: user.enabled ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
