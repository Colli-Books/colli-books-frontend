import 'package:flutter/material.dart';

abstract class AppColors {
  const AppColors._();

  // -------------------------------------------------
  //                  Raw Colors
  // -------------------------------------------------
  static const Color _oliveGreen = Color(0xFF9e9d20);
  static const Color _oliveGray = Color(0xFF797864);
  static const Color _deepRed = Color(0xFF562628);
  static const Color _deepRedDarker = Color(0xFF3B1A12);
  static const Color _brownGray = Color(0xFF484836);
  static const Color _cyan = Color(0xFF1d8e9e);
  static const Color _whiteCream = Color(0xFFf6f0e2);
  static const Color _whiteCreamDarker = Color(0xFFE2DDD3);
  static const Color _coralRed = Color(0xFFe36467);
  static const Color _green = Color(0xFF2E7D32);
  static const Color _orange = Color(0xFFED6C02);

  // -------------------------------------------------
  //                  Semantic Colors
  // -------------------------------------------------

  // Brand & Accents
  static const Color primary = _oliveGreen;
  static const Color secondary = _deepRed;

  // Backgrounds & Surfaces
  static const Color background = _oliveGray;
  static const Color surface = _whiteCream;
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = _whiteCreamDarker;

  // Text & Typography
  static const Color textPrimary = _deepRedDarker;
  static const Color textSecondary = _brownGray;
  static const Color titleText = _deepRed;
  static const Color textOnPrimary = Colors.white;
  static const Color textOnDanger = Colors.white;

// Feedback & Statuses
  static const Color danger = _coralRed;
  static const Color success = _green;
  static const Color warning = _orange;

  // Borders & Dividers
  static const Color border = _whiteCreamDarker;
  static const Color divider = _whiteCreamDarker;
  static const Color pendingBadgeBorder = Color(0xFFe6c7aa);
  static const Color activeBadgeBorder = Color(0xFFbfe0e4);

  // Status Badges
  static const Color activeBadgeBg = Color(0xFFe8f4f5);
  static const Color activeBadgeText = _cyan;

  static const Color pendingBadgeBg = Color(0xFFfae6d5);
  static const Color pendingBadgeText = Color(0xFF944a00);

  // Overlays & Interactive States
  static const Color disabled = Color(0xFFCCCCCC);
  static const Color disabledText = Color(0xFF888888);
  static const Color scrim = Color(0x80000000);
}