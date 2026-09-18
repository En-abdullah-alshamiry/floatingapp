import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==================== LIGHT THEME ====================
  static const Color lightPrimary = Color(0xFF1A1A1A);
  static const Color lightSecondary = Color(0xFF2D2D2D);
  static const Color lightAccent = Color(0xFFC8A97E);
  static const Color lightGold = Color(0xFFD4AF37);
  static const Color lightBackground = Color(0xFFF8F6F3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightSubText = Color(0xFF6B6B6B);
  static const Color lightBorder = Color(0xFFE8E4DF);
  static const Color lightDivider = Color(0xFFF0ECE7);
  static const Color lightError = Color(0xFFC0392B);
  static const Color lightSuccess = Color(0xFF27AE60);
  static const Color lightWarning = Color(0xFFF39C12);
  static const Color lightGoldDark = Color(0xFFB8956A);
  static const Color lightOverlay = Color(0x33000000);
  static const Color lightShadow = Color(0x1A000000);

  // ==================== DARK THEME ====================
  static const Color darkPrimary = Color(0xFFC8A97E);
  static const Color darkSecondary = Color(0xFFD4AF37);
  static const Color darkAccent = Color(0xFFE8C97A);
  static const Color darkGold = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF242424);
  static const Color darkText = Color(0xFFF5F0EB);
  static const Color darkSubText = Color(0xFF9E9E9E);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkDivider = Color(0xFF2A2A2A);
  static const Color darkError = Color(0xFFE74C3C);
  static const Color darkSuccess = Color(0xFF2ECC71);
  static const Color darkWarning = Color(0xFFF1C40F);
  static const Color darkGoldLight = Color(0xFFF0D99A);
  static const Color darkOverlay = Color(0x66000000);
  static const Color darkShadow = Color(0x33000000);

  // ==================== SHARED ====================
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF0D99A);
  static const Color goldDark = Color(0xFFB8956A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ==================== GRADIENTS ====================
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFC8A97E), Color(0xFFB8956A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ==================== LIGHT GRADIENT ====================
  static const LinearGradient lightGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F6F3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF242424), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [Color(0xFF2A2A2A), Color(0xFF333333), Color(0xFF2A2A2A)],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF2D2D2D),
      Color(0xFF1A1A1A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient saleGradient = LinearGradient(
    colors: [Color(0xFFC0392B), Color(0xFFE74C3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
