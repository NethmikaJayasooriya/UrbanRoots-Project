import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFF07160F);
  static const Color card = Color(0xFF10231A);
  static const Color accent = Color(0xFF3BFF8F);

  static const Color text = Colors.white;
  static const Color muted = Color(0xFF99AFA8);

  // you already have this
  static const Color border = Color(0xFF1E3A2E);

  // ✅ add these (needed by notifications UI)
  static const Color subText = Color(0xFFA9C2B7);
  static const Color actionBg = Color(0xFF103424);

  // ✅ optional alias: if some screens use "stroke"
  static const Color stroke = border;
}
