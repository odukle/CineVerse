import 'package:cineverse/data/datasources/remote/tmdb_api_client.dart';
import 'package:cineverse/data/models/tmdb_movie_details_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_genre_dto.dart';
import 'package:cineverse/data/models/tmdb_movies_response_dto.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_section.dart';

abstract interface class RemoteDataSource {
  Future<List<TmdbMovieDto>> fetchPopularMovies();

  Future<List<TmdbMovieGenreDto>> fetchMovieGenres();

  Future<List<TmdbMovieDto>> fetchMoviesForGenre(int genreId, {int page = 1});

  Future<List<TmdbMovieDto>> fetchMoviesForSection(MovieSection section);

  Future<List<TmdbMovieDto>> fetchMoviesForSectionPage(
    MovieSection section, {
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
}
