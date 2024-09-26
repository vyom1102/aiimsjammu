import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kDebugMode) {
      return 'https://dev.iwayplus.in';
    } else {

      return 'https://maps.iwayplus.in';
    }
  }
}
