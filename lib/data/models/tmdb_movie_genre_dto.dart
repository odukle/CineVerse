import 'package:cineverse/domain/entities/movie_genre.dart';

class TmdbMovieGenreDto {
  const TmdbMovieGenreDto({required this.id, required this.name});

  factory TmdbMovieGenreDto.fromJson(Map<String, dynamic> json) {
    return TmdbMovieGenreDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Unknown',
    );
  }

  final int id;
  final String name;

  MovieGenre toDomain() {
    return MovieGenre(id: id, name: name);
  }
}
