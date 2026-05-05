import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppTheme {
  static const Color primary = Color(0xFF3B7EF8);
  static const Color background = Color(0xFF050811);
  static const Color surface = Color(0xFF111827);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color accent = Color(0xFF60A5FA);
  static const Color secondary = accent;
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  static const Map<String, CategoryStyle> categoryStyles = {
    'Food & Dining': CategoryStyle(color: Color(0xFFF97316), icon: LucideIcons.utensils),
    'Transport': CategoryStyle(color: Color(0xFF3B7EF8), icon: LucideIcons.car),
    'Shopping': CategoryStyle(color: Color(0xFFA78BFA), icon: LucideIcons.shoppingBag),
    'Health': CategoryStyle(color: Color(0xFF22C55E), icon: LucideIcons.pill),
    'Entertainment': CategoryStyle(color: Color(0xFFFBBF24), icon: LucideIcons.film),
    'Utilities': CategoryStyle(color: Color(0xFF38BDF8), icon: LucideIcons.zap),
    'Other': CategoryStyle(color: Color(0xFF7A88A8), icon: LucideIcons.package),
  };
}

class CategoryStyle {
  final Color color;
  final IconData icon;
  const CategoryStyle({required this.color, required this.icon});
}
