import 'package:flutter/material.dart';
import 'package:sentinel/config/app_theme.dart';

/// Silme ve geri-dönüşsüz aksiyon onayı için standart dialog.
///
/// Kullanım:
///   final confirmed = await ConfirmDialog.show(
///     context,
///     title: 'Kullanıcıyı Sil',
///     message: 'Bu işlem geri alınamaz.',
///   );
///   if (confirmed == true) { ... }
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Onayla',
    this.isDanger = false,
  });

  final String title;
  final String message;
  final String confirmLabel;

  /// true ise onay butonu [AppTheme.danger] rengini kullanır.
  final bool isDanger;

  /// Dialog'u göster ve boolean cevap döner.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Onayla',
    bool isDanger = false,
  }) =>
      showDialog<bool>(
        context: context,
        builder: (_) => ConfirmDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          isDanger: isDanger,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      content: Text(message,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: isDanger ? AppTheme.danger : AppTheme.primary,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

