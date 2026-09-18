import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const double _cardRadius = 16.0;
  static const double _buttonRadius = 12.0;
  static const double _inputRadius = 12.0;
  static const double _bottomSheetRadius = 24.0;
  static const double _dialogRadius = 20.0;
  static const double _chipRadius = 20.0;

  // ==================== LIGHT THEME ====================
  static ThemeData get lightTheme {
    final lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lightAccent,
      onPrimaryContainer: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE8E4DF),
      onSecondaryContainer: AppColors.lightSecondary,
      tertiary: AppColors.lightGold,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFF3D6),
      onTertiaryContainer: AppColors.lightGoldDark,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFAFAFA),
      surfaceContainer: const Color(0xFFF5F5F5),
      surfaceContainerHigh: const Color(0xFFEEEEEE),
      surfaceContainerHighest: const Color(0xFFE5E5E5),
      surfaceDim: const Color(0xFFD9D9D9),
      error: AppColors.lightError,
      onError: Colors.white,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightDivider,
      shadow: AppColors.lightShadow,
      inverseSurface: AppColors.lightPrimary,
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.lightAccent,
      scrim: Colors.black,
    );

    return _buildTheme(lightColorScheme, Brightness.light);
  }

  // ==================== DARK THEME ====================
  static ThemeData get darkTheme {
    final darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkBackground,
      primaryContainer: AppColors.darkGold,
      onPrimaryContainer: AppColors.darkBackground,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkBackground,
      secondaryContainer: const Color(0xFF333333),
      onSecondaryContainer: AppColors.darkText,
      tertiary: AppColors.darkAccent,
      onTertiary: AppColors.darkBackground,
      tertiaryContainer: const Color(0xFF2D2518),
      onTertiaryContainer: AppColors.darkGoldLight,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerLowest: const Color(0xFF111111),
      surfaceContainerLow: AppColors.darkSurface,
      surfaceContainer: const Color(0xFF1E1E1E),
      surfaceContainerHigh: const Color(0xFF282828),
      surfaceContainerHighest: const Color(0xFF333333),
      surfaceDim: const Color(0xFF0D0D0D),
      error: AppColors.darkError,
      onError: Colors.white,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkDivider,
      shadow: AppColors.darkShadow,
      inverseSurface: AppColors.darkText,
      onInverseSurface: AppColors.darkBackground,
      inversePrimary: AppColors.darkGold,
      scrim: Colors.black,
    );

    return _buildTheme(darkColorScheme, Brightness.dark);
  }

  // ==================== BUILD THEME ====================
  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark ? AppColors.darkSubText : AppColors.lightSubText;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final goldColor = AppColors.gold;

    final baseTextTheme = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final playfairTextTheme = GoogleFonts.playfairDisplayTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final textTheme = baseTextTheme.copyWith(
      displayLarge: playfairTextTheme.displayLarge?.copyWith(color: textPrimary),
      displayMedium: playfairTextTheme.displayMedium?.copyWith(color: textPrimary),
      displaySmall: playfairTextTheme.displaySmall?.copyWith(color: textPrimary),
      headlineLarge: playfairTextTheme.headlineLarge?.copyWith(color: textPrimary),
      headlineMedium: playfairTextTheme.headlineMedium?.copyWith(color: textPrimary),
      headlineSmall: playfairTextTheme.headlineSmall?.copyWith(color: textPrimary),
      titleLarge: baseTextTheme.titleLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
      titleMedium: baseTextTheme.titleMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
      titleSmall: baseTextTheme.titleSmall?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimary, height: 1.6),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textPrimary, height: 1.5),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: textSecondary, height: 1.4),
      labelLarge: baseTextTheme.labelLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelMedium: baseTextTheme.labelMedium?.copyWith(color: textSecondary, fontWeight: FontWeight.w500, letterSpacing: 0.3),
      labelSmall: baseTextTheme.labelSmall?.copyWith(color: textSecondary, letterSpacing: 1.0, fontWeight: FontWeight.w500),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,

      // ==================== APP BAR ====================
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.1),
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // ==================== CARD ====================
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: isDark ? 2 : 1,
        shadowColor: isDark ? Colors.black38 : Colors.grey.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ==================== ELEVATED BUTTON ====================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          foregroundColor: AppColors.black,
          elevation: 2,
          shadowColor: goldColor.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ==================== FILLED BUTTON ====================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ==================== OUTLINED BUTTON ====================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: borderColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ==================== TEXT BUTTON ====================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ==================== ICON BUTTON ====================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textPrimary,
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
        ),
      ),

      // ==================== INPUT DECORATION ====================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkCard : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
        ),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5)),
        ),
      ),

      // ==================== SEARCH ====================
      // Search experience uses inputDecorationTheme (rounded, filled fields).

      // ==================== BOTTOM NAVIGATION ====================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        selectedItemColor: goldColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ==================== NAVIGATION BAR (Material 3) ====================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 8,
        shadowColor: isDark ? Colors.black54 : Colors.grey.withValues(alpha: 0.2),
        indicatorColor: goldColor.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: goldColor,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: goldColor, size: 24);
          }
          return IconThemeData(color: textSecondary, size: 24);
        }),
      ),

      // ==================== NAVIGATION RAIL ====================
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        selectedIconTheme: IconThemeData(color: goldColor, size: 24),
        unselectedIconTheme: IconThemeData(color: textSecondary, size: 24),
        selectedLabelTextStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: goldColor,
        ),
        unselectedLabelTextStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        indicatorColor: goldColor.withValues(alpha: 0.2),
      ),

      // ==================== CHIP ====================
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkCard : Colors.grey.shade50,
        selectedColor: goldColor,
        disabledColor: isDark ? AppColors.darkCard : Colors.grey.shade200,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_chipRadius),
          side: BorderSide(color: borderColor),
        ),
        side: BorderSide(color: borderColor),
      ),

      // ==================== BADGE ====================
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.lightError,
        textColor: Colors.white,
        smallSize: 8,
        largeSize: 16,
        textStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ==================== BOTTOM SHEET ====================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_bottomSheetRadius),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: borderColor,
      ),

      // ==================== DIALOG ====================
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_dialogRadius),
        ),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
      ),

      // ==================== SNACKBAR ====================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightPrimary,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        elevation: 8,
      ),

      // ==================== TOOLTIP ====================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkText : AppColors.lightPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 12,
          color: isDark ? AppColors.darkBackground : Colors.white,
        ),
      ),

      // ==================== TAB BAR ====================
      tabBarTheme: TabBarThemeData(
        labelColor: goldColor,
        unselectedLabelColor: textSecondary,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: goldColor,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: borderColor,
      ),

      // ==================== DIVIDER ====================
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 0.5,
        space: 1,
      ),

      // ==================== LIST TILE ====================
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 13,
          color: textSecondary,
          height: 1.4,
        ),
        leadingAndTrailingTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
        iconColor: textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),

      // ==================== POPUP MENU ====================
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? AppColors.darkCard : Colors.white,
        elevation: 8,
        shadowColor: isDark ? Colors.black54 : Colors.grey.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textPrimary,
        ),
      ),

      // ==================== DROPDOWN ====================
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? AppColors.darkCard : Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textPrimary,
        ),
      ),

      // ==================== PROGRESS INDICATOR ====================
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: goldColor,
        linearTrackColor: borderColor,
        circularTrackColor: borderColor,
      ),

      // ==================== SWITCH ====================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return goldColor;
          }
          return isDark ? AppColors.darkSubText : Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return goldColor.withValues(alpha: 0.3);
          }
          return isDark ? AppColors.darkBorder : Colors.grey.shade300;
        }),
      ),

      // ==================== CHECKBOX ====================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return goldColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.black),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ==================== RADIO ====================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return goldColor;
          }
          return borderColor;
        }),
      ),

      // ==================== SLIDER ====================
      sliderTheme: SliderThemeData(
        activeTrackColor: goldColor,
        inactiveTrackColor: borderColor,
        thumbColor: goldColor,
        overlayColor: goldColor.withValues(alpha: 0.1),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),

      // ==================== FLOATING ACTION BUTTON ====================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: goldColor,
        foregroundColor: AppColors.black,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),

      // ==================== PAGE TRANSITIONS ====================
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
