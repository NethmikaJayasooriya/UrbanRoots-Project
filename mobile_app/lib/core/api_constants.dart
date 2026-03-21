// lib/core/api_constants.dart

class ApiConstants {

  static const String baseUrl = 'http://10.0.2.2:3000';

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
