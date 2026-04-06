import 'package:flutter/material.dart';
import 'package:sentinel/config/app_theme.dart';

/// Standart Sentinel kartı.
/// Yuvarlak köşe (12px) + hafif gölge.
///
/// Kullanım:
///   AppCard(child: Column(...))
///   AppCard(padding: EdgeInsets.all(16), child: Text('...'))
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;

  /// Belirtilmezse çocuk widget kendi padding'ini yönetir.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: padding,
      child: child,
    );
  }
}

