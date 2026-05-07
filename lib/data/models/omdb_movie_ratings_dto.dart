import 'package:cineverse/domain/entities/movie_details.dart';

class OmdbMovieRatingsDto {
  const OmdbMovieRatingsDto({this.imdbRating, this.rottenTomatoesRating});

  factory OmdbMovieRatingsDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawRatings =
        (json['Ratings'] as List<dynamic>?) ?? <dynamic>[];

    return OmdbMovieRatingsDto(
      imdbRating: _normalizeRatingValue(json['imdbRating'] as String?),
      rottenTomatoesRating: _resolveNamedRating(
        rawRatings,
        source: 'Rotten Tomatoes',
      ),
    );
  }

  final String? imdbRating;
  final String? rottenTomatoesRating;

  List<MovieRating> toDomain() {
    final List<MovieRating> ratings = <MovieRating>[
      if (imdbRating != null) MovieRating(source: 'IMDb', value: imdbRating!),
      if (rottenTomatoesRating != null)
        MovieRating(source: 'Rotten Tomatoes', value: rottenTomatoesRating!),
    ];

    return List<MovieRating>.unmodifiable(ratings);
  }

  static String? _resolveNamedRating(
    List<dynamic> rawRatings, {
    required String source,
  }) {
    for (final Map<String, dynamic> rating
        in rawRatings.whereType<Map<String, dynamic>>()) {
      if ((rating['Source'] as String? ?? '').trim() == source) {
        return _normalizeRatingValue(rating['Value'] as String?);
      }
    }

    return null;
  }

  static String? _normalizeRatingValue(String? value) {
    final String normalized = (value ?? '').trim();
    if (normalized.isEmpty || normalized == 'N/A') {
      return null;
    }

    return normalized;
  }
}
