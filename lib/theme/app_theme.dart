import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Purple-Black Palette ──
  static const Color primary = Color(0xFF9B59FF);       // vivid purple
  static const Color primaryDark = Color(0xFF7B3FE4);
  static const Color primaryLight = Color(0xFFBB86FC);
  static const Color accent = Color(0xFFD4AAFF);        // soft lavender
  static const Color bgBlack = Color(0xFF08080D);       // near-black
  static const Color surface = Color(0xFF10101A);
  static const Color card = Color(0xFF18182A);
  static const Color cardHover = Color(0xFF22223A);
  static const Color divider = Color(0xFF2A2A40);
  static const Color textWhite = Color(0xFFF0EEFF);
  static const Color textGrey = Color(0xFF9494B0);
  static const Color textDim = Color(0xFF55556A);
  static const Color errorRed = Color(0xFFFF4C6A);
  static const Color successGreen = Color(0xFF2ECC71);
  static const Color shimmerBase = Color(0xFF18182A);
  static const Color shimmerHigh = Color(0xFF22223A);

  // ── Gradients ──
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9B59FF), Color(0xFF6B3FD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF10101A), Color(0xFF08080D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E30), Color(0xFF18182A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgBlack,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: bgBlack,
        onSurface: textWhite,
        onError: textWhite,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: textWhite, letterSpacing: -1),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textWhite, letterSpacing: -0.5),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: primary),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textWhite),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textWhite),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textWhite),
          bodyLarge: TextStyle(fontSize: 16, color: textWhite, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, color: textGrey, height: 1.4),
          bodySmall: TextStyle(fontSize: 12, color: textDim),
          labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: textWhite, letterSpacing: 0.5),
        iconTheme: const IconThemeData(color: textWhite, size: 24),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: divider, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: errorRed, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: errorRed, width: 2)),
        labelStyle: const TextStyle(color: textGrey, fontSize: 14),
        hintStyle: const TextStyle(color: textDim, fontSize: 14),
        prefixIconColor: primary,
        errorStyle: const TextStyle(color: errorRed, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primary.withValues(alpha: 0.12),
        labelStyle: const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600),
        side: BorderSide(color: primary.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 0.5),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: GoogleFonts.poppins(color: textWhite, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textWhite),
      ),
      iconTheme: const IconThemeData(color: primary),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
    );
  }
}
