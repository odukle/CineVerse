import 'package:cineverse/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.detailsCard.withValues(alpha: 0.5),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Helper for rectangular text lines
  static Widget textLine({
    double width = double.infinity,
    double height = 14,
    double borderRadius = 4,
    EdgeInsetsGeometry? margin,
  }) {
    return ShimmerEffect(
      width: width,
      height: height,
      borderRadius: borderRadius,
      margin: margin,
    );
  }

  /// Helper for poster-like shapes
  static Widget poster({
    required double width,
    required double height,
    double borderRadius = 12,
  }) {
    return ShimmerEffect(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}
