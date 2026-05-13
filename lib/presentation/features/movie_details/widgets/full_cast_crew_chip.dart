import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FullCastCrewChip extends StatelessWidget {
  const FullCastCrewChip({
    super.key,
    required this.title,
    required this.cast,
    required this.crew,
  });

  final String title;
  final List<MovieCredit> cast;
  final List<MovieCredit> crew;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: () {
        context.pushNamed(
          AppRoute.fullCastCrew.name,
          extra: {'title': title, 'cast': cast, 'crew': crew},
        );
      },
      backgroundColor: AppColors.cinemaAccent.withValues(alpha: 0.1),
      side: BorderSide(color: AppColors.cinemaAccent, width: 1),
      label: Text(
        'Full Cast & Crew',
        style: TextStyle(
          color: AppColors.cinemaAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
