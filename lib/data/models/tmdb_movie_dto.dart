import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';

class TmdbMovieDto {
  const TmdbMovieDto({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
    this.voteAverage,
    this.mediaType,
    this.genreIds = const [],
    this.voteCount = 0,
    this.popularity = 0.0,
  });

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) {
    final mediaTypeString = json['media_type'] as String?;
    GlobalMediaType? mediaType;
    if (mediaTypeString == 'movie') {
      mediaType = GlobalMediaType.movie;
    } else if (mediaTypeString == 'tv') {
      mediaType = GlobalMediaType.tv;
    } else if (mediaTypeString == 'person') {
      mediaType = GlobalMediaType.person;
    }

    final rawImagePath =
        (json['poster_path'] as String?) ?? (json['profile_path'] as String?);

    return TmdbMovieDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title:
          (json['title'] as String?) ?? (json['name'] as String?) ?? 'Untitled',
      posterPath: _normalizeImagePath(
        rawImagePath,
        size: 'w500',
      ),
      releaseDate:
          (json['release_date'] as String?) ??
          (json['first_air_date'] as String?),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      mediaType: mediaType,
      genreIds:
          (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final double? voteAverage;
  final GlobalMediaType? mediaType;
  final List<int> genreIds;
  final int voteCount;
  final double popularity;

  MediaTitle toDomain() {
    return MediaTitle(
      id: id,
      title: title,
      posterPath: posterPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      mediaType: mediaType,
      genreIds: genreIds,
      voteCount: voteCount,
      popularity: popularity,
    );
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
