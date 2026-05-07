import 'package:cineverse/data/models/tmdb_movie_watch_providers_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prefers US watch providers and maps provider logos', () {
    final TmdbMovieWatchProvidersDto dto = TmdbMovieWatchProvidersDto.fromJson(
      <String, dynamic>{
        'id': 231,
        'results': <String, dynamic>{
          'US': <String, dynamic>{
            'link': 'https://www.themoviedb.org/movie/231/watch?locale=US',
            'flatrate': <Map<String, dynamic>>[
              <String, dynamic>{
                'provider_id': 8,
                'provider_name': 'Netflix',
                'logo_path': '/netflix-logo.jpg',
              },
            ],
            'rent': <Map<String, dynamic>>[
              <String, dynamic>{
                'provider_id': 2,
                'provider_name': 'Apple TV',
                'logo_path': '/apple-tv-logo.jpg',
              },
            ],
            'buy': <Map<String, dynamic>>[
              <String, dynamic>{
                'provider_id': 3,
                'provider_name': 'Google Play Movies',
                'logo_path': '/google-play-logo.jpg',
              },
            ],
          },
        },
      },
      preferredRegionCode: 'US',
    );

    expect(dto.link, 'https://www.themoviedb.org/movie/231/watch?locale=US');
    expect(dto.streaming, hasLength(1));
    expect(dto.streaming.first.name, 'Netflix');
    expect(
      dto.streaming.first.logoPath,
      'https://image.tmdb.org/t/p/w92/netflix-logo.jpg',
    );
    expect(dto.rent.single.name, 'Apple TV');
    expect(dto.buy.single.name, 'Google Play Movies');

    final availability = dto.toDomain();
    expect(availability, isNotNull);
    expect(availability!.hasProviders, isTrue);
  });
}
