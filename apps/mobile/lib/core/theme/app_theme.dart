import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  static const Color canvas = Color(0xFFD7F7EC);
  static const Color shell = Color(0xFFEFFDF7);
  static const Color ink = Color(0xFF173B3B);
  static const Color midnight = Color(0xFF1A5C58);
  static const Color teal = Color(0xFF3CA79D);
  static const Color tide = Color(0xFF8BE5D2);
  static const Color clay = Color(0xFFB88C5E);
  static const Color gold = Color(0xFFE8D189);
  static const Color mintWash = Color(0xFFC4F3E5);
  static const Color skyWash = Color(0xFFD9F8F1);
  static const Color slate = Color(0xFF5E7E7C);
  static const Color line = Color(0x459CCFC0);
  static const Color shadow = Color(0x33496D63);
  static const Color card = Color(0xFFF5FFF9);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const base = ColorScheme.light(
      primary: AppColors.teal,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.ink,
      tertiary: AppColors.clay,
      onTertiary: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.ink,
      outline: AppColors.line,
    );

    final textTheme = GoogleFonts.notoSansKrTextTheme().copyWith(
      displaySmall: GoogleFonts.notoSansKr(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -1.0,
        color: AppColors.ink,
      ),
      headlineMedium: GoogleFonts.notoSansKr(
        fontSize: 29,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.7,
        color: AppColors.ink,
      ),
      headlineSmall: GoogleFonts.notoSansKr(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleLarge: GoogleFonts.notoSansKr(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: GoogleFonts.notoSansKr(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: GoogleFonts.notoSansKr(
        fontSize: 15,
        height: 1.45,
        color: AppColors.ink,
      ),
      bodyMedium: GoogleFonts.notoSansKr(
        fontSize: 14,
        height: 1.45,
        color: AppColors.slate,
      ),
      labelLarge: GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      labelMedium: GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.slate,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.midnight,
          foregroundColor: AppColors.gold,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.line),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.72),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle: textTheme.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.42),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.midnight, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card.withValues(alpha: 0.9),
        indicatorColor: AppColors.gold.withValues(alpha: 0.22),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.ink
                : AppColors.slate,
          ),
        ),
      ),
    );
  }

  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'DELIVERED':
        return const Color(0xFF2F8C66);
      case 'IN_TRANSIT':
      case 'DISPATCHED':
      case 'ASSIGNED':
      case 'ACCEPTED':
        return AppColors.teal;
      case 'CANCELLED':
      case 'REJECTED':
        return AppColors.clay;
      default:
        return AppColors.gold;
    }
  }
}
