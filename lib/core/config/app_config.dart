import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  const AppConfig({
    this.tmdbApiKey = '',
    this.omdbApiKey = '',
    this.movieProxyBaseUrl = '',
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      tmdbApiKey: String.fromEnvironment('TMDB_API_KEY', defaultValue: ''),
      omdbApiKey: String.fromEnvironment('OMDB_API_KEY', defaultValue: ''),
      movieProxyBaseUrl: String.fromEnvironment(
        'MOVIE_PROXY_BASE_URL',
        defaultValue: '',
      ),
    );
  }

  final String tmdbApiKey;
  final String omdbApiKey;
  final String movieProxyBaseUrl;

  bool get hasTmdbApiKey => tmdbApiKey.trim().isNotEmpty;

  bool get hasOmdbApiKey => omdbApiKey.trim().isNotEmpty;

  bool get hasMovieProxyBaseUrl => movieProxyBaseUrl.trim().isNotEmpty;

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
