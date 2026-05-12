import 'package:cineverse/app/theme/theme_palette.dart';
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static ThemePalette _palette = ThemePalette.lumi;
  
  static ThemePalette get palette => _palette;
  static set palette(ThemePalette p) => _palette = p;

  static const seed = Color(0xFFD4A756);
  static const background = Color(0xFF070B12);
  static const surface = Color(0xFF101722);
  static const surfaceHigh = Color(0xFF182230);
  static const outline = Color(0xFF314155);
  static const accent = Color(0xFFC76B5F);

  static Color get cinemaBackground => _palette.background;
  static Color get cinemaGradientTop => _palette.gradientTop;
  static Color get cinemaGradientBottom => _palette.gradientBottom;
  static Color get cinemaSurface => _palette.surface;
  static Color get cinemaBottomBar => _palette.bottomBar;
  static Color get cinemaPlaceholder => _palette.background.withValues(alpha: 0.8);
  static Color get cinemaPillText => _palette.accent.withValues(alpha: 0.9);
  static Color get cinemaAccent => _palette.accent;
  static Color get cinemaSelected => _palette.selected;
  static Color get cinemaScoreRing => _palette.accent;

  static Color get detailsBackdropPlaceholder => _palette.gradientTop;
  static Color get detailsCard => _palette.card;
  static Color get detailsCardShadow => _palette.gradientBottom.withValues(alpha: 0.4);
  static Color get detailsPosterSurface => _palette.surface;
  static Color get detailsPosterShadow => _palette.gradientBottom.withValues(alpha: 0.3);
  static const detailsPositiveRating = Color(0xFF58D356);
  static Color get detailsOutline => _palette.outline;
  static Color get detailsSecondary => _palette.outline.withValues(alpha: 0.8);

  static List<Color> get cinemaGradient => [
    _palette.gradientTop,
    _palette.background,
    _palette.gradientBottom,
  ];
}

