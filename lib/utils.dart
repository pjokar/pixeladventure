import 'package:flutter/foundation.dart';

class Utils {
  static String capitalizeFirstLetter(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }

  static bool isWebPlatform() {
    return kIsWeb;
  }
}
