import 'package:flutter/material.dart';
import 'package:sentinel/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/services/user_service.dart';
import 'package:sentinel/models/user.dart';
import 'package:sentinel/core/navigation/app_router.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  GoRouter? _router;
  String? _previousLocation;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (_router != router) {
      _router?.routerDelegate.removeListener(_onRouteChange);
      _router = router;
      _router!.routerDelegate.addListener(_onRouteChange);
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouteChange);
    super.dispose();
  }

  void _onRouteChange() {
    if (!mounted) return;
    final location =
        _router!.routerDelegate.currentConfiguration.uri.toString();
    final wasInSubRoute = _previousLocation != null &&
        _previousLocation != AppRoutes.adminUsers &&
        _previousLocation!.startsWith(AppRoutes.adminUsers);
    if (location == AppRoutes.adminUsers && wasInSubRoute) {
      _fetchUsers();
    }
    _previousLocation = location;
  }

  // Kullanıcıları API'den çeken ana fonksiyon
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await UserService.instance.getUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Kullanıcı Yönetimi'),
          actions: [
            // Listeyi Yenileme Butonu
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Yenile',
              onPressed: _fetchUsers,
            ),
            // ÇIKIŞ YAP (LOGOUT) BUTONU EKLENDİ
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Çıkış Yap',
              onPressed: () async {
                // Kullanıcıya emin misin diye soralım
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Çıkış Yap'),
                    content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Çıkış Yap')
                      ),
                    ],
                  ),
                );

                // Eğer evet dediyse çıkış yap ve login'e yönlendir
                if (confirm == true && mounted) {
                  try {
                    await AuthService.instance.logout();
                    // SessionNotifier tetiklendi, redirect guard login'e yönlendirecek
                  } catch (e, st) {
                    debugPrint('[Logout] HATA: $e');
                    debugPrint('[Logout] StackTrace: $st');
                  }
                }
              },
            ),
          ],
        ),
      // Yeni kullanıcı ekleme butonu
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_admin_users',
        onPressed: () {
          context.go(AppRoutes.adminUserNew);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Yeni Ekle'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Kullanıcılar yüklenemedi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            )
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, color: Colors.grey.shade400, size: 80),
            const SizedBox(height: 16),
            Text(
              'Henüz kullanıcı bulunmuyor',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
            ),
          ],
        ),
      );
    }

    // Pull-to-refresh (Aşağı çekerek yenileme)
    return RefreshIndicator(
      onRefresh: _fetchUsers,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80), // Alttan FAB için boşluk
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: user.enabled ? Colors.blue.shade100 : Colors.grey.shade200,
                radius: 25,
                child: Icon(
                  Icons.person,
                  color: user.enabled ? Colors.blue.shade700 : Colors.grey,
                  size: 30,
                ),
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(user.email),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.deepPurple.shade200),
                        ),
                        child: Text(
                          user.role.name.toUpperCase(),
                          style: TextStyle(fontSize: 10, color: Colors.deepPurple.shade700, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!user.enabled)
                        const Text('• Pasif', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    tooltip: 'Düzenle',
                    onPressed: () {
                      context.go(AppRoutes.adminUserEdit(user.id.toString()));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.grey),
                    tooltip: 'Detay / Kamera Erişimi',
                    onPressed: () {
                      context.go(AppRoutes.adminUserDetail(user.id.toString()));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}