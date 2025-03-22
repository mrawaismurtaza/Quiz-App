import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF4A67FF);
  static const Color secondaryColor = Color(0xFF6C63FF);
  static const Color accentColor = Color(0xFF38CFFF);
  
  static const Color textPrimaryLight = Color(0xFF333333);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color cardLight = Colors.white;
  
  static const Color textPrimaryDark = Color(0xFFF2F2F2);
  static const Color textSecondaryDark = Color(0xFFBBBBBB);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  
  static const Color correctAnswer = Color(0xFF4CAF50);
  static const Color wrongAnswer = Color(0xFFF44336);
  
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: cardLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        color: textPrimaryLight,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        color: textSecondaryLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: primaryColor.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        color: textPrimaryDark,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        color: textSecondaryDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: primaryColor.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}