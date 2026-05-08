import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/domain/entities/media_title.dart';

class TmdbMovieDto {
  const TmdbMovieDto({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
    this.voteAverage,
  });

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) {
    return TmdbMovieDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title:
          (json['title'] as String?) ?? (json['name'] as String?) ?? 'Untitled',
      posterPath: _normalizeImagePath(
        json['poster_path'] as String?,
        size: 'w500',
      ),
      releaseDate:
          (json['release_date'] as String?) ??
          (json['first_air_date'] as String?),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
    );
  }

  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final double? voteAverage;

  MediaTitle toDomain() {
    return MediaTitle(
      id: id,
      title: title,
      posterPath: posterPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
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
