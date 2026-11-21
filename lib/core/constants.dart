import 'package:flutter/foundation.dart';

class AppConstants {
  // Production server URL
  static const String _baseHost = 'https://app.marsksa.com';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8001/api';
    }
    return '$_baseHost/api';
  }

  static String get storageUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8001/storage/';
    }
    return '$_baseHost/storage/';
  }

  static const String appName = 'Shash - شاش';
}
