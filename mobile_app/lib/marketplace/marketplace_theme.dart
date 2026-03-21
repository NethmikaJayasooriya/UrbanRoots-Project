import 'package:flutter/material.dart';

class MarketplaceTheme {
  static const Color background = Color(0xFF050E07);
  static const Color cardColor = Color(0xFF0A1F0F);
  static const Color primaryGreen = Color(0xFF1DB954);
  static const Color lightGreen = Color(0xFF8DFFC4);
  static const Color darkGreen = Color(0xFF001A0F);
  static const Color textWhite = Colors.white;
  static const Color textGray = Colors.white54;

  static BoxDecoration glassBox({double radius = 16}) {
    return BoxDecoration(
      color: cardColor.withOpacity(0.6),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: primaryGreen.withOpacity(0.15), width: 1),
      boxShadow: [
        BoxShadow(
          color: primaryGreen.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
