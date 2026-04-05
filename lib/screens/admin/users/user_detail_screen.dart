import 'package:flutter/material.dart';
import 'package:sentinel/models/user.dart';
import 'package:sentinel/models/user_camera_access.dart';
import 'package:sentinel/models/user_role.dart';
import 'package:sentinel/services/user_service.dart';

/// Kullanıcı detay ekranı.
/// Kullanıcı bilgilerini ve atanmış kamera erişimlerini gösterir.
class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key, required this.userId});

  /// Router path parametresinden String olarak gelir.
  final String userId;

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  User? _user;
  List<UserCameraAccess> _accesses = [];
  bool _loading = true;
  String? _error;

  int get _userId => int.parse(widget.userId);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      // İkisini paralel çek
      final results = await Future.wait([
        UserService.instance.getUser(_userId),
        UserService.instance.getUserCameraAccess(_userId),
      ]);
      setState(() {
        _user     = results[0] as User;
        _accesses = results[1] as List<UserCameraAccess>;
      });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user?.name ?? 'Kullanıcı #${widget.userId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadData,
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
            ElevatedButton(onPressed: _loadData, child: const Text('Yeniden Dene')),
          ],
        ),
      );
    }

    final user = _user!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Kullanıcı bilgileri ───────────────────────────────────────────
        _SectionHeader(title: 'Bilgiler'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(label: 'ID',    value: user.id.toString()),
                const Divider(height: 24),
                _InfoRow(label: 'Ad',    value: user.name),
                const Divider(height: 24),
                _InfoRow(label: 'E-posta', value: user.email),
                const Divider(height: 24),
                _InfoRow(
                  label: 'Rol',
                  value: user.role == UserRole.admin ? 'ADMIN' : 'OPERATOR',
                  valueColor: user.role == UserRole.admin
                      ? Colors.deepPurple
                      : Colors.blueGrey,
                ),
                const Divider(height: 24),
                _InfoRow(
                  label: 'Durum',
                  value: user.enabled ? 'Aktif' : 'Pasif',
                  valueColor: user.enabled ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Kamera erişimleri ─────────────────────────────────────────────
        _SectionHeader(
          title: 'Kamera Erişimleri',
          trailing: Text(
            '${_accesses.length} kamera',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (_accesses.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Bu kullanıcıya atanmış kamera erişimi yok.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _accesses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final access = _accesses[index];
                return ListTile(
                  leading: const Icon(Icons.videocam_outlined),
                  title: Text(access.cameraName),
                  subtitle: Text('Kamera ID: ${access.cameraId}'),
                  trailing: Text(
                    'Erişim #${access.id}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Yardımcı widget'lar
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}