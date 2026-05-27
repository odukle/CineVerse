import 'package:cineverse/domain/entities/movie_details.dart';

class OmdbTitleDetailsDto {
  const OmdbTitleDetailsDto({
    this.title,
    this.year,
    this.rated,
    this.released,
    this.runtime,
    this.genre,
    this.director,
    this.writer,
    this.actors,
    this.language,
    this.country,
    this.awards,
    this.boxOffice,
    this.imdbRating,
    this.imdbVotes,
    this.metascore,
    this.plot,
    this.type,
    this.poster,
    this.ratings = const <MovieRating>[],
  });

  factory OmdbTitleDetailsDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawRatings =
        (json['Ratings'] as List<dynamic>?) ?? <dynamic>[];
    return OmdbTitleDetailsDto(
      title: _normalizeText(json['Title'] as String?),
      year: _normalizeText(json['Year'] as String?),
      rated: _normalizeText(json['Rated'] as String?),
      released: _normalizeText(json['Released'] as String?),
      runtime: _normalizeText(json['Runtime'] as String?),
      genre: _normalizeText(json['Genre'] as String?),
      director: _normalizeText(json['Director'] as String?),
      writer: _normalizeText(json['Writer'] as String?),
      actors: _normalizeText(json['Actors'] as String?),
      language: _normalizeText(json['Language'] as String?),
      country: _normalizeText(json['Country'] as String?),
      awards: _normalizeText(json['Awards'] as String?),
      boxOffice: _normalizeText(json['BoxOffice'] as String?),
      imdbRating: _normalizeText(json['imdbRating'] as String?),
      imdbVotes: _normalizeText(json['imdbVotes'] as String?),
      metascore: _normalizeText(json['Metascore'] as String?),
      plot: _normalizeText(json['Plot'] as String?),
      type: _normalizeText(json['Type'] as String?),
      poster: _normalizePoster(json['Poster'] as String?),
      ratings: _parseRatings(rawRatings),
    );
  }

  final String? title;
  final String? year;
  final String? rated;
  final String? released;
  final String? runtime;
  final String? genre;
  final String? director;
  final String? writer;
  final String? actors;
  final String? language;
  final String? country;
  final String? awards;
  final String? boxOffice;
  final String? imdbRating;
  final String? imdbVotes;
  final String? metascore;
  final String? plot;
  final String? type;
  final String? poster;
  final List<MovieRating> ratings;

  static String? _normalizeText(String? value) {
    final String normalized = (value ?? '').trim();
    if (normalized.isEmpty || normalized == 'N/A') {
      return null;
    }
    return normalized;
  }

  static String? _normalizePoster(String? value) {
    final String? normalized = _normalizeText(value);
    if (normalized == null) {
      return null;
    }
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }
    return null;
  }

  static List<MovieRating> _parseRatings(List<dynamic> rawRatings) {
    final List<MovieRating> parsed = <MovieRating>[];
    for (final Map<String, dynamic> entry
        in rawRatings.whereType<Map<String, dynamic>>()) {
      final String source = _normalizeText(entry['Source'] as String?) ?? '';
      final String value = _normalizeText(entry['Value'] as String?) ?? '';
      if (source.isEmpty || value.isEmpty) {
        continue;
      }
      parsed.add(MovieRating(source: source, value: value));
    }
    return List<MovieRating>.unmodifiable(parsed);
  }
}
