import 'package:cineverse/domain/entities/search_collection.dart';

class TmdbSearchCollectionDto {
  const TmdbSearchCollectionDto({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
    this.overview,
  });

  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;

  factory TmdbSearchCollectionDto.fromJson(Map<String, dynamic> json) {
    return TmdbSearchCollectionDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      posterPath: _normalizeImagePath(json['poster_path'] as String?, size: 'w500'),
      backdropPath: _normalizeImagePath(json['backdrop_path'] as String?, size: 'w780'),
      overview: json['overview'] as String?,
    );
  }

  SearchCollection toDomain() {
    return SearchCollection(
      id: id,
      name: name,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
    );
  }

  static String? _normalizeImagePath(String? path, {required String size}) {
    if (path == null || path.trim().isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size${path.trim()}';
  }
}
