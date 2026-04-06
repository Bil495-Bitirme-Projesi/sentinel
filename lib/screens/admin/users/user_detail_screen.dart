import 'package:flutter/material.dart';
import 'package:sentinel/config/app_theme.dart';
import 'package:sentinel/models/user.dart';
import 'package:sentinel/models/user_camera_access.dart';
import 'package:sentinel/models/user_role.dart';
import 'package:sentinel/services/user_service.dart';
import 'package:sentinel/widgets/app_card.dart';
import 'package:sentinel/widgets/empty_state.dart';
import 'package:sentinel/widgets/error_state.dart';
import 'package:sentinel/widgets/info_tile.dart';
import 'package:sentinel/widgets/section_header.dart';
import 'package:sentinel/widgets/status_badge.dart';

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
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);

    final user = _user!;
    final isAdmin = user.role == UserRole.admin;

    return ListView(
      padding: AppTheme.pagePadding,
      children: [
        // ── Kullanıcı bilgileri ───────────────────────────────────────────
        SectionHeader('Bilgiler',
            trailing: StatusBadge(
              label: isAdmin ? 'ADMIN' : 'OPERATOR',
              color: isAdmin ? AppTheme.primary : AppTheme.textMuted,
            )),
        AppCard(
          child: Column(
            children: [
              InfoTile(icon: Icons.tag,            label: 'ID',      value: user.id.toString()),
              InfoTile(icon: Icons.person_outline,  label: 'Ad',      value: user.name),
              InfoTile(icon: Icons.email_outlined,  label: 'E-posta', value: user.email),
              InfoTile(
                icon: Icons.shield_outlined,
                label: 'Rol',
                value: isAdmin ? 'ADMIN' : 'OPERATOR',
                valueColor: isAdmin ? AppTheme.primary : AppTheme.textMuted,
              ),
              InfoTile(
                icon: Icons.circle_outlined,
                label: 'Durum',
                value: user.enabled ? 'Aktif' : 'Pasif',
                valueColor: user.enabled ? AppTheme.success : AppTheme.danger,
                showDivider: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Kamera erişimleri ─────────────────────────────────────────────
        SectionHeader(
          'Kamera Erişimleri',
          trailing: StatusBadge(
            label: '${_accesses.length} kamera',
            color: AppTheme.textMuted,
          ),
        ),
        if (_accesses.isEmpty)
          EmptyState(
            icon: Icons.videocam_off_outlined,
            message: 'Bu kullanıcıya atanmış kamera erişimi yok.',
          )
        else
          AppCard(
            child: Column(
              children: [
                for (int i = 0; i < _accesses.length; i++)
                  InfoTile(
                    icon: Icons.videocam_outlined,
                    label: _accesses[i].cameraName,
                    value: '#${_accesses[i].cameraId}',
                    showDivider: i < _accesses.length - 1,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
