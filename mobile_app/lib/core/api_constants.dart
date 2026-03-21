// lib/core/api_constants.dart

class ApiConstants {
  // ── Change this to your NestJS server address ──────────────
  // Android emulator  → 'http://10.0.2.2:3000'
  // iOS simulator     → 'http://127.0.0.1:3000'
  // Physical device   → 'http://<your-machine-ip>:3000'
  static const String baseUrl = 'http://10.0.2.2:3000';

  // ── Products ───────────────────────────────────────────────
  static const String products        = '/products';
  static String productById(String id) => '/products/$id';
  static String toggleActive(String id) => '/products/$id/toggle-active';

  // ── Sales ──────────────────────────────────────────────────
  static const String sales           = '/sales';

  // ── Sellers ────────────────────────────────────────────────
  static const String sellers         = '/sellers';
  static String sellerById(String id) => '/sellers/$id';
}
