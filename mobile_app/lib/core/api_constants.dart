// lib/core/api_constants.dart

import 'package:flutter/foundation.dart';

class ApiConstants {

  // Production backend (deployed on Render)
  static const String _prodUrl = 'https://urbanroots-project.onrender.com';

  // Local dev override — use this when testing against a local backend:
  //   flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000   (emulator)
  //   flutter run --dart-define=BACKEND_URL=http://192.168.1.x:3000 (real device)
  static const String _devUrlOverride =
      String.fromEnvironment('BACKEND_URL', defaultValue: '');

  static String get baseUrl {
    // Use local override when provided (all platforms during dev)
    if (_devUrlOverride.isNotEmpty) return _devUrlOverride;
    // Default: production backend for all builds (APK, web, iOS)
    return _prodUrl;
  }

  // ── Products ───────────────────────────────────────────────
  static const String products          = '/products';
  static String productById(String id)  => '/products/$id';
  static String toggleActive(String id) => '/products/$id/toggle-active';

  // ── Sales ──────────────────────────────────────────────────
  static const String sales             = '/sales';

  // ── Sellers ────────────────────────────────────────────────
  static const String sellers           = '/sellers';
  static String sellerById(String id)   => '/sellers/$id';
  static String sellerByUid(String uid) => '/sellers/by-uid/$uid';

  // ── Beneficiaries ──────────────────────────────────────────
  static const String beneficiaries            = '/beneficiaries';
  static String beneficiaryById(String id)     => '/beneficiaries/$id';
}
