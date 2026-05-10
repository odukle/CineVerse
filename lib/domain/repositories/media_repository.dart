import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_images.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/entities/person_details.dart';

abstract interface class MediaRepository {
  Future<List<MediaTitle>> fetchPopularMovies();

  Future<List<MovieGenre>> fetchMovieGenres();
  Future<List<MovieGenre>> fetchTvGenres();

  Future<List<MediaTitle>> fetchMoviesForGenre(int genreId, {int page = 1});
  Future<List<MediaTitle>> fetchTvShowsForGenre(int genreId, {int page = 1});

  Future<List<MediaTitle>> fetchMoviesForSection(MovieSection section);

  Future<List<MediaTitle>> fetchMoviesForSectionPage(
    MovieSection section, {
    int page = 1,
  });

  Future<List<MediaTitle>> discoverMedia({
    required bool isTv,
    required MediaFilter filter,
    String? query,
    int page = 1,
  });

  Future<List<MediaTitle>> searchMulti(String query, {int page = 1});

  Future<MovieDetails> fetchMovieDetails(int movieId, {bool isTv = false});

  Future<List<MovieRecommendation>> fetchMovieRecommendations(
    int movieId, {
    int page = 1,
    bool isTv = false,
  });

  Future<MediaImages> fetchMediaImages(int mediaId, {required bool isTv});
  Future<MediaImages> fetchPersonImages(int personId);

  Future<PersonDetails> fetchPersonDetails(int personId);
  Future<List<MediaTitle>> searchPersons(String query, {int page = 1});
}
