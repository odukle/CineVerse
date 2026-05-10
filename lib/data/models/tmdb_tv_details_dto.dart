import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/domain/entities/movie_details.dart';

class TmdbTvSeasonDto {
  const TmdbTvSeasonDto({
    required this.id,
    required this.seasonNumber,
    required this.name,
    this.overview,
    this.posterPath,
    this.airDate,
    this.voteAverage,
    this.episodeCount,
    this.episodes = const <TmdbTvEpisodeDto>[],
  });

  factory TmdbTvSeasonDto.fromJson(Map<String, dynamic> json) {
    final int seasonNo = (json['season_number'] as num?)?.toInt() ?? 0;
    final List<dynamic>? rawEpisodes = json['episodes'] as List<dynamic>?;
    final List<TmdbTvEpisodeDto> episodesList = rawEpisodes
            ?.whereType<Map<String, dynamic>>()
            .map((e) => TmdbTvEpisodeDto.fromJson(e, seasonNumberFallback: seasonNo))
            .toList() ??
        const <TmdbTvEpisodeDto>[];

    return TmdbTvSeasonDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      seasonNumber: seasonNo,
      name: (json['name'] as String?)?.trim() ?? 'Untitled',
      overview: _optionalText(json['overview']),
      posterPath: _normalizeImagePath(
        json['poster_path'] as String?,
        size: 'w500',
      ),
      airDate: _optionalText(json['air_date']),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      episodeCount: (json['episode_count'] as num?)?.toInt() ?? episodesList.length,
      episodes: episodesList,
    );
  }

  final int id;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? airDate;
  final double? voteAverage;
  final int? episodeCount;
  final List<TmdbTvEpisodeDto> episodes;

  TvSeason toDomain() {
    return TvSeason(
      id: id,
      seasonNumber: seasonNumber,
      name: name,
      overview: overview,
      posterPath: posterPath,
      airDate: airDate,
      voteAverage: voteAverage,
      episodeCount: episodeCount ?? episodes.length,
      episodes: episodes.map((e) => e.toDomain()).toList(),
    );
  }
}

class TmdbTvEpisodeDto {
  const TmdbTvEpisodeDto({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    this.overview,
    this.airDate,
    this.stillPath,
    this.voteAverage,
    this.runtimeMinutes,
    this.cast = const <MovieCredit>[],
    this.crew = const <MovieCredit>[],
    this.images = const <String>[],
  });

  factory TmdbTvEpisodeDto.fromJson(
    Map<String, dynamic> json, {
    int? seasonNumberFallback,
  }) {
    // Handle both season-level episode list and single episode detail structures
    final credits = (json['credits'] as Map<String, dynamic>?) ?? {};
    final images = (json['images'] as Map<String, dynamic>?) ?? {};

    return TmdbTvEpisodeDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      episodeNumber: (json['episode_number'] as num?)?.toInt() ?? 0,
      seasonNumber:
          (json['season_number'] as num?)?.toInt() ??
          seasonNumberFallback ??
          0,
      name: (json['name'] as String?)?.trim() ?? 'Untitled',
      overview: _optionalText(json['overview']),
      airDate: _optionalText(json['air_date']),
      stillPath: _normalizeImagePath(
        json['still_path'] as String?,
        size: 'w500',
      ),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      runtimeMinutes: (json['runtime'] as num?)?.toInt(),
      cast: _resolveEpisodeCast((credits['cast'] as List<dynamic>?) ?? []),
      crew: _resolveEpisodeCrew((credits['crew'] as List<dynamic>?) ?? []),
      images: (images['stills'] as List<dynamic>?)
              ?.map((e) => _normalizeImagePath(e['file_path'] as String?, size: 'original'))
              .whereType<String>()
              .toList() ??
          const [],
    );
  }

  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? airDate;
  final String? stillPath;
  final double? voteAverage;
  final int? runtimeMinutes;
  final List<MovieCredit> cast;
  final List<MovieCredit> crew;
  final List<String> images;

  TvEpisode toDomain() {
    return TvEpisode(
      id: id,
      episodeNumber: episodeNumber,
      seasonNumber: seasonNumber,
      name: name,
      overview: overview,
      airDate: airDate,
      stillPath: stillPath,
      voteAverage: voteAverage,
      runtimeMinutes: runtimeMinutes,
      cast: cast,
      crew: crew,
      images: images,
    );
  }
}

List<MovieCredit> _resolveEpisodeCast(List<dynamic> rawCast) {
  return rawCast
      .whereType<Map<String, dynamic>>()
      .map((credit) => MovieCredit(
            id: (credit['id'] as num?)?.toInt() ?? 0,
            name: (credit['name'] as String?)?.trim() ?? 'Unknown',
            role: 'Actor',
            characterName: _optionalText(credit['character']),
            imageUrl: _normalizeImagePath(credit['profile_path'] as String?, size: 'w185'),
          ))
      .toList();
}

List<MovieCredit> _resolveEpisodeCrew(List<dynamic> rawCrew) {
  return rawCrew
      .whereType<Map<String, dynamic>>()
      .map((credit) => MovieCredit(
            id: (credit['id'] as num?)?.toInt() ?? 0,
            name: (credit['name'] as String?)?.trim() ?? 'Unknown',
            role: _optionalText(credit['job']) ?? _optionalText(credit['department']) ?? 'Crew',
            imageUrl: _normalizeImagePath(credit['profile_path'] as String?, size: 'w185'),
          ))
      .toList();
}

String? _optionalText(Object? value) {
  final String? text = value as String?;
  if (text == null) return null;
  final String trimmed = text.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _normalizeImagePath(String? rawImagePath, {required String size}) {
  if (rawImagePath == null || rawImagePath.isEmpty) return null;
  if (rawImagePath.startsWith('http')) return rawImagePath;
  return '${AppConstants.tmdbImageBaseUrl}/$size$rawImagePath';
}
