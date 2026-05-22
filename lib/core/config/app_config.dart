import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  const AppConfig({
    this.tmdbApiKey = '',
    this.omdbApiKey = '',
    this.movieProxyBaseUrl = '',
    this.openRouterApiKey = '',
    this.tonightRecommendationsApiUrl = '',
    this.watchProviderResolverApiUrl = '',
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      tmdbApiKey: String.fromEnvironment('TMDB_API_KEY'),
      omdbApiKey: String.fromEnvironment('OMDB_API_KEY'),
      movieProxyBaseUrl: String.fromEnvironment('MOVIE_PROXY_BASE_URL'),
      openRouterApiKey: String.fromEnvironment('OPENROUTER_API_KEY'),
      tonightRecommendationsApiUrl: String.fromEnvironment(
        'TONIGHT_RECOMMENDATIONS_API_URL',
        defaultValue:
            'https://us-central1-cineverse-flutter-591.cloudfunctions.net/recommendTonight',
      ),
      watchProviderResolverApiUrl: String.fromEnvironment(
        'WATCH_PROVIDER_RESOLVER_API_URL',
        defaultValue:
            'https://us-central1-cineverse-flutter-591.cloudfunctions.net/resolveProviderLink',
      ),
    );
  }

  final String tmdbApiKey;
  final String omdbApiKey;
  final String movieProxyBaseUrl;
  final String openRouterApiKey;
  final String tonightRecommendationsApiUrl;
  final String watchProviderResolverApiUrl;

  bool get hasTmdbApiKey => tmdbApiKey.trim().isNotEmpty;

  bool get hasOmdbApiKey => omdbApiKey.trim().isNotEmpty;

  bool get hasMovieProxyBaseUrl => movieProxyBaseUrl.trim().isNotEmpty;

  bool get hasOpenRouterApiKey => openRouterApiKey.trim().isNotEmpty;

  bool get hasTonightRecommendationsApiUrl =>
      tonightRecommendationsApiUrl.trim().isNotEmpty;

  bool get hasWatchProviderResolverApiUrl =>
      watchProviderResolverApiUrl.trim().isNotEmpty;

  bool get hasMovieApiAccess => hasMovieProxyBaseUrl || hasTmdbApiKey;

  String get effectiveMovieApiBaseUrl {
    if (!hasMovieProxyBaseUrl) {
      return 'https://api.themoviedb.org/3';
    }

    return movieProxyBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
