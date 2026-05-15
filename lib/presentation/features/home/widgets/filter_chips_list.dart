import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FilterChipsList extends ConsumerWidget {
  const FilterChipsList({required this.isTv, super.key});

  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(isTv ? tvFilterProvider : movieFilterProvider);
    final genresAsync = ref.watch(
      isTv ? tvGenresProvider : movieGenresProvider,
    );

    if (filter.isDefault) return const SizedBox.shrink();

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Sort Chip (always show if not default)
          if (filter.sortField != SortField.popularity ||
              filter.sortOrder != SortOrder.descending)
            _buildChip(
              context,
              ref,
              'Sort: ${filter.sortField.label} (${filter.sortOrder.label})',
              () {
                final newFilter = filter.copyWith(
                  sortField: SortField.popularity,
                  sortOrder: SortOrder.descending,
                );
                _updateFilter(ref, newFilter);
              },
            ),

          // Availabilities
          ...filter.availabilities.map(
            (a) => _buildChip(context, ref, 'Type: $a', () {
              final newSet = Set<String>.from(filter.availabilities)..remove(a);
              _updateFilter(ref, filter.copyWith(availabilities: newSet));
            }),
          ),

          // User Score
          if (filter.userScore.start > 0 || filter.userScore.end < 10)
            _buildChip(
              context,
              ref,
              'Score: ${filter.userScore.start.toInt()}-${filter.userScore.end.toInt()}',
              () {
                _updateFilter(
                  ref,
                  filter.copyWith(userScore: const RangeValues(0, 10)),
                );
              },
            ),

          // Release Types
          ...filter.releaseTypes.map(
            (t) => _buildChip(
              context,
              ref,
              'Release: ${_getReleaseTypeLabel(t)}',
              () {
                final newSet = Set<int>.from(filter.releaseTypes)..remove(t);
                _updateFilter(ref, filter.copyWith(releaseTypes: newSet));
              },
            ),
          ),

          // Date Range
          if (filter.releaseDateFrom != null || filter.releaseDateTo != null)
            _buildChip(
              context,
              ref,
              'Date: ${_formatDate(filter.releaseDateFrom)} - ${_formatDate(filter.releaseDateTo)}',
              () {
                _updateFilter(
                  ref,
                  filter.copyWith(releaseDateFrom: null, releaseDateTo: null),
                );
              },
            ),

          // Min Votes
          if (filter.minUserVotes > 0)
            _buildChip(context, ref, 'Votes: >${filter.minUserVotes}', () {
              _updateFilter(ref, filter.copyWith(minUserVotes: 0));
            }),

          // Genres
          ...filter.genres.map((gId) {
            final genreName = genresAsync.maybeWhen(
              data: (list) => list
                  .firstWhere(
                    (g) => g.id == gId,
                    orElse: () => const MovieGenre(id: 0, name: 'Unknown'),
                  )
                  .name,
              orElse: () => 'Genre $gId',
            );
            return _buildChip(context, ref, genreName, () {
              final newSet = Set<int>.from(filter.genres)..remove(gId);
              _updateFilter(ref, filter.copyWith(genres: newSet));
            });
          }),

          // People
          ...filter.personIds.map((id) {
            final index = filter.personIds.toList().indexOf(id);
            final name = filter.personNames.elementAt(index);
            return _buildChip(context, ref, name, () {
              final newIds = Set<int>.from(filter.personIds)..remove(id);
              final newNames = Set<String>.from(filter.personNames)
                ..remove(name);
              _updateFilter(
                ref,
                filter.copyWith(personIds: newIds, personNames: newNames),
              );
            });
          }),

          // Mood
          if (filter.mood != null)
            _buildChip(context, ref, filter.mood!.label, () {
              _updateFilter(ref, filter.copyWith(clearMood: true));
            }),

          // Runtime
          if (filter.runtime.start > 0 || filter.runtime.end < 390)
            _buildChip(
              context,
              ref,
              'Runtime: ${filter.runtime.start.toInt()}-${filter.runtime.end.toInt()}m',
              () {
                _updateFilter(
                  ref,
                  filter.copyWith(runtime: const RangeValues(0, 390)),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    VoidCallback onDeleted,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
        onDeleted: onDeleted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: AppColors.cinemaBorder.withValues(alpha: 0.32)),
        shadowColor: AppColors.cinemaGlow.withValues(alpha: 0.12),
        elevation: 0,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _updateFilter(WidgetRef ref, MediaFilter newFilter) {
    if (isTv) {
      ref.read(tvFilterProvider.notifier).updateFilter(newFilter);
      resetMovieSection(ref, MovieSection.tvDiscover);
    } else {
      ref.read(movieFilterProvider.notifier).updateFilter(newFilter);
      resetMovieSection(ref, MovieSection.discover);
    }
  }

  String _getReleaseTypeLabel(int type) {
    switch (type) {
      case 1:
        return 'Premiere';
      case 2:
        return 'Theatrical (Ltd)';
      case 3:
        return 'Theatrical';
      case 4:
        return 'Digital';
      case 5:
        return 'Physical';
      case 6:
        return 'TV';
      default:
        return 'Other';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '?';
    return DateFormat('yyyy').format(date);
  }
}
