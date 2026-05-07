import 'package:cineverse/data/datasources/local/local_data_source.dart';
import 'package:cineverse/data/datasources/remote/omdb_api_client.dart';
import 'package:cineverse/data/datasources/remote/remote_data_source.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
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
    return genreDtos
        .map((genreDto) => genreDto.toDomain())
        .toList(growable: false);
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
  Future<List<MediaTitle>> fetchMoviesForSection(MovieSection section) async {
    return fetchMoviesForSectionPage(section);
  }

  @override
  Future<List<MediaTitle>> fetchMoviesForSectionPage(
    MovieSection section, {
    int page = 1,
  }) async {
    final movieDtos = await remoteDataSource.fetchMoviesForSectionPage(
      section,
      page: page,
    );

    return movieDtos
        .map((movieDto) => movieDto.toDomain())
        .toList(growable: false);
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
        externalRatings: omdbRatingsDto?.toDomain() ?? const <MovieRating>[],
      );
    } on OmdbApiException catch (error) {
      debugPrint('[MovieDetails] OMDb ratings unavailable for $imdbId: $error');
      return baseDetails;
    }
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
}
