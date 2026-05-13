import 'package:cineverse/app/theme/theme_palette.dart';
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static ThemePalette palette = ThemePalette.lumi;

  static Color get seed => palette.accent;
  static Color get background => palette.background;
  static Color get surface => palette.surface;
  static Color get surfaceHigh => palette.card;
  static Color get outline => palette.outline;
  static Color get accent => palette.accent;

  static Color get cinemaBackground => palette.background;
  static Color get cinemaGradientTop => palette.gradientTop;
  static Color get cinemaGradientBottom => palette.gradientBottom;
  static Color get cinemaSurface => palette.surface;
  static Color get cinemaBottomBar => palette.bottomBar;
  static Color get cinemaPlaceholder => palette.background.withValues(alpha: 0.8);
  static Color get cinemaPillText => palette.accent.withValues(alpha: 0.9);
  static Color get cinemaAccent => palette.accent;
  static Color get cinemaSelected => palette.selected;
  static Color get cinemaScoreRing => palette.accent;

  static Color get detailsBackdropPlaceholder => palette.gradientTop;
  static Color get detailsCard => palette.card;
  static Color get detailsCardShadow => palette.gradientBottom.withValues(alpha: 0.4);
  static Color get detailsPosterSurface => palette.surface;
  static Color get detailsPosterShadow => palette.gradientBottom.withValues(alpha: 0.3);
  static const detailsPositiveRating = Color(0xFF58D356);
  static Color get detailsOutline => palette.outline;
  static Color get detailsSecondary => palette.outline.withValues(alpha: 0.8);

  static List<Color> get cinemaGradient => [
    palette.gradientTop,
    palette.background,
    palette.gradientBottom,
  ];
}

