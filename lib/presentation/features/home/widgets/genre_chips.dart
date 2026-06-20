import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenreChips extends ConsumerWidget {
  const GenreChips({required this.isTv, super.key});
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter =
        isTv ? ref.watch(tvFilterProvider) : ref.watch(movieFilterProvider);
    final genresAsync =
        isTv ? ref.watch(tvGenresProvider) : ref.watch(movieGenresProvider);
    final selectedGenreId =
        isTv
            ? ref.watch(selectedTvGenreIdProvider)
            : ref.watch(selectedMovieGenreIdProvider);

    if (!filter.isDefault) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: InputChip(
            label: Text(context.l10n.filtered),
            onDeleted: () {
              if (isTv) {
                ref.read(tvFilterProvider.notifier).reset();
              } else {
                ref.read(movieFilterProvider.notifier).reset();
              }
            },
            deleteIcon: Icon(
              Icons.close,
              size: 14,
              color: AppColors.cinemaAccent,
            ),
            backgroundColor: AppColors.cinemaAccent.withValues(alpha: 0.1),
            labelStyle: TextStyle(
              color: AppColors.cinemaAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            side: BorderSide(color: AppColors.cinemaAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      );
    }

    return genresAsync.maybeWhen(
      data:
          (genres) => SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: genres.length + 1,
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final genre = isAll ? null : genres[index - 1];
                final isSelected =
                    isAll ? selectedGenreId == null : selectedGenreId == genre?.id;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(isAll ? 'All' : genre!.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        final id = isAll ? null : genre!.id;
                        if (isTv) {
                          ref.read(selectedTvGenreIdProvider.notifier).setGenre(id);
                        } else {
                          ref
                              .read(selectedMovieGenreIdProvider.notifier)
                              .setGenre(id);
                        }
                      }
                    },
                    backgroundColor: Colors.transparent,
                    selectedColor: AppColors.cinemaAccent.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.cinemaAccent : Colors.white70,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color:
                          isSelected
                              ? AppColors.cinemaAccent
                              : Colors.white.withValues(alpha: 0.1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
      orElse: () => const SizedBox(height: 50),
    );
  }
}
