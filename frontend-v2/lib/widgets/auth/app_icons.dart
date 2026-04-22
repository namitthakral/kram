import 'package:flutter/material.dart';

/// Custom icons used in the auth screens
class AppIcons {
  AppIcons._();

  // Kram logo icon
  static const Widget kramLogo = Icon(
    Icons.school_rounded,
    size: 24,
    color: Color(0xFF630ED4),
  );

  // Email icon
  static const Widget email = Icon(
    Icons.email_outlined,
    size: 16,
    color: Color(0xFF7B7487),
  );

  // Password/Lock icon  
  static const Widget lock = Icon(
    Icons.lock_outline_rounded,
    size: 16,
    color: Color(0xFF7B7487),
  );

  // Eye icon for password visibility
  static const Widget eye = Icon(
    Icons.visibility_outlined,
    size: 16,
    color: Color(0xFF7B7487),
  );

  // Eye off icon for password visibility
  static const Widget eyeOff = Icon(
    Icons.visibility_off_outlined,
    size: 16,
    color: Color(0xFF7B7487),
  );

  // Arrow right icon
  static const Widget arrowRight = Icon(
    Icons.arrow_forward_rounded,
    size: 12,
    color: Colors.white,
  );

  // Google icon (simplified)
  static const Widget google = Icon(
    Icons.g_mobiledata_rounded,
    size: 16,
    color: Color(0xFF4A4455),
  );

  // Canvas/LMS icon
  static const Widget canvas = Icon(
    Icons.account_balance_outlined,
    size: 16,
    color: Color(0xFF4A4455),
  );
}