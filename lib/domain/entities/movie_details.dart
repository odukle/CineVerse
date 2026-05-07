class MovieDetails {
  const MovieDetails({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.genres = const <String>[],
    this.runtimeMinutes,
    this.cast = const <MovieCredit>[],
    this.crew = const <MovieCredit>[],
    this.externalRatings = const <MovieRating>[],
    this.contentRating,
    this.contentRatingDescription,
    this.catalogScore,
    this.tagline,
    this.budget,
    this.revenue,
    this.originalLanguage,
    this.status,
    this.voteCount,
    this.recommendations = const <MovieRecommendation>[],
    this.watchAvailability,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final String? releaseDate;
  final List<String> genres;
  final int? runtimeMinutes;
  final List<MovieCredit> cast;
  final List<MovieCredit> crew;
  final List<MovieRating> externalRatings;
  final String? contentRating;
  final String? contentRatingDescription;
  final double? catalogScore;
  final String? tagline;
  final int? budget;
  final int? revenue;
  final String? originalLanguage;
  final String? status;
  final int? voteCount;
  final List<MovieRecommendation> recommendations;
  final MovieWatchAvailability? watchAvailability;

  MovieDetails copyWith({
    List<MovieRating>? externalRatings,
    MovieWatchAvailability? watchAvailability,
  }) {
    return MovieDetails(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      releaseDate: releaseDate,
      genres: genres,
      runtimeMinutes: runtimeMinutes,
      cast: cast,
      crew: crew,
      externalRatings: externalRatings ?? this.externalRatings,
      contentRating: contentRating,
      contentRatingDescription: contentRatingDescription,
      catalogScore: catalogScore,
      tagline: tagline,
      budget: budget,
      revenue: revenue,
      originalLanguage: originalLanguage,
      status: status,
      voteCount: voteCount,
      recommendations: recommendations,
      watchAvailability: watchAvailability ?? this.watchAvailability,
    );
  }
}

class MovieCredit {
  const MovieCredit({
    required this.name,
    required this.role,
    this.characterName,
    this.imageUrl,
  });

  final String name;
  final String role;
  final String? characterName;
  final String? imageUrl;
}

class MovieRating {
  const MovieRating({required this.source, required this.value});

  final String source;
  final String value;
}

class MovieRecommendation {
  const MovieRecommendation({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
}

class MovieWatchAvailability {
  const MovieWatchAvailability({
    this.link,
    this.streaming = const <MovieWatchProvider>[],
    this.free = const <MovieWatchProvider>[],
    this.rent = const <MovieWatchProvider>[],
    this.buy = const <MovieWatchProvider>[],
  });

  final String? link;
  final List<MovieWatchProvider> streaming;
  final List<MovieWatchProvider> free;
  final List<MovieWatchProvider> rent;
  final List<MovieWatchProvider> buy;

  bool get hasProviders =>
      streaming.isNotEmpty ||
      free.isNotEmpty ||
      rent.isNotEmpty ||
      buy.isNotEmpty;
}

class MovieWatchProvider {
  const MovieWatchProvider({
    required this.id,
    required this.name,
    this.logoPath,
  });

  final int id;
  final String name;
  final String? logoPath;
}
