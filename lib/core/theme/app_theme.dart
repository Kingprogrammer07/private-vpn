import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds (Deep Obsidian Dark with subtle Cyber-Green undertone)
  static const Color background = Color(0xFF070B09);
  static const Color surface = Color(0xFF0F1713);
  static const Color surfaceLight = Color(0xFF16241C);
  static const Color border = Color(0xFF1E3327);
  
  // Accents (Electric Cyber Neon Green)
  static const Color primary = Color(0xFF00FF88); // Electric Neon Green
  static const Color primaryGlow = Color(0x4000FF88);
  
  static const Color connected = Color(0xFF00FF88); // Neon Green Active
  static const Color connectedGlow = Color(0x4D00FF88);
  
  static const Color connecting = Color(0xFFFFCC00); // Electric Amber
  static const Color connectingGlow = Color(0x40FFCC00);
  
  static const Color disconnected = Color(0xFF2E3E34); // Slate
  static const Color error = Color(0xFFFF4D4D);
  
  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1B5A9);
  static const Color textMuted = Color(0xFF637B6E);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      fontFamily: 'Segoe UI',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }
}
