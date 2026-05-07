import 'package:cineverse/data/models/omdb_movie_ratings_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps OMDb movie ratings into domain ratings', () {
    final OmdbMovieRatingsDto dto = OmdbMovieRatingsDto.fromJson(
      <String, dynamic>{
        'imdbRating': '7.9/10',
        'Ratings': <Map<String, dynamic>>[
          <String, dynamic>{
            'Source': 'Internet Movie Database',
            'Value': '7.9/10',
          },
          <String, dynamic>{'Source': 'Rotten Tomatoes', 'Value': '88%'},
        ],
      },
    );

    expect(dto.imdbRating, '7.9/10');
    expect(dto.rottenTomatoesRating, '88%');
    expect(dto.toDomain(), hasLength(2));
    expect(dto.toDomain().first.source, 'IMDb');
    expect(dto.toDomain().first.value, '7.9/10');
    expect(dto.toDomain().last.source, 'Rotten Tomatoes');
    expect(dto.toDomain().last.value, '88%');
  });
}
