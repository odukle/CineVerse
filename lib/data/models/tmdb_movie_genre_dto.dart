import 'package:cineverse/domain/entities/movie_genre.dart';

class TmdbMovieGenreDto {
  const TmdbMovieGenreDto({required this.id, required this.name});

  factory TmdbMovieGenreDto.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final int parsedId;
    if (idValue is int) {
      parsedId = idValue;
    } else if (idValue is String) {
      parsedId = int.tryParse(idValue) ?? 0;
    } else if (idValue is num) {
      parsedId = idValue.toInt();
    } else {
      parsedId = 0;
    }

    return TmdbMovieGenreDto(
      id: parsedId,
      name: json['name'] as String? ?? 'Unknown',
    );
  }

  final int id;
  final String name;

  MovieGenre toDomain() {
    return MovieGenre(id: id, name: name);
  }
}
