import 'package:cineverse/data/datasources/remote/tmdb_api_client.dart';
import 'package:cineverse/data/models/tmdb_movie_details_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_dto.dart';
import 'package:cineverse/data/models/tmdb_movie_genre_dto.dart';
import 'package:cineverse/data/models/tmdb_movies_response_dto.dart';
import 'package:cineverse/data/models/tmdb_person_details_dto.dart';
import 'package:cineverse/data/models/tmdb_review_dto.dart';
import 'package:cineverse/data/models/tmdb_tv_details_dto.dart';
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
    MediaFilter? filter,
  });

  Future<List<TmdbMovieDto>> discoverMedia({
    required bool isTv,
    required MediaFilter filter,
    String? query,
    int page = 1,
  });

  Future<List<TmdbMovieDto>> searchMovies(String query, {int page = 1});
  Future<List<TmdbMovieDto>> searchTvShows(String query, {int page = 1});
  Future<List<TmdbMovieDto>> searchMulti(String query, {int page = 1});
  Future<List<TmdbMovieDto>> searchPersons(String query, {int page = 1});

  Future<TmdbMovieDetailsDto> fetchMovieDetails(
    int movieId, {
    bool isTv = false,
  });

  Future<List<MovieRecommendation>> fetchMovieRecommendations(
    int movieId, {
    int page = 1,
    bool isTv = false,
  });

  Future<List<TmdbReviewDto>> fetchMediaReviews(
    int mediaId, {
    int page = 1,
    required bool isTv,
  });

  Future<MediaImages> fetchMediaImages(int mediaId, {required bool isTv});
  Future<MediaImages> fetchPersonImages(int personId);

  Future<TmdbPersonDetailsDto> fetchPersonDetails(int personId);
  Future<TmdbPersonCombinedCreditsDto> fetchPersonCombinedCredits(int personId);

  Future<TmdbTvSeasonDto> fetchTvSeasonDetails(int tvId, int seasonNumber);
  Future<TmdbTvEpisodeDto> fetchTvEpisodeDetails(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  );
  Future<MediaImages> fetchTvSeasonImages(int tvId, int seasonNumber);
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
    MediaFilter? filter,
  }) async {
    final TmdbMoviesResponseDto response = await apiClient
        .fetchMoviesForSection(section, page: page, filter: filter);
    return response.movies;
  }

  @override
  Future<List<TmdbMovieDto>> discoverMedia({
    required bool isTv,
    required MediaFilter filter,
    String? query,
    int page = 1,
  }) async {
    final TmdbMoviesResponseDto response = await apiClient.discoverMedia(
      isTv: isTv,
      filter: filter,
      query: query,
      page: page,
    );
    return response.movies;
  }

  @override
  Future<List<TmdbMovieDto>> searchMovies(String query, {int page = 1}) async {
    final TmdbMoviesResponseDto response = await apiClient.searchMovies(
      query,
      page: page,
    );
    return response.movies;
  }

  @override
  Future<List<TmdbMovieDto>> searchTvShows(String query, {int page = 1}) async {
    final TmdbMoviesResponseDto response = await apiClient.searchTvShows(
      query,
      page: page,
    );
    return response.movies;
  }

  @override
  Future<List<TmdbMovieDto>> searchMulti(String query, {int page = 1}) async {
    final TmdbMoviesResponseDto response = await apiClient.searchMulti(
      query,
      page: page,
    );
    return response.movies;
  }

  @override
  Future<List<TmdbMovieDto>> searchPersons(String query, {int page = 1}) async {
    final TmdbMoviesResponseDto response = await apiClient.searchPersons(
      query,
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
  Future<List<TmdbReviewDto>> fetchMediaReviews(
    int mediaId, {
    int page = 1,
    required bool isTv,
  }) {
    return apiClient.fetchMediaReviews(mediaId, page: page, isTv: isTv);
  }

  @override
  Future<MediaImages> fetchMediaImages(int mediaId, {required bool isTv}) {
    return apiClient.fetchMediaImages(mediaId, isTv: isTv);
  }

  @override
  Future<MediaImages> fetchPersonImages(int personId) {
    return apiClient.fetchPersonImages(personId);
  }

  @override
  Future<TmdbPersonDetailsDto> fetchPersonDetails(int personId) {
    return apiClient.fetchPersonDetails(personId);
  }

  @override
  Future<TmdbPersonCombinedCreditsDto> fetchPersonCombinedCredits(
    int personId,
  ) {
    return apiClient.fetchPersonCombinedCredits(personId);
  }

  @override
  Future<TmdbTvSeasonDto> fetchTvSeasonDetails(int tvId, int seasonNumber) {
    return apiClient.fetchTvSeasonDetails(tvId, seasonNumber);
  }

  @override
  Future<TmdbTvEpisodeDto> fetchTvEpisodeDetails(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) {
    return apiClient.fetchTvEpisodeDetails(tvId, seasonNumber, episodeNumber);
  }

  @override
  Future<MediaImages> fetchTvSeasonImages(int tvId, int seasonNumber) {
    return apiClient.fetchTvSeasonImages(tvId, seasonNumber);
  }
}
