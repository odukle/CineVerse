import 'package:cineverse/presentation/features/home/home_scaffold.dart';
import 'package:cineverse/presentation/features/home/movies_screen.dart';
import 'package:cineverse/presentation/features/home/tv_shows_screen.dart';
import 'package:cineverse/presentation/features/watchlist/watchlist_screen.dart';
import 'package:cineverse/presentation/features/home/account_screen.dart';
import 'package:cineverse/presentation/features/movie_details/movie_details_screen.dart';
import 'package:cineverse/presentation/features/movies/explore_screen.dart';
import 'package:cineverse/presentation/features/movies/widgets/filter_screen.dart';
import 'package:cineverse/presentation/features/search/search_screen.dart';
import 'package:cineverse/presentation/features/search/widgets/global_filter_screen.dart';
import 'package:cineverse/presentation/features/movies/explore_section_screen.dart';
import 'package:cineverse/presentation/features/movies/models/explore_models.dart';
import 'package:cineverse/presentation/features/movies/what_should_i_watch_tonight_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cineverse/presentation/features/person/person_details_screen.dart';
import 'package:cineverse/presentation/features/watchlist/notes_screen.dart';
import 'package:cineverse/presentation/features/watchlist/note_details_screen.dart';
import 'package:cineverse/presentation/features/home/appearance_screen.dart';
import 'package:cineverse/presentation/features/home/watch_history_analytics_screen.dart';
import 'package:cineverse/presentation/features/home/notifications_screen.dart';
import 'package:cineverse/presentation/features/splash/lumi_splash_screen.dart';

import 'package:cineverse/presentation/features/movie_details/all_reviews_screen.dart';

import 'package:cineverse/presentation/features/movie_details/full_cast_crew_screen.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/presentation/features/movie_details/all_seasons_screen.dart';
import 'package:cineverse/presentation/features/movie_details/season_details_screen.dart';
import 'package:cineverse/presentation/features/movie_details/episode_details_screen.dart';
import 'package:cineverse/presentation/features/quotes/explore_wikiquotes_screen.dart';
import 'package:cineverse/presentation/features/movie_details/quote_share_editor_screen.dart';
import 'package:cineverse/domain/repositories/quotes_repository.dart';
import 'package:cineverse/presentation/features/movie_details/movie_awards_screen.dart';
import 'package:cineverse/presentation/features/movie_details/widgets/movie_awards_helper.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const LumiSplashScreen(),
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return HomeScaffold(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.01),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: children[navigationShell.currentIndex],
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.explore.path,
                name: AppRoute.explore.name,
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.movies.path,
                name: AppRoute.movies.name,
                builder: (context, state) => const MoviesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.tvShows.path,
                name: AppRoute.tvShows.name,
                builder: (context, state) => const TvShowsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.watchlist.path,
                name: AppRoute.watchlist.name,
                builder: (context, state) => const WatchlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.account.path,
                name: AppRoute.account.name,
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.movieDetails.path,
        name: AppRoute.movieDetails.name,
        builder: (context, state) {
          final String movieIdValue = state.pathParameters['movieId']!;
          final bool isTv = state.uri.queryParameters['isTv'] == 'true';
          final String? heroTag = state.uri.queryParameters['heroTag'];
          return MovieDetailsScreen(
            movieId: int.parse(movieIdValue),
            isTv: isTv,
            heroTag: heroTag,
          );
        },
      ),
      GoRoute(
        path: AppRoute.filter.path,
        name: AppRoute.filter.name,
        builder: (context, state) {
          final bool isTv = state.uri.queryParameters['isTv'] == 'true';
          return FilterScreen(isTv: isTv);
        },
      ),
      GoRoute(
        path: AppRoute.search.path,
        name: AppRoute.search.name,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoute.globalFilter.path,
        name: AppRoute.globalFilter.name,
        builder: (context, state) => const GlobalFilterScreen(),
      ),
      GoRoute(
        path: AppRoute.personDetails.path,
        name: AppRoute.personDetails.name,
        builder: (context, state) {
          final String personIdValue = state.pathParameters['personId']!;
          final String? heroTag = state.uri.queryParameters['heroTag'];
          return PersonDetailsScreen(
            personId: int.parse(personIdValue),
            heroTag: heroTag,
          );
        },
      ),
      GoRoute(
        path: AppRoute.notes.path,
        name: AppRoute.notes.name,
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: AppRoute.noteDetails.path,
        name: AppRoute.noteDetails.name,
        builder: (context, state) {
          final noteId = int.parse(state.pathParameters['noteId']!);
          return NoteDetailsScreen(noteId: noteId);
        },
      ),
      GoRoute(
        path: AppRoute.fullCastCrew.path,
        name: AppRoute.fullCastCrew.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return FullCastCrewScreen(
            title: extra['title'] as String,
            cast: extra['cast'] as List<MovieCredit>,
            crew: extra['crew'] as List<MovieCredit>,
          );
        },
      ),
      GoRoute(
        path: AppRoute.seasonDetails.path,
        name: AppRoute.seasonDetails.name,
        builder: (context, state) {
          final tvId = int.parse(state.pathParameters['tvId']!);
          final seasonNumber = int.parse(state.pathParameters['seasonNumber']!);
          final showTitle = state.uri.queryParameters['showTitle'] ?? 'Season';
          return SeasonDetailsScreen(
            tvId: tvId,
            seasonNumber: seasonNumber,
            showTitle: showTitle,
          );
        },
      ),
      GoRoute(
        path: AppRoute.episodeDetails.path,
        name: AppRoute.episodeDetails.name,
        builder: (context, state) {
          final tvId = int.parse(state.pathParameters['tvId']!);
          final seasonNumber = int.parse(state.pathParameters['seasonNumber']!);
          final episodeNumber = int.parse(
            state.pathParameters['episodeNumber']!,
          );
          final showTitle = state.uri.queryParameters['showTitle'] ?? 'Episode';
          return EpisodeDetailsScreen(
            tvId: tvId,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            showTitle: showTitle,
          );
        },
      ),
      GoRoute(
        path: AppRoute.allSeasons.path,
        name: AppRoute.allSeasons.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return AllSeasonsScreen(
            showTitle: extra['showTitle'] as String,
            seasons: extra['seasons'] as List<TvSeason>,
            tvId: extra['tvId'] as int,
          );
        },
      ),
      GoRoute(
        path: AppRoute.exploreSection.path,
        name: AppRoute.exploreSection.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final bool isTv = state.uri.queryParameters['isTv'] == 'true';
          return ExploreSectionScreen(
            sectionTitle: extra['sectionTitle'] as String,
            filters: extra['filters'] as List<ExploreFilterOption>,
            isTv: isTv,
          );
        },
      ),
      GoRoute(
        path: AppRoute.whatShouldIWatchTonight.path,
        name: AppRoute.whatShouldIWatchTonight.name,
        builder: (context, state) {
          final bool isTv = state.uri.queryParameters['isTv'] == 'true';
          return WhatShouldIWatchTonightScreen(isTv: isTv);
        },
      ),
      GoRoute(
        path: AppRoute.allReviews.path,
        name: AppRoute.allReviews.name,
        builder: (context, state) {
          final id = int.parse(state.uri.queryParameters['id']!);
          final isTv = state.uri.queryParameters['isTv'] == 'true';
          return AllReviewsScreen(mediaId: id, isTv: isTv);
        },
      ),
      GoRoute(
        path: AppRoute.appearance.path,
        name: AppRoute.appearance.name,
        builder: (context, state) => const AppearanceScreen(),
      ),
      GoRoute(
        path: AppRoute.watchAnalytics.path,
        name: AppRoute.watchAnalytics.name,
        builder: (context, state) => const WatchHistoryAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoute.notifications.path,
        name: AppRoute.notifications.name,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoute.exploreQuotes.path,
        name: AppRoute.exploreQuotes.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ExploreWikiquotesScreen(
            title: extra['title'] as String? ?? '',
            isTv: extra['isTv'] as bool? ?? false,
            isSeason: extra['isSeason'] as bool? ?? false,
            pageName: extra['pageName'] as String?,
            details: extra['details'] as MovieDetails?,
            seasonNumber: extra['seasonNumber'] as int?,
          );
        },
      ),
      GoRoute(
        path: AppRoute.quoteShareEditor.path,
        name: AppRoute.quoteShareEditor.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuoteShareEditorScreen(
            details: extra['details'] as MovieDetails,
            isTv: extra['isTv'] as bool? ?? false,
            initialQuote: extra['initialQuote'] as MediaQuote?,
            seasonNumber: extra['seasonNumber'] as int?,
          );
        },
      ),
      GoRoute(
        path: AppRoute.movieAwards.path,
        name: AppRoute.movieAwards.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MovieAwardsScreen(
            awards: extra['awards'] as MovieAwards,
            movieTitle: extra['movieTitle'] as String,
          );
        },
      ),
    ],
  );
});

