import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
//  APP STYLES  —  Central Stylesheet
//  Color palette provided by the design team
//
//  bgColor     = Color(0xFF07160F)  → deep dark green background
//  surfaceColor= Color(0xFF16201B)  → card / surface color
//  neonGreen   = Color(0xFF00E676)  → primary neon green accent
// ═══════════════════════════════════════════════════════════

// ───────────────────────────────────────────────────────────
// COLORS
// ───────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Team provided palette ──────────────────────────────
  static const Color bgColor      = Color(0xFF07160F); // deep dark bg
  static const Color surfaceColor = Color(0xFF16201B); // cards, panels
  static const Color neonGreen    = Color(0xFF00E676); // primary accent

  // ── Extended palette (derived from team colors) ────────
  static const Color primary      = neonGreen;                  // alias
  static const Color primaryDark  = Color(0xFF00B85C);          // darker neon
  static const Color surfaceLight = Color(0xFF1E2E26);          // slightly lighter surface
  static const Color surfaceDark  = Color(0xFF0F1A13);          // slightly darker surface

  // ── Status colors ──────────────────────────────────────
  static const Color danger       = Color(0xFFFF3B3B);          // disease/error red
  static const Color warning      = Color(0xFFFFD700);          // auto flash / caution
  static const Color success      = neonGreen;                  // success = primary
  static const Color accent       = Color(0xFF69F0AE);          // soft neon green

  // ── Text colors ────────────────────────────────────────
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted     = Colors.white38;
  static const Color textHint      = Colors.white24;
  static const Color textDisabled  = Colors.white12;

  // ── Border colors ──────────────────────────────────────
  static const Color borderGreen  = Color(0xFF00E676);
  static const Color borderWhite  = Colors.white24;
  static const Color borderSurface= Color(0xFF1E3A28);

  // ── Transparent helpers ────────────────────────────────
  static Color overlay(double opacity)        => Colors.black.withOpacity(opacity);
  static Color primaryFaded(double opacity)   => neonGreen.withOpacity(opacity);
  static Color dangerFaded(double opacity)    => danger.withOpacity(opacity);
  static Color surfaceFaded(double opacity)   => surfaceColor.withOpacity(opacity);
  static Color whiteFaded(double opacity)     => Colors.white.withOpacity(opacity);
}

// ───────────────────────────────────────────────────────────
// SPACING
// ───────────────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 14.0;
  static const double lg   = 20.0;
  static const double xl   = 26.0;
  static const double xxl  = 36.0;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 22, vertical: 16);
  static const EdgeInsets cardPadding   = EdgeInsets.all(14);
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets pillPadding   =
      EdgeInsets.symmetric(horizontal: 16, vertical: 9);
  static const EdgeInsets chipPadding   =
      EdgeInsets.symmetric(horizontal: 10, vertical: 5);
}

// ───────────────────────────────────────────────────────────
// TYPOGRAPHY
// ───────────────────────────────────────────────────────────
class AppText {
  AppText._();

  static const TextStyle heading = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.3,
  );

  static const TextStyle subheading = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textMuted,
    fontSize: 12,
  );

  static const TextStyle label = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle buttonLabel = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const TextStyle dangerHeading = TextStyle(
    color: AppColors.danger,
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle primaryValue = TextStyle(
    color: AppColors.neonGreen,
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  static const TextStyle tip = TextStyle(
    color: Colors.white54,
    fontSize: 11,
  );
}

// ───────────────────────────────────────────────────────────
// 🟦 BORDER RADIUS
// ───────────────────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double xs   = 6.0;
  static const double sm   = 10.0;
  static const double md   = 14.0;
  static const double lg   = 18.0;
  static const double xl   = 24.0;
  static const double xxl  = 32.0;
  static const double pill = 100.0;

  static BorderRadius get xsBR   => BorderRadius.circular(xs);
  static BorderRadius get smBR   => BorderRadius.circular(sm);
  static BorderRadius get mdBR   => BorderRadius.circular(md);
  static BorderRadius get lgBR   => BorderRadius.circular(lg);
  static BorderRadius get xlBR   => BorderRadius.circular(xl);
  static BorderRadius get xxlBR  => BorderRadius.circular(xxl);
  static BorderRadius get pillBR => BorderRadius.circular(pill);
}

// ───────────────────────────────────────────────────────────
// 📦 BOX DECORATIONS
// ───────────────────────────────────────────────────────────
class AppStyles {
  AppStyles._();

