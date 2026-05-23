import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/features/home/widgets/filter_chips_list.dart';
import 'package:cineverse/presentation/features/home/widgets/media_grid.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoviesScreen extends ConsumerWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(movieGenresProvider);
    final isFiltered = ref.watch(isMovieFilteredProvider);

    return isFiltered
        ? Column(
            children: [
              const FilterChipsList(isTv: false),
              const Expanded(child: MediaGrid(isTv: false)),
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
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
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
                          onTap: (_) => HapticFeedback.selectionClick(),
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.label,
                          indicator: BoxDecoration(
                            color: AppColors.cinemaAccent.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.cinemaAccent.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          indicatorPadding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 0,
                          ),
                          splashBorderRadius: BorderRadius.circular(999),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white.withValues(
                            alpha: 0.7,
                          ),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          tabs: [
                            const Tab(
                              child: SizedBox(
                                height: 28,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      'Popular',
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ...allGenres.map(
                              (g) => Tab(
                                child: SizedBox(
                                  height: 28,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        genres.length > 5
                                            ? g.name
                                            : g.name.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          const MediaGrid(isTv: false),
                          ...allGenres.map(
                            (g) => MediaGrid(isTv: false, genreId: g.id),
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
