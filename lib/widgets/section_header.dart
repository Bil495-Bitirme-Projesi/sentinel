import 'package:flutter/material.dart';
import 'package:sentinel/config/app_theme.dart';

/// Bölüm başlığı — büyük harf, küçük, soluk metin.
///
/// Kullanım:
///   SectionHeader('Bilgiler')   → "BİLGİLER"
///   SectionHeader('Kameralar', trailing: Text('3 adet'))
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;

  /// Başlığın sağına hizalanır (örn. sayaç metni).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.sectionHeaderPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(), style: AppTheme.sectionHeaderStyle),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

