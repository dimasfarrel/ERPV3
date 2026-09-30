import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary brand color
  static Color primary = const Color(0xFF194BFB);
  static Color primaryLight = const Color(0xFF4169FC);
  static Color primaryDark = const Color(0xFF0E36D9);
  static Color primarySurface = const Color(0xFFEEF2FF);

  // Semantic colors
  static Color success = const Color(0xFF10B981);
  static Color successSurface = const Color(0xFFD1FAE5);
  static Color warning = const Color(0xFFF59E0B);
  static Color warningSurface = const Color(0xFFFEF3C7);
  static Color danger = const Color(0xFFEF4444);
  static Color dangerSurface = const Color(0xFFFEE2E2);
  static Color info = const Color(0xFF3B82F6);
  static Color infoSurface = const Color(0xFFDBEAFE);

  // Neutral
  static Color secondary = const Color(0xFF1E293B);
  static Color textMuted = const Color(0xFF64748B);
  static Color borderLight = const Color(0xFFE2E8F0);
  static Color bgApp = const Color(0xFFF1F5F9);
  static Color bgCard = const Color(0xFFFFFFFF);
  static Color bgSidebar = const Color(0xFF0F172A);
  static Color sidebarText = const Color(0xFF94A3B8);
  static Color sidebarActive = const Color(0xFFFFFFFF);

  // Gradients
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient get sidebarGradient => LinearGradient(
    colors: [bgSidebar, secondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static LinearGradient get bgGradient => LinearGradient(
    colors: [primarySurface, bgApp],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static void updatePrimaryColor(Color color) {
    primary = color;
    primaryLight = color.withOpacity(0.8);
    primaryDark = color.withOpacity(0.9);
    primarySurface = color.withOpacity(0.1);
  }

  static void updateThemeMode(bool isDark) {
    if (isDark) {
      secondary = const Color(0xFFF8FAFC);
      textMuted = const Color(0xFF94A3B8);
      borderLight = const Color(0xFF334155);
      bgApp = const Color(0xFF0F172A);
      bgCard = const Color(0xFF1E293B);
      bgSidebar = const Color(0xFF020617);
      sidebarText = const Color(0xFF94A3B8);
      sidebarActive = const Color(0xFFFFFFFF);
    } else {
      secondary = const Color(0xFF1E293B);
      textMuted = const Color(0xFF64748B);
      borderLight = const Color(0xFFE2E8F0);
      bgApp = const Color(0xFFF1F5F9);
      bgCard = const Color(0xFFFFFFFF);
      bgSidebar = const Color(0xFF0F172A);
      sidebarText = const Color(0xFF94A3B8);
      sidebarActive = const Color(0xFFFFFFFF);
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.bgCard,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgApp,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.secondary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.secondary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.secondary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.secondary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.secondary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: BorderSide(color: AppColors.borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.borderLight),
        ),
      ),
      dividerTheme: DividerThemeData(color: AppColors.borderLight, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.secondary,
        ),
      ),
    );
  }
}
