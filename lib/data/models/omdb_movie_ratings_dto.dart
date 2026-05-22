import 'package:cineverse/domain/entities/movie_details.dart';

class OmdbMovieRatingsDto {
  const OmdbMovieRatingsDto({
    this.imdbRating,
    this.rottenTomatoesRating,
    this.metacriticRating,
    this.awards,
    this.dvdReleaseDate,
  });

  factory OmdbMovieRatingsDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawRatings =
        (json['Ratings'] as List<dynamic>?) ?? <dynamic>[];

    return OmdbMovieRatingsDto(
      imdbRating: _normalizeRatingValue(json['imdbRating'] as String?),
      rottenTomatoesRating: _resolveNamedRating(
        rawRatings,
        source: 'Rotten Tomatoes',
      ),
      metacriticRating: _resolveNamedRating(rawRatings, source: 'Metacritic'),
      awards: json['Awards'] as String?,
      dvdReleaseDate: json['DVD'] as String?,
    );
  }

  final String? imdbRating;
  final String? rottenTomatoesRating;
  final String? metacriticRating;
  final String? awards;
  final String? dvdReleaseDate;

  List<MovieRating> toDomain({String? imdbId, String? title}) {
    final String encodedTitle = Uri.encodeComponent(title ?? '');
    final List<MovieRating> ratings = <MovieRating>[
      if (imdbRating != null)
        MovieRating(
          source: 'IMDb',
          value: imdbRating!,
          url:
              imdbId != null ? 'https://www.imdb.com/title/$imdbId/' : null,
        ),
      if (rottenTomatoesRating != null)
        MovieRating(
          source: 'Rotten Tomatoes',
          value: rottenTomatoesRating!,
          url:
              title != null
                  ? 'https://www.rottentomatoes.com/search?search=$encodedTitle'
                  : null,
        ),
      if (metacriticRating != null)
        MovieRating(
          source: 'Metacritic',
          value: metacriticRating!,
          url:
              title != null
                  ? 'https://www.metacritic.com/search/movie/$encodedTitle/results'
                  : null,
        ),
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
