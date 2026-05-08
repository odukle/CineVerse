import 'dart:io';

import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/data/models/tmdb_movie_details_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_genre_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_watch_providers_dto.dart';
import 'package:cineverse/data/models/tmdb_movies_response_dto.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_images.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TmdbApiException implements Exception {
  const TmdbApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TmdbApiClient {
  TmdbApiClient({
    required this.client,
    required this.appConfig,
    required this.preferredRegionCode,
  });

  static const String _trendingMoviePath = '/trending/movie';
  static const int _actionGenreId = 28;
  static const int _dramaGenreId = 18;
  static const int _thrillerGenreId = 53;

  final Dio client;
  final AppConfig appConfig;
  final String preferredRegionCode;

  Future<TmdbMoviesResponseDto> fetchPopularMovies() {
    return _getMovies(
      operation: 'fetchPopularMovies',
      path: '${AppConstants.tmdbMoviePath}/popular',
      queryParameters: _pagedQueryParameters(),
    );
  }

  Future<List<TmdbMovieGenreDto>> fetchMovieGenres() async {
    return _fetchGenres(isTv: false);
  }

  Future<List<TmdbMovieGenreDto>> fetchTvGenres() async {
    return _fetchGenres(isTv: true);
  }

  Future<List<TmdbMovieGenreDto>> _fetchGenres({required bool isTv}) async {
    _assertMovieApiConfigured();

    try {
      final Response<Map<String, dynamic>> response = await client
          .get<Map<String, dynamic>>(
            isTv ? '${AppConstants.tmdbGenrePath}/tv/list' : '${AppConstants.tmdbGenrePath}/movie/list',
            queryParameters: _detailQueryParameters(),
          );
      final Map<String, dynamic>? payload = response.data;
      final List<dynamic>? genres = payload?['genres'] as List<dynamic>?;

      if (genres == null) {
        throw const TmdbApiException('TMDb returned an empty genre payload.');
      }

      return genres
          .whereType<Map<String, dynamic>>()
          .map(TmdbMovieGenreDto.fromJson)
          .toList(growable: false);
    } on DioException catch (error, stackTrace) {
      _logFailure(isTv ? 'fetchTvGenres' : 'fetchMovieGenres', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  Future<TmdbMoviesResponseDto> fetchMoviesForGenre(
    int genreId, {
    int page = 1,
  }) {
    return _getMovies(
      operation: 'fetchMoviesForGenre($genreId)',
      path: AppConstants.tmdbDiscoverMoviePath,
      queryParameters: <String, dynamic>{
        ..._pagedQueryParameters(page: page),
        'include_adult': false,
        'include_video': false,
        'sort_by': 'popularity.desc',
        'with_genres': genreId,
        'vote_count.gte': 100,
      },
    );
  }

  Future<TmdbMoviesResponseDto> fetchMoviesForSection(
    MovieSection section, {
    int page = 1,
  }) {
    final ({String path, Map<String, dynamic> queryParameters}) request =
        _requestForSection(section, page: page);

    return _getMovies(
      operation: 'fetchMoviesForSection($section)',
      path: request.path,
      queryParameters: request.queryParameters,
    );
  }

  Future<TmdbMoviesResponseDto> discoverMedia({
    required bool isTv,
    required MediaFilter filter,
    int page = 1,
  }) {
    final Map<String, dynamic> queryParams = <String, dynamic>{
      ..._pagedQueryParameters(page: page),
      'include_adult': false,
      'sort_by': filter.sortByValue,
      'vote_average.gte': filter.userScore.start,
      'vote_average.lte': filter.userScore.end,
      'vote_count.gte': filter.includeNotRated ? 0 : filter.minUserVotes,
      'with_runtime.gte': filter.runtime.start.toInt(),
      'with_runtime.lte': filter.runtime.end.toInt(),
    };

    if (filter.genres.isNotEmpty) {
      queryParams['with_genres'] = filter.genres.join(',');
    }

    if (filter.availabilities.isNotEmpty) {
      queryParams['with_watch_monetization_types'] =
          filter.availabilities.join('|');
      queryParams['watch_region'] = preferredRegionCode;
    }

    if (isTv) {
      if (filter.releaseDateFrom != null) {
        queryParams['first_air_date.gte'] =
            filter.releaseDateFrom!.toIso8601String().split('T')[0];
      }
      if (filter.releaseDateTo != null) {
        queryParams['first_air_date.lte'] =
            filter.releaseDateTo!.toIso8601String().split('T')[0];
      }
    } else {
      if (filter.releaseDateFrom != null) {
        queryParams['primary_release_date.gte'] =
            filter.releaseDateFrom!.toIso8601String().split('T')[0];
      }
      if (filter.releaseDateTo != null) {
        queryParams['primary_release_date.lte'] =
            filter.releaseDateTo!.toIso8601String().split('T')[0];
      }
      if (filter.releaseTypes.isNotEmpty) {
        queryParams['with_release_type'] = filter.releaseTypes.join('|');
      }
    }

    return _getMovies(
      operation: 'discoverMedia(isTv: $isTv)',
      path: isTv ? AppConstants.tmdbDiscoverTvPath : AppConstants.tmdbDiscoverMoviePath,
      queryParameters: queryParams,
    );
  }

  Future<List<MovieRecommendation>> fetchMovieRecommendations(
    int movieId, {
    int page = 1,
    bool isTv = false,
  }) async {
    _assertMovieApiConfigured();

    try {
      return await _fetchMovieRecommendations(movieId, page: page, isTv: isTv);
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchMovieRecommendations($movieId)', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  Future<TmdbMovieDetailsDto> fetchMovieDetails(
    int movieId, {
    bool isTv = false,
  }) async {
    _assertMovieApiConfigured();

    try {
      return await _fetchMovieDetails(movieId, isTv: isTv);
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchMovieDetails', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  Future<TmdbMovieDetailsDto> _fetchMovieDetails(
    int mediaId, {
    required bool isTv,
  }) async {
    final String path = isTv
        ? '${AppConstants.tmdbTvPath}/$mediaId'
        : '${AppConstants.tmdbMoviePath}/$mediaId';
    final String appendToResponse = isTv
        ? 'credits,content_ratings,external_ids,recommendations,watch/providers'
        : 'credits,release_dates,external_ids,recommendations,watch/providers';

    final Response<Map<String, dynamic>> response = await client
        .get<Map<String, dynamic>>(
          path,
          queryParameters: <String, dynamic>{
            ..._detailQueryParameters(),
            'append_to_response': appendToResponse,
          },
        );
    final Map<String, dynamic>? payload = response.data;

    if (payload == null) {
      throw const TmdbApiException(
        'TMDb returned an empty movie details payload.',
      );
    }

    TmdbMovieDetailsDto details = TmdbMovieDetailsDto.fromJson(
      payload,
      preferredRegionCode: preferredRegionCode,
      isTv: isTv,
    );

    final MovieWatchAvailability? watchAvailability =
        details.watchAvailability ??
        await _fetchMovieWatchAvailability(mediaId, isTv: isTv);

    if (watchAvailability != null) {
      details = details.copyWith(watchAvailability: watchAvailability);
    }

    return details;
  }

  Future<MediaImages> fetchMediaImages(
    int mediaId, {
    required bool isTv,
  }) async {
    _assertMovieApiConfigured();

    final String path =
        isTv
            ? '${AppConstants.tmdbTvPath}/$mediaId/images'
            : '${AppConstants.tmdbMoviePath}/$mediaId/images';

    try {
      final Response<Map<String, dynamic>> response = await client.get<
        Map<String, dynamic>
      >(path, queryParameters: _authQueryParameters());

      final Map<String, dynamic>? payload = response.data;
      final List<dynamic> postersPayload =
          (payload?['posters'] as List<dynamic>?) ?? <dynamic>[];
      final List<dynamic> backdropsPayload =
          (payload?['backdrops'] as List<dynamic>?) ?? <dynamic>[];
      final List<dynamic> logosPayload =
          (payload?['logos'] as List<dynamic>?) ?? <dynamic>[];

      final List<String> posters =
          postersPayload
              .whereType<Map<String, dynamic>>()
              .take(10)
              .map(
                (item) => _normalizeImagePath(
                  item['file_path'] as String?,
                  size: 'w780',
                ),
              )
              .whereType<String>()
              .toList(growable: false);

      final List<String> backdrops =
          backdropsPayload
              .whereType<Map<String, dynamic>>()
              .take(10)
              .map(
                (item) => _normalizeImagePath(
                  item['file_path'] as String?,
                  size: 'w1280',
                ),
              )
              .whereType<String>()
              .toList(growable: false);

      final List<String> logos =
          logosPayload
              .whereType<Map<String, dynamic>>()
              // Prioritize English logos if available
              .sortedBy((item) => item['iso_639_1'] == 'en' ? 0 : 1)
              .take(5)
              .map(
                (item) => _normalizeImagePath(
                  item['file_path'] as String?,
                  size: 'w500',
                ),
              )
              .whereType<String>()
              .toList(growable: false);

      return MediaImages(posters: posters, backdrops: backdrops, logos: logos);
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchMediaImages($mediaId)', error, stackTrace);
      return MediaImages.empty;
    }
  }

  Future<List<MovieRecommendation>> _fetchMovieRecommendations(
    int mediaId, {
    required int page,
    required bool isTv,
  }) async {
    final String path = isTv
        ? '${AppConstants.tmdbTvPath}/$mediaId/recommendations'
        : '${AppConstants.tmdbMoviePath}/$mediaId/recommendations';

    final Response<Map<String, dynamic>> response = await client
        .get<Map<String, dynamic>>(
          path,
          queryParameters: _pagedQueryParameters(page: page),
        );
    final Map<String, dynamic>? payload = response.data;
    final List<dynamic> results =
        (payload?['results'] as List<dynamic>?) ?? <dynamic>[];

    return results
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => MovieRecommendation(
            id: (item['id'] as num?)?.toInt() ?? 0,
            title:
                ((item['title'] as String?) ?? (item['name'] as String?) ?? '')
                    .trim(),
            posterPath: _normalizeImagePath(
              item['poster_path'] as String?,
              size: 'w342',
            ),
            releaseDate:
                (item['release_date'] as String?)?.trim() ??
                (item['first_air_date'] as String?)?.trim(),
          ),
        )
        .where((item) => item.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<MovieWatchAvailability?> _fetchMovieWatchAvailability(
    int mediaId, {
    required bool isTv,
  }) async {
    final String path = isTv
        ? '${AppConstants.tmdbTvPath}/$mediaId/watch/providers'
        : '${AppConstants.tmdbMoviePath}/$mediaId/watch/providers';

    try {
      final Response<Map<String, dynamic>> response = await client
          .get<Map<String, dynamic>>(
            path,
            queryParameters: _authQueryParameters(),
          );
      final Map<String, dynamic>? payload = response.data;
      if (payload == null) {
        return null;
      }

      return TmdbMovieWatchProvidersDto.fromJson(
        payload,
        preferredRegionCode: preferredRegionCode,
      ).toDomain();
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchMovieWatchAvailability', error, stackTrace);
      return null;
    }
  }

  Future<TmdbMoviesResponseDto> _getMovies({
    required String operation,
    required String path,
    required Map<String, dynamic> queryParameters,
  }) async {
    _assertMovieApiConfigured();

    try {
      final Response<Map<String, dynamic>> response = await client
          .get<Map<String, dynamic>>(path, queryParameters: queryParameters);
      final Map<String, dynamic>? payload = response.data;

      if (payload == null) {
        throw const TmdbApiException('TMDb returned an empty payload.');
      }

      return TmdbMoviesResponseDto.fromJson(payload);
    } on DioException catch (error, stackTrace) {
      _logFailure(operation, error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  void _assertMovieApiConfigured() {
    if (!appConfig.hasMovieApiAccess) {
      throw StateError(
        'Neither MOVIE_PROXY_BASE_URL nor TMDB_API_KEY is configured.',
      );
    }
  }

  Map<String, dynamic> _pagedQueryParameters({int page = 1}) {
    return <String, dynamic>{..._queryParametersWithRegion(), 'page': page};
  }

  Map<String, dynamic> _detailQueryParameters() {
    return <String, dynamic>{
      ..._authQueryParameters(),
      'language': AppConstants.tmdbDefaultLanguage,
    };
  }

  Map<String, dynamic> _queryParametersWithRegion() {
    return <String, dynamic>{
      ..._detailQueryParameters(),
      'region': preferredRegionCode,
    };
  }

  Map<String, dynamic> _authQueryParameters() {
    return <String, dynamic>{
      if (!appConfig.hasMovieProxyBaseUrl) 'api_key': appConfig.tmdbApiKey,
    };
  }

  ({String path, Map<String, dynamic> queryParameters}) _requestForSection(
    MovieSection section, {
    int page = 1,
  }) {
    return switch (section) {
      MovieSection.discover => (
        path: AppConstants.tmdbDiscoverMoviePath,
        queryParameters: <String, dynamic>{
          ..._pagedQueryParameters(page: page),
          'include_adult': false,
          'include_video': false,
          'sort_by': 'popularity.desc',
        },
      ),
      MovieSection.trendingDay => (
        path: '$_trendingMoviePath/day',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'page': page,
        },
      ),
      MovieSection.trendingWeek => (
        path: '$_trendingMoviePath/week',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'page': page,
        },
      ),
      MovieSection.popular => (
        path: '${AppConstants.tmdbMoviePath}/popular',
        queryParameters: _pagedQueryParameters(page: page),
      ),
      MovieSection.topRated => (
        path: '${AppConstants.tmdbMoviePath}/top_rated',
        queryParameters: _pagedQueryParameters(page: page),
      ),
      MovieSection.nowPlaying => (
        path: '${AppConstants.tmdbMoviePath}/now_playing',
        queryParameters: _pagedQueryParameters(page: page),
      ),
      MovieSection.upcoming => (
        path: '${AppConstants.tmdbMoviePath}/upcoming',
        queryParameters: _pagedQueryParameters(page: page),
      ),
      MovieSection.tvPopular => (
        path: '${AppConstants.tmdbTvPath}/popular',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'page': page,
        },
      ),
      MovieSection.tvTopRated => (
        path: '${AppConstants.tmdbTvPath}/top_rated',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'page': page,
        },
      ),
      MovieSection.tvOnTheAir => (
        path: '${AppConstants.tmdbTvPath}/on_the_air',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'page': page,
        },
      ),
      MovieSection.tvAiringToday => (
        path: '${AppConstants.tmdbTvPath}/airing_today',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'page': page,
        },
      ),
      MovieSection.tvDiscover => (
        path: AppConstants.tmdbDiscoverTvPath,
        queryParameters: <String, dynamic>{
          ..._pagedQueryParameters(page: page),
          'include_adult': false,
          'sort_by': 'popularity.desc',
        },
      ),
      MovieSection.action => _genreRequest(_actionGenreId, page: page),
      MovieSection.drama => _genreRequest(_dramaGenreId, page: page),
      MovieSection.thriller => _genreRequest(_thrillerGenreId, page: page),
    };
  }

  ({String path, Map<String, dynamic> queryParameters}) _genreRequest(
    int genreId, {
    int page = 1,
  }) {
    return (
      path: AppConstants.tmdbDiscoverMoviePath,
      queryParameters: <String, dynamic>{
        ..._pagedQueryParameters(page: page),
        'include_adult': false,
        'include_video': false,
        'sort_by': 'popularity.desc',
        'with_genres': genreId,
        'vote_count.gte': 100,
      },
    );
  }

  String _messageForDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'TMDb request timed out. Check your connection and try again.';
    }

    if (error.type == DioExceptionType.badResponse) {
      final int? statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        if (appConfig.hasMovieProxyBaseUrl) {
          return 'Movie proxy authentication failed. Check the Worker deployment and TMDB_API_KEY secret.';
        }
        return 'TMDb authentication failed. Check TMDB_API_KEY.';
      }
      if (statusCode == 404) {
        return 'The requested movie or TV title could not be found.';
      }

      return '${appConfig.hasMovieProxyBaseUrl ? 'Movie proxy' : 'TMDb'} returned an unexpected response (${statusCode ?? 'unknown'}).';
    }

    if (error.type == DioExceptionType.connectionError) {
      final Object? rootError = error.error;
      if (rootError is SocketException) {
        if (appConfig.hasMovieProxyBaseUrl) {
          return 'Could not connect to the movie proxy. Check proxy DNS, deployment, or network access.';
        }
        return 'Could not connect to TMDb. Check internet or DNS access.';
      }
    }

    return 'Unexpected ${appConfig.hasMovieProxyBaseUrl ? 'movie proxy' : 'TMDb'} error: ${error.message ?? 'unknown error'}';
  }

  void _logFailure(
    String operation,
    DioException error,
    StackTrace stackTrace,
  ) {
    debugPrint('[TMDb][$operation] ${error.type}: ${error.message}');
    if (error.response != null) {
      debugPrint(
        '[TMDb][$operation] status=${error.response?.statusCode} data=${error.response?.data}',
      );
    }
    if (error.error != null) {
      debugPrint('[TMDb][$operation] root=${error.error}');
    }
    debugPrintStack(stackTrace: stackTrace);
  }

  String? _normalizeImagePath(String? rawImagePath, {required String size}) {
    if (rawImagePath == null || rawImagePath.isEmpty) return null;
    if (rawImagePath.startsWith('http://') ||
        rawImagePath.startsWith('https://')) {
      return rawImagePath;
    }
    return '${AppConstants.tmdbImageBaseUrl}/$size$rawImagePath';
  }
}
