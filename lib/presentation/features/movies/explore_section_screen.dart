import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/presentation/features/movies/models/explore_models.dart';
import 'package:cineverse/presentation/features/movies/providers/library_recommendations_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/movies/widgets/trending_person_card.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreSectionScreen extends ConsumerStatefulWidget {
  const ExploreSectionScreen({
    required this.sectionTitle,
    required this.filters,
    required this.isTv,
    super.key,
  });

  final String sectionTitle;
  final List<ExploreFilterOption> filters;
  final bool isTv;

  @override
  ConsumerState<ExploreSectionScreen> createState() =>
      _ExploreSectionScreenState();
}

class _ExploreSectionScreenState extends ConsumerState<ExploreSectionScreen> {
  late ExploreFilterOption _selectedFilter;
  late PageController _pageController;
  final ScrollController _chipScrollController = ScrollController();
  late List<GlobalKey> _chipKeys;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.filters.first;
    _pageController = PageController(
      initialPage: widget.filters.indexOf(_selectedFilter),
    );
    _chipKeys = List.generate(widget.filters.length, (index) => GlobalKey());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chipScrollController.dispose();
    super.dispose();
  }

  void _selectFilter(ExploreFilterOption option, {bool fromPage = false}) {
    if (option == _selectedFilter) return;

    final index = widget.filters.indexOf(option);
    setState(() {
      _selectedFilter = option;
    });

    // Scroll chip into view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chipKeys[index].currentContext != null) {
        Scrollable.ensureVisible(
          _chipKeys[index].currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5, // Center the chip
        );
      }
    });

    if (!fromPage) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            widget.sectionTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            if (widget.filters.length > 1)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  controller: _chipScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.filters.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final option = widget.filters[index];
                    final isSelected = option.matches(_selectedFilter);
                    return ChoiceChip(
                      key: _chipKeys[index],
                      label: Text(option.label),
                      selected: isSelected,
                      onSelected: (_) => _selectFilter(option),
                      backgroundColor: AppColors.cinemaSurface.withValues(
                        alpha: 0.5,
                      ),
                      selectedColor: AppColors.cinemaAccent,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.filters.length,
                onPageChanged: (index) =>
                    _selectFilter(widget.filters[index], fromPage: true),
                itemBuilder: (context, index) {
                  final filter = widget.filters[index];
                  return _FilterResultsGrid(
                    filter: filter,
                    isTv: widget.isTv,
                    sectionTitle: widget.sectionTitle,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterResultsGrid extends ConsumerStatefulWidget {
  const _FilterResultsGrid({
    required this.filter,
    required this.isTv,
    required this.sectionTitle,
  });

  final ExploreFilterOption filter;
  final bool isTv;
  final String sectionTitle;

  @override
  ConsumerState<_FilterResultsGrid> createState() => _FilterResultsGridState();
}

class _FilterResultsGridState extends ConsumerState<_FilterResultsGrid> {
  static const int _hiddenGemsMinItemsForScrollableGrid = 12;

  final ScrollController _scrollController = ScrollController();
  bool _hiddenGemsAutoLoadScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.filter.isLibraryRecommendations) {
      if (ref
          .read(libraryRecommendationsProvider(widget.filter.recSource))
          .isLoading) {
        return;
      }
      if (ref.read(
        libraryRecommendationsExhaustedProvider(widget.filter.recSource),
      )) {
        return;
      }

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 400) {
        loadNextLibraryRecsPage(ref, widget.filter.recSource);
      }
      return;
    }

    final movies = widget.filter.isHiddenGems
        ? ref.read(hiddenGemsSectionProvider)
        : (widget.filter.mood != null
              ? ref.read(
                  moodSectionProvider((
                    mood: widget.filter.mood!,
                    isTv: widget.isTv,
                  )),
                )
              : (widget.filter.genreId != null
                    ? ref.read(
                        exploreGenreSectionProvider((
                          id: widget.filter.genreId!,
                          isTv: widget.isTv,
                        )),
                      )
                    : ref.read(
                        exploreMovieSectionProvider(widget.filter.section!),
                      )));

    if (movies.isLoading) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      final isExhausted = widget.filter.isHiddenGems
          ? ref.read(hiddenGemsSectionExhaustedProvider)
          : (widget.filter.mood != null
                ? ref.read(
                    moodSectionExhaustedProvider((
                      mood: widget.filter.mood!,
                      isTv: widget.isTv,
                    )),
                  )
                : (widget.filter.genreId != null
                      ? ref.read(
                          exploreGenreSectionExhaustedProvider((
                            id: widget.filter.genreId!,
                            isTv: widget.isTv,
                          )),
                        )
                      : ref.read(
                          exploreMovieSectionExhaustedProvider(
                            widget.filter.section!,
                          ),
                        )));

      if (isExhausted) return;

      if (widget.filter.isHiddenGems) {
        loadNextHiddenGemsPages(ref);
      } else if (widget.filter.mood != null) {
        loadNextMoodPages(ref, widget.filter.mood!, isTv: widget.isTv);
      } else if (widget.filter.genreId != null) {
        loadNextExploreGenrePages(
          ref,
          widget.filter.genreId!,
          isTv: widget.isTv,
        );
      } else if (widget.filter.section != null) {
        loadNextExplorePages(ref, widget.filter.section!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movies = widget.filter.isLibraryRecommendations
        ? ref.watch(libraryRecommendationsProvider(widget.filter.recSource))
        : (widget.filter.isHiddenGems
              ? ref.watch(hiddenGemsSectionProvider)
              : (widget.filter.mood != null
                    ? ref.watch(
                        moodSectionProvider((
                          mood: widget.filter.mood!,
                          isTv: widget.isTv,
                        )),
                      )
                    : (widget.filter.genreId != null
                          ? ref.watch(
                              exploreGenreSectionProvider((
                                id: widget.filter.genreId!,
                                isTv: widget.isTv,
                              )),
                            )
                          : ref.watch(
                              exploreMovieSectionProvider(
                                widget.filter.section!,
                              ),
                            ))));

    final bool isExhausted = widget.filter.isLibraryRecommendations
        ? ref.watch(
            libraryRecommendationsExhaustedProvider(widget.filter.recSource),
          )
        : (widget.filter.isHiddenGems
              ? ref.watch(hiddenGemsSectionExhaustedProvider)
              : (widget.filter.mood != null
                    ? ref.watch(
                        moodSectionExhaustedProvider((
                          mood: widget.filter.mood!,
                          isTv: widget.isTv,
                        )),
                      )
                    : (widget.filter.genreId != null
                          ? ref.watch(
                              exploreGenreSectionExhaustedProvider((
                                id: widget.filter.genreId!,
                                isTv: widget.isTv,
                              )),
                            )
                          : ref.watch(
                              exploreMovieSectionExhaustedProvider(
                                widget.filter.section!,
                              ),
                            ))));

    return movies.when(
      skipLoadingOnReload: true,
      loading: () => const _GridShimmer(),
      error: (err, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.errorGeneric(err.toString()), style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (widget.filter.isHiddenGems) {
                  ref.invalidate(hiddenGemsSectionProvider);
                } else if (widget.filter.genreId != null) {
                  ref.invalidate(
                    exploreGenreSectionProvider((
                      id: widget.filter.genreId!,
                      isTv: widget.isTv,
                    )),
                  );
                } else if (widget.filter.mood != null) {
                  ref.invalidate(
                    moodSectionProvider((
                      mood: widget.filter.mood!,
                      isTv: widget.isTv,
                    )),
                  );
                } else {
                  ref.invalidate(
                    exploreMovieSectionProvider(widget.filter.section!),
                  );
                }
              },
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
      data: (data) {
        final List<MediaTitle> dataForFilter =
            widget.filter.isHiddenGems && widget.filter.genreId != null
            ? data
                  .where(
                    (item) => item.genreIds.contains(widget.filter.genreId),
                  )
                  .toList(growable: false)
            : data;

        if (widget.filter.isHiddenGems &&
            widget.filter.genreId != null &&
            !movies.isLoading &&
            !isExhausted &&
            dataForFilter.length < _hiddenGemsMinItemsForScrollableGrid &&
            !_hiddenGemsAutoLoadScheduled) {
          _hiddenGemsAutoLoadScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _hiddenGemsAutoLoadScheduled = false;
            if (!mounted) return;
            loadNextHiddenGemsPages(ref);
          });
        }

        if (dataForFilter.isEmpty) {
          if (widget.filter.isHiddenGems &&
              !isExhausted &&
              !_hiddenGemsAutoLoadScheduled) {
            _hiddenGemsAutoLoadScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _hiddenGemsAutoLoadScheduled = false;
              if (!mounted) return;
              loadNextHiddenGemsPages(ref);
            });
          }
          return Center(
            child: Text(
              context.l10n.noItemsFound,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        final double screenWidth = MediaQuery.sizeOf(context).width;
        final double cardWidth = (screenWidth - 32 - 24) / 3;

        final bool showFooter = movies.isLoading || isExhausted;
        final int itemCount = dataForFilter.length + (showFooter ? 3 : 0);

        final bool isPersonSection =
            widget.filter.section == MovieSection.personTrendingDay ||
            widget.filter.section == MovieSection.personTrendingWeek;

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: isPersonSection ? 0.68 : 0.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index >= dataForFilter.length) {
              if (index == dataForFilter.length + 1) {
                // Middle of the last row
                return Center(
                  child: movies.isLoading
                      ? CircularProgressIndicator(color: AppColors.cinemaAccent)
                      : Text(
                          context.l10n.noMoreEntries,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                );
              }
              return const SizedBox.shrink();
            }

            return isPersonSection
                ? TrendingPersonCard(
                    person: dataForFilter[index],
                    accent: AppColors.cinemaAccent,
                    width: cardWidth,
                  )
                : MediaPosterGridCard(
                    movie: dataForFilter[index],
                    sectionTitle: widget.sectionTitle,
                    width: cardWidth,
                    isTvTitle: widget.isTv,
                    disableSortBasedSubtitle: true,
                  );
          },
        );
      },
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ShimmerEffect.poster(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          const SizedBox(height: 8),
          ShimmerEffect.textLine(width: 60, height: 12),
        ],
      ),
    );
  }
}
