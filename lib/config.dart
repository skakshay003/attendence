// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';

class ApiConstants {
  // static const String backendIP = 'https://app.staffin.cloud/'; 
  static const String backendIP = 'http://mindtek.seasense.in/mindtek/admin_login/';
}

void hack(dynamic data) {
  // Only print sensitive data in debug mode
  if (!kReleaseMode) {
    print(data);
  }
}