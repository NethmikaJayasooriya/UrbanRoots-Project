// lib/core/api_constants.dart

import 'package:flutter/foundation.dart';

class ApiConstants {

  static const String baseUrl = 'https://urbanroots-project.onrender.com';

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
