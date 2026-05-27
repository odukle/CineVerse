import 'package:cineverse/data/models/tmdb_movie_dto.dart';
import 'package:cineverse/domain/entities/movie_collection.dart';

class TmdbMovieCollectionDto {
  const TmdbMovieCollectionDto({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    required this.parts,
  });

  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final List<TmdbMovieDto> parts;

  factory TmdbMovieCollectionDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawParts = (json['parts'] as List<dynamic>?) ?? <dynamic>[];
    return TmdbMovieCollectionDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String?,
      posterPath: _normalizeImagePath(json['poster_path'] as String?, size: 'w500'),
      backdropPath: _normalizeImagePath(json['backdrop_path'] as String?, size: 'w780'),
      parts: rawParts
          .whereType<Map<String, dynamic>>()
          .map(TmdbMovieDto.fromJson)
          .toList(growable: false),
    );
  }

  MovieCollection toDomain() {
    return MovieCollection(
      id: id,
      name: name,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      parts: parts.map((e) => e.toDomain()).toList(),
    );
  }

  static String? _normalizeImagePath(String? path, {required String size}) {
    if (path == null || path.trim().isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size${path.trim()}';
  }
}
