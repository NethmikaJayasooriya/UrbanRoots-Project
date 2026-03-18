import 'package:flutter/material.dart';

class AppColors {
  // main background color
  static const Color background = Color(0xFF07160f);

  //Surface color for cards and containers
  static const Color surfaceColor = Color(0xFF16201b);
  static const Color surfaceAlt  = Color(0xFF1E2D24);  

  //brand neon green for active states and highlights
  static const Color primary = Color(0xFF00e676);
  static const Color primaryMuted = Color(0x2200e676); 

  //font colors
  static const Color textMain = Colors.white;
  static const Color textdim = Colors.white54;
  static const Color textLight = Colors.white70;
  static const Color textFaint = Colors.white38;

  // Error / destructive actions
  static const Color error = Colors.redAccent;

  // Borders
  static const Color border = Color(0xFF2A3D2A);
}

class AppSizes {
  // Border radius
  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;

  // Padding
  static const double paddingSm = 8;
  static const double paddingMd = 16;
  static const double paddingLg = 24;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 22;
  static const double iconLg = 32;

  // Button height
  static const double buttonHeight = 50;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    color: AppColors.textMain,
  );

  static const TextStyle muted = TextStyle(
    fontSize: 12,
    color: AppColors.textdim,
  );

  static const TextStyle price = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
}

class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.surfaceColor,
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    border: Border.all(color: AppColors.border),
  );

  static InputDecoration field(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
  );
}
