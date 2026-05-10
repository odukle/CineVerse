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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cineverse/presentation/features/person/person_details_screen.dart';
import 'package:cineverse/presentation/features/watchlist/notes_screen.dart';
import 'package:cineverse/presentation/features/watchlist/note_details_screen.dart';
import 'package:cineverse/presentation/features/movie_details/full_cast_crew_screen.dart';
import 'package:cineverse/domain/entities/movie_details.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.explore.path,
    routes: [
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
    ],
  );
});

enum AppRoute {
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
  fullCastCrew('/full-cast-crew', 'full-cast-crew');

  const AppRoute(this.path, this.name);

  final String path;
  final String name;
}
