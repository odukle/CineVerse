import 'package:cineverse/data/datasources/local/local_data_source.dart';
import 'package:cineverse/data/datasources/remote/omdb_api_client.dart';
import 'package:cineverse/data/datasources/remote/remote_data_source.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_images.dart';
import 'package:cineverse/domain/entities/media_review.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/entities/person_details.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:flutter/foundation.dart';

class MediaRepositoryImpl implements MediaRepository {
  const MediaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.omdbApiClient,
  });

  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final OmdbApiClient omdbApiClient;

  @override
  Future<List<MediaTitle>> fetchPopularMovies() async {
    final movieDtos = await remoteDataSource.fetchPopularMovies();

    return movieDtos
        .map((movieDto) => movieDto.toDomain())
        .toList(growable: false);
  }

  @override
  Future<List<MovieGenre>> fetchMovieGenres() async {
    final genreDtos = await remoteDataSource.fetchMovieGenres();
    return genreDtos.map((dto) => dto.toDomain()).toList(growable: false);
  }

  @override
  Future<List<MovieGenre>> fetchTvGenres() async {
    final genreDtos = await remoteDataSource.fetchTvGenres();
    return genreDtos.map((dto) => dto.toDomain()).toList(growable: false);
  }

  @override
  Future<List<MediaTitle>> fetchMoviesForGenre(
    int genreId, {
    int page = 1,
  }) async {
    final movieDtos = await remoteDataSource.fetchMoviesForGenre(
      genreId,
      page: page,
    );

    return movieDtos
        .map((movieDto) => movieDto.toDomain())
        .toList(growable: false);
  }

  @override
  Future<List<MediaTitle>> fetchTvShowsForGenre(
    int genreId, {
    int page = 1,
  }) async {
    final movieDtos = await remoteDataSource.fetchTvShowsForGenre(
      genreId,
      page: page,
    );

    return movieDtos
        .map((movieDto) => movieDto.toDomain())
        .toList(growable: false);
  }

  @override
  Future<List<MediaTitle>> fetchMoviesForSection(MovieSection section) async {
    return fetchMoviesForSectionPage(section);
  }

  @override
  Future<List<MediaTitle>> fetchMoviesForSectionPage(
    MovieSection section, {
    int page = 1,
    MediaFilter? filter,
  }) async {
    final movieDtos = await remoteDataSource.fetchMoviesForSectionPage(
      section,
      page: page,
      filter: filter,
    );

    return movieDtos
        .map((movieDto) => movieDto.toDomain())
        .toList(growable: false);
  }

  @override
  Future<List<MediaTitle>> discoverMedia({
    required bool isTv,
    required MediaFilter filter,
    String? query,
    int page = 1,
  }) async {
    final movieDtos = await remoteDataSource.discoverMedia(
      isTv: isTv,
      filter: filter,
      query: query,
      page: page,
    );

    return movieDtos
        .map((movieDto) => movieDto.toDomain().copyWith(
              mediaType: isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
            ))
        .toList(growable: false);
  }

  @override
  Future<List<MediaTitle>> searchMovies(String query, {int page = 1}) async {
    final results = await remoteDataSource.searchMovies(query, page: page);
    return results
        .map((m) => m.toDomain().copyWith(mediaType: GlobalMediaType.movie))
        .toList();
  }

  @override
  Future<List<MediaTitle>> searchTvShows(String query, {int page = 1}) async {
    final results = await remoteDataSource.searchTvShows(query, page: page);
    return results
        .map((m) => m.toDomain().copyWith(mediaType: GlobalMediaType.tv))
        .toList();
  }

  @override
  Future<List<MediaTitle>> searchMulti(String query, {int page = 1}) async {
    final movieDtos = await remoteDataSource.searchMulti(query, page: page);

    return movieDtos
        .map((movieDto) => movieDto.toDomain())
        .toList(growable: false);
  }

  @override
  Future<List<MediaTitle>> searchPersons(String query, {int page = 1}) async {
    final results = await remoteDataSource.searchPersons(query, page: page);
    return results
        .map((m) => m.toDomain().copyWith(mediaType: GlobalMediaType.person))
        .toList();
  }

  @override
  Future<TvSeason> fetchTvSeasonDetails(int tvId, int seasonNumber) async {
    final dto = await remoteDataSource.fetchTvSeasonDetails(tvId, seasonNumber);
    return dto.toDomain();
  }

  @override
  Future<TvEpisode> fetchTvEpisodeDetails(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    final dto = await remoteDataSource.fetchTvEpisodeDetails(
      tvId,
      seasonNumber,
      episodeNumber,
    );
    return dto.toDomain();
  }

  @override
  Future<MovieDetails> fetchMovieDetails(
    int movieId, {
    bool isTv = false,
  }) async {
    final movieDetailsDto = await remoteDataSource.fetchMovieDetails(
      movieId,
      isTv: isTv,
    );
    final MovieDetails baseDetails = movieDetailsDto.toDomain();
    final String? imdbId = movieDetailsDto.imdbId;

    if (imdbId == null || imdbId.isEmpty) {
      return baseDetails;
    }

    try {
      final omdbRatingsDto = await omdbApiClient.fetchMovieRatings(imdbId);
      return baseDetails.copyWith(
        externalRatings:
            omdbRatingsDto?.toDomain(
              imdbId: imdbId,
              title: baseDetails.title,
            ) ??
            const <MovieRating>[],
      );
    } on OmdbApiException catch (error) {
      debugPrint('[MovieDetails] OMDb ratings unavailable for $imdbId: $error');
      return baseDetails;
    }
  }

  @override
  Future<List<MediaReview>> fetchMediaReviews(
    int mediaId, {
    int page = 1,
    required bool isTv,
  }) async {
    final reviewDtos = await remoteDataSource.fetchMediaReviews(
      mediaId,
      page: page,
      isTv: isTv,
    );

    return reviewDtos
        .map((dto) => dto.toDomain())
        .toList(growable: false);
  }

  @override
  Future<List<MovieRecommendation>> fetchMovieRecommendations(
    int movieId, {
    int page = 1,
    bool isTv = false,
  }) async {
    return remoteDataSource.fetchMovieRecommendations(
      movieId,
      page: page,
      isTv: isTv,
    );
  }

  @override
  Future<MediaImages> fetchMediaImages(int mediaId, {required bool isTv}) {
    return remoteDataSource.fetchMediaImages(mediaId, isTv: isTv);
  }

  @override
  Future<MediaImages> fetchPersonImages(int personId) {
    return remoteDataSource.fetchPersonImages(personId);
  }

  @override
  Future<PersonDetails> fetchPersonDetails(int personId) async {
    final personDetailsDto = await remoteDataSource.fetchPersonDetails(
      personId,
    );
    final creditsDto = await remoteDataSource.fetchPersonCombinedCredits(
      personId,
    );

    final Map<String, List<PersonCredit>> creditsByDepartment = {};

    // Process Cast Credits (Acting)
    for (final castDto in creditsDto.cast) {
      final media = castDto.media.toDomain();
      final isTv = media.mediaType == GlobalMediaType.tv;
      final deptLabel = 'Acting (${isTv ? "TV" : "Movies"})';

      final credit = PersonCredit(
        media: media,
        role: castDto.character,
        department: 'Acting',
      );
      creditsByDepartment.putIfAbsent(deptLabel, () => []).add(credit);
    }

    // Process Crew Credits
    for (final crewDto in creditsDto.crew) {
      final dept = crewDto.department ?? 'Other';
      final media = crewDto.media.toDomain();
      final isTv = media.mediaType == GlobalMediaType.tv;
      final deptLabel = '$dept (${isTv ? "TV" : "Movies"})';

      final credit = PersonCredit(
        media: media,
        role: crewDto.job,
        department: dept,
      );
      creditsByDepartment.putIfAbsent(deptLabel, () => []).add(credit);
    }

    // Deduplicate and sort each department
    for (final dept in creditsByDepartment.keys) {
      final credits = creditsByDepartment[dept]!;
      final seenIds = <int>{};
      final uniqueCredits =
          credits.where((e) => seenIds.add(e.media.id)).toList();
      uniqueCredits.sort(
        (a, b) => b.media.popularity.compareTo(a.media.popularity),
      );
      creditsByDepartment[dept] = uniqueCredits;
    }

    return personDetailsDto.toDomain(creditsByDepartment: creditsByDepartment);
  }
}
