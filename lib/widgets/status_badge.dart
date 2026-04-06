import 'package:flutter/material.dart';

/// Renkli etiket — rol, durum, alert seviyesi için.
///
/// Kullanım:
///   StatusBadge(label: 'ADMIN', color: AppTheme.primary)
///   StatusBadge(label: 'Aktif', color: AppTheme.success)
///   StatusBadge(label: 'KRİTİK', color: AppTheme.danger)
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26), // %10 opaklık
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(77)), // %30 opaklık
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

