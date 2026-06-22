import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const darkGreen   = Color(0xFF2E3A2E);
  static const green       = Color(0xFF6A7562);
  static const lightGreen  = Color(0xFFAFB796);
  static const primary     = Color(0xFF4CAF50);
  static const beige       = Color(0xFFF1EEE9);
  static const peach       = Color(0xFFDAB79F);
  static const background  = Color(0xFFF5F5F0);
  static const surface     = Color(0xFFFFFFFF);
  static const text        = Color(0xFF1A1A1A);
  static const textLight   = Color(0xFF6A7562);
  static const textMuted   = Color(0xFF9E9E9E);
  static const border      = Color(0xFFE8E8E0);
  static const error       = Color(0xFFE53935);

  static const statusPending    = Color(0xFFFF9800);
  static const statusProgress   = Color(0xFF2196F3);
  static const statusResolved   = Color(0xFF4CAF50);
  static const statusClosed     = Color(0xFF9E9E9E);

  static const gradientStart = Color(0xFF2E3A2E);
  static const gradientEnd   = Color(0xFF4A5E4A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1E2B1E), Color(0xFF3A4E3A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTextStyles {
  static TextStyle display(BuildContext context) =>
      GoogleFonts.tajawal(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text);
  static TextStyle title(BuildContext context) =>
      GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text);
  static TextStyle subtitle(BuildContext context) =>
      GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.text);
  static TextStyle body(BuildContext context) =>
      GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.text);
  static TextStyle caption(BuildContext context) =>
      GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w300, color: AppColors.textMuted);
  static TextStyle label(BuildContext context) =>
      GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLight);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkGreen,
        primary: AppColors.darkGreen,
        secondary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.tajawalTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.darkGreen.withAlpha(30),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.tajawal(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
            );
          }
          return GoogleFonts.tajawal(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.darkGreen, size: 24);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 22);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
        ),
        labelStyle: GoogleFonts.tajawal(color: AppColors.textLight, fontSize: 14),
        hintStyle: GoogleFonts.tajawal(color: AppColors.textMuted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

// Reusable shadow decoration
BoxDecoration cardDecoration({double radius = 20, Color? color}) => BoxDecoration(
  color: color ?? AppColors.surface,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [
    BoxShadow(
      color: AppColors.darkGreen.withAlpha(15),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ],
);
