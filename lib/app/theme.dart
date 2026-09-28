import 'package:flutter/material.dart';

class AppTheme {
  // Color Tokens
  static const Color bgBase = Color(0xFF0E0D12);
  static const Color surface1 = Color(0xFF1A1820);
  static const Color surface2 = Color(0xFF221F2B);
  static const Color accentStart = Color(0xFFFF6B4A);
  static const Color accentEnd = Color(0xFFFF3D7F);
  static const Color gold = Color(0xFFFFC94D);
  static const Color infoCyan = Color(0xFF3DD9C4);
  static const Color textPrimary = Color(0xFFF5F3F7);
  static const Color textSecondary = Color(0xFFA9A5B4);

  // Gradient Token
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentStart, accentEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Spacing
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Radii
  static const double radiusCard = 16.0;
  static const double radiusButton = 16.0;
  static const double radiusBottomSheet = 24.0;
  static const double radiusDialog = 24.0;
  static const double radiusChip = 10.0;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgBase,
      colorScheme: const ColorScheme.dark(
        surface: surface1,
        primary: accentStart,
        secondary: accentEnd,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface1,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusBottomSheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDialog),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 24,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          fontSize: 13,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textPrimary,
        ),
      ),
    );
  }
}
