import 'package:flutter/material.dart';

enum AppThemeType {
  lumi, // Neon midnight cinema
  midnight, // Deep blue noir
  oceanic, // Teal current
  forest, // Emerald luxe
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
    background: Color(0xFF09111F),
    gradientTop: Color(0xFF152A4F),
    gradientBottom: Color(0xFF220B35),
    surface: Color(0xFF12243F),
    bottomBar: Color(0xFF0B1527),
    accent: Color(0xFF42E8FF),
    selected: Color(0xFFFF5CA8),
    card: Color(0xFF101C34),
    outline: Color(0xFF8668FF),
  );

  static const midnight = ThemePalette(
    background: Color(0xFF050912),
    gradientTop: Color(0xFF0C1B35),
    gradientBottom: Color(0xFF1A0A20),
    surface: Color(0xFF111D33),
    bottomBar: Color(0xFF07101D),
    accent: Color(0xFF5BB8FF),
    selected: Color(0xFF8B7CFF),
    card: Color(0xFF0D172B),
    outline: Color(0xFF39527F),
  );

  static const oceanic = ThemePalette(
    background: Color(0xFF041516),
    gradientTop: Color(0xFF08333A),
    gradientBottom: Color(0xFF03111B),
    surface: Color(0xFF0D2830),
    bottomBar: Color(0xFF081920),
    accent: Color(0xFF47E7D0),
    selected: Color(0xFF60A5FA),
    card: Color(0xFF0A2128),
    outline: Color(0xFF0EC6B4),
  );

  static const forest = ThemePalette(
    background: Color(0xFF08140F),
    gradientTop: Color(0xFF123123),
    gradientBottom: Color(0xFF120A18),
    surface: Color(0xFF153125),
    bottomBar: Color(0xFF0B1F18),
    accent: Color(0xFFE4C15C),
    selected: Color(0xFF55E6B5),
    card: Color(0xFF10261D),
    outline: Color(0xFF3E7E62),
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
