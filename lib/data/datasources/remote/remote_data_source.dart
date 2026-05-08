import 'package:cineverse/data/datasources/remote/tmdb_api_client.dart';
import 'package:cineverse/data/models/tmdb_movie_details_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_genre_dto.dart';
import 'package:cineverse/data/models/tmdb_movies_response_dto.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_images.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_section.dart';

abstract interface class RemoteDataSource {
  Future<List<TmdbMovieDto>> fetchPopularMovies();

  Future<List<TmdbMovieGenreDto>> fetchMovieGenres();
  Future<List<TmdbMovieGenreDto>> fetchTvGenres();

  Future<List<TmdbMovieDto>> fetchMoviesForGenre(int genreId, {int page = 1});
  Future<List<TmdbMovieDto>> fetchTvShowsForGenre(int genreId, {int page = 1});

  Future<List<TmdbMovieDto>> fetchMoviesForSection(MovieSection section);

  Future<List<TmdbMovieDto>> fetchMoviesForSectionPage(
    MovieSection section, {
    int page = 1,
  });

  Future<List<TmdbMovieDto>> discoverMedia({
    required bool isTv,
    required MediaFilter filter,
    int page = 1,
  });

  Future<TmdbMovieDetailsDto> fetchMovieDetails(
    int movieId, {
    bool isTv = false,
  });

  Future<List<MovieRecommendation>> fetchMovieRecommendations(
    int movieId, {
    int page = 1,
    bool isTv = false,
  });

  Future<MediaImages> fetchMediaImages(int mediaId, {required bool isTv});
}

class TmdbRemoteDataSource implements RemoteDataSource {
  const TmdbRemoteDataSource(this.apiClient);

  final TmdbApiClient apiClient;

  @override
  Future<List<TmdbMovieDto>> fetchPopularMovies() async {
    final TmdbMoviesResponseDto response = await apiClient.fetchPopularMovies();
    return response.movies;
  }

  @override
  Future<List<TmdbMovieGenreDto>> fetchMovieGenres() {
    return apiClient.fetchMovieGenres();
  }

  @override
  Future<List<TmdbMovieGenreDto>> fetchTvGenres() {
    return apiClient.fetchTvGenres();
  }

  @override
  Future<List<TmdbMovieDto>> fetchMoviesForGenre(
    int genreId, {
    int page = 1,
  }) async {
    final TmdbMoviesResponseDto response = await apiClient.fetchMoviesForGenre(
      genreId,
      page: page,
    );
    return response.movies;
  }

  @override
  Future<List<TmdbMovieDto>> fetchTvShowsForGenre(
    int genreId, {
    int page = 1,
  }) async {
    final TmdbMoviesResponseDto response = await apiClient.fetchTvShowsForGenre(
      genreId,
      page: page,
    );
    return response.movies;
  }

  @override
  Future<List<TmdbMovieDto>> fetchMoviesForSection(MovieSection section) async {
    return fetchMoviesForSectionPage(section);
  }

  @override
  Future<List<TmdbMovieDto>> fetchMoviesForSectionPage(
    MovieSection section, {
    int page = 1,
  }) async {
    final TmdbMoviesResponseDto response = await apiClient
        .fetchMoviesForSection(section, page: page);
    return response.movies;
  }

  @override
  Future<List<TmdbMovieDto>> discoverMedia({
    required bool isTv,
    required MediaFilter filter,
    int page = 1,
  }) async {
    final TmdbMoviesResponseDto response = await apiClient.discoverMedia(
      isTv: isTv,
      filter: filter,
      page: page,
    );
    return response.movies;
  }

  @override
  Future<TmdbMovieDetailsDto> fetchMovieDetails(
    int movieId, {
    bool isTv = false,
  }) async {
    return apiClient.fetchMovieDetails(movieId, isTv: isTv);
  }

  @override
  Future<List<MovieRecommendation>> fetchMovieRecommendations(
    int movieId, {
    int page = 1,
    bool isTv = false,
  }) {
    return apiClient.fetchMovieRecommendations(movieId, page: page, isTv: isTv);
  }

  @override
  Future<MediaImages> fetchMediaImages(int mediaId, {required bool isTv}) {
    return apiClient.fetchMediaImages(mediaId, isTv: isTv);
  }
}
