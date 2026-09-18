import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText {
  AppText._();

  // ==================== HEADING STYLES (ENGLISH) ====================
  static TextStyle h1 = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle h2 = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static TextStyle h3 = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static TextStyle h4 = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle h5 = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle h6 = GoogleFonts.playfairDisplay(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ==================== HEADING STYLES (ARABIC) ====================
  static TextStyle h1Ar = GoogleFonts.notoSansArabic(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static TextStyle h2Ar = GoogleFonts.notoSansArabic(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    height: 1.45,
  );

  static TextStyle h3Ar = GoogleFonts.notoSansArabic(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static TextStyle h4Ar = GoogleFonts.notoSansArabic(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static TextStyle h5Ar = GoogleFonts.notoSansArabic(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static TextStyle h6Ar = GoogleFonts.notoSansArabic(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // ==================== BODY STYLES ====================
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle bodyLargeAr = GoogleFonts.notoSansArabic(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.8,
  );

  static TextStyle bodyMediumAr = GoogleFonts.notoSansArabic(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  static TextStyle bodySmallAr = GoogleFonts.notoSansArabic(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  // ==================== CAPTION & LABEL ====================
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.3,
  );

  static TextStyle captionAr = GoogleFonts.notoSansArabic(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  static TextStyle labelAr = GoogleFonts.notoSansArabic(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  static TextStyle overlineAr = GoogleFonts.notoSansArabic(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ==================== PRICE STYLES ====================
  static TextStyle price = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static TextStyle priceLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static TextStyle priceSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle priceAr = GoogleFonts.notoSansArabic(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  static TextStyle priceStrikeThrough = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    decoration: TextDecoration.lineThrough,
  );

  static TextStyle priceStrikeThroughAr = GoogleFonts.notoSansArabic(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    decoration: TextDecoration.lineThrough,
  );

  // ==================== BUTTON STYLES ====================
  static TextStyle buttonLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static TextStyle buttonMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.3,
  );

  static TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.3,
  );

  static TextStyle buttonLargeAr = GoogleFonts.notoSansArabic(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static TextStyle buttonMediumAr = GoogleFonts.notoSansArabic(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static TextStyle buttonSmallAr = GoogleFonts.notoSansArabic(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // ==================== NAVIGATION ====================
  static TextStyle navItem = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle navItemAr = GoogleFonts.notoSansArabic(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ==================== CHIP / TAG ====================
  static TextStyle chip = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle chipAr = GoogleFonts.notoSansArabic(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // ==================== SNACKBAR ====================
  static TextStyle snackbar = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle snackbarAr = GoogleFonts.notoSansArabic(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.6,
  );

  // ==================== HELPERS ====================
  static TextStyle forLocale(TextStyle enStyle, TextStyle arStyle, Locale locale) {
    return locale.languageCode == 'ar' ? arStyle : enStyle;
  }
}
