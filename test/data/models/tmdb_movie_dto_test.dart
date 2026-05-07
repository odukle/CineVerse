import 'package:cineverse/data/models/tmdb_movie_dto.dart';
import 'package:cineverse/data/models/tmdb_movies_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a TMDb movie dto into a MediaTitle entity', () {
    final TmdbMovieDto dto = TmdbMovieDto.fromJson(<String, dynamic>{
      'id': 550,
      'title': 'Fight Club',
      'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      'release_date': '1999-10-15',
    });

    final mediaTitle = dto.toDomain();

    expect(mediaTitle.id, 550);
    expect(mediaTitle.title, 'Fight Club');
    expect(
      mediaTitle.posterPath,
      'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    );
    expect(mediaTitle.releaseDate, '1999-10-15');
  });

  test('normalizes relative TMDb image paths into full artwork urls', () {
    final TmdbMovieDto dto = TmdbMovieDto.fromJson(<String, dynamic>{
      'id': 231,
      'title': 'Titanic',
      'poster_path': '/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg',
    });

    expect(
      dto.posterPath,
      'https://image.tmdb.org/t/p/w500/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg',
    );
  });

  test('parses a TMDb movies response', () {
    final TmdbMoviesResponseDto response = TmdbMoviesResponseDto.fromJson(
      <String, dynamic>{
        'results': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 603,
            'title': 'The Matrix',
            'poster_path': '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
            'release_date': '1999-03-30',
          },
        ],
      },
    );

    expect(response.movies, hasLength(1));
    expect(response.movies.first.title, 'The Matrix');
  });
}