  // Dark card
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.surfaceColor,
    borderRadius: AppRadius.mdBR,
    border: Border.all(
      color: AppColors.borderGreen.withOpacity(0.15),
    ),
  );

  // Elevated card (slightly lighter)
  static BoxDecoration get cardLight => BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: AppRadius.mdBR,
    border: Border.all(
      color: AppColors.whiteFaded(0.06),
    ),
  );

  // Result bottom sheet
  static BoxDecoration get bottomSheet => BoxDecoration(
    color: AppColors.bgColor,
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(28),
    ),
    border: Border.all(
      color: AppColors.borderGreen.withOpacity(0.25),
      width: 1.5,
    ),
  );

  // Pill shaped (flash button / status hint)
  static BoxDecoration pillDecoration({
    required Color borderColor,
    Color? bgColor,
  }) =>
      BoxDecoration(
        color: bgColor ?? AppColors.overlay(0.5),
        borderRadius: AppRadius.pillBR,
        border: Border.all(color: borderColor.withOpacity(0.7), width: 1.3),
      );

  // Danger badge
  static BoxDecoration get dangerBadge => BoxDecoration(
    color: AppColors.dangerFaded(0.15),
    borderRadius: AppRadius.xsBR,
    border: Border.all(color: AppColors.dangerFaded(0.4)),
  );

  // Success / primary badge
  static BoxDecoration get primaryBadge => BoxDecoration(
    color: AppColors.primaryFaded(0.12),
    borderRadius: AppRadius.xsBR,
    border: Border.all(color: AppColors.primaryFaded(0.35)),
  );

  // Circle icon button
  static BoxDecoration get iconCircle => BoxDecoration(
    shape: BoxShape.circle,
    color: AppColors.overlay(0.45),
    border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
  );

  // Shutter outer ring
  static BoxDecoration get shutterRing => BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.neonGreen, width: 3),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryFaded(0.35),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  );

  // Shutter inner fill
  static BoxDecoration get shutterInner => const BoxDecoration(
    shape: BoxShape.circle,
    color: AppColors.neonGreen,
  );

  // Checkbox
  static BoxDecoration checkBox({required bool checked}) => BoxDecoration(
    borderRadius: AppRadius.xsBR,
    border: Border.all(
      color: checked ? AppColors.neonGreen : Colors.white24,
      width: 1.5,
    ),
    color: checked ? AppColors.neonGreen : Colors.transparent,
  );

  // Product icon box
  static BoxDecoration get productIcon => BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: AppRadius.smBR,
  );

  // Camera top gradient
  static BoxDecoration get topGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.7),
        Colors.transparent,
      ],
    ),
  );

  // Camera bottom gradient
  static BoxDecoration get bottomGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Colors.black.withOpacity(0.8),
        Colors.transparent,
      ],
    ),
  );

  // Scan frame border
  static BoxDecoration get scanFrame => BoxDecoration(
    borderRadius: AppRadius.lgBR,
    border: Border.all(
      color: AppColors.neonGreen.withOpacity(0.5),
      width: 1.5,
    ),
  );

  // Scanning line glow
  static BoxDecoration get scanLine => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.transparent,
        AppColors.neonGreen.withOpacity(0.9),
        Colors.transparent,
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryFaded(0.5),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  );

  // Tip chip
  static BoxDecoration get tipChip => BoxDecoration(
    color: AppColors.surfaceFaded(0.7),
    borderRadius: AppRadius.mdBR,
    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
  );

  // Progress bar background
  static BoxDecoration get progressBg => BoxDecoration(
    color: Colors.white.withOpacity(0.07),
    borderRadius: AppRadius.pillBR,
  );

  // View button on product card
  static BoxDecoration get viewButton => BoxDecoration(
    color: AppColors.primaryFaded(0.12),
    borderRadius: AppRadius.smBR,
    border: Border.all(color: AppColors.primaryFaded(0.35)),
  );
}

// ───────────────────────────────────────────────────────────
// 🎞️ DURATIONS
// ───────────────────────────────────────────────────────────
class AppDuration {
  AppDuration._();

  static const Duration fast   = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 400);
  static const Duration slow   = Duration(milliseconds: 800);
  static const Duration pulse  = Duration(milliseconds: 1000);
  static const Duration scan   = Duration(milliseconds: 1600);
  static const Duration bar    = Duration(milliseconds: 1400);
}

// ───────────────────────────────────────────────────────────
// THEME  —  use in MaterialApp(theme: AppTheme.dark)
// ───────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgColor,
    colorScheme: const ColorScheme.dark(
      primary:    AppColors.neonGreen,
      secondary:  AppColors.accent,
      surface:    AppColors.surfaceColor,
      error:      AppColors.danger,
      onPrimary:  Colors.black,
      onSurface:  Colors.white,
    ),
    cardColor: AppColors.surfaceColor,
    dividerColor: Colors.white12,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        textStyle: AppText.buttonLabel,
        padding: AppSpacing.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xxlBR,
        ),
        elevation: 0,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: AppText.heading,
      titleMedium:   AppText.subheading,
      bodyMedium:    AppText.body,
      labelMedium:   AppText.label,
      bodySmall:     AppText.caption,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}