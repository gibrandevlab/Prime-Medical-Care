import 'package:flutter/material.dart';

class AppColors {
  // Palette Premium (Hybrid Dark Mode)
  // Background: Deep Dark Teal/Slate (Premium Nuance)
  static const Color background = Color(0xFF102027); 
  
  // Surface: White (High Contrast for Content)
  static const Color surface = Color(0xFFFFFFFF); 
  
  // Primary: Medical Teal
  static const Color primary = Color(0xFF00695C);
  
  // Text:
  static const Color textPrimary = Color(0xFF212121); // Black (for on Surface)
  static const Color textOnBg = Color(0xFFECEFF1);    // White (for on Background)
  static const Color textSecondary = Color(0xFF757575); 
  
  static const Color accent = Color(0xFFD4AF37); // Gold
  static const Color danger = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color itemBackground = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Tahoma',
      brightness: Brightness.light, // Keep Light brightness so widgets expect dark text on light surface
      
      // Override Scaffold BG to be Dark
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary, // Text on Surface is Black
        background: AppColors.background,
        onBackground: AppColors.textOnBg, // Text on BG is White
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background, // Dark Header to match BG
        foregroundColor: Colors.white,         // White Text
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // cardTheme: const CardTheme(
      //   color: AppColors.surface,
      //   elevation: 2,
      //   shadowColor: Colors.black12,
      //   margin: EdgeInsets.symmetric(vertical: 8),
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      // ),

      // Standardize Text styles to be readable on their respective backgrounds
      textTheme: const TextTheme(
        // Default text (on cards) -> Black
        bodyMedium: TextStyle(color: AppColors.textPrimary, fontFamily: 'Tahoma'),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontFamily: 'Tahoma'),
        
        // Titles (usually on AppBar or Section Headers) -> Check usage
        titleMedium: TextStyle(color: AppColors.textPrimary, fontFamily: 'Tahoma', fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontFamily: 'Tahoma', fontWeight: FontWeight.bold),
      ),

      // --- INPUT THEME ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: Colors.black26),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Clean look
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tahoma', fontSize: 16),
          elevation: 2,
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),

      // tabBarTheme: const TabBarTheme(
      //   labelColor: Colors.white,
      //   unselectedLabelColor: Colors.white70,
      //   indicatorColor: Colors.white,
      // ),
    );
  }
}
