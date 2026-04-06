import 'package:flutter/material.dart';
import 'package:sentinel/config/app_theme.dart';

/// Form ekranlarının altına yapışık aksiyon butonu.
/// Scaffold'ın `bottomNavigationBar`'ına veya body sonuna konur.
///
/// Kullanım:
///   bottomNavigationBar: StickyBottomButton(
///     label: 'Kaydet',
///     onPressed: _loading ? null : _submit,
///     loading: _loading,
///   )
class StickyBottomButton extends StatelessWidget {
  const StickyBottomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  /// Belirtilmezse [AppTheme.primary] kullanılır.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: loading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: color ?? AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

