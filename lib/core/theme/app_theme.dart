import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Nexus Enterprise Brand Color Palette (Indigo + Slate Modern Aesthetic)
  static Color primary = const Color(0xFF4F46E5); // Indigo 600
  static Color primaryLight = const Color(0xFF6366F1); // Indigo 500
  static Color primaryDark = const Color(0xFF4338CA); // Indigo 700
  static Color primarySurface = const Color(0xFFEEF2FF); // Indigo 50

  // Secondary & Accents
  static Color accentSky = const Color(0xFF0EA5E9); // Sky 500 (Lite POS Mode)
  static Color accentSkySurface = const Color(0xFFE0F2FE); // Sky 50
  static Color manufacturing = const Color(0xFF8B5CF6); // Violet 500 (BOM / SPK)
  static Color manufacturingSurface = const Color(0xFFEDE9FE);

  // Semantic Status Colors
  static Color success = const Color(0xFF10B981); // Emerald 500
  static Color successSurface = const Color(0xFFECFDF5);
  static Color warning = const Color(0xFFF59E0B); // Amber 500
  static Color warningSurface = const Color(0xFFFFFBEB);
  static Color danger = const Color(0xFFEF4444); // Red 500
  static Color dangerSurface = const Color(0xFFFEF2F2);
  static Color info = const Color(0xFF3B82F6); // Blue 500
  static Color infoSurface = const Color(0xFFEFF6FF);

  // Neutral Colors (Slate Scale)
  static Color secondary = const Color(0xFF0F172A); // Slate 900
  static Color textMuted = const Color(0xFF64748B); // Slate 500
  static Color borderLight = const Color(0xFFE2E8F0); // Slate 200
  static Color bgApp = const Color(0xFFF8FAFC); // Slate 50
  static Color bgCard = const Color(0xFFFFFFFF);
  static Color bgSidebar = const Color(0xFF090D16); // Sleek Dark Slate
  static Color sidebarText = const Color(0xFF94A3B8); // Slate 400
  static Color sidebarActive = const Color(0xFFFFFFFF);

  // Gradients
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get liteGradient => LinearGradient(
    colors: [accentSky, const Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get sidebarGradient => LinearGradient(
    colors: [const Color(0xFF090D16), const Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient get bannerGradient => const LinearGradient(
    colors: [Color(0xFF090D16), Color(0xFF172554), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get bgGradient => LinearGradient(
    colors: [primarySurface, bgApp],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static void updatePrimaryColor(Color color) {
    primary = color;
    primaryLight = color.withAlpha(200);
    primaryDark = color.withAlpha(230);
    primarySurface = color.withAlpha(25);
  }

  static void updateThemeMode(bool isDark) {
    if (isDark) {
      secondary = const Color(0xFFF8FAFC);
      textMuted = const Color(0xFF94A3B8);
      borderLight = const Color(0xFF1E293B);
      bgApp = const Color(0xFF020617);
      bgCard = const Color(0xFF0F172A);
      bgSidebar = const Color(0xFF020617);
      sidebarText = const Color(0xFF94A3B8);
      sidebarActive = const Color(0xFFFFFFFF);
      primarySurface = const Color(0xFF1E1B4B);
      successSurface = const Color(0xFF064E3B);
      warningSurface = const Color(0xFF451A03);
      dangerSurface = const Color(0xFF450A0A);
      infoSurface = const Color(0xFF172554);
      accentSkySurface = const Color(0xFF0C4A6E);
      manufacturingSurface = const Color(0xFF2E1065);
    } else {
      secondary = const Color(0xFF0F172A);
      textMuted = const Color(0xFF64748B);
      borderLight = const Color(0xFFE2E8F0);
      bgApp = const Color(0xFFF8FAFC);
      bgCard = const Color(0xFFFFFFFF);
      bgSidebar = const Color(0xFF090D16);
      sidebarText = const Color(0xFF94A3B8);
      sidebarActive = const Color(0xFFFFFFFF);
      primarySurface = const Color(0xFFEEF2FF);
      successSurface = const Color(0xFFECFDF5);
      warningSurface = const Color(0xFFFFFBEB);
      dangerSurface = const Color(0xFFFEF2F2);
      infoSurface = const Color(0xFFEFF6FF);
      accentSkySurface = const Color(0xFFE0F2FE);
      manufacturingSurface = const Color(0xFFEDE9FE);
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    final isDark = AppColors.secondary == const Color(0xFFF8FAFC);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.bgCard,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgApp,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.secondary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.secondary,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.secondary,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textMuted,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary,
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondary),
        dataTextStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.secondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: BorderSide(color: AppColors.borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
        labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.borderLight),
        ),
      ),
      dividerTheme: DividerThemeData(color: AppColors.borderLight, thickness: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgCard,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondary),
        contentTextStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.secondary),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.bgCard,
        surfaceTintColor: Colors.transparent,
        textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.secondary),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        surface: const Color(0xFF0F172A),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF020617),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFFF1F5F9),
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
