import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/models/explore_models.dart';
import 'package:cineverse/presentation/features/movies/providers/library_recommendations_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
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
  ConsumerState<ExploreSectionScreen> createState() => _ExploreSectionScreenState();
}

class _ExploreSectionScreenState extends ConsumerState<ExploreSectionScreen> {
  late ExploreFilterOption _selectedFilter;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.filters.first;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_selectedFilter.isLibraryRecommendations) {
      if (ref.read(libraryRecommendationsProvider(_selectedFilter.recSource)).isLoading) return;
      if (ref.read(libraryRecommendationsExhaustedProvider(_selectedFilter.recSource))) return;

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 400) {
        loadNextLibraryRecsPage(ref, _selectedFilter.recSource);
      }
      return;
    }

    final movies = _selectedFilter.genreId != null
        ? ref.read(genreSectionProvider((id: _selectedFilter.genreId!, isTv: widget.isTv)))
        : ref.read(movieSectionProvider(_selectedFilter.section!));

    if (movies.isLoading) return;
    
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      final isExhausted = _selectedFilter.genreId != null
          ? ref.read(genreSectionExhaustedProvider((id: _selectedFilter.genreId!, isTv: widget.isTv)))
          : ref.read(movieSectionExhaustedProvider(_selectedFilter.section!));
          
      if (isExhausted) return;

      if (_selectedFilter.genreId != null) {
        loadNextGenrePages(ref, _selectedFilter.genreId!, isTv: widget.isTv);
      } else if (_selectedFilter.section != null) {
        loadNextPages(ref, _selectedFilter.section!);
      }
    }
  }

  void _selectFilter(ExploreFilterOption option) {
    setState(() {
      _selectedFilter = option;
    });
    // Scroll back to top when filter changes
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final AsyncValue<List<MediaTitle>> movies = _selectedFilter.isLibraryRecommendations
        ? ref.watch(libraryRecommendationsProvider(_selectedFilter.recSource))
        : (_selectedFilter.genreId != null
            ? ref.watch(
                genreSectionProvider((id: _selectedFilter.genreId!, isTv: widget.isTv)),
              )
            : ref.watch(movieSectionProvider(_selectedFilter.section!)));

    final bool isExhausted = _selectedFilter.isLibraryRecommendations
        ? ref.watch(libraryRecommendationsExhaustedProvider(_selectedFilter.recSource))
        : (_selectedFilter.genreId != null
            ? ref.watch(genreSectionExhaustedProvider((id: _selectedFilter.genreId!, isTv: widget.isTv)))
            : ref.watch(movieSectionExhaustedProvider(_selectedFilter.section!)));

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cinemaBackground,
        title: Text(
          widget.sectionTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: widget.filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final option = widget.filters[index];
                  final isSelected = option.matches(_selectedFilter);
                  return ChoiceChip(
                    label: Text(option.label),
                    selected: isSelected,
                    onSelected: (_) => _selectFilter(option),
                    backgroundColor: AppColors.cinemaSurface.withValues(alpha: 0.5),
                    selectedColor: AppColors.cinemaAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
            child: movies.when(
              skipLoadingOnReload: true,
              loading: () => _GridShimmer(),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: $err', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedFilter.genreId != null) {
                          ref.invalidate(genreSectionProvider((id: _selectedFilter.genreId!, isTv: widget.isTv)));
                        } else {
                          ref.invalidate(movieSectionProvider(_selectedFilter.section!));
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (data) {
                if (data.isEmpty) {
                  return const Center(
                    child: Text('No items found', style: TextStyle(color: Colors.white70)),
                  );
                }
 
                final double screenWidth = MediaQuery.sizeOf(context).width;
                final double cardWidth = (screenWidth - 32 - 24) / 3;
 
                final bool showFooter = movies.isLoading || isExhausted;
                final int itemCount = data.length + (showFooter ? 3 : 0);

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index >= data.length) {
                      if (index == data.length + 1) { // Middle of the last row
                        return Center(
                          child: movies.isLoading
                              ? CircularProgressIndicator(color: AppColors.cinemaAccent)
                              : Text(
                                  'No more entries',
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

                    return MediaPosterGridCard(
                      movie: data[index],
                      sectionTitle: widget.sectionTitle,
                      width: cardWidth,
                      isTvTitle: widget.isTv,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
          Expanded(child: ShimmerEffect.poster(width: double.infinity, height: double.infinity)),
          const SizedBox(height: 8),
          ShimmerEffect.textLine(width: 60, height: 12),
        ],
      ),
    );
  }
}
