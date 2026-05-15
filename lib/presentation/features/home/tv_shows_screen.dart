import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/features/home/widgets/filter_chips_list.dart';
import 'package:cineverse/presentation/features/home/widgets/media_grid.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvShowsScreen extends ConsumerWidget {
  const TvShowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(tvGenresProvider);
    final isFiltered = ref.watch(isTvFilteredProvider);

    return isFiltered
        ? Column(
            children: [
              const FilterChipsList(isTv: true),
              const Expanded(child: MediaGrid(isTv: true)),
            ],
          )
        : genresAsync.when(
            data: (genres) {
              final allGenres = genres;
              return DefaultTabController(
                length: allGenres.length + 1,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: LinearGradient(
                            colors: AppColors.cinemaPanelGradient,
                          ),
                          border: Border.all(
                            color: AppColors.cinemaBorder.withValues(
                              alpha: 0.28,
                            ),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.cinemaGlow.withValues(
                                alpha: 0.12,
                              ),
                              blurRadius: 22,
                              spreadRadius: -12,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          dividerColor: Colors.transparent,
                          indicatorPadding: const EdgeInsets.symmetric(
                            vertical: 2,
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          tabs: [
                            const Tab(text: 'Popular'),
                            ...allGenres.map(
                              (g) => Tab(
                                text: genres.length > 5
                                    ? g.name
                                    : g.name.toUpperCase(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          const MediaGrid(isTv: true),
                          ...allGenres.map(
                            (g) => MediaGrid(isTv: true, genreId: g.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.cinemaAccent),
            ),
            error: (error, _) =>
                Center(child: Text('Error loading genres: $error')),
          );
  }
}
