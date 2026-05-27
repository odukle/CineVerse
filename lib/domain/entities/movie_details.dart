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
    this.facebookId,
    this.instagramId,
    this.twitterId,
    this.tiktokId,
    this.youtubeId,
    this.wikidataId,
    this.trailerYouTubeKey,
    this.seasons = const <TvSeason>[],
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.lastEpisodeToAir,
    this.nextEpisodeToAir,
    this.awards,
    this.digitalReleaseDate,
    this.physicalReleaseDate,
    this.belongsToCollection,
    this.keywords = const <MovieKeyword>[],
    this.videos = const <MovieVideo>[],
    this.productionCompanies = const <ProductionCompany>[],
    this.productionCountries = const <String>[],
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
  final String? facebookId;
  final String? instagramId;
  final String? twitterId;
  final String? tiktokId;
  final String? youtubeId;
  final String? wikidataId;
  final String? trailerYouTubeKey;
  final List<TvSeason> seasons;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final TvEpisode? lastEpisodeToAir;
  final TvEpisode? nextEpisodeToAir;
  final String? awards;
  final String? digitalReleaseDate;
  final String? physicalReleaseDate;
  final MovieCollectionInfo? belongsToCollection;
  final List<MovieKeyword> keywords;
  final List<MovieVideo> videos;
  final List<ProductionCompany> productionCompanies;
  final List<String> productionCountries;

  bool get hasSocialHandles =>
      (facebookId?.isNotEmpty ?? false) ||
      (instagramId?.isNotEmpty ?? false) ||
      (twitterId?.isNotEmpty ?? false) ||
      (tiktokId?.isNotEmpty ?? false) ||
      (youtubeId?.isNotEmpty ?? false) ||
      (imdbId?.isNotEmpty ?? false);

  MovieDetails copyWith({
    List<MovieRating>? externalRatings,
    MovieWatchAvailability? watchAvailability,
    String? awards,
    String? digitalReleaseDate,
    String? physicalReleaseDate,
    MovieCollectionInfo? belongsToCollection,
    List<MovieKeyword>? keywords,
    List<MovieVideo>? videos,
    List<ProductionCompany>? productionCompanies,
    List<String>? productionCountries,
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
      facebookId: facebookId,
      instagramId: instagramId,
      twitterId: twitterId,
      tiktokId: tiktokId,
      youtubeId: youtubeId,
      wikidataId: wikidataId,
      trailerYouTubeKey: trailerYouTubeKey,
      seasons: seasons,
      numberOfSeasons: numberOfSeasons,
      numberOfEpisodes: numberOfEpisodes,
      lastEpisodeToAir: lastEpisodeToAir,
      nextEpisodeToAir: nextEpisodeToAir,
      awards: awards ?? this.awards,
      digitalReleaseDate: digitalReleaseDate ?? this.digitalReleaseDate,
      physicalReleaseDate: physicalReleaseDate ?? this.physicalReleaseDate,
      belongsToCollection: belongsToCollection ?? this.belongsToCollection,
      keywords: keywords ?? this.keywords,
      videos: videos ?? this.videos,
      productionCompanies: productionCompanies ?? this.productionCompanies,
      productionCountries: productionCountries ?? this.productionCountries,
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

class MovieCollectionInfo {
  const MovieCollectionInfo({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
  });

  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;
}

class MovieVideo {
  const MovieVideo({
    required this.name,
    required this.key,
    required this.site,
    required this.type,
    required this.official,
  });

  final String name;
  final String key;
  final String site;
  final String type;
  final bool official;
}

class ProductionCompany {
  const ProductionCompany({
    required this.id,
    required this.name,
    this.logoPath,
    required this.originCountry,
  });

  final int id;
  final String name;
  final String? logoPath;
  final String originCountry;
}

class MovieKeyword {
  const MovieKeyword({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}
