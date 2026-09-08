
import 'package:flutter/material.dart';

class AppConstants {
  static const Color primary = Color(0xff16A34A);
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color darkGreen = Color(0xFF15803D);
  static const Color darkGray = Color(0xFF1F2937);
  static const Color gray = Color(0xFF6B7280);
  static const String appName = "Turfix";
  static const String currency = "₹";

  static double kHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.8;
  }
}
