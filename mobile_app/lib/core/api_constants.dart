// lib/core/api_constants.dart

import 'package:flutter/foundation.dart';

class ApiConstants {

  // Production backend (deployed on Render)
  static const String _prodUrl = 'https://urbanroots-project.onrender.com';

  // ─── LOCAL DEV URLS ────────────────────────────────────────────────────────
  // • Android Emulator : 10.0.2.2 maps to host's localhost
  // • Real Device (USB/WiFi): use the host PC's LAN IP on the same network
  //
  // To override at run-time (recommended for switching between emulator/device):
  //   Emulator:    flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000
  //   Real Device: flutter run --dart-define=BACKEND_URL=http://192.168.1.6:3000
  //
  // UPDATE _realDeviceUrl below whenever your PC's Wi-Fi IP changes.
  static const String _emulatorUrl   = 'http://10.0.2.2:3000';
  static const String _realDeviceUrl = 'http://192.168.1.6:3000'; // ← your PC Wi-Fi IP

  // Set to true when running on a real physical device (USB/WiFi debug).
  // Set to false when using the Android/iOS emulator.
  static const bool _useRealDevice = true;

  static String get baseUrl {
    // 1. Command-line override always wins (--dart-define=BACKEND_URL=...)
    const envUrl = String.fromEnvironment('BACKEND_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      debugPrint('URBANROOTS_DEBUG: Using env override: $envUrl');
      return envUrl;
    }

    // 2. Local dev routing
    if (kDebugMode) {
      if (kIsWeb) {
        debugPrint('URBANROOTS_DEBUG: Platform=WEB -> localhost:3000');
        return 'http://localhost:3000';
      }
      if (_useRealDevice) {
        debugPrint('URBANROOTS_DEBUG: Platform=REAL_DEVICE -> $_realDeviceUrl');
        return _realDeviceUrl;
      } else {
        debugPrint('URBANROOTS_DEBUG: Platform=EMULATOR -> $_emulatorUrl');
        return _emulatorUrl;
      }
    }

    // 3. Production fallback
    debugPrint('URBANROOTS_DEBUG: Using production URL');
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
