import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_images.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/movie_section.dart';

abstract interface class MediaRepository {
  Future<List<MediaTitle>> fetchPopularMovies();

  Future<List<MovieGenre>> fetchMovieGenres();
  Future<List<MovieGenre>> fetchTvGenres();

  Future<List<MediaTitle>> fetchMoviesForGenre(int genreId, {int page = 1});

  Future<List<MediaTitle>> fetchMoviesForSection(MovieSection section);

  Future<List<MediaTitle>> fetchMoviesForSectionPage(
    MovieSection section, {
    int page = 1,
  });

  Future<List<MediaTitle>> discoverMedia({
    required bool isTv,
    required MediaFilter filter,
    int page = 1,
  });

  Future<MovieDetails> fetchMovieDetails(int movieId, {bool isTv = false});

  Future<List<MovieRecommendation>> fetchMovieRecommendations(
    int movieId, {
    int page = 1,
    bool isTv = false,
  });

  Future<MediaImages> fetchMediaImages(int mediaId, {required bool isTv});
}
