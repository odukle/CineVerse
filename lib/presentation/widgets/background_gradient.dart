import 'package:cineverse/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BackgroundGradient extends StatelessWidget {
  const BackgroundGradient({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.cinemaGradient,
            ),
          ),
        ),
        Positioned(
          top: -90,
          left: -40,
          child: _GlowOrb(
            size: 240,
            color: AppColors.cinemaGlow.withValues(alpha: 0.2),
          ),
        ),
        Positioned(
          top: 120,
          right: -70,
          child: _GlowOrb(
            size: 260,
            color: AppColors.cinemaWarmGlow.withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          bottom: -80,
          left: 40,
          child: _GlowOrb(
            size: 220,
            color: AppColors.cinemaSelected.withValues(alpha: 0.14),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.white.withValues(alpha: 0.015),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color,
              blurRadius: size * 0.55,
              spreadRadius: size * 0.08,
            ),
          ],
        ),
      ),
    );
  }
}
