import 'package:flutter/material.dart';

/// Sentinel uygulaması için renk paleti, tipografi ve dekorasyon sabitleri.
///
/// Konsept: Güvenlik kamera yönetimi — güvenilir, net, aksiyon odaklı.
/// Her widget bu sınıftan renk/dekorasyon alır; hardcoded değer kullanmaz.
abstract class AppTheme {
  AppTheme._();

  // ── Renkler ───────────────────────────────────────────────────────────────

  static const background    = Color(0xFFF2F4F7); // sayfa arka planı
  static const surface       = Color(0xFFFFFFFF); // kart / panel yüzeyi
  static const primary       = Color(0xFF1E40AF); // mavi — güven, teknoloji
  static const accent        = Color(0xFFF59E0B); // amber — uyarı, alert
  static const danger        = Color(0xFFDC2626); // kırmızı — kritik, pasif
  static const success       = Color(0xFF16A34A); // yeşil — aktif, online
  static const textPrimary   = Color(0xFF111827); // ana metin
  static const textMuted     = Color(0xFF6B7280); // yardımcı metin / ikon
  static const borderColor   = Color(0xFFE5E7EB); // kart ve satır kenarı

  // ── Gölge ─────────────────────────────────────────────────────────────────

  static const cardShadow = BoxShadow(
    blurRadius: 10,
    color: Color(0x14000000), // %8 siyah
    offset: Offset(0, 4),
  );

  // ── Dekorasyonlar ─────────────────────────────────────────────────────────

  static const cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [cardShadow],
  );

  static BoxDecoration rowDecoration({Color bg = surface}) => BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.8),
        ),
      );

  // ── Padding ───────────────────────────────────────────────────────────────

  static const pagePadding   = EdgeInsets.all(16);
  static const rowPadding    = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  static const sectionHeaderPadding =
      EdgeInsetsDirectional.fromSTEB(4, 0, 0, 8);

  // ── Tipografi ─────────────────────────────────────────────────────────────

  static const sectionHeaderStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: textMuted,
    letterSpacing: 0.8,
  );

  // ── MaterialApp ThemeData ─────────────────────────────────────────────────

  /// [MaterialApp.theme] içinde kullanılacak hazır tema.
  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: Color(0x18000000),
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}


