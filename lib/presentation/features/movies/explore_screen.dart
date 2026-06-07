import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/movie_mood.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart';
import 'package:cineverse/app/router/app_router.dart' show AppRoute;
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/explore_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/hidden_titles_provider.dart';
import 'package:cineverse/presentation/features/movies/models/explore_models.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/movies/widgets/rating_badge.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:cineverse/presentation/widgets/trailer_player_screen.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/presentation/features/movies/providers/library_recommendations_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/library_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:cineverse/domain/entities/library_item.dart';
import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/presentation/features/home/providers/reminders_provider.dart';
import 'package:cineverse/presentation/widgets/animated_dialog.dart';
import 'package:cineverse/presentation/widgets/media_actions_dialogs.dart';
import 'package:cineverse/core/utils/toast_utils.dart';
import 'package:cineverse/presentation/features/movie_details/movie_details_screen.dart'
    show GeneralReminderDialog, GeneralReminderDialogResult;

_DiscoverSpotlightState? _discoverSpotlightState;

class _SectionVisualSpec {
  const _SectionVisualSpec({
    required this.icon,
    required this.accent,
    required this.subtitle,
  });

  final IconData icon;
  final Color accent;
  final String subtitle;
}

const Map<String, _SectionVisualSpec> _sectionVisuals =
    <String, _SectionVisualSpec>{
      'Trending': _SectionVisualSpec(
        icon: Icons.trending_up_rounded,
        accent: Color(0xFF49E4FF),
        subtitle: 'Hot now across the audience feed',
      ),
      "What's Popular": _SectionVisualSpec(
        icon: Icons.local_fire_department_rounded,
        accent: Color(0xFFFF9966),
        subtitle: 'Big crowd-pleasers with strong momentum',
      ),
      'Hidden Gems': _SectionVisualSpec(
        icon: Icons.auto_awesome_rounded,
        accent: Color(0xFFE6C76A),
        subtitle: 'High-rated titles most viewers skip',
      ),
      'Now Playing': _SectionVisualSpec(
        icon: Icons.theaters_rounded,
        accent: Color(0xFFFF6E8A),
        subtitle: 'Current theatrical slate and near-future releases',
      ),
      'TV Trending': _SectionVisualSpec(
        icon: Icons.live_tv_rounded,
        accent: Color(0xFF42E8FF),
        subtitle: 'Most discussed shows this week',
      ),
      'On The Air': _SectionVisualSpec(
        icon: Icons.wifi_tethering_rounded,
        accent: Color(0xFF91F6A1),
        subtitle: 'Series currently airing with active episodes',
      ),
      'Discover by Mood': _SectionVisualSpec(
        icon: Icons.mood_rounded,
        accent: Color(0xFFB391FF),
        subtitle: 'Pick a vibe and get instant matching titles',
      ),
      'Recommended for You': _SectionVisualSpec(
        icon: Icons.psychology_rounded,
        accent: Color(0xFF7DD9FF),
        subtitle: 'Personalized from your watch behavior',
      ),
    };

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  static const List<ExploreShelfData> _movieBaseSections = <ExploreShelfData>[
    ExploreShelfData(
      title: 'Trending',
      filters: <ExploreFilterOption>[
        ExploreFilterOption(label: 'Today', section: MovieSection.trendingDay),
        ExploreFilterOption(
          label: 'This Week',
          section: MovieSection.trendingWeek,
        ),
      ],
      variant: _ShelfVariant.featured,
    ),
    ExploreShelfData(
      title: "What's Popular",
      filters: <ExploreFilterOption>[
        ExploreFilterOption(label: 'Popular', section: MovieSection.popular),
        ExploreFilterOption(label: 'Top Rated', section: MovieSection.topRated),
        ExploreFilterOption(
          label: 'In Theaters',
          section: MovieSection.nowPlaying,
        ),
        ExploreFilterOption(
          label: 'Coming Soon',
          section: MovieSection.upcoming,
        ),
      ],
    ),
    ExploreShelfData(
      title: 'Hidden Gems',
      filters: <ExploreFilterOption>[
        ExploreFilterOption(label: 'All', isHiddenGems: true),
      ],
    ),
    ExploreShelfData(
      title: 'Now Playing',
      filters: <ExploreFilterOption>[
        ExploreFilterOption(
          label: 'In Theaters',
          section: MovieSection.nowPlaying,
        ),
        ExploreFilterOption(
          label: 'Coming Soon',
          section: MovieSection.upcoming,
        ),
        ExploreFilterOption(label: 'Top Rated', section: MovieSection.topRated),
      ],
    ),
  ];

  static const List<ExploreShelfData> _tvBaseSections = <ExploreShelfData>[
    ExploreShelfData(
      title: 'TV Trending',
      filters: <ExploreFilterOption>[
        ExploreFilterOption(
          label: 'Today',
          section: MovieSection.tvTrendingDay,
        ),
        ExploreFilterOption(
          label: 'This Week',
          section: MovieSection.tvTrendingWeek,
        ),
      ],
      variant: _ShelfVariant.featured,
    ),
    ExploreShelfData(
      title: "What's Popular",
      filters: <ExploreFilterOption>[
        ExploreFilterOption(label: 'Popular', section: MovieSection.tvPopular),
        ExploreFilterOption(
          label: 'Top Rated',
          section: MovieSection.tvTopRated,
        ),
        ExploreFilterOption(
          label: 'On The Air',
          section: MovieSection.tvOnTheAir,
        ),
        ExploreFilterOption(
          label: 'Airing Today',
          section: MovieSection.tvAiringToday,
        ),
      ],
    ),
    ExploreShelfData(
      title: 'On The Air',
      filters: <ExploreFilterOption>[
        ExploreFilterOption(
          label: 'On The Air',
          section: MovieSection.tvOnTheAir,
        ),
        ExploreFilterOption(
          label: 'Airing Today',
          section: MovieSection.tvAiringToday,
        ),
        ExploreFilterOption(
          label: 'Top Rated',
          section: MovieSection.tvTopRated,
        ),
      ],
    ),
  ];

  static const ExploreShelfData _moodSection = ExploreShelfData(
    title: 'Discover by Mood',
    filters: <ExploreFilterOption>[
      ExploreFilterOption(label: 'Mind-bending', mood: MovieMood.mindBending),
      ExploreFilterOption(label: 'Feel-good', mood: MovieMood.feelGood),
      ExploreFilterOption(label: 'Dark', mood: MovieMood.dark),
      ExploreFilterOption(label: 'Fast-paced', mood: MovieMood.fastPaced),
      ExploreFilterOption(
        label: 'Edge-of-your-seat',
        mood: MovieMood.edgeOfYourSeat,
      ),
      ExploreFilterOption(label: 'Cinematic', mood: MovieMood.cinematic),
      ExploreFilterOption(label: 'Indie', mood: MovieMood.indie),
    ],
  );

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final mediaType = ref.watch(exploreMediaTypeProvider);
    final bool isTv = mediaType == ExploreMediaType.tv;

    final appConfig = ref.watch(appConfigProvider);
    final bool hasMovieApiAccess = appConfig.hasMovieApiAccess;

    final List<ExploreShelfData> baseSections = isTv
        ? ExploreScreen._tvBaseSections
        : ExploreScreen._movieBaseSections;

    if (!hasMovieApiAccess) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.vpn_key_outlined, size: 52, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Movie API configuration required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Add MOVIE_PROXY_BASE_URL to connect the app to the TMDB proxy.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return _AmbientGlowingBackdrop(
      scrollController: _scrollController,
      child: Stack(
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 550),
            switchInCurve: Curves.easeInQuad,
            switchOutCurve: Curves.easeOutQuad,
            layoutBuilder:
                (Widget? currentChild, List<Widget> previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      ...previousChildren,
                      currentChild ?? const SizedBox.shrink(),
                    ],
                  );
                },
            transitionBuilder: (Widget child, Animation<double> animation) {
              final isEntering = child.key == ValueKey(mediaType);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: isEntering
                        ? const Offset(0.04, 0)
                        : const Offset(-0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: CustomScrollView(
              key: ValueKey(mediaType), // Force refresh when switching type
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              // ignore: deprecated_member_use
              cacheExtent:
                  1500, // Pre-build shelves in the background to eliminate stutter
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                const SliverToBoxAdapter(child: _DiscoverSpotlightSection()),
                const SliverToBoxAdapter(child: _SectionDivider()),
                if (!isTv)
                  const SliverToBoxAdapter(
                    child: _ScrollReveal(
                      child: _TonightWatchQuickLaunchStrip(),
                    ),
                  ),
                if (!isTv) const SliverToBoxAdapter(child: _SectionDivider()),

                // Optimized combined shelf list (Base sections only)
                SliverList(
                  delegate: SliverChildBuilderDelegate((
                    BuildContext context,
                    int index,
                  ) {
                    final bool isLast = index == baseSections.length - 1;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ScrollReveal(
                          indexOffset: index,
                          child: _MovieShelfSection(
                            section: baseSections[index],
                          ),
                        ),
                        if (!isLast) const _SectionDivider(),
                      ],
                    );
                  }, childCount: baseSections.length),
                ),
                const SliverToBoxAdapter(child: _SectionDivider()),
                const SliverToBoxAdapter(
                  child: _ScrollReveal(child: _CuratedCollectionSection()),
                ),
                const SliverToBoxAdapter(child: _SectionDivider()),
                const SliverToBoxAdapter(
                  child: _ScrollReveal(child: _LibraryRecommendationsSection()),
                ),
                const SliverToBoxAdapter(child: _SectionDivider()),
                const SliverToBoxAdapter(
                  child: _ScrollReveal(
                    child: _MovieShelfSection(
                      section: ExploreScreen._moodSection,
                    ),
                  ),
                ),
                if (!isTv) const SliverToBoxAdapter(child: _SectionDivider()),
                if (!isTv)
                  const SliverToBoxAdapter(
                    child: _ScrollReveal(child: _TonightWatchLauncherSection()),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 52)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryRecommendationsSection extends ConsumerWidget {
  const _LibraryRecommendationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final mediaType = ref.watch(exploreMediaTypeProvider);
    final bool isTv = mediaType == ExploreMediaType.tv;
    final targetType = isTv ? GlobalMediaType.tv : GlobalMediaType.movie;

    // Fast check for empty library to show prompt
    final watchlist = ref.watch(watchlistProvider).value ?? [];
    final watched = ref.watch(watchedItemsProvider).value ?? [];
    final favourites = ref.watch(favouritesProvider).value ?? [];
    final namedLists = ref.watch(namedListsProvider).value ?? [];

    bool hasItems = false;
    if (watchlist.any((item) => item.mediaType == targetType)) {
      hasItems = true;
    } else if (watched.any((item) => item.mediaType == targetType)) {
      hasItems = true;
    } else if (favourites.any((item) => item.mediaType == targetType)) {
      hasItems = true;
    } else if (namedLists.any(
      (list) => list.items.any((item) => item.mediaType == targetType),
    )) {
      hasItems = true;
    }

    if (!hasItems) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTv ? Icons.tv_off_rounded : Icons.movie_filter_rounded,
                size: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Start adding titles for recommendations',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add ${isTv ? 'TV shows' : 'movies'} to your watchlist, favourites, or watched list to see titles you might love.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final recommendations = ref.watch(
      libraryRecommendationsProvider(RecSource.all),
    );
    final _SectionVisualSpec visual =
        _sectionVisuals['Recommended for You'] ??
        const _SectionVisualSpec(
          icon: Icons.psychology_rounded,
          accent: Color(0xFF7DD9FF),
          subtitle: 'Personalized from your watch behavior',
        );

    void navigateToSection() {
      context.pushNamed(
        AppRoute.exploreSection.name,
        queryParameters: {'isTv': isTv.toString()},
        extra: {
          'sectionTitle': 'Recommended for You',
          'filters': [
            const ExploreFilterOption(
              label: 'All',
              isLibraryRecommendations: true,
              recSource: RecSource.all,
            ),
            const ExploreFilterOption(
              label: 'Watchlist',
              isLibraryRecommendations: true,
              recSource: RecSource.watchlist,
            ),
            const ExploreFilterOption(
              label: 'Favourites',
              isLibraryRecommendations: true,
              recSource: RecSource.favourites,
            ),
            const ExploreFilterOption(
              label: 'Lists',
              isLibraryRecommendations: true,
              recSource: RecSource.lists,
            ),
            const ExploreFilterOption(
              label: 'Watched',
              isLibraryRecommendations: true,
              recSource: RecSource.watched,
            ),
          ],
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionMarker(icon: visual.icon, accent: visual.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended for You',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visual.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _SectionFilterPill(
                label: 'See All',
                onTap: navigateToSection,
                accent: visual.accent,
              ),
            ],
          ),
        ),
        recommendations.when(
          skipLoadingOnReload: true,
          data: (data) {
            if (data.isEmpty) return const SizedBox.shrink();

            const double horizontalPadding = 16;
            const double itemSpacing = 12;
            final double screenWidth = MediaQuery.sizeOf(context).width;
            final double cardWidth =
                (screenWidth - (horizontalPadding * 2) - (itemSpacing * 2)) / 3;
            final double finalCardWidth = cardWidth.clamp(100.0, 108.0);

            return SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: itemSpacing),
                itemBuilder: (context, index) {
                  return _PosterShell(
                    index: index,
                    accent: visual.accent,
                    child: RepaintBoundary(
                      child: MediaPosterGridCard(
                        movie: data[index],
                        sectionTitle: 'Recommended for You',
                        width: finalCardWidth,
                        isTvTitle: isTv,
                        disableSortBasedSubtitle: true,
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const _ShelfShimmer(),
          error: (err, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ShelfVariant {
  static const String featured = 'featured';
}

class _TonightWatchQuickLaunchStrip extends ConsumerWidget {
  const _TonightWatchQuickLaunchStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isTv =
        ref.watch(exploreMediaTypeProvider) == ExploreMediaType.tv;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            context.pushNamed(
              AppRoute.whatShouldIWatchTonight.name,
              queryParameters: <String, String>{'isTv': isTv.toString()},
            );
          },
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cinemaAccent.withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTv
                        ? 'Need something to watch tonight?'
                        : 'Need a movie for tonight?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: AppColors.cinemaAccent.withValues(alpha: 0.16),
                    border: Border.all(
                      color: AppColors.cinemaAccent.withValues(alpha: 0.36),
                    ),
                  ),
                  child: Text(
                    isTv ? 'Try AI Shows' : 'Try AI Movies',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TonightWatchLauncherSection extends ConsumerStatefulWidget {
  const _TonightWatchLauncherSection();

  @override
  ConsumerState<_TonightWatchLauncherSection> createState() =>
      _TonightWatchLauncherSectionState();
}

class _TonightWatchLauncherSectionState
    extends ConsumerState<_TonightWatchLauncherSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isTv =
        ref.watch(exploreMediaTypeProvider) == ExploreMediaType.tv;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double t = _controller.value;
          final Color accent = AppColors.cinemaAccent;
          final Color highlight = AppColors.cinemaSelected;
          final Color baseSurface = AppColors.cinemaSurface;

          final double angle = t * 2 * math.pi;
          final Alignment beginAlignment = Alignment(
            math.cos(angle),
            math.sin(angle),
          );
          final Alignment endAlignment = Alignment(
            -math.cos(angle),
            -math.sin(angle),
          );

          final double pulse = (math.sin(angle * 2) + 1.0) / 2.0;
          final double blurRadius = 24 + (pulse * 10);
          final double spreadRadius = -12 + (pulse * 2);

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18 + (pulse * 0.08)),
                  blurRadius: blurRadius,
                  spreadRadius: spreadRadius,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: highlight.withValues(alpha: 0.08 + (pulse * 0.06)),
                  blurRadius: blurRadius - 4,
                  spreadRadius: spreadRadius - 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: <Color>[
                    accent,
                    highlight.withValues(alpha: 0.6),
                    accent.withValues(alpha: 0.2),
                    highlight,
                    accent,
                  ],
                  begin: beginAlignment,
                  end: endAlignment,
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(29),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.pushNamed(
                      AppRoute.whatShouldIWatchTonight.name,
                      queryParameters: <String, String>{
                        'isTv': isTv.toString(),
                      },
                    );
                  },
                  child: Ink(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(29),
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color.lerp(baseSurface, Colors.black, 0.18)!,
                          Color.lerp(baseSurface, AppColors.background, 0.28)!,
                          Color.lerp(
                            AppColors.background,
                            AppColors.cinemaGradientBottom,
                            0.56,
                          )!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -12,
                          top: -12,
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withValues(
                                alpha: 0.08 + (pulse * 0.06),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 8,
                          child: Icon(
                            Icons.bolt_rounded,
                            color: Colors.white.withValues(
                              alpha: 0.6 + (pulse * 0.2),
                            ),
                            size: 22,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(
                                  alpha: 0.16 + (pulse * 0.08),
                                ),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: accent.withValues(
                                    alpha: 0.3 + (pulse * 0.2),
                                  ),
                                ),
                              ),
                              child: Text(
                                'AI Tonight Watch',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Describe it your way.\nWe find the best matches.',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                height: 1.06,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isTv
                                  ? 'Type or speak a natural-language request. Lumi builds an AI plan, runs vector search, and returns multiple show picks.'
                                  : 'Type or speak a natural-language request. Lumi builds an AI plan, runs vector search, and returns multiple movie picks.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const <Widget>[
                                _TonightLauncherFeatureChip(
                                  icon: Icons.mic_none_rounded,
                                  label: 'Voice input',
                                ),
                                _TonightLauncherFeatureChip(
                                  icon: Icons.auto_awesome_rounded,
                                  label: 'AI query plan',
                                ),
                                _TonightLauncherFeatureChip(
                                  icon: Icons.view_carousel_rounded,
                                  label: 'Multiple picks',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isTv ? 'Find Shows' : 'Find Movies',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TonightLauncherFeatureChip extends StatelessWidget {
  const _TonightLauncherFeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.92)),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.label,
    required this.color,
    this.icon,
    this.accent,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color resolvedAccent = accent ?? color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: resolvedAccent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon ?? Icons.info_outline_rounded,
            size: 13,
            color: Colors.white.withValues(alpha: 0.74),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverSpotlightSection extends ConsumerStatefulWidget {
  const _DiscoverSpotlightSection();

  @override
  ConsumerState<_DiscoverSpotlightSection> createState() =>
      _DiscoverSpotlightSectionState();
}

class _DiscoverSpotlightSectionState
    extends ConsumerState<_DiscoverSpotlightSection>
    with TickerProviderStateMixin {
  static const int _recentSpotlightMemory = 10;
  final math.Random _random = math.Random();

  late AnimationController _diceController;
  late AnimationController _pulseController;
  late Animation<double> _diceAnimation;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _slideshowTimer;
  List<String> _slideshowImages = [];
  List<String> _slideshowTaglines = [];
  String? _logoUrl;
  int _currentImageIndex = 0;
  int _currentTaglineIndex = 0;
  bool _isNextImageReady = false;
  int _animatedSwitcherKeyVersion = 0;
  int? _lastMovieId;

  // Swipe gesture & backdrop loading states
  late AnimationController _swipeAnimationController;
  late Animation<double> _swipeAnimation;
  double _swipeOffset = 0.0;
  bool _isSwipeActionsRevealed = false;
  bool _isBackdropLoading = true;
  bool _dragThresholdCrossed = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _diceAnimation = Tween<double>(begin: 0, end: 1.5).animate(
      CurvedAnimation(
        parent: _diceController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.86,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.86,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_diceController);

    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _swipeAnimation = const AlwaysStoppedAnimation<double>(0.0);
    _swipeAnimationController.addListener(() {
      setState(() {
        _swipeOffset = _swipeAnimation.value;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _triggerSwipeHint();
      }
    });
  }

  void _animateSwipe(
    double target, {
    Duration? duration,
    VoidCallback? onComplete,
  }) {
    final double start = _swipeOffset;
    _swipeAnimation = Tween<double>(begin: start, end: target).animate(
      CurvedAnimation(
        parent: _swipeAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    if (duration != null) {
      _swipeAnimationController.duration = duration;
    } else {
      _swipeAnimationController.duration = const Duration(milliseconds: 300);
    }
    _swipeAnimationController.forward(from: 0.0).then((_) {
      if (onComplete != null) {
        onComplete();
      }
    });
  }

  void _triggerSwipeHint() {
    if (!mounted || _isSwipeActionsRevealed || _swipeOffset != 0.0) return;

    // A subtle wiggle/shake animation to hint swipe capability
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted || _isSwipeActionsRevealed || _swipeOffset != 0.0) return;
      _animateSwipe(
        -40.0,
        duration: const Duration(milliseconds: 400),
        onComplete: () {
          if (!mounted) return;
          _animateSwipe(
            20.0,
            duration: const Duration(milliseconds: 300),
            onComplete: () {
              if (!mounted) return;
              _animateSwipe(0.0, duration: const Duration(milliseconds: 250));
            },
          );
        },
      );
    });
  }

  void _startSlideshow(int movieId) {
    _slideshowTimer?.cancel();
    _currentImageIndex = 0;
    _currentTaglineIndex = 0;
    _slideshowImages = [];
    _slideshowTaglines = [];
    _logoUrl = null;
    _isNextImageReady = false;

    Future.microtask(() {
      if (mounted && _lastMovieId == movieId) {
        setState(() {
          _isBackdropLoading = true;
        });
      }
    });

    final mediaType = ref.read(exploreMediaTypeProvider);
    final bool isTv = mediaType == ExploreMediaType.tv;

    ref
        .read(mediaImagesProvider((id: movieId, isTv: isTv)).future)
        .then((images) {
          if (mounted && _lastMovieId == movieId) {
            final List<String> fetchedImages = images.backdrops.isNotEmpty
                ? images.backdrops
                : images.posters;

            if (fetchedImages.isNotEmpty) {
              precacheImage(
                    CachedNetworkImageProvider(fetchedImages.first),
                    context,
                  )
                  .then((_) {
                    if (mounted && _lastMovieId == movieId) {
                      setState(() {
                        _animatedSwitcherKeyVersion++;
                        _slideshowImages = fetchedImages;
                        _logoUrl = images.logos.isNotEmpty
                            ? images.logos.first
                            : null;
                        _isBackdropLoading = false;
                        _preloadNextImage();
                      });
                    }
                  })
                  .catchError((_) {
                    if (mounted && _lastMovieId == movieId) {
                      setState(() {
                        _animatedSwitcherKeyVersion++;
                        _slideshowImages = fetchedImages;
                        _logoUrl = images.logos.isNotEmpty
                            ? images.logos.first
                            : null;
                        _isBackdropLoading = false;
                      });
                    }
                  });
            } else {
              setState(() {
                _isBackdropLoading = false;
              });
            }
          }
        })
        .catchError((_) {
          if (mounted && _lastMovieId == movieId) {
            setState(() {
              _isBackdropLoading = false;
            });
          }
        });

    ref.read(mediaTaglinesProvider((id: movieId, isTv: isTv)).future).then((
      taglines,
    ) {
      if (!mounted || _lastMovieId != movieId) {
        return;
      }
      final List<String> normalized = taglines
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
      setState(() {
        _slideshowTaglines = normalized;
        _currentTaglineIndex = 0;
      });
    });

    _slideshowTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_slideshowImages.length > 1 && _isNextImageReady && mounted) {
        setState(() {
          _animatedSwitcherKeyVersion++;
          _currentImageIndex =
              (_currentImageIndex + 1) % _slideshowImages.length;
          if (_slideshowTaglines.length > 1) {
            _currentTaglineIndex =
                (_currentTaglineIndex + 1) % _slideshowTaglines.length;
          }
          _isNextImageReady = false;
          _preloadNextImage();
        });
      }
    });
  }

  Future<void> _showTrailer(
    BuildContext context, {
    required MediaTitle movie,
    required MovieDetails details,
    required bool isTv,
  }) async {
    final String? trailerKey = details.trailerYouTubeKey;
    if (trailerKey == null || trailerKey.isEmpty) {
      return;
    }
    _pauseSpotlightForTrailer();
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => TrailerPlayerScreen(
          data: TrailerPlaybackData(
            videoKey: trailerKey,
            title: details.title,
            tagline: details.tagline,
            overview: details.overview,
            posterPath: details.posterPath ?? movie.posterPath,
            backdropPath: details.backdropPath,
            releaseDate: details.releaseDate ?? movie.releaseDate,
            runtimeMinutes: details.runtimeMinutes,
            voteAverage: details.catalogScore ?? movie.voteAverage,
            voteCount: details.voteCount,
            categoryLabel: 'From Spotlight',
            sourceMediaId: details.id,
            isTv: isTv,
            recommendations: details.recommendations,
          ),
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    _resumeSpotlightAfterTrailer();
  }

  void _pauseSpotlightForTrailer() {
    _slideshowTimer?.cancel();
    _slideshowTimer = null;
    if (_pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  void _resumeSpotlightAfterTrailer() {
    if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
    final int? movieId =
        _discoverSpotlightState?.currentMovieId ?? _lastMovieId;
    if (movieId != null) {
      _startSlideshow(movieId);
    }
  }

  void _preloadNextImage() {
    if (_slideshowImages.isEmpty || !mounted) return;
    final int nextIndex = (_currentImageIndex + 1) % _slideshowImages.length;
    final String imageUrl = _slideshowImages[nextIndex];

    precacheImage(CachedNetworkImageProvider(imageUrl), context).then((_) {
      if (mounted && _lastMovieId != null) {
        setState(() {
          _isNextImageReady = true;
        });
      }
    });
  }

  Color _getGenreAccentColor(List<int> genreIds, int movieSeed) {
    if (genreIds.isEmpty) {
      return Color.lerp(
        AppColors.cinemaAccent,
        AppColors.cinemaSelected,
        (movieSeed % 7) / 7,
      )!;
    }
    for (final id in genreIds) {
      switch (id) {
        case 28: // Action
          return const Color(0xFFE94560);
        case 12: // Adventure
          return const Color(0xFFFF9500);
        case 16: // Animation
          return const Color(0xFFFF4081);
        case 35: // Comedy
          return const Color(0xFFFFD60A);
        case 80: // Crime
          return const Color(0xFF90A4AE);
        case 18: // Drama
          return const Color(0xFF5C6BC0);
        case 14: // Fantasy
          return const Color(0xFF69F0AE);
        case 27: // Horror
          return const Color(0xFFD50000);
        case 9648: // Mystery
          return const Color(0xFF7E57C2);
        case 10749: // Romance
          return const Color(0xFFEC407A);
        case 878: // Science Fiction
          return const Color(0xFF00E5FF);
        case 53: // Thriller
          return const Color(0xFFFF6D00);
      }
    }
    return Color.lerp(
      AppColors.cinemaAccent,
      AppColors.cinemaSelected,
      (genreIds.first % 7) / 7,
    )!;
  }

  Future<void> _handleHideAction(
    MediaTitle media,
    bool isTv,
    List<MediaTitle> movies,
  ) async {
    final notifier = ref.read(hiddenTitlesProvider.notifier);
    final bool dontAskAgain = await notifier.getDontAskAgain();

    bool shouldHide = false;
    bool setDontAskAgainPref = false;

    if (dontAskAgain) {
      shouldHide = true;
    } else {
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      final bool? result = await showAnimatedDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          bool isChecked = true;
          return StatefulBuilder(
            builder: (context, dialogSetState) {
              return AlertDialog(
                backgroundColor: AppColors.detailsCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                title: Text(
                  'Hide Title',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hiding this title will prevent it from appearing in the Spotlight section in the future.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(unselectedWidgetColor: Colors.white30),
                          child: Checkbox(
                            value: isChecked,
                            activeColor: AppColors.cinemaAccent,
                            checkColor: Colors.black,
                            onChanged: (bool? value) {
                              dialogSetState(() {
                                isChecked = value ?? false;
                              });
                            },
                          ),
                        ),
                        const Text(
                          "Don't ask again",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, isChecked),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    child: const Text(
                      'Hide',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
      if (result != null) {
        shouldHide = true;
        setDontAskAgainPref = result;
      }
    }

    if (shouldHide) {
      if (setDontAskAgainPref) {
        await notifier.setDontAskAgain(true);
      }
      HapticFeedback.mediumImpact();
      await notifier.hideTitle(media, isTv);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${media.title}" has been hidden'),
            backgroundColor: AppColors.detailsCard,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _checkAndLazyLoad(WidgetRef ref, List<int> pool, List<int> remaining) {
    if (pool.length < 6 || remaining.length < 4) {
      final mediaType = ref.read(exploreMediaTypeProvider);
      final section = mediaType == ExploreMediaType.tv
          ? MovieSection.tvDiscover
          : MovieSection.discover;
      loadNextExplorePages(ref, section);
    }
  }

  void _resetSpotlight(List<MediaTitle> movies) {
    final int? currentMovieId = movies.isNotEmpty ? movies.first.id : null;
    setState(() {
      _animatedSwitcherKeyVersion++;
      _swipeOffset = 0.0;
      _isSwipeActionsRevealed = false;
      _isBackdropLoading = true;
      _discoverSpotlightState = _DiscoverSpotlightState(
        poolMovieIds: movies.map((m) => m.id).toList(),
        currentMovieId: currentMovieId,
        remainingMovieIds: _buildRotationQueue(
          movies.map((m) => m.id).toList(),
          excludeMovieId: currentMovieId,
          recentMovieIds: currentMovieId == null
              ? const <int>[]
              : <int>[currentMovieId],
        ),
        recentMovieIds: currentMovieId == null
            ? const <int>[]
            : <int>[currentMovieId],
        dismissedMovieIds: const <int>{},
      );
    });
    if (movies.isNotEmpty) {
      _startSlideshow(movies.first.id);
    }
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    _audioPlayer.dispose();
    _diceController.dispose();
    _pulseController.dispose();
    _swipeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<MediaTitle>> discoverPool = ref.watch(
      discoverPoolProvider,
    );
    discoverPool.whenData(_queueDiscoverPoolSync);
    final _DiscoverSpotlightState? spotlightState = _discoverSpotlightState;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      child: discoverPool.when(
        skipLoadingOnReload: !discoverPool.hasError,
        loading: () => Container(
          height: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.detailsCard.withValues(alpha: 0.2),
          ),
          child: Stack(
            children: [
              const ShimmerEffect(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 16,
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShimmerEffect.textLine(width: 150, height: 24),
                    const SizedBox(height: 8),
                    ShimmerEffect.textLine(width: 100, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        error: (Object error, StackTrace stackTrace) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Failed to load discover picks. $error',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref.invalidate(discoverPoolProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.cinemaAccent,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                ),
              ),
            ],
          ),
        ),
        data: (List<MediaTitle> movies) {
          final List<MediaTitle> activeMovies = movies
              .where(
                (m) =>
                    !(spotlightState?.dismissedMovieIds.contains(m.id) ??
                        false),
              )
              .toList();

          if (movies.isEmpty) {
            return Text(
              'No discover picks available right now.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
              ),
            );
          }

          final double posterWidth = MediaQuery.sizeOf(context).width - 32;

          if (activeMovies.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.04),
                    border: Border.all(
                      color: AppColors.cinemaAccent.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _SectionMarker(
                            icon: Icons.auto_awesome_rounded,
                            accent: AppColors.cinemaAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Discover Spotlight',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cinematic picks with instant vibe context. Roll for another surprise card.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: SizedBox(
                    width: posterWidth,
                    height: 320,
                    child: Container(
                      padding: const EdgeInsets.all(1.2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: <Color>[
                            AppColors.cinemaAccent.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.1),
                            AppColors.cinemaSelected.withValues(alpha: 0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.cinemaAccent.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 20,
                            spreadRadius: -4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withValues(alpha: 0.02),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.cinemaAccent
                                            .withValues(alpha: 0.1),
                                        border: Border.all(
                                          color: AppColors.cinemaAccent
                                              .withValues(alpha: 0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.auto_awesome_motion_rounded,
                                        color: AppColors.cinemaAccent,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Spotlight Completed',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'You have swiped and cleared all choices in your discover feed.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            fontSize: 13,
                                          ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: () => _resetSpotlight(movies),
                                      icon: const Icon(
                                        Icons.restart_alt_rounded,
                                        size: 20,
                                      ),
                                      label: const Text('Reset Spotlight'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.cinemaAccent,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: AppColors.cinemaAccent
                                            .withValues(alpha: 0.4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final MediaTitle movie =
              _currentMovie(activeMovies, spotlightState) ?? activeMovies.first;

          final MovieDetails details = MovieDetails(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
            releaseDate: movie.releaseDate,
            catalogScore: movie.voteAverage,
          );

          if (_lastMovieId != movie.id) {
            _lastMovieId = movie.id;
            // Use post frame callback to avoid calling setState during build if needed,
            // though _startSlideshow calls setState in its .then() which is fine.
            // But we need to call it now to initialize the first poster if any.
            Future.microtask(() => _startSlideshow(movie.id));
          }

          final String? currentSlideshowUrl = _slideshowImages.isNotEmpty
              ? _slideshowImages[_currentImageIndex]
              : movie.posterPath;
          final String? rotatingTagline = _slideshowTaglines.isNotEmpty
              ? _slideshowTaglines[_currentTaglineIndex]
              : null;

          final mediaType = ref.watch(exploreMediaTypeProvider);
          final bool isTv = mediaType == ExploreMediaType.tv;

          final AsyncValue<MovieDetails> movieDetails = ref.watch(
            movieDetailsProvider(
              GetMovieDetailsParams(movieId: movie.id, isTv: isTv),
            ),
          );
          final List<MovieRating> ratings =
              movieDetails.value?.externalRatings
                  .take(2)
                  .toList(growable: false) ??
              const <MovieRating>[];
          final MovieRating? rottenTomatoesRating = _ratingForSource(
            ratings,
            'Rotten Tomatoes',
          );
          final MovieRating? imdbRating = _ratingForSource(ratings, 'IMDb');
          final bool isRatingLoading =
              movieDetails.isLoading && movieDetails.value == null;
          final String scoreLabel = rottenTomatoesRating == null
              ? 'NA'
              : _normalizeScore(rottenTomatoesRating.value) ?? 'NA';
          const double spotlightBadgeSize = 30;
          final Widget scoreBadge = isRatingLoading
              ? RatingBadge.loading(size: spotlightBadgeSize)
              : rottenTomatoesRating == null
              ? RatingBadge.tmdb(
                  catalogScore: movieDetails.value?.catalogScore,
                  size: spotlightBadgeSize,
                )
              : RatingBadge.rottenTomatoes(
                  label: scoreLabel,
                  size: spotlightBadgeSize,
                );

          final List<int> genreIds = movie.genreIds;
          final Color spotlightTint = _getGenreAccentColor(genreIds, movie.id);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: spotlightTint.withValues(alpha: 0.32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _SectionMarker(
                          icon: Icons.auto_awesome_rounded,
                          accent: spotlightTint,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Discover Spotlight',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cinematic picks with instant vibe context. Roll for another surprise card.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final double pulse = _pulseController.value;
                    final double blurRadius = 24 + (pulse * 12);
                    final double opacity = 0.12 + (pulse * 0.08);

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final Animation<double> fadeAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        );
                        final Animation<Offset> slideAnimation = Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(fadeAnimation);

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: slideAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: SizedBox(
                        key: ValueKey<int>(movie.id),
                        width: posterWidth,
                        height: 320,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Background swipe actions layer
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    // Swipe Right background (Hide)
                                    if (_swipeOffset > 0)
                                      Positioned(
                                        top: 0,
                                        bottom: 0,
                                        left: 0,
                                        width: 76,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.45,
                                            ),
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.redAccent
                                                    .withValues(alpha: 0.25),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  HapticFeedback.selectionClick();
                                                  _animateSwipe(
                                                    0.0,
                                                    onComplete: () {
                                                      setState(() {
                                                        _isSwipeActionsRevealed =
                                                            false;
                                                      });
                                                    },
                                                  );
                                                  _handleHideAction(
                                                    movie,
                                                    isTv,
                                                    movies,
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent
                                                        .withValues(alpha: 0.2),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons
                                                        .visibility_off_rounded,
                                                    color: Colors.redAccent,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Swipe Left background (Reveal actions vertically)
                                    if (_swipeOffset < 0)
                                      Positioned(
                                        top: 0,
                                        bottom: 0,
                                        right: 0,
                                        width: 76,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.45,
                                            ),
                                            border: Border(
                                              left: BorderSide(
                                                color: spotlightTint.withValues(
                                                  alpha: 0.25,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _SpotlightListButton(
                                                details: details,
                                                isTv: isTv,
                                              ),
                                              const SizedBox(height: 8),
                                              _SpotlightFavouriteButton(
                                                details: details,
                                                isTv: isTv,
                                              ),
                                              const SizedBox(height: 8),
                                              _SpotlightWatchlistButton(
                                                details: details,
                                                isTv: isTv,
                                              ),
                                              const SizedBox(height: 8),
                                              _SpotlightWatchedButton(
                                                details: details,
                                                isTv: isTv,
                                              ),
                                              const SizedBox(height: 8),
                                              _SpotlightReminderButton(
                                                details: details,
                                                isTv: isTv,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // Foreground Card layer
                            Positioned.fill(
                              child: GestureDetector(
                                onHorizontalDragStart: (DragStartDetails d) {
                                  _swipeAnimationController.stop();
                                  _dragThresholdCrossed = false;
                                },
                                onHorizontalDragUpdate: (DragUpdateDetails d) {
                                  setState(() {
                                    _swipeOffset += d.delta.dx;
                                    // Clamping with spring resistance in both directions
                                    if (_swipeOffset < -76.0) {
                                      final double overflow =
                                          _swipeOffset + 76.0;
                                      _swipeOffset = -76.0 + overflow * 0.15;
                                    } else if (_swipeOffset > 76.0) {
                                      final double overflow =
                                          _swipeOffset - 76.0;
                                      _swipeOffset = 76.0 + overflow * 0.15;
                                    }

                                    // Trigger light haptic click exactly once when crossing the threshold
                                    final double absOffset = _swipeOffset.abs();
                                    if (absOffset > 38.0 &&
                                        !_dragThresholdCrossed) {
                                      _dragThresholdCrossed = true;
                                      HapticFeedback.selectionClick();
                                    } else if (absOffset <= 38.0 &&
                                        _dragThresholdCrossed) {
                                      _dragThresholdCrossed = false;
                                    }
                                  });
                                },
                                onHorizontalDragEnd: (DragEndDetails d) {
                                  if (_swipeOffset > 0) {
                                    // Swipe Right (Reveal Hide on Left)
                                    if (_swipeOffset > 38.0 ||
                                        (d.primaryVelocity ?? 0.0) > 300) {
                                      HapticFeedback.lightImpact();
                                      _animateSwipe(
                                        76.0,
                                        onComplete: () {
                                          setState(() {
                                            _isSwipeActionsRevealed = true;
                                          });
                                        },
                                      );
                                    } else {
                                      _animateSwipe(
                                        0.0,
                                        onComplete: () {
                                          setState(() {
                                            _isSwipeActionsRevealed = false;
                                          });
                                        },
                                      );
                                    }
                                  } else {
                                    // Swipe Left (Reveal Actions on Right)
                                    if (_swipeOffset < -38.0 ||
                                        (d.primaryVelocity ?? 0.0) < -300) {
                                      HapticFeedback.lightImpact();
                                      _animateSwipe(
                                        -76.0,
                                        onComplete: () {
                                          setState(() {
                                            _isSwipeActionsRevealed = true;
                                          });
                                        },
                                      );
                                    } else {
                                      _animateSwipe(
                                        0.0,
                                        onComplete: () {
                                          setState(() {
                                            _isSwipeActionsRevealed = false;
                                          });
                                        },
                                      );
                                    }
                                  }
                                },
                                child: Transform.translate(
                                  offset: Offset(_swipeOffset, 0),
                                  child: Container(
                                    width: posterWidth,
                                    height: 320,
                                    padding: const EdgeInsets.all(1.2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        colors: <Color>[
                                          spotlightTint.withValues(alpha: 0.6),
                                          Colors.white.withValues(alpha: 0.15),
                                          spotlightTint.withValues(alpha: 0.3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: spotlightTint.withValues(
                                            alpha: opacity,
                                          ),
                                          blurRadius: blurRadius,
                                          spreadRadius: -6,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: Colors.white.withValues(
                                          alpha: 0.02,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 16,
                                            sigmaY: 16,
                                          ),
                                          child: Stack(
                                            children: [
                                              // Background image/slideshow
                                              Positioned.fill(
                                                child: Hero(
                                                  tag:
                                                      'movie-poster-${movie.id}-spotlight',
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (_isSwipeActionsRevealed ||
                                                            _swipeOffset.abs() >
                                                                5.0) {
                                                          _animateSwipe(
                                                            0.0,
                                                            onComplete: () {
                                                              setState(() {
                                                                _isSwipeActionsRevealed =
                                                                    false;
                                                              });
                                                            },
                                                          );
                                                        } else {
                                                          context.pushNamed(
                                                            AppRoute
                                                                .movieDetails
                                                                .name,
                                                            pathParameters:
                                                                <
                                                                  String,
                                                                  String
                                                                >{
                                                                  'movieId': movie
                                                                      .id
                                                                      .toString(),
                                                                },
                                                            queryParameters:
                                                                <
                                                                  String,
                                                                  String
                                                                >{
                                                                  'heroTag':
                                                                      'movie-poster-${movie.id}-spotlight',
                                                                  'isTv': isTv
                                                                      .toString(),
                                                                },
                                                          );
                                                        }
                                                      },
                                                      child: AnimatedSwitcher(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 600,
                                                            ),
                                                        child:
                                                            _isBackdropLoading
                                                            ? _SpotlightLoadingView(
                                                                key:
                                                                    ValueKey<
                                                                      String
                                                                    >(
                                                                      'spotlight-loading-${movie.id}-$_animatedSwitcherKeyVersion',
                                                                    ),
                                                                accentColor:
                                                                    spotlightTint,
                                                              )
                                                            : currentSlideshowUrl ==
                                                                  null
                                                            ? ColoredBox(
                                                                key:
                                                                    ValueKey<
                                                                      String
                                                                    >(
                                                                      'spotlight-placeholder-$_animatedSwitcherKeyVersion',
                                                                    ),
                                                                color: AppColors
                                                                    .cinemaPlaceholder,
                                                                child: const Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .movie_outlined,
                                                                    size: 52,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              )
                                                            : _KenBurnsImage(
                                                                key:
                                                                    ValueKey<
                                                                      String
                                                                    >(
                                                                      'spotlight-image-${movie.id}-$currentSlideshowUrl-$_animatedSwitcherKeyVersion',
                                                                    ),
                                                                imageUrl:
                                                                    currentSlideshowUrl,
                                                                width:
                                                                    posterWidth,
                                                                height: 320,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Gradient overlay (top)
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                height: 60,
                                                child: IgnorePointer(
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          Colors.black
                                                              .withValues(
                                                                alpha: 0.6,
                                                              ),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Gradient overlay (bottom)
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                height: 160,
                                                child: IgnorePointer(
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .bottomCenter,
                                                        end:
                                                            Alignment.topCenter,
                                                        colors: [
                                                          Colors.black
                                                              .withValues(
                                                                alpha: 0.8,
                                                              ),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Play / Close Preview overlay button
                                              if (movieDetails
                                                          .value
                                                          ?.trailerYouTubeKey !=
                                                      null &&
                                                  movieDetails
                                                      .value!
                                                      .trailerYouTubeKey!
                                                      .isNotEmpty)
                                                Positioned(
                                                  top: 12,
                                                  left: 12,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                        sigmaX: 8,
                                                        sigmaY: 8,
                                                      ),
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () =>
                                                              _showTrailer(
                                                                context,
                                                                movie: movie,
                                                                details:
                                                                    movieDetails
                                                                        .value!,
                                                                isTv: isTv,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          child: Ink(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 6,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                    alpha: 0.5,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                              border: Border.all(
                                                                color: spotlightTint
                                                                    .withValues(
                                                                      alpha:
                                                                          0.6,
                                                                    ),
                                                                width: 1.0,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .play_arrow_rounded,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 14,
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  'Play Preview',
                                                                  style: theme
                                                                      .textTheme
                                                                      .labelSmall
                                                                      ?.copyWith(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            10,
                                                                        letterSpacing:
                                                                            0.3,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                              // Tagline (Slide up & Fade)
                                              Positioned(
                                                bottom: 104,
                                                left: 16,
                                                right: 16,
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 500,
                                                  ),
                                                  transitionBuilder:
                                                      (
                                                        Widget child,
                                                        Animation<double>
                                                        animation,
                                                      ) {
                                                        final inAnimation =
                                                            Tween<Offset>(
                                                              begin:
                                                                  const Offset(
                                                                    0.0,
                                                                    0.4,
                                                                  ),
                                                              end: Offset.zero,
                                                            ).animate(
                                                              CurvedAnimation(
                                                                parent:
                                                                    animation,
                                                                curve: Curves
                                                                    .easeOutCubic,
                                                              ),
                                                            );
                                                        final fadeAnimation =
                                                            CurvedAnimation(
                                                              parent: animation,
                                                              curve:
                                                                  Curves.easeIn,
                                                            );
                                                        return SlideTransition(
                                                          position: inAnimation,
                                                          child: FadeTransition(
                                                            opacity:
                                                                fadeAnimation,
                                                            child: child,
                                                          ),
                                                        );
                                                      },
                                                  child:
                                                      rotatingTagline != null &&
                                                          rotatingTagline
                                                              .isNotEmpty
                                                      ? Text(
                                                          rotatingTagline,
                                                          key: ValueKey<String>(
                                                            rotatingTagline,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: theme
                                                              .textTheme
                                                              .labelSmall
                                                              ?.copyWith(
                                                                color: Colors
                                                                    .white
                                                                    .withValues(
                                                                      alpha:
                                                                          0.9,
                                                                    ),
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    0.2,
                                                                shadows: [
                                                                  const Shadow(
                                                                    color: Colors
                                                                        .black,
                                                                    blurRadius:
                                                                        8,
                                                                  ),
                                                                ],
                                                              ),
                                                        )
                                                      : (movieDetails
                                                                        .value
                                                                        ?.tagline !=
                                                                    null &&
                                                                movieDetails
                                                                    .value!
                                                                    .tagline!
                                                                    .isNotEmpty
                                                            ? Text(
                                                                movieDetails
                                                                    .value!
                                                                    .tagline!,
                                                                key: ValueKey<String>(
                                                                  movieDetails
                                                                      .value!
                                                                      .tagline!,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: theme.textTheme.labelSmall?.copyWith(
                                                                  color: Colors
                                                                      .white
                                                                      .withValues(
                                                                        alpha:
                                                                            0.9,
                                                                      ),
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  letterSpacing:
                                                                      0.2,
                                                                  shadows: [
                                                                    const Shadow(
                                                                      color: Colors
                                                                          .black,
                                                                      blurRadius:
                                                                          8,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : const SizedBox.shrink(
                                                                key: ValueKey(
                                                                  'empty-tagline',
                                                                ),
                                                              )),
                                                ),
                                              ),

                                              // Floating Glassmorphic Bottom Pane
                                              Positioned(
                                                bottom: 12,
                                                left: 12,
                                                right: 12,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.55,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    border: Border.all(
                                                      color: spotlightTint
                                                          .withValues(
                                                            alpha: 0.35,
                                                          ),
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.25,
                                                            ),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                        sigmaX: 12,
                                                        sigmaY: 12,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 12,
                                                            ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child: GestureDetector(
                                                                behavior:
                                                                    HitTestBehavior
                                                                        .opaque,
                                                                onTap: () => context.pushNamed(
                                                                  AppRoute
                                                                      .movieDetails
                                                                      .name,
                                                                  pathParameters:
                                                                      <
                                                                        String,
                                                                        String
                                                                      >{
                                                                        'movieId': movie
                                                                            .id
                                                                            .toString(),
                                                                      },
                                                                  queryParameters:
                                                                      <
                                                                        String,
                                                                        String
                                                                      >{
                                                                        'heroTag':
                                                                            'movie-poster-${movie.id}-spotlight',
                                                                        'isTv': isTv
                                                                            .toString(),
                                                                      },
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    if (_logoUrl !=
                                                                        null)
                                                                      _logoUrl!.toLowerCase().endsWith(
                                                                            '.svg',
                                                                          )
                                                                          ? SvgPicture.network(
                                                                              _logoUrl!,
                                                                              height: 28,
                                                                              fit: BoxFit.contain,
                                                                              alignment: Alignment.centerLeft,
                                                                              placeholderBuilder:
                                                                                  (
                                                                                    context,
                                                                                  ) => const SizedBox(
                                                                                    height: 28,
                                                                                  ),
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: _logoUrl!,
                                                                              height: 28,
                                                                              fit: BoxFit.contain,
                                                                              alignment: Alignment.centerLeft,
                                                                            )
                                                                    else
                                                                      Text(
                                                                        movie
                                                                            .title,
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: theme.textTheme.titleMedium?.copyWith(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.w900,
                                                                        ),
                                                                      ),
                                                                    const SizedBox(
                                                                      height: 6,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        if (!isRatingLoading &&
                                                                            rottenTomatoesRating !=
                                                                                null) ...[
                                                                          const _TomatoIcon(),
                                                                          const SizedBox(
                                                                            width:
                                                                                6,
                                                                          ),
                                                                          Text(
                                                                            scoreLabel,
                                                                            style: theme.textTheme.labelSmall?.copyWith(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w800,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                            width:
                                                                                1,
                                                                            height:
                                                                                10,
                                                                            color: Colors.white.withValues(
                                                                              alpha: 0.2,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                        ] else ...[
                                                                          scoreBadge,
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                        ],
                                                                        if (imdbRating !=
                                                                            null) ...[
                                                                          const _ImdbIcon(),
                                                                          const SizedBox(
                                                                            width:
                                                                                6,
                                                                          ),
                                                                          Text(
                                                                            imdbRating.value,
                                                                            style: theme.textTheme.labelSmall?.copyWith(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.w800,
                                                                            ),
                                                                          ),
                                                                        ] else
                                                                          Text(
                                                                            'IMDb NA',
                                                                            style: theme.textTheme.labelSmall?.copyWith(
                                                                              color: Colors.white.withValues(
                                                                                alpha: 0.6,
                                                                              ),
                                                                              fontWeight: FontWeight.w800,
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Material(
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                onTap: () =>
                                                                    _rollNextMovie(
                                                                      movies,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                child: Ink(
                                                                  width: 44,
                                                                  height: 44,
                                                                  decoration: BoxDecoration(
                                                                    color: AppColors
                                                                        .cinemaSelected
                                                                        .withValues(
                                                                          alpha:
                                                                              0.1,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                    border: Border.all(
                                                                      color: AppColors
                                                                          .cinemaSelected
                                                                          .withValues(
                                                                            alpha:
                                                                                0.2,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  child: Center(
                                                                    child: ScaleTransition(
                                                                      scale:
                                                                          _scaleAnimation,
                                                                      child: RotationTransition(
                                                                        turns:
                                                                            _diceAnimation,
                                                                        child: Icon(
                                                                          Icons
                                                                              .casino_outlined,
                                                                          color:
                                                                              AppColors.cinemaSelected,
                                                                          size:
                                                                              24,
                                                                        ),
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
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  MediaTitle? _currentMovie(
    List<MediaTitle> movies,
    _DiscoverSpotlightState? spotlightState,
  ) {
    final int? currentMovieId = spotlightState?.currentMovieId;
    if (currentMovieId == null) {
      return null;
    }

    for (final MediaTitle movie in movies) {
      if (movie.id == currentMovieId) {
        return movie;
      }
    }

    return null;
  }

  void _queueDiscoverPoolSync(List<MediaTitle> movies) {
    final List<int> nextPoolMovieIds = movies
        .map((movie) => movie.id)
        .toList(growable: false);
    final _DiscoverSpotlightState? spotlightState = _discoverSpotlightState;

    if (listEquals(nextPoolMovieIds, spotlightState?.poolMovieIds)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _syncDiscoverPool(movies);
    });
  }

  void _syncDiscoverPool(List<MediaTitle> movies) {
    final _DiscoverSpotlightState? spotlightState = _discoverSpotlightState;
    final Set<int> dismissed =
        spotlightState?.dismissedMovieIds ?? const <int>{};

    final List<int> poolMovieIds = movies
        .map((movie) => movie.id)
        .where((id) => !dismissed.contains(id))
        .toList(growable: false);

    if (listEquals(poolMovieIds, spotlightState?.poolMovieIds)) {
      return;
    }

    final int? currentMovieId = spotlightState?.currentMovieId;
    final List<int> recentMovieIds =
        (spotlightState?.recentMovieIds ?? const <int>[])
            .where(poolMovieIds.contains)
            .toList(growable: false);
    final bool canKeepCurrentMovie =
        currentMovieId != null && poolMovieIds.contains(currentMovieId);

    List<int> nextRemainingMovieIds = <int>[
      ...(spotlightState?.remainingMovieIds ?? const <int>[])
          .where(poolMovieIds.contains)
          .where((int id) => !recentMovieIds.contains(id))
          .toSet(),
    ];
    nextRemainingMovieIds.removeWhere(
      (int id) => id == currentMovieId || dismissed.contains(id),
    );

    final Set<int> queuedIds = nextRemainingMovieIds.toSet();
    for (final int id in _buildRotationQueue(
      poolMovieIds,
      excludeMovieId: currentMovieId,
      recentMovieIds: recentMovieIds,
    )) {
      if (queuedIds.add(id)) {
        nextRemainingMovieIds.add(id);
      }
    }

    int? nextCurrentMovieId = canKeepCurrentMovie ? currentMovieId : null;
    if (nextCurrentMovieId == null && nextRemainingMovieIds.isNotEmpty) {
      nextCurrentMovieId = nextRemainingMovieIds.removeLast();
    }
    if (nextCurrentMovieId == null && poolMovieIds.isNotEmpty) {
      nextCurrentMovieId = poolMovieIds.first;
    }

    List<int> nextRecentMovieIds = List<int>.from(recentMovieIds);
    nextRecentMovieIds = _appendRecentMovie(nextRecentMovieIds, currentMovieId);
    nextRecentMovieIds = _appendRecentMovie(
      nextRecentMovieIds,
      nextCurrentMovieId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _animatedSwitcherKeyVersion++;
      if (nextCurrentMovieId != currentMovieId) {
        _swipeOffset = 0.0;
        _isSwipeActionsRevealed = false;
        _isBackdropLoading = true;
      }
      _discoverSpotlightState = _DiscoverSpotlightState(
        poolMovieIds: poolMovieIds,
        currentMovieId: nextCurrentMovieId,
        remainingMovieIds: nextRemainingMovieIds,
        recentMovieIds: nextRecentMovieIds,
        dismissedMovieIds: dismissed,
      );
    });

    _checkAndLazyLoad(ref, poolMovieIds, nextRemainingMovieIds);
  }

  Future<void> _rollNextMovie(List<MediaTitle> movies) async {
    if (movies.isEmpty) {
      return;
    }

    final _DiscoverSpotlightState? spotlightState = _discoverSpotlightState;
    final Set<int> dismissed =
        spotlightState?.dismissedMovieIds ?? const <int>{};

    final List<int> poolMovieIds =
        (spotlightState?.poolMovieIds ??
                movies.map((movie) => movie.id).toList(growable: false))
            .where((id) => !dismissed.contains(id))
            .toList();

    List<int> remainingMovieIds = List<int>.from(
      spotlightState?.remainingMovieIds ?? const <int>[],
    ).where((id) => !dismissed.contains(id)).toList();
    final List<int> recentMovieIds = List<int>.from(
      spotlightState?.recentMovieIds ?? const <int>[],
    ).where(poolMovieIds.contains).toList();
    final int? currentMovieId = spotlightState?.currentMovieId;

    remainingMovieIds.removeWhere((int id) => recentMovieIds.contains(id));

    if (remainingMovieIds.isEmpty) {
      remainingMovieIds = _buildRotationQueue(
        poolMovieIds,
        excludeMovieId: currentMovieId,
        recentMovieIds: recentMovieIds,
      );
    }

    if (remainingMovieIds.isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    final int nextCurrentMovieId = remainingMovieIds.removeLast();
    List<int> nextRecentMovieIds = List<int>.from(recentMovieIds);
    nextRecentMovieIds = _appendRecentMovie(nextRecentMovieIds, currentMovieId);
    nextRecentMovieIds = _appendRecentMovie(
      nextRecentMovieIds,
      nextCurrentMovieId,
    );

    setState(() {
      _animatedSwitcherKeyVersion++;
      _swipeOffset = 0.0;
      _isSwipeActionsRevealed = false;
      _isBackdropLoading = true;
      _discoverSpotlightState = _DiscoverSpotlightState(
        poolMovieIds: poolMovieIds,
        currentMovieId: nextCurrentMovieId,
        remainingMovieIds: remainingMovieIds,
        recentMovieIds: nextRecentMovieIds,
        dismissedMovieIds: dismissed,
      );
    });

    _checkAndLazyLoad(ref, poolMovieIds, remainingMovieIds);

    HapticFeedback.mediumImpact();
    _diceController.forward(from: 0);
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/dice_shuffle.wav'));
  }

  List<int> _shuffleMovieIds(List<int> movieIds, {int? excludeMovieId}) {
    final List<int> shuffledMovieIds = movieIds
        .where((movieId) => movieId != excludeMovieId)
        .toList(growable: true);
    shuffledMovieIds.shuffle(_random);
    return shuffledMovieIds;
  }

  List<int> _buildRotationQueue(
    List<int> movieIds, {
    int? excludeMovieId,
    List<int> recentMovieIds = const <int>[],
  }) {
    final Set<int> recentSet = recentMovieIds.toSet();
    final List<int> preferred = movieIds
        .where((int movieId) => movieId != excludeMovieId)
        .where((int movieId) => !recentSet.contains(movieId))
        .toList(growable: true);
    preferred.shuffle(_random);
    if (preferred.isNotEmpty) {
      return preferred;
    }
    return _shuffleMovieIds(movieIds, excludeMovieId: excludeMovieId);
  }

  List<int> _appendRecentMovie(List<int> recentMovieIds, int? movieId) {
    if (movieId == null) {
      return recentMovieIds;
    }
    final List<int> next =
        recentMovieIds.where((int id) => id != movieId).toList(growable: true)
          ..add(movieId);
    if (next.length > _recentSpotlightMemory) {
      next.removeRange(0, next.length - _recentSpotlightMemory);
    }
    return next;
  }
}

class _DiscoverSpotlightState {
  const _DiscoverSpotlightState({
    required this.poolMovieIds,
    required this.currentMovieId,
    required this.remainingMovieIds,
    this.recentMovieIds = const <int>[],
    this.dismissedMovieIds = const <int>{},
  });

  final List<int> poolMovieIds;
  final int? currentMovieId;
  final List<int> remainingMovieIds;
  final List<int> recentMovieIds;
  final Set<int> dismissedMovieIds;
}

class _MovieShelfSection extends ConsumerStatefulWidget {
  const _MovieShelfSection({required this.section});

  final ExploreShelfData section;

  @override
  ConsumerState<_MovieShelfSection> createState() => _MovieShelfSectionState();
}

class _MovieShelfSectionState extends ConsumerState<_MovieShelfSection> {
  static const List<int> _hiddenGemsCuratedGenreOrder = <int>[
    18, // Drama
    53, // Thriller
    80, // Crime
    9648, // Mystery
    35, // Comedy
    10749, // Romance
    27, // Horror
    14, // Fantasy
    878, // Sci-Fi
    16, // Animation
  ];
  static const int _hiddenGemsMinTitlesPerGenre = 2;

  late ExploreFilterOption _selectedFilter;
  bool _hiddenGemsPrefetchScheduled = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.section.filters.first;
  }

  @override
  void didUpdateWidget(_MovieShelfSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.section.title != oldWidget.section.title) {
      _selectedFilter = widget.section.filters.first;
    }
  }

  List<ExploreFilterOption> _hiddenGemsGenreFilters(List<MovieGenre> genres) {
    if (genres.isEmpty) {
      return widget.section.filters;
    }
    final Map<int, MovieGenre> genresById = <int, MovieGenre>{
      for (final MovieGenre genre in genres) genre.id: genre,
    };
    final List<MovieGenre> curatedGenres = _hiddenGemsCuratedGenreOrder
        .map((int id) => genresById[id])
        .whereType<MovieGenre>()
        .toList(growable: false);
    final List<MovieGenre> effectiveGenres = curatedGenres.isNotEmpty
        ? curatedGenres
        : genres.take(10).toList(growable: false);
    final ExploreFilterOption allFilter = widget.section.filters.first;
    return <ExploreFilterOption>[
      allFilter,
      ...effectiveGenres.map(
        (MovieGenre genre) => ExploreFilterOption(
          label: genre.name,
          genreId: genre.id,
          isHiddenGems: true,
        ),
      ),
    ];
  }

  void _maybePrefetchHiddenGemsPages({
    required List<MediaTitle> data,
    required List<ExploreFilterOption> filters,
    required bool isExhausted,
  }) {
    if (!mounted || isExhausted || _hiddenGemsPrefetchScheduled) {
      return;
    }
    final List<int> genreIds = filters
        .where((ExploreFilterOption filter) => filter.isHiddenGems)
        .map((ExploreFilterOption filter) => filter.genreId)
        .whereType<int>()
        .toSet()
        .toList(growable: false);
    if (genreIds.isEmpty) {
      return;
    }
    final Map<int, int> counts = <int, int>{
      for (final int genreId in genreIds) genreId: 0,
    };
    for (final MediaTitle title in data) {
      for (final int genreId in title.genreIds) {
        final int? current = counts[genreId];
        if (current != null) {
          counts[genreId] = current + 1;
        }
      }
    }
    final bool needsMore = counts.values.any(
      (int count) => count < _hiddenGemsMinTitlesPerGenre,
    );
    if (!needsMore) {
      return;
    }
    _hiddenGemsPrefetchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hiddenGemsPrefetchScheduled = false;
      if (!mounted) {
        return;
      }
      loadNextHiddenGemsPages(ref);
    });
  }

  void _navigateToSection({required List<ExploreFilterOption> filters}) {
    final mediaType = ref.read(exploreMediaTypeProvider);
    final bool routeIsTv = mediaType == ExploreMediaType.tv;

    context.pushNamed(
      AppRoute.exploreSection.name,
      queryParameters: {'isTv': routeIsTv.toString()},
      extra: {'sectionTitle': widget.section.title, 'filters': filters},
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final mediaType = ref.watch(exploreMediaTypeProvider);
    final bool isTv = mediaType == ExploreMediaType.tv;
    final _SectionVisualSpec visual =
        _sectionVisuals[widget.section.title] ??
        const _SectionVisualSpec(
          icon: Icons.movie_outlined,
          accent: Color(0xFF7DD9FF),
          subtitle: 'Fresh picks updated continuously',
        );
    final bool isHiddenGemsSection =
        !isTv && widget.section.filters.any((filter) => filter.isHiddenGems);
    final List<ExploreFilterOption> effectiveFilters = isHiddenGemsSection
        ? _hiddenGemsGenreFilters(
            ref.watch(movieGenresProvider).asData?.value ??
                const <MovieGenre>[],
          )
        : widget.section.filters;
    final ExploreFilterOption activeFilter =
        effectiveFilters.any((filter) => filter.matches(_selectedFilter))
        ? _selectedFilter
        : effectiveFilters.first;

    final AsyncValue<List<MediaTitle>> movies;
    if (activeFilter.isHiddenGems) {
      movies = ref.watch(hiddenGemsSectionProvider);
    } else if (activeFilter.mood != null) {
      movies = ref.watch(
        moodSectionProvider((mood: activeFilter.mood!, isTv: isTv)),
      );
    } else if (activeFilter.genreId != null) {
      movies = ref.watch(
        exploreGenreSectionProvider((id: activeFilter.genreId!, isTv: isTv)),
      );
    } else {
      movies = ref.watch(exploreMovieSectionProvider(activeFilter.section!));
    }

    const double horizontalPadding = 16;
    const double itemSpacing = 12;
    const double shelfHeight = 220;

    // Use a more efficient way to get width
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double cardWidth =
        (screenWidth - (horizontalPadding * 2) - (itemSpacing * 2)) / 3;
    final double finalCardWidth = cardWidth.clamp(100.0, 108.0);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionMarker(icon: visual.icon, accent: visual.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.section.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          visual.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.64),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SectionFilterPill(
                    label: 'See All',
                    onTap: () => _navigateToSection(filters: effectiveFilters),
                    accent: visual.accent,
                    icon: Icons.open_in_new_rounded,
                  ),
                ],
              ),
            ),
            if (effectiveFilters.length > 1)
              Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: effectiveFilters.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = effectiveFilters[index];
                    final bool isSelected = filter.matches(activeFilter);
                    return _InlineFilterChip(
                      label: filter.label,
                      isSelected: isSelected,
                      accent: visual.accent,
                      onTap: () {
                        if (!filter.matches(activeFilter)) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              child: Container(
                key: ValueKey<String>(
                  '${widget.section.title}_${activeFilter.label}',
                ),
                child: movies.when(
                  skipLoadingOnReload: !movies.hasError,
                  loading: () => _ShelfShimmer(accent: visual.accent),
                  error: (Object error, StackTrace stackTrace) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionMessageCard(
                      title: 'Couldn’t load this rail',
                      body:
                          'There was a temporary issue loading ${widget.section.title.toLowerCase()}.',
                      accent: visual.accent,
                      icon: Icons.wifi_tethering_error_rounded,
                      actionLabel: 'Retry',
                      onAction: () {
                        final int? genreId = activeFilter.genreId;
                        final MovieMood? mood = activeFilter.mood;
                        if (mood != null) {
                          ref.invalidate(
                            moodSectionProvider((mood: mood, isTv: isTv)),
                          );
                        } else if (activeFilter.isHiddenGems) {
                          ref.invalidate(hiddenGemsSectionProvider);
                        } else if (genreId != null) {
                          ref.invalidate(
                            exploreGenreSectionProvider((
                              id: genreId,
                              isTv: isTv,
                            )),
                          );
                        } else {
                          ref.invalidate(
                            exploreMovieSectionProvider(activeFilter.section!),
                          );
                        }
                      },
                    ),
                  ),
                  data: (List<MediaTitle> data) {
                    if (activeFilter.isHiddenGems) {
                      _maybePrefetchHiddenGemsPages(
                        data: data,
                        filters: effectiveFilters,
                        isExhausted: ref.watch(
                          hiddenGemsSectionExhaustedProvider,
                        ),
                      );
                    }
                    final List<MediaTitle> sectionData =
                        activeFilter.isHiddenGems &&
                            activeFilter.genreId != null
                        ? data
                              .where(
                                (MediaTitle title) => title.genreIds.contains(
                                  activeFilter.genreId,
                                ),
                              )
                              .toList(growable: false)
                        : data;
                    if (sectionData.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SectionMessageCard(
                          title: 'No titles here yet',
                          body:
                              activeFilter.isHiddenGems &&
                                  activeFilter.genreId != null
                              ? 'No hidden gems found for this genre yet. Try another genre.'
                              : 'Try another filter or open this section for broader discovery.',
                          accent: visual.accent,
                          icon: Icons.search_off_rounded,
                          actionLabel: 'See all filters',
                          onAction: () =>
                              _navigateToSection(filters: effectiveFilters),
                        ),
                      );
                    }

                    return SizedBox(
                      height: shelfHeight,
                      child: ListView.separated(
                        // ignore: deprecated_member_use
                        cacheExtent:
                            500, // Pre-render slightly more items for smoothness
                        padding: const EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        scrollDirection: Axis.horizontal,
                        addAutomaticKeepAlives: true, // Keep posters in memory
                        itemCount: sectionData.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: itemSpacing),
                        itemBuilder: (context, index) {
                          return _PosterShell(
                            index: index,
                            accent: visual.accent,
                            child: RepaintBoundary(
                              child: MediaPosterGridCard(
                                movie: sectionData[index],
                                sectionTitle: widget.section.title,
                                width: finalCardWidth,
                                isTvTitle: isTv,
                                disableSortBasedSubtitle: true,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollReveal extends StatefulWidget {
  const _ScrollReveal({required this.child, this.indexOffset = 0});

  final Widget child;
  final int indexOffset;

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  ScrollPosition? _scrollPosition;
  bool _hasRevealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cleanupScrollListener();

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      _scrollPosition = scrollable.position;
      _scrollPosition!.addListener(_checkVisibility);
      // Check visibility after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkVisibility();
        }
      });
    } else {
      // Fallback: if there is no scrollable, just animate in immediately
      _reveal();
    }
  }

  @override
  void dispose() {
    _cleanupScrollListener();
    _controller.dispose();
    super.dispose();
  }

  void _cleanupScrollListener() {
    _scrollPosition?.removeListener(_checkVisibility);
    _scrollPosition = null;
  }

  void _checkVisibility() {
    if (_hasRevealed || !mounted) return;

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;

    // Get the position of this widget relative to the viewport
    final RenderBox viewport =
        scrollable.context.findRenderObject() as RenderBox;
    if (!renderObject.attached || !viewport.attached) return;

    try {
      final Offset position = renderObject.localToGlobal(
        Offset.zero,
        ancestor: viewport,
      );
      final double viewportHeight = viewport.size.height;

      // If the top of this widget is within viewport height (partially visible)
      if (position.dy < viewportHeight - 40) {
        _reveal();
      }
    } catch (_) {
      // Catch any render box mapping errors if layout is changing rapidly
    }
  }

  void _reveal() {
    if (_hasRevealed) return;
    _hasRevealed = true;
    _cleanupScrollListener();

    final int delayMs = (widget.indexOffset * 100).clamp(0, 400);
    if (delayMs == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SlideTransition(position: _slideAnimation, child: widget.child),
      ),
    );
  }
}

class _CuratedCollectionSection extends ConsumerWidget {
  const _CuratedCollectionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<CuratedTonightRailData> curatedState = ref.watch(
      curatedTonightRailProvider,
    );
    final bool isTv =
        ref.watch(exploreMediaTypeProvider) == ExploreMediaType.tv;
    const Color accent = Color(0xFFE6C76A);
    const double horizontalPadding = 16;
    const double itemSpacing = 12;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double cardWidth =
        (screenWidth - (horizontalPadding * 2) - (itemSpacing * 2)) / 3;
    final double finalCardWidth = cardWidth.clamp(100.0, 108.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: curatedState.when(
              skipLoadingOnReload: !curatedState.hasError,
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const _SectionMarker(
                        icon: Icons.auto_awesome_rounded,
                        accent: accent,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Curated Tonight',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ShimmerEffect.textLine(width: 230, height: 14),
                ],
              ),
              error: (Object error, StackTrace stackTrace) => _SectionMessageCard(
                title: 'Couldn’t load curated picks',
                body:
                    'There was a temporary issue loading tonight’s curated list.',
                accent: accent,
                icon: Icons.wifi_tethering_error_rounded,
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(curatedTonightRailProvider),
              ),
              data: (CuratedTonightRailData curated) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _SectionMarker(
                        icon: Icons.auto_awesome_rounded,
                        accent: accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Curated Tonight: ${curated.profile.title}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              curated.profile.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.76),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _InfoBadge(
                        label: 'Today',
                        color: accent,
                        accent: accent,
                        icon: Icons.today_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: curated.profile.tags
                        .map((String tag) => _CuratedTagChip(label: tag))
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          curatedState.when(
            skipLoadingOnReload: !curatedState.hasError,
            loading: () => const _ShelfShimmer(accent: accent),
            error: (Object error, StackTrace stackTrace) =>
                const SizedBox.shrink(),
            data: (CuratedTonightRailData curated) {
              if (curated.titles.isEmpty) {
                return _SectionMessageCard(
                  title: 'No curated picks available',
                  body:
                      'Try again in a moment while we refresh tonight’s TMDB list.',
                  accent: accent,
                  icon: Icons.search_off_rounded,
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(curatedTonightRailProvider),
                );
              }

              return SizedBox(
                height: 220,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: curated.titles.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: itemSpacing),
                  itemBuilder: (context, index) {
                    return _PosterShell(
                      index: index,
                      accent: accent,
                      child: MediaPosterGridCard(
                        movie: curated.titles[index],
                        sectionTitle: 'Curated Tonight',
                        width: finalCardWidth,
                        isTvTitle: isTv,
                        disableSortBasedSubtitle: true,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CuratedTagChip extends StatelessWidget {
  const _CuratedTagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.cinemaBorder;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.0),
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}

class _SectionMarker extends StatelessWidget {
  const _SectionMarker({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: accent.withValues(alpha: 0.18),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Icon(icon, color: Colors.white.withValues(alpha: 0.95), size: 18),
    );
  }
}

class _SectionMessageCard extends StatelessWidget {
  const _SectionMessageCard({
    required this.title,
    required this.body,
    required this.accent,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final Color accent;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.35,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...<Widget>[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.chevron_right_rounded, size: 18),
                    label: Text(actionLabel!),
                    style: TextButton.styleFrom(
                      foregroundColor: accent,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 34),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterShell extends StatefulWidget {
  const _PosterShell({
    required this.index,
    required this.accent,
    required this.child,
  });

  final int index;
  final Color accent;
  final Widget child;

  @override
  State<_PosterShell> createState() => _PosterShellState();
}

class _PosterShellState extends State<_PosterShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    final int delayMs = (widget.index * 40).clamp(0, 520);
    if (delayMs == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SlideTransition(position: _slideAnimation, child: widget.child),
      ),
    );
  }
}

class _ShelfShimmer extends StatelessWidget {
  const _ShelfShimmer({this.accent});

  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 108,
              height: 153,
              padding: const EdgeInsets.all(1.2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    (accent ?? AppColors.cinemaGlow).withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.12),
                    (accent ?? AppColors.cinemaWarmGlow).withValues(
                      alpha: 0.46,
                    ),
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: (accent ?? AppColors.cinemaGlow).withValues(
                      alpha: 0.16,
                    ),
                    blurRadius: 20,
                    spreadRadius: -10,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ShimmerEffect.poster(width: 108, height: 153),
              ),
            ),
            const SizedBox(height: 12),
            ShimmerEffect.textLine(width: 80, height: 12),
            const SizedBox(height: 6),
            ShimmerEffect.textLine(width: 40, height: 10),
          ],
        ),
      ),
    );
  }
}

class _SectionFilterPill extends StatelessWidget {
  const _SectionFilterPill({
    required this.label,
    required this.onTap,
    this.accent,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final Color? accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                (accent ?? AppColors.cinemaAccent).withValues(alpha: 0.22),
                AppColors.cinemaPanelMid.withValues(alpha: 0.94),
                AppColors.cinemaPanelBottom.withValues(alpha: 0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (accent ?? AppColors.cinemaBorder).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.tune_rounded,
                color: (accent ?? AppColors.cinemaAccent).withValues(
                  alpha: 0.92,
                ),
                size: 13,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: (accent ?? AppColors.cinemaGlow),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineFilterChip extends StatelessWidget {
  const _InlineFilterChip({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.96,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? accent : Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

MovieRating? _ratingForSource(List<MovieRating> ratings, String source) {
  for (final MovieRating rating in ratings) {
    if (rating.source == source) {
      return rating;
    }
  }

  return null;
}

String? _normalizeScore(String rawValue) {
  final RegExp percentPattern = RegExp(r'(\d{1,3})\s*%');
  final Match? percentMatch = percentPattern.firstMatch(rawValue);
  if (percentMatch != null) {
    return '${percentMatch.group(1)}%';
  }

  final RegExp tenPointPattern = RegExp(r'(\d+(?:\.\d+)?)\s*/\s*10');
  final Match? tenPointMatch = tenPointPattern.firstMatch(rawValue);
  if (tenPointMatch != null) {
    final double? parsedValue = double.tryParse(tenPointMatch.group(1)!);
    if (parsedValue != null) {
      return '${(parsedValue * 10).round()}%';
    }
  }

  return null;
}

class _ImdbIcon extends StatelessWidget {
  const _ImdbIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logos/IMDB_Logo.svg',
      height: 13,
      fit: BoxFit.contain,
    );
  }
}

class _TomatoIcon extends StatelessWidget {
  const _TomatoIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logos/Rotten_Tomatoes.svg',
      height: 15,
      fit: BoxFit.contain,
    );
  }
}

class _AmbientGlowingBackdrop extends StatefulWidget {
  const _AmbientGlowingBackdrop({
    required this.child,
    required this.scrollController,
  });

  final Widget child;
  final ScrollController scrollController;

  @override
  State<_AmbientGlowingBackdrop> createState() =>
      _AmbientGlowingBackdropState();
}

class _AmbientGlowingBackdropState extends State<_AmbientGlowingBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[
              _controller,
              widget.scrollController,
            ]),
            builder: (context, _) {
              final double offset = widget.scrollController.hasClients
                  ? widget.scrollController.offset
                  : 0.0;
              return CustomPaint(
                painter: _GlowingBlobsPainter(
                  animationValue: _controller.value,
                  scrollOffset: offset,
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _GlowingBlobsPainter extends CustomPainter {
  _GlowingBlobsPainter({
    required this.animationValue,
    required this.scrollOffset,
  });

  final double animationValue;
  final double scrollOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final double angle = animationValue * 2 * math.pi;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Subtle parallax drift factor
    final double yOffset = -scrollOffset * 0.08;

    // Blob 1: Cyan-Blueish
    final double x1 = size.width * (0.25 + 0.15 * math.sin(angle));
    final double y1 = size.height * (0.3 + 0.1 * math.cos(angle)) + yOffset;
    final double r1 = math.min(size.width, size.height) * 0.45;
    paint.shader = RadialGradient(
      colors: <Color>[
        const Color(0xFF00E5FF).withValues(alpha: 0.18),
        const Color(0xFF00E5FF).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(x1, y1), radius: r1));
    canvas.drawCircle(Offset(x1, y1), r1, paint);

    // Blob 2: Magenta/Pinkish
    final double x2 = size.width * (0.75 + 0.12 * math.cos(angle + 1.0));
    final double y2 =
        size.height * (0.45 + 0.15 * math.sin(angle + 1.0)) + yOffset;
    final double r2 = math.min(size.width, size.height) * 0.5;
    paint.shader = RadialGradient(
      colors: <Color>[
        const Color(0xFFE040FB).withValues(alpha: 0.15),
        const Color(0xFFE040FB).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(x2, y2), radius: r2));
    canvas.drawCircle(Offset(x2, y2), r2, paint);

    // Blob 3: Deep Indigo/Purple
    final double x3 = size.width * (0.45 + 0.2 * math.sin(angle + 2.5));
    final double y3 =
        size.height * (0.8 + 0.12 * math.cos(angle + 2.5)) + yOffset;
    final double r3 = math.min(size.width, size.height) * 0.55;
    paint.shader = RadialGradient(
      colors: <Color>[
        const Color(0xFF651FFF).withValues(alpha: 0.18),
        const Color(0xFF651FFF).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(x3, y3), radius: r3));
    canvas.drawCircle(Offset(x3, y3), r3, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowingBlobsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scrollOffset != scrollOffset;
  }
}

class _KenBurnsImage extends StatefulWidget {
  const _KenBurnsImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final double width;
  final double height;

  @override
  State<_KenBurnsImage> createState() => _KenBurnsImageState();
}

class _KenBurnsImageState extends State<_KenBurnsImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _panAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _initAnimations();
    _controller.forward();
  }

  void _initAnimations() {
    final int hash = widget.imageUrl.hashCode;
    final bool zoomIn = hash.isEven;
    final bool driftDown = (hash % 3) != 0;

    _scaleAnimation = Tween<double>(
      begin: zoomIn ? 1.02 : 1.12,
      end: zoomIn ? 1.12 : 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _panAnimation = Tween<Offset>(
      begin: driftDown ? const Offset(0, -0.02) : const Offset(0, 0.02),
      end: driftDown ? const Offset(0, 0.02) : const Offset(0, -0.02),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void didUpdateWidget(_KenBurnsImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      _initAnimations();
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double panY = _panAnimation.value.dy * 14;
        const double assumedBackdropAspectRatio = 16 / 9;
        final double renderedImageHeight = math.min(
          widget.height,
          widget.width / assumedBackdropAspectRatio,
        );
        final double effectiveImageBottom =
            renderedImageHeight * _scaleAnimation.value + panY;
        final bool hasBottomGap = effectiveImageBottom < widget.height - 1;
        final Color baseColor = Theme.of(context).scaffoldBackgroundColor;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Top-anchored full-width backdrop.
            Transform.translate(
              offset: Offset(0, panY),
              child: Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.diagonal3Values(
                  _scaleAnimation.value,
                  _scaleAnimation.value,
                  1.0,
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  width: widget.width,
                  height: widget.height,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            if (hasBottomGap) ...<Widget>[
              // Clean seam mask without blur/cut lines.
              Positioned(
                left: 0,
                right: 0,
                top: math.max(0, effectiveImageBottom - widget.height * 0.1),
                bottom: 0,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          baseColor.withValues(alpha: 0.75),
                          baseColor,
                        ],
                        stops: const <double>[0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SpotlightCircleActionButton extends StatelessWidget {
  const _SpotlightCircleActionButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 18),
        ),
      ),
    );
  }
}

class _SpotlightCircleActionShimmer extends StatelessWidget {
  const _SpotlightCircleActionShimmer();
  @override
  Widget build(BuildContext context) {
    return const ShimmerEffect(width: 38, height: 38, borderRadius: 19);
  }
}

class _SpotlightListButton extends ConsumerWidget {
  const _SpotlightListButton({required this.details, required this.isTv});
  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SpotlightCircleActionButton(
      icon: Icons.list_rounded,
      onPressed: () => showAnimatedDialog(
        context: context,
        builder: (context) => AddToListDialog(details: details, isTv: isTv),
      ),
    );
  }
}

class _SpotlightFavouriteButton extends ConsumerWidget {
  const _SpotlightFavouriteButton({required this.details, required this.isTv});
  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaType = isTv ? GlobalMediaType.tv : GlobalMediaType.movie;
    final isFav = ref.watch(
      isFavouriteProvider((id: details.id, type: mediaType)),
    );

    return _SpotlightCircleActionButton(
      icon: isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
      iconColor: isFav ? Colors.redAccent : Colors.white,
      onPressed: () async {
        final item = FavouriteItem(
          id: details.id,
          title: details.title,
          posterPath: details.posterPath,
          releaseDate: details.releaseDate,
          mediaType: mediaType,
          addedDate: DateTime.now(),
          voteAverage: details.catalogScore,
        );
        await ref.read(favouritesProvider.notifier).toggleFavourite(item);
        if (context.mounted) {
          ToastUtils.showToast(
            context,
            isFav ? 'Removed from Favourites' : 'Added to Favourites',
          );
        }
      },
    );
  }
}

class _SpotlightWatchlistButton extends ConsumerWidget {
  const _SpotlightWatchlistButton({required this.details, required this.isTv});
  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInWatchlistAsync = ref.watch(isInWatchlistProvider(details.id));

    return isInWatchlistAsync.when(
      data: (isAdded) => _SpotlightCircleActionButton(
        icon: isAdded ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
        iconColor: isAdded ? AppColors.cinemaAccent : Colors.white,
        onPressed: () async {
          final item = WatchlistItem(
            id: details.id,
            title: details.title,
            posterPath: details.posterPath,
            releaseDate: details.releaseDate,
            mediaType: isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
            addedDate: DateTime.now(),
            voteAverage: details.catalogScore,
          );
          await ref.read(watchlistProvider.notifier).toggleItem(item);
          if (context.mounted) {
            ToastUtils.showToast(
              context,
              isAdded ? 'Removed from Watchlist' : 'Added to Watchlist',
            );
          }
        },
      ),
      loading: () => const _SpotlightCircleActionShimmer(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _SpotlightWatchedButton extends ConsumerWidget {
  const _SpotlightWatchedButton({required this.details, required this.isTv});
  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaType = isTv ? GlobalMediaType.tv : GlobalMediaType.movie;
    final isWatchedAsync = ref.watch(
      isWatchedProvider((id: details.id, type: mediaType)),
    );
    final watchedItemAsync = ref.watch(
      watchedItemProvider((id: details.id, type: mediaType)),
    );

    return isWatchedAsync.when(
      data: (isWatched) => _SpotlightCircleActionButton(
        onPressed: () => showAnimatedDialog(
          context: context,
          builder: (context) => WatchedDialog(
            details: details,
            isTv: isTv,
            existingItem: watchedItemAsync.value,
          ),
        ),
        icon: isWatched
            ? Icons.check_circle_rounded
            : Icons.check_circle_outline_rounded,
        iconColor: isWatched ? AppColors.cinemaAccent : Colors.white,
      ),
      loading: () => const _SpotlightCircleActionShimmer(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _SpotlightReminderButton extends ConsumerWidget {
  const _SpotlightReminderButton({required this.details, required this.isTv});
  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<AppReminder> reminders =
        ref.watch(remindersProvider).asData?.value ?? const <AppReminder>[];
    final DateTime now = DateTime.now();
    final bool hasActiveReminder = reminders.any(
      (reminder) =>
          reminder.type == ReminderType.general &&
          reminder.mediaId == details.id &&
          reminder.isTv == isTv &&
          reminder.notifyAt.isAfter(now),
    );

    return _SpotlightCircleActionButton(
      icon: hasActiveReminder
          ? Icons.notifications_active_rounded
          : Icons.notifications_none_rounded,
      iconColor: hasActiveReminder ? const Color(0xFFFFC857) : Colors.white,
      onPressed: () => _showReminderDialog(context, ref),
    );
  }

  Future<void> _showReminderDialog(BuildContext context, WidgetRef ref) async {
    final GeneralReminderDialogResult? result =
        await showAnimatedDialog<GeneralReminderDialogResult>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const GeneralReminderDialog(),
        );

    if (result == null || !context.mounted) {
      return;
    }

    await ref
        .read(remindersProvider.notifier)
        .addReminder(
          AppReminder(
            id: buildReminderId(),
            type: ReminderType.general,
            title: details.title,
            message: result.reminderText.trim().isEmpty
                ? 'Reminder for ${details.title}'
                : result.reminderText,
            notifyAt: result.notifyAt,
            createdAt: DateTime.now(),
            mediaId: details.id,
            isTv: isTv,
          ),
        );

    if (context.mounted) {
      ToastUtils.showToast(context, 'Reminder set successfully');
    }
  }
}

class _SpotlightLoadingView extends StatefulWidget {
  const _SpotlightLoadingView({required this.accentColor, super.key});
  final Color accentColor;

  @override
  State<_SpotlightLoadingView> createState() => _SpotlightLoadingViewState();
}

class _SpotlightLoadingViewState extends State<_SpotlightLoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      // Visually center between the top preview chip and bottom metadata pane.
      alignment: const Alignment(0, -0.16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withValues(
                        alpha: 0.25 * _pulseAnimation.value,
                      ),
                      blurRadius: 36 * _pulseAnimation.value,
                      spreadRadius: 6 * _pulseAnimation.value,
                    ),
                  ],
                ),
              );
            },
          ),
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.4),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.movie_filter_rounded,
                color: widget.accentColor,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
