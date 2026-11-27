import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const Color brandBlue = Color(0xFF4D6FB7);
  static const Color brandBlueHover = Color(0xFF3B5898);
  static const Color brandBlueDark = Color(0xFF2F4880);
  static const Color brandBlueTint = Color(0xFFDCE4F5);
  static const Color softBorder = Color(0xFFD0D9EC);

  static const Color warmPaper = Color(0xFFF6F5F0);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color darkCanvas = Color(0xFF12151F);
  static const Color darkSurface = Color(0xFF1B2030);

  static const Color ink = Color(0xFF121212);
  static const Color mutedInk = Color(0xFF52525B);

  static const Color saffron = Color(0xFFF4C430);
  static const Color coral = Color(0xFFFF6B4A);
  static const Color navyClock = Color(0xFF111936);
  static const Color ticketCream = Color(0xFFFFF3C4);

  static const Color onTime = Color(0xFF2EC4B6);
  static const Color late = Color(0xFFF4C430);
  static const Color absent = Color(0xFFE63946);
  static const Color excused = Color(0xFFA8B9DF);

  static Color cardBorder(bool dark) =>
      dark ? Colors.white.withValues(alpha: 0.1) : softBorder;

  static List<BoxShadow> softShadow(bool dark) => [
    BoxShadow(
      color: dark
          ? Colors.black.withValues(alpha: 0.28)
          : brandBlue.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.brandBlue,
    brightness: brightness,
    primary: dark ? AppColors.excused : AppColors.brandBlue,
    onPrimary: dark ? AppColors.ink : Colors.white,
    secondary: AppColors.saffron,
    onSecondary: AppColors.ink,
    surface: dark ? AppColors.darkSurface : AppColors.cardSurface,
    onSurface: dark ? AppColors.warmPaper : AppColors.ink,
    error: AppColors.absent,
  );

  final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
    TextTheme(
      bodyMedium: TextStyle(height: 1.45, color: scheme.onSurface),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface),
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: baseTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? AppColors.darkCanvas : AppColors.cardSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.cardBorder(dark)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.cardBorder(dark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.brandBlue, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        elevation: 0,
        backgroundColor: AppColors.brandBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: AppColors.cardBorder(dark)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: dark ? AppColors.darkSurface : AppColors.warmPaper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.cardBorder(dark)),
      ),
    ),
  );
}
