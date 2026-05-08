import 'dart:math' as math;

import 'package:cineverse/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RatingBadge extends StatelessWidget {
  const RatingBadge.loading({super.key, required this.size})
    : label = null,
      catalogScore = null,
      _mode = _RatingBadgeMode.loading;

  const RatingBadge.rottenTomatoes({
    super.key,
    required this.label,
    required this.size,
  }) : catalogScore = null,
       _mode = _RatingBadgeMode.rottenTomatoes;

  const RatingBadge.tmdb({super.key, required this.size, this.catalogScore})
    : label = null,
      _mode = _RatingBadgeMode.tmdb;

  final String? label;
  final double? catalogScore;
  final double size;
  final _RatingBadgeMode _mode;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: switch (_mode) {
          _RatingBadgeMode.loading => _LoadingDotsBadge(size: size),
          _RatingBadgeMode.rottenTomatoes => _RottenTomatoesBadge(
            label: label ?? 'NA',
            size: size,
          ),
          _RatingBadgeMode.tmdb => _TmdbBadge(
            scorePercent: _catalogScorePercent(catalogScore),
            size: size,
          ),
        },
      ),
    );
  }
}

enum _RatingBadgeMode { loading, rottenTomatoes, tmdb }

class _LoadingDotsBadge extends StatefulWidget {
  const _LoadingDotsBadge({required this.size});

  final double size;

  @override
  State<_LoadingDotsBadge> createState() => _LoadingDotsBadgeState();
}

class _LoadingDotsBadgeState extends State<_LoadingDotsBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double dotSize = widget.size * 0.11;
    final double gap = widget.size * 0.07;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.22),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(3, (int index) {
                final double phase = (_controller.value + index / 3) % 1.0;
                final double wave =
                    (math.sin((phase * math.pi * 2) - math.pi / 2) + 1) / 2;
                final double scale = 0.6 + (wave * 0.45);
                final double opacity = 0.35 + (wave * 0.65);

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: gap / 2),
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        key: ValueKey<String>(
                          'rating-badge-loading-dot-$index',
                        ),
                        width: dotSize,
                        height: dotSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _RottenTomatoesBadge extends StatelessWidget {
  const _RottenTomatoesBadge({required this.label, required this.size});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(bottom: size * 0.15),
            child: SvgPicture.asset(
              'assets/logos/Rotten_Tomatoes.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Transform.translate(
              offset: Offset(0, size * 0.07),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.2,
                  shadows: const <Shadow>[
                    Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TmdbBadge extends StatelessWidget {
  const _TmdbBadge({required this.scorePercent, required this.size});

  final int? scorePercent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String displayScore = scorePercent == null ? 'NA' : '$scorePercent%';
    final double progress = (scorePercent ?? 0).clamp(0, 100) / 100;
    final double strokeWidth = math.max(2.0, size * 0.06);

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.22),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: progress,
              trackColor: Colors.white.withValues(alpha: 0.14),
              progressColor: AppColors.cinemaScoreRing,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(strokeWidth * 0.65),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   'TMDB',
              //   textAlign: TextAlign.center,
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: Theme.of(context).textTheme.labelSmall?.copyWith(
              //     color: Colors.white,
              //     fontWeight: FontWeight.w900,
              //     fontSize: size * 0.12,
              //     letterSpacing: 0.4,
              //     shadows: const <Shadow>[
              //       Shadow(color: Colors.black, blurRadius: 4),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 1),
              Text(
                displayScore,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.28,
                  height: 1,
                  shadows: const <Shadow>[
                    Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

int? _catalogScorePercent(double? catalogScore) {
  if (catalogScore == null || catalogScore.isNaN) {
    return null;
  }

  return (catalogScore * 10).round().clamp(0, 100);
}

class _CircularProgressPainter extends CustomPainter {
  const _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius =
        math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
        arcRect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
