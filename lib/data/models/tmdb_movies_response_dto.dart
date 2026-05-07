import 'package:cineverse/data/models/tmdb_movie_dto.dart';

class TmdbMoviesResponseDto {
  const TmdbMoviesResponseDto({required this.movies});

  factory TmdbMoviesResponseDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawResults =
        (json['results'] as List<dynamic>?) ?? <dynamic>[];

    return TmdbMoviesResponseDto(
      movies: rawResults
          .whereType<Map<String, dynamic>>()
          .map(TmdbMovieDto.fromJson)
          .toList(growable: false),
    );
  }

  final List<TmdbMovieDto> movies;
}
