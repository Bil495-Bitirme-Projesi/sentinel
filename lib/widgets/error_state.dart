import 'package:flutter/material.dart';
import 'package:sentinel/config/app_theme.dart';

/// Hata durumu — hata mesajı + "Yeniden Dene" butonu.
///
/// Kullanım:
///   ErrorState(message: _error!, onRetry: _loadData)
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppTheme.danger),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Yeniden Dene'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

