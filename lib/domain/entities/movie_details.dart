import 'package:cineverse/domain/entities/media_title.dart';

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
    this.imdbId,
    this.trailerYouTubeKey,
    this.seasons = const <TvSeason>[],
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.lastEpisodeToAir,
    this.nextEpisodeToAir,
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
  final String? imdbId;
  final String? trailerYouTubeKey;
  final List<TvSeason> seasons;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final TvEpisode? lastEpisodeToAir;
  final TvEpisode? nextEpisodeToAir;

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
      imdbId: imdbId,
      trailerYouTubeKey: trailerYouTubeKey,
      seasons: seasons,
      numberOfSeasons: numberOfSeasons,
      numberOfEpisodes: numberOfEpisodes,
      lastEpisodeToAir: lastEpisodeToAir,
      nextEpisodeToAir: nextEpisodeToAir,
    );
  }
}

class TvSeason {
  const TvSeason({
    required this.id,
    required this.seasonNumber,
    required this.name,
    this.overview,
    this.posterPath,
    this.episodeCount,
    this.airDate,
    this.voteAverage,
    this.episodes = const <TvEpisode>[],
  });

  final int id;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? posterPath;
  final int? episodeCount;
  final String? airDate;
  final double? voteAverage;
  final List<TvEpisode> episodes;
}

class TvEpisode {
  const TvEpisode({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    this.overview,
    this.airDate,
    this.stillPath,
    this.voteAverage,
    this.runtimeMinutes,
    this.cast = const <MovieCredit>[],
    this.crew = const <MovieCredit>[],
    this.images = const <String>[],
  });

  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? airDate;
  final String? stillPath;
  final double? voteAverage;
  final int? runtimeMinutes;
  final List<MovieCredit> cast;
  final List<MovieCredit> crew;
  final List<String> images;
}

class MovieCredit {
  const MovieCredit({
    required this.id,
    required this.name,
    required this.role,
    this.characterName,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String role;
  final String? characterName;
  final String? imageUrl;
}

class MovieRating {
  const MovieRating({required this.source, required this.value, this.url});

  final String source;
  final String value;
  final String? url;
}

class MovieRecommendation {
  const MovieRecommendation({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
    this.voteAverage,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final double? voteAverage;

  MediaTitle toMediaTitle() {
    return MediaTitle(
      id: id,
      title: title,
      posterPath: posterPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
    );
  }
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
