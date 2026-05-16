import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color accentAmber = Color(0xFFFFC107);
  static const Color darkGold = Color(0xFFB8960C);
  static const Color lightGold = Color(0xFFFFF0B3);
  static const Color backgroundBlack = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF141414);
  static const Color cardDark = Color(0xFF1C1C1E);
  static const Color cardHover = Color(0xFF2C2C2E);
  static const Color dividerColor = Color(0xFF2C2C2E);
  static const Color textWhite = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFFAAAAAA);
  static const Color textDarkGrey = Color(0xFF666666);
  static const Color errorRed = Color(0xFFFF453A);
  static const Color successGreen = Color(0xFF32D74B);
  static const Color shimmerBase = Color(0xFF1C1C1E);
  static const Color shimmerHighlight = Color(0xFF2C2C2E);

  // ── Gradients ──
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF0A0A0A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF141414)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundBlack,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: accentAmber,
        surface: surfaceDark,
        error: errorRed,
        onPrimary: backgroundBlack,
        onSecondary: backgroundBlack,
        onSurface: textWhite,
        onError: textWhite,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: textWhite, letterSpacing: -1),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textWhite, letterSpacing: -0.5),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: primaryGold),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textWhite),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textWhite),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textWhite),
          bodyLarge: TextStyle(fontSize: 16, color: textWhite, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, color: textGrey, height: 1.4),
          bodySmall: TextStyle(fontSize: 12, color: textDarkGrey),
          labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: backgroundBlack, letterSpacing: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryGold,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: primaryGold, letterSpacing: 1),
        iconTheme: const IconThemeData(color: primaryGold, size: 24),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: backgroundBlack,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: backgroundBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          side: const BorderSide(color: primaryGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGold,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: dividerColor, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryGold, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: errorRed, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: errorRed, width: 2)),
        labelStyle: const TextStyle(color: textGrey, fontSize: 14),
        hintStyle: const TextStyle(color: textDarkGrey, fontSize: 14),
        prefixIconColor: primaryGold,
        errorStyle: const TextStyle(color: errorRed, fontSize: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryGold,
        unselectedItemColor: textDarkGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryGold.withValues(alpha: 0.12),
        labelStyle: const TextStyle(color: primaryGold, fontSize: 12, fontWeight: FontWeight.w600),
        side: BorderSide(color: primaryGold.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(color: dividerColor, thickness: 0.5),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: GoogleFonts.poppins(color: textWhite, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textWhite),
      ),
      iconTheme: const IconThemeData(color: primaryGold),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryGold),
    );
  }
}
