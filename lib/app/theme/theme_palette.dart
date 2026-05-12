import 'package:flutter/material.dart';

enum AppThemeType {
  lumi,     // Original Dark Purple/Cinema
  midnight, // Pitch Black/Deep Blue
  oceanic,  // Deep Teal/Cyan
  forest,   // Dark Emerald/Gold
}

class ThemePalette {
  final Color background;
  final Color gradientTop;
  final Color gradientBottom;
  final Color surface;
  final Color bottomBar;
  final Color accent;
  final Color selected;
  final Color card;
  final Color outline;

  const ThemePalette({
    required this.background,
    required this.gradientTop,
    required this.gradientBottom,
    required this.surface,
    required this.bottomBar,
    required this.accent,
    required this.selected,
    required this.card,
    required this.outline,
  });

  static const lumi = ThemePalette(
    background: Color(0xFF171336),
    gradientTop: Color(0xFF221D4B),
    gradientBottom: Color(0xFF120F2A),
    surface: Color(0xFF2D2A34),
    bottomBar: Color(0xFF2F2A33),
    accent: Color(0xFF39D0B8),
    selected: Color(0xFF19B7ED),
    card: Color(0xFF2B2555),
    outline: Color(0xFF8769FF),
  );

  static const midnight = ThemePalette(
    background: Color(0xFF070B12),
    gradientTop: Color(0xFF101722),
    gradientBottom: Color(0xFF030508),
    surface: Color(0xFF182230),
    bottomBar: Color(0xFF0C121D),
    accent: Color(0xFF3B82F6),
    selected: Color(0xFF60A5FA),
    card: Color(0xFF111827),
    outline: Color(0xFF1E293B),
  );

  static const oceanic = ThemePalette(
    background: Color(0xFF021B1A),
    gradientTop: Color(0xFF042F2E),
    gradientBottom: Color(0xFF01100F),
    surface: Color(0xFF0F3635),
    bottomBar: Color(0xFF061B1A),
    accent: Color(0xFF2DD4BF),
    selected: Color(0xFF5EEAD4),
    card: Color(0xFF062C2B),
    outline: Color(0xFF14B8A6),
  );

  static const forest = ThemePalette(
    background: Color(0xFF06140E),
    gradientTop: Color(0xFF0D251A),
    gradientBottom: Color(0xFF030806),
    surface: Color(0xFF163226),
    bottomBar: Color(0xFF0A1F16),
    accent: Color(0xFFD4AF37), // Gold
    selected: Color(0xFFE5C158),
    card: Color(0xFF0E241B),
    outline: Color(0xFF2F5F4B),
  );

  static ThemePalette fromType(AppThemeType type) {
    switch (type) {
      case AppThemeType.lumi:
        return lumi;
      case AppThemeType.midnight:
        return midnight;
      case AppThemeType.oceanic:
        return oceanic;
      case AppThemeType.forest:
        return forest;
    }
  }
}
