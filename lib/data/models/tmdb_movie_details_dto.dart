import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/data/models/tmdb_movie_watch_providers_dto.dart';
import 'package:cineverse/domain/entities/movie_details.dart';

class TmdbMovieDetailsDto {
  const TmdbMovieDetailsDto({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.genres = const <String>[],
    this.runtimeMinutes,
    this.imdbId,
    this.cast = const <MovieCredit>[],
    this.crew = const <MovieCredit>[],
    this.contentRating,
    this.contentRatingDescription,
    this.score,
    this.tagline,
    this.budget,
    this.revenue,
    this.originalLanguage,
    this.status,
    this.voteCount,
    this.recommendations = const <MovieRecommendation>[],
    this.watchAvailability,
    this.trailerYouTubeKey,
  });

  factory TmdbMovieDetailsDto.fromJson(
    Map<String, dynamic> json, {
    required String preferredRegionCode,
    bool isTv = false,
  }) {
    final Map<String, dynamic> credits =
        (json['aggregate_credits'] as Map<String, dynamic>?) ??
        (json['credits'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
    final Map<String, dynamic> externalIds =
        (json['external_ids'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final List<dynamic> rawGenres =
        (json['genres'] as List<dynamic>?) ?? <dynamic>[];
    final Map<String, dynamic> rawRecommendations =
        (json['recommendations'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
    final Map<String, dynamic> rawWatchProviders =
        (json['watch/providers'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
    final Map<String, dynamic> rawVideos =
        (json['videos'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final bool isAggregate = json.containsKey('aggregate_credits');

    return TmdbMovieDetailsDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title:
          (json['title'] as String?) ?? (json['name'] as String?) ?? 'Untitled',
      posterPath: _normalizeImagePath(
        json['poster_path'] as String?,
        size: 'w500',
      ),
      backdropPath: _normalizeImagePath(
        json['backdrop_path'] as String?,
        size: 'w780',
      ),
      overview: _optionalText(json['overview']),
      releaseDate:
          _optionalText(json['release_date']) ??
          _optionalText(json['first_air_date']),
      genres: rawGenres
          .whereType<Map<String, dynamic>>()
          .map((genre) => (genre['name'] as String?)?.trim())
          .whereType<String>()
          .where((genre) => genre.isNotEmpty)
          .toList(growable: false),
      runtimeMinutes: _resolveRuntimeMinutes(json, isTv: isTv),
      imdbId: (externalIds['imdb_id'] as String?)?.trim(),
      cast: _resolveCast(
        (credits['cast'] as List<dynamic>?) ?? <dynamic>[],
        isAggregate: isAggregate,
      ),
      crew: _resolveCrew(
        (credits['crew'] as List<dynamic>?) ?? <dynamic>[],
        isAggregate: isAggregate,
      ),
      contentRating: _resolveContentRating(
        json,
        preferredRegionCode,
        isTv: isTv,
      ),
      contentRatingDescription: _resolveContentRatingDescription(
        json,
        preferredRegionCode,
        isTv: isTv,
      ),
      score: (json['vote_average'] as num?)?.toDouble(),
      tagline: _optionalText(json['tagline']),
      budget: (json['budget'] as num?)?.toInt(),
      revenue: (json['revenue'] as num?)?.toInt(),
      originalLanguage: _optionalText(json['original_language']),
      status: _optionalText(json['status']),
      voteCount: (json['vote_count'] as num?)?.toInt(),
      recommendations: _resolveRecommendations(
        (rawRecommendations['results'] as List<dynamic>?) ?? <dynamic>[],
      ),
      watchAvailability: rawWatchProviders.isEmpty
          ? null
          : TmdbMovieWatchProvidersDto.fromJson(
              rawWatchProviders,
              preferredRegionCode: preferredRegionCode,
            ).toDomain(),
      trailerYouTubeKey: _resolveTrailerKey(
        (rawVideos['results'] as List<dynamic>?) ?? <dynamic>[],
      ),
    );
  }

  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final String? releaseDate;
  final List<String> genres;
  final int? runtimeMinutes;
  final String? imdbId;
  final List<MovieCredit> cast;
  final List<MovieCredit> crew;
  final String? contentRating;
  final String? contentRatingDescription;
  final double? score;
  final String? tagline;
  final int? budget;
  final int? revenue;
  final String? originalLanguage;
  final String? status;
  final int? voteCount;
  final List<MovieRecommendation> recommendations;
  final MovieWatchAvailability? watchAvailability;
  final String? trailerYouTubeKey;

  TmdbMovieDetailsDto copyWith({MovieWatchAvailability? watchAvailability}) {
    return TmdbMovieDetailsDto(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      releaseDate: releaseDate,
      genres: genres,
      runtimeMinutes: runtimeMinutes,
      imdbId: imdbId,
      cast: cast,
      crew: crew,
      contentRating: contentRating,
      contentRatingDescription: contentRatingDescription,
      score: score,
      tagline: tagline,
      budget: budget,
      revenue: revenue,
      originalLanguage: originalLanguage,
      status: status,
      voteCount: voteCount,
      recommendations: recommendations,
      watchAvailability: watchAvailability ?? this.watchAvailability,
      trailerYouTubeKey: trailerYouTubeKey,
    );
  }

  MovieDetails toDomain() {
    return MovieDetails(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      releaseDate: releaseDate,
      genres: genres,
      runtimeMinutes: runtimeMinutes,
      cast: cast,
      crew: crew,
      contentRating: contentRating,
      contentRatingDescription: contentRatingDescription,
      catalogScore: score,
      tagline: tagline,
      budget: budget,
      revenue: revenue,
      originalLanguage: originalLanguage,
      status: status,
      voteCount: voteCount,
      recommendations: recommendations,
      watchAvailability: watchAvailability,
      imdbId: imdbId,
      trailerYouTubeKey: trailerYouTubeKey,
    );
  }

  static List<MovieRecommendation> _resolveRecommendations(
    List<dynamic> rawResults,
  ) {
    return rawResults
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

  static List<MovieCredit> _resolveCast(
    List<dynamic> rawCast, {
    bool isAggregate = false,
  }) {
    return rawCast
        .whereType<Map<String, dynamic>>()
        .where(
          (credit) => ((credit['name'] as String?) ?? '').trim().isNotEmpty,
        )
        .map((credit) {
          String? character;
          if (isAggregate) {
            final List<dynamic> roles =
                (credit['roles'] as List<dynamic>?) ?? <dynamic>[];
            if (roles.isNotEmpty) {
              final Map<String, dynamic> role = roles.first;
              final String charName = _optionalText(role['character']) ?? '';
              final int episodes = (role['episode_count'] as num?)?.toInt() ?? 0;
              character = episodes > 0 ? '$charName ($episodes eps)' : charName;
            }
          } else {
            character = _optionalText(credit['character']);
          }

          return MovieCredit(
            id: (credit['id'] as num?)?.toInt() ?? 0,
            name: (credit['name'] as String).trim(),
            role: 'Actor',
            characterName: character,
            imageUrl: _normalizeImagePath(
              credit['profile_path'] as String?,
              size: 'w185',
            ),
          );
        })
        .toList(growable: false);
  }

  static List<MovieCredit> _resolveCrew(
    List<dynamic> rawCrew, {
    bool isAggregate = false,
  }) {
    final Set<String> seenCredits = <String>{};
    final List<MovieCredit> crewCredits = <MovieCredit>[];

    for (final Map<String, dynamic> credit
        in rawCrew.whereType<Map<String, dynamic>>()) {
      final String name = _optionalText(credit['name']) ?? '';
      String role = '';

      if (isAggregate) {
        final List<dynamic> jobs =
            (credit['jobs'] as List<dynamic>?) ?? <dynamic>[];
        if (jobs.isNotEmpty) {
          final Map<String, dynamic> job = jobs.first;
          role = _optionalText(job['job']) ?? _optionalText(job['department']) ?? '';
        }
      } else {
        role =
            _optionalText(credit['job']) ??
            _optionalText(credit['department']) ??
            '';
      }

      if (name.isEmpty || role.isEmpty) {
        continue;
      }

      final String dedupeKey = '${name.toLowerCase()}|${role.toLowerCase()}';
      if (!seenCredits.add(dedupeKey)) {
        continue;
      }

      crewCredits.add(
        MovieCredit(
          id: (credit['id'] as num?)?.toInt() ?? 0,
          name: name,
          role: role,
          imageUrl: _normalizeImagePath(
            credit['profile_path'] as String?,
            size: 'w185',
          ),
        ),
      );
    }

    return crewCredits;
  }

  static int? _resolveRuntimeMinutes(
    Map<String, dynamic> json, {
    required bool isTv,
  }) {
    final int? movieRuntime = (json['runtime'] as num?)?.toInt();
    if (movieRuntime != null) {
      return movieRuntime;
    }

    if (!isTv) {
      return null;
    }

    final List<int> episodeRuntimes =
        (json['episode_run_time'] as List<dynamic>?)
            ?.whereType<num>()
            .map((runtime) => runtime.toInt())
            .where((runtime) => runtime > 0)
            .toList(growable: false) ??
        const <int>[];

    if (episodeRuntimes.isEmpty) {
      return null;
    }

    return (episodeRuntimes.reduce(
              (int value, int runtime) => value + runtime,
            ) /
            episodeRuntimes.length)
        .round();
  }

  static String? _resolveContentRating(
    Map<String, dynamic> json,
    String preferredRegionCode, {
    required bool isTv,
  }) {
    if (isTv) {
      final Map<String, dynamic> contentRatings =
          (json['content_ratings'] as Map<String, dynamic>?) ??
          <String, dynamic>{};
      final List<dynamic> rawResults =
          (contentRatings['results'] as List<dynamic>?) ?? <dynamic>[];
      final Map<String, dynamic>? preferredRegion = _selectTvContentRating(
        rawResults,
        preferredRegionCode,
      );

      return _optionalText(preferredRegion?['rating']);
    }

    final Map<String, dynamic> releaseDates =
        (json['release_dates'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final Map<String, dynamic>? release = _selectReleaseDate(
      (releaseDates['results'] as List<dynamic>?) ?? <dynamic>[],
      preferredRegionCode,
    );
    return _optionalText(release?['certification']);
  }

  static String? _resolveContentRatingDescription(
    Map<String, dynamic> json,
    String preferredRegionCode, {
    required bool isTv,
  }) {
    if (isTv) {
      return null;
    }

    final Map<String, dynamic> releaseDates =
        (json['release_dates'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final Map<String, dynamic>? release = _selectReleaseDate(
      (releaseDates['results'] as List<dynamic>?) ?? <dynamic>[],
      preferredRegionCode,
    );
    final List<dynamic> descriptors =
        (release?['descriptors'] as List<dynamic>?) ?? <dynamic>[];
    final String descriptorText = descriptors
        .whereType<String>()
        .map((descriptor) => descriptor.trim())
        .where((descriptor) => descriptor.isNotEmpty)
        .join(', ');

    if (descriptorText.isNotEmpty) {
      return descriptorText;
    }

    return _optionalText(release?['note']);
  }

  static Map<String, dynamic>? _selectReleaseDate(
    List<dynamic> rawResults,
    String preferredRegionCode,
  ) {
    final List<Map<String, dynamic>> typedResults = rawResults
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    final Map<String, dynamic>? preferredRegion = typedResults
        .cast<Map<String, dynamic>?>()
        .firstWhere(
          (result) =>
              result?['iso_3166_1'] == preferredRegionCode &&
              _firstCertifiedRelease(
                    (result?['release_dates'] as List<dynamic>?) ?? <dynamic>[],
                  ) !=
                  null,
          orElse: () => null,
        );

    final List<dynamic> preferredEntries =
        (preferredRegion?['release_dates'] as List<dynamic>?) ?? <dynamic>[];
    final Map<String, dynamic>? preferredRelease = _firstCertifiedRelease(
      preferredEntries,
    );
    if (preferredRelease != null) {
      return preferredRelease;
    }

    for (final Map<String, dynamic> result in typedResults) {
      final Map<String, dynamic>? release = _firstCertifiedRelease(
        (result['release_dates'] as List<dynamic>?) ?? <dynamic>[],
      );
      if (release != null) {
        return release;
      }
    }

    return null;
  }

  static Map<String, dynamic>? _firstCertifiedRelease(
    List<dynamic> rawEntries,
  ) {
    for (final Map<String, dynamic> entry
        in rawEntries.whereType<Map<String, dynamic>>()) {
      if (_optionalText(entry['certification']) != null) {
        return entry;
      }
    }

    return null;
  }

  static Map<String, dynamic>? _selectTvContentRating(
    List<dynamic> rawResults,
    String preferredRegionCode,
  ) {
    final List<Map<String, dynamic>> typedResults = rawResults
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    final Map<String, dynamic>? preferredRegion = typedResults
        .cast<Map<String, dynamic>?>()
        .firstWhere(
          (result) =>
              result?['iso_3166_1'] == preferredRegionCode &&
              _optionalText(result?['rating']) != null,
          orElse: () => null,
        );

    if (_optionalText(preferredRegion?['rating']) != null) {
      return preferredRegion;
    }

    for (final Map<String, dynamic> result in typedResults) {
      if (_optionalText(result['rating']) != null) {
        return result;
      }
    }

    return null;
  }

  static String? _optionalText(Object? value) {
    final String? text = value as String?;
    if (text == null) {
      return null;
    }

    final String trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _normalizeImagePath(
    String? rawImagePath, {
    required String size,
  }) {
    if (rawImagePath == null || rawImagePath.isEmpty) {
      return null;
    }

    if (rawImagePath.startsWith('http://') ||
        rawImagePath.startsWith('https://')) {
      return rawImagePath;
    }

    return '${AppConstants.tmdbImageBaseUrl}/$size$rawImagePath';
  }
}

String? _resolveTrailerKey(List<dynamic> rawVideos) {
  final List<Map<String, dynamic>> videos = rawVideos
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);

  // 1. Try to find an official trailer on YouTube
  for (final Map<String, dynamic> video in videos) {
    if (video['site'] == 'YouTube' &&
        video['type'] == 'Trailer' &&
        video['official'] == true) {
      return video['key'] as String?;
    }
  }

  // 2. Any trailer on YouTube
  for (final Map<String, dynamic> video in videos) {
    if (video['site'] == 'YouTube' && video['type'] == 'Trailer') {
      return video['key'] as String?;
    }
  }

  // 3. Any video on YouTube
  for (final Map<String, dynamic> video in videos) {
    if (video['site'] == 'YouTube') {
      return video['key'] as String?;
    }
  }

  return null;
}
