import 'package:cineverse/presentation/features/home/account_screen.dart';
import 'package:cineverse/presentation/features/home/home_scaffold.dart';
import 'package:cineverse/presentation/features/home/movies_screen.dart';
import 'package:cineverse/presentation/features/home/tv_shows_screen.dart';
import 'package:cineverse/presentation/features/movie_details/movie_details_screen.dart';
import 'package:cineverse/presentation/features/movies/explore_screen.dart';
import 'package:cineverse/presentation/features/movies/widgets/filter_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.explore.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeScaffold(navigationShell: navigationShell);
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
    ],
  );
});


enum AppRoute {
  explore('/explore', 'explore'),
  movies('/', 'movies'),
  tvShows('/tv-shows', 'tv-shows'),
  account('/account', 'account'),
  movieDetails('/movies/:movieId', 'movie-details'),
  filter('/filter', 'filter');

  const AppRoute(this.path, this.name);

  final String path;
  final String name;
}
