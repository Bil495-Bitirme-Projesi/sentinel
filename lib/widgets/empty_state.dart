import 'package:flutter/material.dart';
import 'package:sentinel/config/app_theme.dart';

/// Boş liste / veri yok durumu.
///
/// Kullanım:
///   EmptyState(message: 'Henüz kullanıcı yok.')
///   EmptyState(icon: Icons.videocam_off, message: 'Kamera bulunamadı.')
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppTheme.textMuted.withAlpha(128)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

