import 'package:cineverse/data/models/tmdb_movie_details_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps TMDb movie details payload into domain-friendly fields', () {
    final TmdbMovieDetailsDto dto = TmdbMovieDetailsDto.fromJson(
      <String, dynamic>{
        'id': 231,
        'title': 'Titanic',
        'poster_path': '/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg',
        'backdrop_path': '/rzdPqYx7Um4FUZeD8wpXqjAUcEm.jpg',
        'overview': 'Jack and Rose fall in love aboard the Titanic.',
        'release_date': '1997-12-19',
        'runtime': 194,
        'vote_average': 7.9,
        'external_ids': <String, dynamic>{'imdb_id': 'tt0120338'},
        'genres': <Map<String, dynamic>>[
          <String, dynamic>{'name': 'Drama'},
          <String, dynamic>{'name': 'Romance'},
        ],
        'credits': <String, dynamic>{
          'cast': <Map<String, dynamic>>[
            <String, dynamic>{
              'name': 'Leonardo DiCaprio',
              'character': 'Jack Dawson',
              'profile_path': '/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg',
            },
          ],
          'crew': <Map<String, dynamic>>[
            <String, dynamic>{'name': 'James Cameron', 'job': 'Director'},
            <String, dynamic>{'name': 'James Cameron', 'job': 'Writer'},
          ],
        },
        'release_dates': <String, dynamic>{
          'results': <Map<String, dynamic>>[
            <String, dynamic>{
              'iso_3166_1': 'US',
              'release_dates': <Map<String, dynamic>>[
                <String, dynamic>{
                  'certification': 'PG-13',
                  'descriptors': <String>['disaster peril'],
                },
              ],
            },
          ],
        },
      },
      preferredRegionCode: 'US',
    );

    expect(dto.id, 231);
    expect(dto.title, 'Titanic');
    expect(dto.releaseDate, '1997-12-19');
    expect(
      dto.posterPath,
      'https://image.tmdb.org/t/p/w500/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg',
    );
    expect(
      dto.backdropPath,
      'https://image.tmdb.org/t/p/w780/rzdPqYx7Um4FUZeD8wpXqjAUcEm.jpg',
    );
    expect(dto.overview, 'Jack and Rose fall in love aboard the Titanic.');
    expect(dto.genres, <String>['Drama', 'Romance']);
    expect(dto.runtimeMinutes, 194);
    expect(dto.imdbId, 'tt0120338');
    expect(dto.contentRating, 'PG-13');
    expect(dto.contentRatingDescription, 'disaster peril');
    expect(dto.score, 7.9);
    expect(dto.cast, hasLength(1));
    expect(dto.cast.first.name, 'Leonardo DiCaprio');
    expect(dto.cast.first.characterName, 'Jack Dawson');
    expect(
      dto.cast.first.imageUrl,
      'https://image.tmdb.org/t/p/w185/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg',
    );
    expect(dto.crew, hasLength(2));
    expect(dto.crew.first.name, 'James Cameron');
    expect(dto.crew.first.role, 'Director');

    final domain = dto.toDomain();
    expect(domain.releaseDate, '1997-12-19');
    expect(domain.catalogScore, 7.9);
  });
}
