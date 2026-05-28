import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  const AppConfig({
    this.movieProxyBaseUrl = 'https://cineverse-tmdb-proxy.sodukle.workers.dev',
    this.tonightRecommendationsApiUrl = '',
    this.watchProviderResolverApiUrl = '',
    this.movieAwardsResolverApiUrl = '',
    this.omdbResolverApiUrl = '',
    this.showTonightDiagnostics = false,
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      movieProxyBaseUrl: String.fromEnvironment(
        'MOVIE_PROXY_BASE_URL',
        defaultValue: 'https://cineverse-tmdb-proxy.sodukle.workers.dev',
      ),
      tonightRecommendationsApiUrl: String.fromEnvironment(
        'TONIGHT_RECOMMENDATIONS_API_URL',
        defaultValue:
            'https://us-east4-cineverse-flutter-591.cloudfunctions.net/recommendTonight',
      ),
      watchProviderResolverApiUrl: String.fromEnvironment(
        'WATCH_PROVIDER_RESOLVER_API_URL',
        defaultValue:
            'https://us-central1-cineverse-flutter-591.cloudfunctions.net/resolveProviderLink',
      ),
      movieAwardsResolverApiUrl: String.fromEnvironment(
        'MOVIE_AWARDS_RESOLVER_API_URL',
        defaultValue:
            'https://us-central1-cineverse-flutter-591.cloudfunctions.net/resolveMovieAwards',
      ),
      omdbResolverApiUrl: String.fromEnvironment(
        'OMDB_RESOLVER_API_URL',
        defaultValue:
            'https://us-east4-cineverse-flutter-591.cloudfunctions.net/resolveOmdbTitleDetails',
      ),
      showTonightDiagnostics: bool.fromEnvironment(
        'TONIGHT_SHOW_DIAGNOSTICS',
        defaultValue: false,
      ),
    );
  }

  final String movieProxyBaseUrl;
  final String tonightRecommendationsApiUrl;
  final String watchProviderResolverApiUrl;
  final String movieAwardsResolverApiUrl;
  final String omdbResolverApiUrl;
  final bool showTonightDiagnostics;

  bool get hasMovieProxyBaseUrl => movieProxyBaseUrl.trim().isNotEmpty;

  bool get hasTonightRecommendationsApiUrl =>
      tonightRecommendationsApiUrl.trim().isNotEmpty;

  bool get hasWatchProviderResolverApiUrl =>
      watchProviderResolverApiUrl.trim().isNotEmpty;

  bool get hasMovieAwardsResolverApiUrl =>
      movieAwardsResolverApiUrl.trim().isNotEmpty;

  bool get hasOmdbResolverApiUrl => omdbResolverApiUrl.trim().isNotEmpty;

  bool get hasMovieApiAccess => hasMovieProxyBaseUrl;

  String get effectiveMovieApiBaseUrl {
    return movieProxyBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
