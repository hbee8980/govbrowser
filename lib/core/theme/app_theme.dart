import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color primaryColor = Color(0xFF1565C0); // Professional Blue
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color accentColor = Color(0xFF00897B); // Teal accent
  static const Color urgentColor = Color(0xFFE53935); // Red for urgent items
  static const Color successColor = Color(0xFF43A047); // Green for success
  static const Color warningColor = Color(0xFFFFA000); // Amber for warnings

  // Neutral colors
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2D2D2D);

  // Sidekick overlay colors
  static const Color overlayBackground = Color(0xFF1E3A5F);
  static const Color overlayFab = Color(0xFF2196F3);

  /// Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceLight,
        error: urgentColor,
      ),
      scaffoldBackgroundColor: surfaceLight,
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: overlayFab,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryColor),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryLight.withValues(alpha: 0.1),
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.inter(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: _buildTextTheme(Brightness.light),
      dividerTheme: DividerThemeData(color: Colors.grey[300], thickness: 1),
    );
  }

  /// Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryLight,
        secondary: accentColor,
        surface: surfaceDark,
        error: urgentColor,
      ),
      scaffoldBackgroundColor: surfaceDark,
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: primaryLight,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: overlayFab,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryLight),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryDark.withValues(alpha: 0.3),
        selectedColor: primaryLight,
        labelStyle: GoogleFonts.inter(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      dividerTheme: DividerThemeData(color: Colors.grey[800], thickness: 1),
    );
  }

  /// Build text theme with Google Fonts
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor =
        brightness == Brightness.light ? Colors.black87 : Colors.white;
    final secondaryColor =
        brightness == Brightness.light ? Colors.black54 : Colors.white70;

    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
    );
  }
}
