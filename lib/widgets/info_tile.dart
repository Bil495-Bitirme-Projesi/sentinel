import 'package:flutter/material.dart';
import 'package:sentinel/config/app_theme.dart';

/// Detay ekranlarında kullanılan bilgi satırı.
/// icon | label (soluk) | value (sağ hizalı, renkli olabilir)
///
/// Kullanım:
///   InfoTile(icon: Icons.person_outline, label: 'Ad', value: user.name)
///   InfoTile(icon: Icons.circle, label: 'Durum', value: 'Aktif', valueColor: AppTheme.success)
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  /// Alt çizgi gösterilsin mi? Son satırda false geç.
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.borderColor, width: 0.8),
              ),
            )
          : null,
      padding: AppTheme.rowPadding,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