enum AppRoute {
  splash('/splash', 'splash'),
  explore('/explore', 'explore'),
  movies('/', 'movies'),
  tvShows('/tv-shows', 'tv-shows'),
  watchlist('/watchlist', 'watchlist'),
  account('/account', 'account'),
  movieDetails('/movies/:movieId', 'movie-details'),
  filter('/filter', 'filter'),
  search('/search', 'search'),
  globalFilter('/global-filter', 'global-filter'),
  personDetails('/person/:personId', 'person-details'),
  notes('/notes', 'notes'),
  noteDetails('/notes/:noteId', 'note-details'),
  fullCastCrew('/full-cast-crew', 'full-cast-crew'),
  seasonDetails('/tv/:tvId/seasons/:seasonNumber', 'season-details'),
  episodeDetails(
    '/tv/:tvId/seasons/:seasonNumber/episodes/:episodeNumber',
    'episode-details',
  ),
  allSeasons('/tv/:tvId/seasons', 'all-seasons'),
  exploreSection('/explore-section', 'explore-section'),
  whatShouldIWatchTonight(
    '/what-should-i-watch-tonight',
    'what-should-i-watch-tonight',
  ),
  appearance('/appearance', 'appearance'),
  watchAnalytics('/watch-analytics', 'watch-analytics'),
  notifications('/notifications', 'notifications'),
  allReviews('/reviews', 'all-reviews'),
  exploreQuotes('/explore_quotes', 'explore_quotes'),
  quoteShareEditor('/quote_share_editor', 'quote_share_editor'),
  movieAwards('/movie_awards', 'movie-awards');

  const AppRoute(this.path, this.name);

  final String path;
  final String name;
}
