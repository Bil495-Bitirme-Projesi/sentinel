import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/config/app_theme.dart';
import 'package:sentinel/core/navigation/app_router.dart';
import 'package:sentinel/models/user.dart';
import 'package:sentinel/models/user_role.dart';
import 'package:sentinel/services/auth_service.dart';
import 'package:sentinel/services/user_service.dart';
import 'package:sentinel/widgets/empty_state.dart';
import 'package:sentinel/widgets/error_state.dart';
import 'package:sentinel/widgets/status_badge.dart';

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
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadUsers);
    if (_users.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Henüz kullanıcı yok.',
      );
    }
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _users.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppTheme.borderColor),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isAdmin ? AppTheme.primary : AppTheme.textMuted,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        user.email,
        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(
            label: isAdmin ? 'ADMIN' : 'OPERATOR',
            color: isAdmin ? AppTheme.primary : AppTheme.textMuted,
          ),
          const SizedBox(width: 8),
          Icon(
            user.enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: user.enabled ? AppTheme.success : AppTheme.danger,
            size: 18,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}
