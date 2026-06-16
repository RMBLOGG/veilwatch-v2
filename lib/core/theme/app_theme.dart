import 'package:flutter/material.dart';

class VeilwatchColors {
  // Base
  static const bg = Color(0xFF0A0A0F);
  static const surface = Color(0xFF12121A);
  static const surfaceElevated = Color(0xFF1A1A26);
  static const border = Color(0xFF252535);

  // Accent - deep violet/indigo
  static const accent = Color(0xFF7C5CFC);
  static const accentDim = Color(0xFF4A3699);
  static const accentGlow = Color(0x337C5CFC);

  // Text
  static const textPrimary = Color(0xFFF0EFFF);
  static const textSecondary = Color(0xFF8B8AA8);
  static const textMuted = Color(0xFF4A4A6A);

  // Status
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFF87171);

  // Gradient
  static const gradientStart = Color(0xFF0A0A0F);
  static const gradientEnd = Color(0xFF1A0A2E);
}

class VeilwatchTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: VeilwatchColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: VeilwatchColors.accent,
          secondary: VeilwatchColors.accentDim,
          surface: VeilwatchColors.surface,
          error: VeilwatchColors.error,
        ),
        fontFamily: 'Urbanist',
        appBarTheme: const AppBarTheme(
          backgroundColor: VeilwatchColors.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Urbanist',
            color: VeilwatchColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: VeilwatchColors.textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: VeilwatchColors.surface,
          selectedItemColor: VeilwatchColors.accent,
          unselectedItemColor: VeilwatchColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: VeilwatchColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            color: VeilwatchColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: VeilwatchColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: VeilwatchColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            color: VeilwatchColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          labelSmall: TextStyle(
            color: VeilwatchColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardTheme(
          color: VeilwatchColors.surfaceElevated,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: VeilwatchColors.surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: VeilwatchColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: VeilwatchColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: VeilwatchColors.accent, width: 1.5),
          ),
          hintStyle: const TextStyle(color: VeilwatchColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerTheme: const DividerThemeData(
          color: VeilwatchColors.border,
          thickness: 1,
        ),
      );
}
