import 'dart:io';

import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/data/models/tmdb_movie_details_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_genre_dto.dart';
import 'package:cineverse/data/models/tmdb_tv_details_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_watch_providers_dto.dart';
import 'package:cineverse/data/models/tmdb_movies_response_dto.dart';
import 'package:cineverse/data/models/tmdb_person_details_dto.dart';
import 'package:cineverse/data/models/tmdb_review_dto.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_images.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/data/models/tmdb_search_collection_dto.dart';
import 'package:cineverse/data/models/tmdb_search_keyword_dto.dart';
import 'package:cineverse/data/models/tmdb_search_company_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_collection_dto.dart';
import 'package:cineverse/data/models/tmdb_company_details_dto.dart';
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
            isTv
                ? '${AppConstants.tmdbGenrePath}/tv/list'
                : '${AppConstants.tmdbGenrePath}/movie/list',
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
      _logFailure(
        isTv ? 'fetchTvGenres' : 'fetchMovieGenres',
        error,
        stackTrace,
      );
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

  Future<TmdbMoviesResponseDto> fetchTvShowsForGenre(
    int genreId, {
    int page = 1,
  }) {
    return _getMovies(
      operation: 'fetchTvShowsForGenre($genreId)',
      path: AppConstants.tmdbDiscoverTvPath,
      queryParameters: <String, dynamic>{
        ..._pagedQueryParameters(page: page),
        'include_adult': false,
        'sort_by': 'popularity.desc',
        'with_genres': genreId,
        'vote_count.gte': 100,
      },
    );
  }

  Future<TmdbMoviesResponseDto> searchMovies(String query, {int page = 1}) {
    return _getMovies(
      operation: 'searchMovies($query)',
      path: AppConstants.tmdbDiscoverMoviePath,
      queryParameters: <String, dynamic>{
        ..._pagedQueryParameters(page: page),
        'with_text_query': query,
        'include_adult': false,
        'sort_by': 'popularity.desc',
      },
    );
  }

  Future<TmdbMoviesResponseDto> searchTvShows(String query, {int page = 1}) {
    return _getMovies(
      operation: 'searchTvShows($query)',
      path: AppConstants.tmdbDiscoverTvPath,
      queryParameters: <String, dynamic>{
        ..._pagedQueryParameters(page: page),
        'with_text_query': query,
        'include_adult': false,
        'sort_by': 'popularity.desc',
      },
    );
  }

  Future<TmdbMoviesResponseDto> searchMulti(String query, {int page = 1}) {
    return _getMovies(
      operation: 'searchMulti($query)',
      path: '/search/multi',
      queryParameters: <String, dynamic>{
        ..._pagedQueryParameters(page: page),
        'query': query,
        'include_adult': false,
      },
    );
  }

  Future<TmdbMoviesResponseDto> searchPersons(String query, {int page = 1}) {
    return _getMovies(
      operation: 'searchPersons($query)',
      path: '/search/person',
      queryParameters: <String, dynamic>{
        ..._pagedQueryParameters(page: page),
        'query': query,
        'include_adult': false,
      },
    );
  }

  Future<TmdbMoviesResponseDto> fetchMoviesForSection(
    MovieSection section, {
    int page = 1,
    MediaFilter? filter,
  }) {
    final ({String path, Map<String, dynamic> queryParameters}) request =
        _requestForSection(section, page: page, filter: filter);

    return _getMovies(
      operation: 'fetchMoviesForSection($section)',
      path: request.path,
      queryParameters: request.queryParameters,
    );
  }

  Future<TmdbMoviesResponseDto> discoverMedia({
    required bool isTv,
    required MediaFilter filter,
    String? query,
    int page = 1,
    String? withKeywords,
    String? withCompanies,
  }) async {
    if (filter.personIds.isNotEmpty) {
      return _discoverWithPersonCredits(
        isTv: isTv,
        filter: filter,
        query: query,
        page: page,
      );
    }

    final Map<String, dynamic> queryParams = <String, dynamic>{
      ..._pagedQueryParameters(page: page),
      'include_adult': false,
      'sort_by': isTv
          ? filter.sortByValue.replaceAll(
              'primary_release_date',
              'first_air_date',
            )
          : filter.sortByValue,
      'vote_average.gte': filter.userScore.start,
      'vote_average.lte': filter.userScore.end,
      'vote_count.gte': filter.minUserVotes,
      'with_runtime.gte': filter.runtime.start.toInt(),
      'with_runtime.lte': filter.runtime.end.toInt(),
    };

    if (query != null && query.isNotEmpty) {
      queryParams['with_text_query'] = query;
    }

    if (withKeywords != null && withKeywords.isNotEmpty) {
      queryParams['with_keywords'] = withKeywords;
    }

    if (withCompanies != null && withCompanies.isNotEmpty) {
      queryParams['with_companies'] = withCompanies;
    }

    if (filter.originalLanguageCode != null &&
        filter.originalLanguageCode!.isNotEmpty) {
      queryParams['with_original_language'] = filter.originalLanguageCode;
    }

    if (filter.mood != null) {
      final mood = filter.mood!;

      final allResults = <TmdbMovieDto>[];
      final seenIds = <int>{};

      // Strict Keyword-based Discovery (No fallback to recommendations)
      // This ensures 100% mood purity and prevents blockbuster leakage
      if (mood.keywordIds.isNotEmpty) {
        final response = await _getMovies(
          operation: 'moodKeywordDiscover',
          path: isTv
              ? AppConstants.tmdbDiscoverTvPath
              : AppConstants.tmdbDiscoverMoviePath,
          queryParameters: <String, dynamic>{
            ...queryParams,
            'with_keywords': mood.keywordIds.join(
              '|',
            ), // OR relationship for keywords
          },
        );

        for (final movie in response.movies) {
          if (seenIds.add(movie.id)) {
            allResults.add(movie);
          }
        }
      }

      // Ensure consistent sorting
      allResults.sort((a, b) => b.popularity.compareTo(a.popularity));

      return TmdbMoviesResponseDto(movies: allResults);
    }

    if (filter.genres.isNotEmpty) {
      queryParams['with_genres'] = filter.genres.join('|');
    }

    if (filter.availabilities.isNotEmpty) {
      queryParams['with_watch_monetization_types'] = filter.availabilities.join(
        '|',
      );
      queryParams['watch_region'] = preferredRegionCode;
    }

    if (isTv) {
      if (filter.releaseDateFrom != null) {
        queryParams['first_air_date.gte'] = filter.releaseDateFrom!
            .toIso8601String()
            .split('T')[0];
      }
      if (filter.releaseDateTo != null) {
        queryParams['first_air_date.lte'] = filter.releaseDateTo!
            .toIso8601String()
            .split('T')[0];
      }
    } else {
      if (filter.releaseDateFrom != null) {
        queryParams['primary_release_date.gte'] = filter.releaseDateFrom!
            .toIso8601String()
            .split('T')[0];
      }
      if (filter.releaseDateTo != null) {
        queryParams['primary_release_date.lte'] = filter.releaseDateTo!
            .toIso8601String()
            .split('T')[0];
      }
      if (filter.releaseTypes.isNotEmpty) {
        queryParams['with_release_type'] = filter.releaseTypes.join('|');
      }
    }

    if (filter.personIds.isNotEmpty) {
      if (isTv) {
        // TV discovery doesn't support with_people, using with_cast as the closest match
        queryParams['with_cast'] = filter.personIds.join(',');
      } else {
        queryParams['with_people'] = filter.personIds.join(',');
      }
    }

    return _getMovies(
      operation: 'discoverMedia(isTv: $isTv)',
      path: isTv
          ? AppConstants.tmdbDiscoverTvPath
          : AppConstants.tmdbDiscoverMoviePath,
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
        ? 'aggregate_credits,content_ratings,external_ids,recommendations,watch/providers,videos,keywords'
        : 'credits,release_dates,external_ids,recommendations,watch/providers,videos,keywords';

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

    final String path = isTv
        ? '${AppConstants.tmdbTvPath}/$mediaId/images'
        : '${AppConstants.tmdbMoviePath}/$mediaId/images';

    try {
      final Response<Map<String, dynamic>> response = await client
          .get<Map<String, dynamic>>(
            path,
            queryParameters: _authQueryParameters(),
          );

      final Map<String, dynamic>? payload = response.data;
      return _parseMediaImages(payload);
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchMediaImages($mediaId)', error, stackTrace);
      return MediaImages.empty;
    }
  }

  Future<List<String>> fetchMediaTaglines(
    int mediaId, {
    required bool isTv,
  }) async {
    _assertMovieApiConfigured();

    final String path = isTv
        ? '${AppConstants.tmdbTvPath}/$mediaId/translations'
        : '${AppConstants.tmdbMoviePath}/$mediaId/translations';

    try {
      final Response<Map<String, dynamic>> response = await client
          .get<Map<String, dynamic>>(
            path,
            queryParameters: _authQueryParameters(),
          );

      final Map<String, dynamic>? payload = response.data;
      final List<dynamic> translations =
          (payload?['translations'] as List<dynamic>?) ?? <dynamic>[];
      final Set<String> unique = <String>{};
      final List<String> ordered = <String>[];

      for (final dynamic entry in translations) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        final String languageCode = (entry['iso_639_1'] as String? ?? '')
            .toLowerCase();
        if (languageCode != 'en') {
          continue;
        }
        final Map<String, dynamic> data =
            (entry['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final String tagline = (data['tagline'] as String? ?? '').trim();
        if (tagline.isEmpty) {
          continue;
        }
        if (unique.add(tagline.toLowerCase())) {
          ordered.add(tagline);
        }
      }

      return ordered;
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchMediaTaglines($mediaId)', error, stackTrace);
      return const <String>[];
    }
  }

  MediaImages _parseMediaImages(Map<String, dynamic>? payload) {
    final List<dynamic> postersPayload =
        (payload?['posters'] as List<dynamic>?) ?? <dynamic>[];
    final List<dynamic> backdropsPayload =
        (payload?['backdrops'] as List<dynamic>?) ?? <dynamic>[];
    final List<dynamic> logosPayload =
        (payload?['logos'] as List<dynamic>?) ?? <dynamic>[];

    final List<String> posters = postersPayload
        .whereType<Map<String, dynamic>>()
        .take(10)
        .map(
          (item) =>
              _normalizeImagePath(item['file_path'] as String?, size: 'w780'),
        )
        .whereType<String>()
        .toList(growable: false);

    final List<String> backdrops = backdropsPayload
        .whereType<Map<String, dynamic>>()
        .take(10)
        .map(
          (item) =>
              _normalizeImagePath(item['file_path'] as String?, size: 'w1280'),
        )
        .whereType<String>()
        .toList(growable: false);

    final List<String> logos = logosPayload
        .whereType<Map<String, dynamic>>()
        .sortedBy((item) {
          final String? path = item['file_path'] as String?;
          final bool isSvg = path?.toLowerCase().endsWith('.svg') ?? false;
          final bool isEn = item['iso_639_1'] == 'en';

          // Priority: SVG English > SVG Other > PNG English > PNG Other
          if (isSvg && isEn) return 0;
          if (isSvg) return 1;
          if (isEn) return 2;
          return 3;
        })
        .take(5)
        .map((item) {
          final String? path = item['file_path'] as String?;
          final bool isSvg = path?.toLowerCase().endsWith('.svg') ?? false;
          return _normalizeImagePath(path, size: isSvg ? 'original' : 'w500');
        })
        .whereType<String>()
        .toList(growable: false);

    return MediaImages(posters: posters, backdrops: backdrops, logos: logos);
  }

  Future<MediaImages> fetchTvSeasonImages(int tvId, int seasonNumber) async {
    _assertMovieApiConfigured();

    try {
      final response = await client.get<Map<String, dynamic>>(
        '/tv/$tvId/season/$seasonNumber/images',
        queryParameters: _authQueryParameters(),
      );

      final Map<String, dynamic>? payload = response.data;
      return _parseMediaImages(payload);
    } on DioException catch (error, stackTrace) {
      _logFailure(
        'fetchTvSeasonImages($tvId, $seasonNumber)',
        error,
        stackTrace,
      );
      return MediaImages.empty;
    }
  }

  Future<MediaImages> fetchPersonImages(int personId) async {
    _assertMovieApiConfigured();

    try {
      final Response<Map<String, dynamic>> response = await client
          .get<Map<String, dynamic>>(
            '/person/$personId/images',
            queryParameters: _authQueryParameters(),
          );

      final Map<String, dynamic>? payload = response.data;
      final List<dynamic> profilesPayload =
          (payload?['profiles'] as List<dynamic>?) ?? <dynamic>[];

      final List<String> profileImages = profilesPayload
          .whereType<Map<String, dynamic>>()
          .map(
            (item) =>
                _normalizeImagePath(item['file_path'] as String?, size: 'h632'),
          )
          .whereType<String>()
          .toList(growable: false);

      List<String> taggedImages = const <String>[];
      try {
        final Response<Map<String, dynamic>> taggedResponse = await client
            .get<Map<String, dynamic>>(
              '/person/$personId/tagged_images',
              queryParameters: <String, dynamic>{
                ..._detailQueryParameters(),
                'page': 1,
              },
            );
        final Map<String, dynamic>? taggedPayload = taggedResponse.data;
        final List<dynamic> taggedResultsPayload =
            (taggedPayload?['results'] as List<dynamic>?) ?? <dynamic>[];
        taggedImages = taggedResultsPayload
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => _normalizeImagePath(
                item['file_path'] as String?,
                size: 'h632',
              ),
            )
            .whereType<String>()
            .toList(growable: false);
      } on DioException catch (error, stackTrace) {
        _logFailure('fetchPersonTaggedImages($personId)', error, stackTrace);
      }

      final List<String> dedupedProfiles = profileImages
          .toSet()
          .take(30)
          .toList(growable: false);
      final List<String> dedupedTagged = taggedImages
          .where((image) => !dedupedProfiles.contains(image))
          .toSet()
          .take(30)
          .toList(growable: false);

      return MediaImages(
        posters: dedupedProfiles,
        backdrops: const [],
        logos: const [],
        profiles: dedupedProfiles,
        taggedImages: dedupedTagged,
      );
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchPersonImages($personId)', error, stackTrace);
      return MediaImages.empty;
    }
  }

  Future<List<TmdbReviewDto>> fetchMediaReviews(
    int mediaId, {
    required bool isTv,
    int page = 1,
  }) async {
    _assertMovieApiConfigured();

    final String path = isTv
        ? '${AppConstants.tmdbTvPath}/$mediaId/reviews'
        : '${AppConstants.tmdbMoviePath}/$mediaId/reviews';

    try {
      final Response<Map<String, dynamic>> response = await client
          .get<Map<String, dynamic>>(
            path,
            queryParameters: _pagedQueryParameters(page: page),
          );
      final Map<String, dynamic>? payload = response.data;
      if (payload == null) return const [];

      return TmdbReviewsResponseDto.fromJson(payload).reviews.map((dto) {
        return dto.copyWith(
          authorAvatarPath: _normalizeImagePath(
            dto.authorAvatarPath,
            size: 'w185',
          ),
        );
      }).toList();
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchMediaReviews($mediaId)', error, stackTrace);
      return const [];
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
            voteAverage: (item['vote_average'] as num?)?.toDouble(),
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
      throw StateError('MOVIE_PROXY_BASE_URL is not configured.');
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
    return const <String, dynamic>{};
  }

  ({String path, Map<String, dynamic> queryParameters}) _requestForSection(
    MovieSection section, {
    int page = 1,
    MediaFilter? filter,
  }) {
    final Map<String, dynamic> pagedParams = _pagedQueryParameters(page: page);

    // Apply sort if filter is provided
    if (filter != null) {
      final bool isTv = section.name.startsWith('tv');
      pagedParams['sort_by'] = isTv
          ? filter.sortByValue.replaceAll(
              'primary_release_date',
              'first_air_date',
            )
          : filter.sortByValue;

      // Special handling for discover endpoints
      if (section == MovieSection.discover ||
          section == MovieSection.tvDiscover) {
        return (
          path: isTv
              ? AppConstants.tmdbDiscoverTvPath
              : AppConstants.tmdbDiscoverMoviePath,
          queryParameters: <String, dynamic>{
            ...pagedParams,
            'include_adult': false,
            if (!isTv) 'include_video': false,
          },
        );
      }
    }

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
      MovieSection.tvTrendingDay => (
        path: '/trending/tv/day',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'page': page,
        },
      ),
      MovieSection.tvTrendingWeek => (
        path: '/trending/tv/week',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'page': page,
        },
      ),
      MovieSection.personTrendingDay => (
        path: '/person/popular',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'page': page,
        },
      ),
      MovieSection.personTrendingWeek => (
        path: '/person/popular',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'page': page,
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
        return 'Movie proxy authentication failed. Check Worker deployment and secret configuration.';
      }
      if (statusCode == 404) {
        return 'The requested movie or TV title could not be found.';
      }

      return 'Movie proxy returned an unexpected response (${statusCode ?? 'unknown'}).';
    }

    if (error.type == DioExceptionType.connectionError) {
      final Object? rootError = error.error;
      if (rootError is SocketException) {
        if (appConfig.hasMovieProxyBaseUrl) {
          return 'Could not connect to the movie proxy. Check proxy DNS, deployment, or network access.';
        }
      }
    }

    return 'Unexpected movie proxy error: ${error.message ?? 'unknown error'}';
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

  Future<TmdbPersonDetailsDto> fetchPersonDetails(int personId) async {
    _assertMovieApiConfigured();
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/person/$personId',
        queryParameters: <String, dynamic>{
          ..._detailQueryParameters(),
          'append_to_response': 'external_ids',
        },
      );
      return TmdbPersonDetailsDto.fromJson(response.data!);
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchPersonDetails', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  Future<TmdbPersonCombinedCreditsDto> fetchPersonCombinedCredits(
    int personId,
  ) async {
    _assertMovieApiConfigured();
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/person/$personId/combined_credits',
        queryParameters: _detailQueryParameters(),
      );
      return TmdbPersonCombinedCreditsDto.fromJson(response.data!);
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchPersonCombinedCredits', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  Future<List<TmdbMovieDto>> fetchMovieCollectionParts(int collectionId) async {
    _assertMovieApiConfigured();
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/collection/$collectionId',
        queryParameters: _detailQueryParameters(),
      );
      final parts = response.data?['parts'] as List<dynamic>?;
      if (parts == null) return const [];
      return parts
          .whereType<Map<String, dynamic>>()
          .map(TmdbMovieDto.fromJson)
          .toList();
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchMovieCollectionParts', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  Future<TmdbMoviesResponseDto> _discoverWithPersonCredits({
    required bool isTv,
    required MediaFilter filter,
    String? query,
    required int page,
  }) async {
    // Credits endpoint doesn't support pagination, so we only return results for page 1
    if (page > 1) {
      return const TmdbMoviesResponseDto(movies: []);
    }

    final List<TmdbMovieDto> allCredits = [];
    final endpoint = isTv ? 'tv_credits' : 'movie_credits';

    for (final personId in filter.personIds) {
      try {
        final response = await client.get<Map<String, dynamic>>(
          '/person/$personId/$endpoint',
          queryParameters: _detailQueryParameters(),
        );

        final List<dynamic> cast =
            response.data?['cast'] as List<dynamic>? ?? [];
        final List<dynamic> crew =
            response.data?['crew'] as List<dynamic>? ?? [];

        for (final item in [...cast, ...crew]) {
          if (item is Map<String, dynamic>) {
            allCredits.add(TmdbMovieDto.fromJson(item));
          }
        }
      } catch (e) {
        debugPrint(
          '[TMDb][_discoverWithPersonCredits] Error fetching $endpoint for $personId: $e',
        );
      }
    }

    // Filter by genres, dates, etc.
    final filtered = allCredits.where((movie) {
      // Title filter (query) - for search screen workaround
      if (query != null && query.isNotEmpty) {
        if (!movie.title.toLowerCase().contains(query.toLowerCase())) {
          return false;
        }
      }

      // Genre filter
      if (filter.genres.isNotEmpty) {
        if (!movie.genreIds.any((id) => filter.genres.contains(id))) {
          return false;
        }
      }

      // Date filter
      if (filter.releaseDateFrom != null || filter.releaseDateTo != null) {
        if (movie.releaseDate == null || movie.releaseDate!.isEmpty) {
          return false;
        }
        final date = DateTime.tryParse(movie.releaseDate!);
        if (date == null) return false;
        if (filter.releaseDateFrom != null &&
            date.isBefore(filter.releaseDateFrom!)) {
          return false;
        }
        if (filter.releaseDateTo != null &&
            date.isAfter(filter.releaseDateTo!)) {
          return false;
        }
      }

      // Score filter
      if (movie.voteAverage != null) {
        if (movie.voteAverage! < filter.userScore.start ||
            movie.voteAverage! > filter.userScore.end) {
          return false;
        }
      }

      // Votes filter
      if (movie.voteCount < filter.minUserVotes) {
        return false;
      }

      return true;
    }).toList();

    // Remove duplicates
    final seenIds = <int>{};
    final unique = filtered.where((m) => seenIds.add(m.id)).toList();

    // Sort
    unique.sort((a, b) {
      final isAsc = filter.sortOrder == SortOrder.ascending;
      int result = 0;
      switch (filter.sortField) {
        case SortField.popularity:
          result = a.popularity.compareTo(b.popularity);
          break;
        case SortField.voteAverage:
          result = (a.voteAverage ?? 0).compareTo(b.voteAverage ?? 0);
          break;
        case SortField.voteCount:
          result = a.voteCount.compareTo(b.voteCount);
          break;
        case SortField.releaseDate:
          final dateA = DateTime.tryParse(a.releaseDate ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.releaseDate ?? '') ?? DateTime(0);
          result = dateA.compareTo(dateB);
          break;
        case SortField.revenue:
          // Credits don't have revenue in these endpoints
          result = 0;
          break;
      }
      return isAsc ? result : -result;
    });

    return TmdbMoviesResponseDto(movies: unique);
  }

  Future<TmdbTvSeasonDto> fetchTvSeasonDetails(
    int tvId,
    int seasonNumber,
  ) async {
    _assertMovieApiConfigured();

    final Response<Map<String, dynamic>> response = await client
        .get<Map<String, dynamic>>(
          '/tv/$tvId/season/$seasonNumber',
          queryParameters: _authQueryParameters(),
        );

    return TmdbTvSeasonDto.fromJson(response.data!);
  }

  Future<TmdbTvEpisodeDto> fetchTvEpisodeDetails(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    _assertMovieApiConfigured();

    final Response<Map<String, dynamic>> response = await client
        .get<Map<String, dynamic>>(
          '/tv/$tvId/season/$seasonNumber/episode/$episodeNumber',
          queryParameters: <String, dynamic>{
            ..._authQueryParameters(),
            'append_to_response': 'credits,images',
          },
        );

    return TmdbTvEpisodeDto.fromJson(response.data!);
  }

  Future<List<TmdbSearchCollectionDto>> searchCollections(
    String query, {
    int page = 1,
  }) async {
    _assertMovieApiConfigured();
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/search/collection',
        queryParameters: <String, dynamic>{
          ..._pagedQueryParameters(page: page),
          'query': query,
        },
      );
      final results = response.data?['results'] as List<dynamic>?;
      if (results == null) return const [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(TmdbSearchCollectionDto.fromJson)
          .toList();
    } on DioException catch (error, stackTrace) {
      _logFailure('searchCollections', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  Future<List<TmdbSearchKeywordDto>> searchKeywords(
    String query, {
    int page = 1,
  }) async {
    _assertMovieApiConfigured();
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/search/keyword',
        queryParameters: <String, dynamic>{
          ..._pagedQueryParameters(page: page),
          'query': query,
        },
      );
      final results = response.data?['results'] as List<dynamic>?;
      if (results == null) return const [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(TmdbSearchKeywordDto.fromJson)
          .toList();
    } on DioException catch (error, stackTrace) {
      _logFailure('searchKeywords', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  Future<List<TmdbSearchCompanyDto>> searchCompanies(
    String query, {
    int page = 1,
  }) async {
    _assertMovieApiConfigured();
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/search/company',
        queryParameters: <String, dynamic>{
          ..._pagedQueryParameters(page: page),
          'query': query,
        },
      );
      final results = response.data?['results'] as List<dynamic>?;
      if (results == null) return const [];
      return results
          .whereType<Map<String, dynamic>>()
          .map(TmdbSearchCompanyDto.fromJson)
          .toList();
    } on DioException catch (error, stackTrace) {
      _logFailure('searchCompanies', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  Future<TmdbMovieCollectionDto> fetchMovieCollection(int collectionId) async {
    _assertMovieApiConfigured();
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/collection/$collectionId',
        queryParameters: _detailQueryParameters(),
      );
      if (response.data == null) throw TmdbApiException('No data returned');
      return TmdbMovieCollectionDto.fromJson(response.data!);
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchMovieCollection', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }

  Future<TmdbCompanyDetailsDto> fetchCompanyDetails(int companyId) async {
    _assertMovieApiConfigured();
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/company/$companyId',
        queryParameters: _detailQueryParameters(),
      );
      if (response.data == null) throw TmdbApiException('No data returned');
      return TmdbCompanyDetailsDto.fromJson(response.data!);
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchCompanyDetails', error, stackTrace);
      throw TmdbApiException(_messageForDioException(error));
    }
  }
}
