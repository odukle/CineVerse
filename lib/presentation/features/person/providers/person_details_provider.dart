import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/person_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Map<int, String> tmdbGenreMap = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Sci-Fi',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
  10759: 'Action & Adventure',
  10762: 'Kids',
  10763: 'News',
  10764: 'Reality',
  10765: 'Sci-Fi & Fantasy',
  10766: 'Soap',
  10767: 'Talk',
  10768: 'War & Politics',
};

class Collaborator {
  const Collaborator({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.count,
    required this.role,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final int count;
  final String role;
}

class PersonAnalyticsData {
  const PersonAnalyticsData({
    required this.actingCount,
    required this.directingCount,
    required this.writingCount,
    required this.otherCount,
    required this.averageRating,
    required this.mostFrequentGenre,
    required this.mostFrequentGenrePercent,
    this.highestGrossingMovie,
    this.fallbackHighestGrossing,
    this.collaborators = const [],
  });

  final int actingCount;
  final int directingCount;
  final int writingCount;
  final int otherCount;
  final double averageRating;
  final String mostFrequentGenre;
  final int mostFrequentGenrePercent;
  final MovieDetails? highestGrossingMovie;
  final MediaTitle? fallbackHighestGrossing;
  final List<Collaborator> collaborators;
}

final personDetailsProvider = FutureProvider.family<PersonDetails, int>((ref, personId) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return repository.fetchPersonDetails(personId);
});

final personAnalyticsProvider = FutureProvider.family<PersonAnalyticsData, int>((ref, personId) async {
  final details = await ref.watch(personDetailsProvider(personId).future);
  final repository = ref.watch(mediaRepositoryProvider);

  int actingCount = details.creditsByDepartment['Acting']?.length ?? 0;
  int directingCount = details.creditsByDepartment['Directing']?.length ?? 0;
  int writingCount = details.creditsByDepartment['Writing']?.length ?? 0;

  int otherCount = 0;
  details.creditsByDepartment.forEach((dept, list) {
    if (dept != 'Acting' && dept != 'Directing' && dept != 'Writing') {
      otherCount += list.length;
    }
  });

  final List<MediaTitle> allMedia = [];
  details.creditsByDepartment.forEach((dept, list) {
    for (final credit in list) {
      allMedia.add(credit.media);
    }
  });

  final ratedMedia = allMedia.where((m) => m.voteAverage != null && m.voteAverage! > 0).toList();
  double averageRating = 0.0;
  if (ratedMedia.isNotEmpty) {
    averageRating = ratedMedia.map((m) => m.voteAverage!).reduce((a, b) => a + b) / ratedMedia.length;
  }

  final genreCounts = <int, int>{};
  for (final media in allMedia) {
    for (final genreId in media.genreIds) {
      genreCounts[genreId] = (genreCounts[genreId] ?? 0) + 1;
    }
  }

  int? topGenreId;
  int maxGenreCount = 0;
  genreCounts.forEach((id, count) {
    if (count > maxGenreCount) {
      maxGenreCount = count;
      topGenreId = id;
    }
  });

  final totalGenreOccurrences = genreCounts.values.fold<int>(0, (a, b) => a + b);
  final mostFrequentGenre = topGenreId != null ? (tmdbGenreMap[topGenreId] ?? 'Unknown') : 'None';
  final mostFrequentGenrePercent = totalGenreOccurrences > 0
      ? ((maxGenreCount / totalGenreOccurrences) * 100).round()
      : 0;

  final movieCredits = allMedia
      .where((m) => m.mediaType == GlobalMediaType.movie)
      .toList();

  final Map<int, MediaTitle> uniqueMovies = {};
  for (final m in movieCredits) {
    uniqueMovies[m.id] = m;
  }

  final sortedMovies = uniqueMovies.values.toList()
    ..sort((a, b) => b.popularity.compareTo(a.popularity));

  final top5Movies = sortedMovies.take(5).toList();

  final movieDetailsList = await Future.wait(
    top5Movies.map((m) => repository
        .fetchMovieDetails(m.id, isTv: false)
        .then<MovieDetails?>((v) => v)
        .catchError((_) => null)),
  );

  final validMovieDetailsList = movieDetailsList.whereType<MovieDetails>().toList();

  MovieDetails? highestGrossingMovie;
  int maxRevenue = 0;
  for (final movie in validMovieDetailsList) {
    if (movie.revenue != null && movie.revenue! > maxRevenue) {
      maxRevenue = movie.revenue!;
      highestGrossingMovie = movie;
    }
  }

  final collaboratorCounts = <int, Collaborator>{};
  for (final movie in validMovieDetailsList) {
    for (final actor in movie.cast) {
      if (actor.id == personId) continue;
      final existing = collaboratorCounts[actor.id];
      if (existing == null) {
        collaboratorCounts[actor.id] = Collaborator(
          id: actor.id,
          name: actor.name,
          imageUrl: actor.imageUrl,
          count: 1,
          role: 'Actor',
        );
      } else {
        collaboratorCounts[actor.id] = Collaborator(
          id: actor.id,
          name: actor.name,
          imageUrl: actor.imageUrl,
          count: existing.count + 1,
          role: existing.role,
        );
      }
    }
    for (final crew in movie.crew) {
      if (crew.id == personId) continue;
      final existing = collaboratorCounts[crew.id];
      if (existing == null) {
        collaboratorCounts[crew.id] = Collaborator(
          id: crew.id,
          name: crew.name,
          imageUrl: crew.imageUrl,
          count: 1,
          role: crew.role,
        );
      } else {
        collaboratorCounts[crew.id] = Collaborator(
          id: crew.id,
          name: crew.name,
          imageUrl: crew.imageUrl,
          count: existing.count + 1,
          role: existing.role,
        );
      }
    }
  }

  final sortedCollaborators = collaboratorCounts.values.toList()
    ..sort((a, b) => b.count.compareTo(a.count));

  final collaborators = sortedCollaborators.take(5).toList();

  return PersonAnalyticsData(
    actingCount: actingCount,
    directingCount: directingCount,
    writingCount: writingCount,
    otherCount: otherCount,
    averageRating: averageRating,
    mostFrequentGenre: mostFrequentGenre,
    mostFrequentGenrePercent: mostFrequentGenrePercent,
    highestGrossingMovie: highestGrossingMovie,
    fallbackHighestGrossing: sortedMovies.isNotEmpty ? sortedMovies.first : null,
    collaborators: collaborators,
  );
});
