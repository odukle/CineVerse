import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/person_details.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int _collaborationMovieDetailsBatchSize = 6;

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
    this.sharedTitles = const [],
  });

  final int id;
  final String name;
  final String? imageUrl;
  final int count;
  final String role;
  final List<SharedCollaborationTitle> sharedTitles;
}

class SharedCollaborationTitle {
  const SharedCollaborationTitle({
    required this.media,
    required this.personRole,
    required this.collaboratorRole,
  });

  final MediaTitle media;
  final String personRole;
  final String collaboratorRole;
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

class PersonAnalyticsProgress {
  const PersonAnalyticsProgress({required this.value, required this.message});

  final double value;
  final String message;
}

final personDetailsProvider = FutureProvider.family<PersonDetails, int>((
  ref,
  personId,
) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return repository.fetchPersonDetails(personId);
});

class PersonAnalyticsProgressNotifier
    extends Notifier<PersonAnalyticsProgress> {
  @override
  PersonAnalyticsProgress build() {
    return const PersonAnalyticsProgress(
      value: 0,
      message: 'Preparing career statistics...',
    );
  }

  void update(double value, String message) {
    state = PersonAnalyticsProgress(value: value.clamp(0, 1), message: message);
  }
}

final personAnalyticsProgressProvider =
    NotifierProvider.family<
      PersonAnalyticsProgressNotifier,
      PersonAnalyticsProgress,
      int
    >((personId) => PersonAnalyticsProgressNotifier());

final personAnalyticsProvider = FutureProvider.family<PersonAnalyticsData, int>(
  (ref, personId) async {
    void updateProgress(double value, String message) {
      Future.microtask(() {
        if (ref.mounted) {
          ref
              .read(personAnalyticsProgressProvider(personId).notifier)
              .update(value, message);
        }
      });
    }

    updateProgress(0.03, 'Loading person credits...');
    final details = await ref.watch(personDetailsProvider(personId).future);
    final repository = ref.watch(mediaRepositoryProvider);

    updateProgress(0.08, 'Grouping career credits by department...');
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

    updateProgress(0.14, 'Calculating rating and genre patterns...');
    final ratedMedia = allMedia
        .where((m) => m.voteAverage != null && m.voteAverage! > 0)
        .toList();
    double averageRating = 0.0;
    if (ratedMedia.isNotEmpty) {
      averageRating =
          ratedMedia.map((m) => m.voteAverage!).reduce((a, b) => a + b) /
          ratedMedia.length;
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

    final totalGenreOccurrences = genreCounts.values.fold<int>(
      0,
      (a, b) => a + b,
    );
    final mostFrequentGenre = topGenreId != null
        ? (tmdbGenreMap[topGenreId] ?? 'Unknown')
        : 'None';
    final mostFrequentGenrePercent = totalGenreOccurrences > 0
        ? ((maxGenreCount / totalGenreOccurrences) * 100).round()
        : 0;

    final sortedMovies = _sortedUniqueMovieCredits(details);

    updateProgress(0.85, 'Fetching details for top movies...');
    final top5Movies = sortedMovies.take(5).toList();
    final movieDetailsList = await Future.wait(
      top5Movies.map(
        (m) => repository
            .fetchMovieDetails(m.id, isTv: false)
            .then<MovieDetails?>((v) => v)
            .catchError((_) => null),
      ),
    );
    final validMovieDetailsList =
        movieDetailsList.whereType<MovieDetails>().toList();

    MovieDetails? highestGrossingMovie;
    int maxRevenue = 0;
    for (final movie in validMovieDetailsList) {
      if (movie.revenue != null && movie.revenue! > maxRevenue) {
        maxRevenue = movie.revenue!;
        highestGrossingMovie = movie;
      }
    }

    updateProgress(
      1,
      'Career statistics ready. Loading collaborations separately...',
    );

    return PersonAnalyticsData(
      actingCount: actingCount,
      directingCount: directingCount,
      writingCount: writingCount,
      otherCount: otherCount,
      averageRating: averageRating,
      mostFrequentGenre: mostFrequentGenre,
      mostFrequentGenrePercent: mostFrequentGenrePercent,
      highestGrossingMovie: highestGrossingMovie,
      fallbackHighestGrossing: sortedMovies.isNotEmpty
          ? sortedMovies.first
          : null,
    );
  },
);

final personCollaboratorsProvider = FutureProvider.family<List<Collaborator>, int>((
  ref,
  personId,
) async {
  void updateProgress(double value, String message) {
    Future.microtask(() {
      if (ref.mounted) {
        ref
            .read(personAnalyticsProgressProvider(personId).notifier)
            .update(value, message);
      }
    });
  }

  updateProgress(0.03, 'Loading person credits...');
  final details = await ref.watch(personDetailsProvider(personId).future);
  final repository = ref.watch(mediaRepositoryProvider);
  final sortedMovies = _sortedUniqueMovieCredits(details);
  final uniqueMovies = <int, MediaTitle>{
    for (final movie in sortedMovies) movie.id: movie,
  };

  updateProgress(
    0.12,
    sortedMovies.isEmpty
        ? 'No movie credits found for collaboration analysis.'
        : 'Preparing ${sortedMovies.length} movie credits for collaboration analysis...',
  );
  final validMovieDetailsList = await _fetchMovieDetailsInBatches(
    repository: repository,
    movies: sortedMovies,
    onProgress: (completed, total) {
      final double ratio = total == 0 ? 1 : completed / total;
      updateProgress(
        0.16 + (ratio * 0.66),
        'Fetching movie cast and crew details ($completed/$total)...',
      );
    },
  );

  final collaboratorCounts = <int, Collaborator>{};
  final collaboratorSharedTitles = <int, Map<int, SharedCollaborationTitle>>{};

  updateProgress(0.84, 'Matching frequent movie collaborators...');
  void registerCollaborator({
    required int collaboratorId,
    required String collaboratorName,
    required String? imageUrl,
    required String role,
    required String personRole,
    required MediaTitle sharedTitle,
  }) {
    final existing = collaboratorCounts[collaboratorId];
    final sharedTitles = collaboratorSharedTitles.putIfAbsent(
      collaboratorId,
      () => <int, SharedCollaborationTitle>{},
    );
    final bool isNewSharedTitle = !sharedTitles.containsKey(sharedTitle.id);
    sharedTitles[sharedTitle.id] = SharedCollaborationTitle(
      media: sharedTitle,
      personRole: personRole,
      collaboratorRole: role,
    );

    if (!isNewSharedTitle) {
      return;
    }

    if (existing == null) {
      collaboratorCounts[collaboratorId] = Collaborator(
        id: collaboratorId,
        name: collaboratorName,
        imageUrl: imageUrl,
        count: 1,
        role: role,
      );
    } else {
      collaboratorCounts[collaboratorId] = Collaborator(
        id: collaboratorId,
        name: collaboratorName,
        imageUrl: imageUrl,
        count: existing.count + 1,
        role: existing.role,
      );
    }
  }

  for (final movie in validMovieDetailsList) {
    final MediaTitle? sharedTitle = uniqueMovies[movie.id];
    if (sharedTitle == null) {
      continue;
    }
    final String personRole = _roleForPersonInMovie(movie, personId);
    for (final actor in movie.cast) {
      if (actor.id == personId) continue;
      registerCollaborator(
        collaboratorId: actor.id,
        collaboratorName: actor.name,
        imageUrl: actor.imageUrl,
        role: _displayRoleForCredit(actor),
        personRole: personRole,
        sharedTitle: sharedTitle,
      );
    }
    for (final crew in movie.crew) {
      if (crew.id == personId) continue;
      registerCollaborator(
        collaboratorId: crew.id,
        collaboratorName: crew.name,
        imageUrl: crew.imageUrl,
        role: _displayRoleForCredit(crew),
        personRole: personRole,
        sharedTitle: sharedTitle,
      );
    }
  }

  updateProgress(0.94, 'Ranking collaborators by shared movie titles...');
  final sortedCollaborators =
      collaboratorCounts.values.map((collaborator) {
        final sharedTitles =
            collaboratorSharedTitles[collaborator.id]?.values.toList() ??
            const <SharedCollaborationTitle>[];
        sharedTitles.sort((a, b) {
          final int popularityCompare = b.media.popularity.compareTo(
            a.media.popularity,
          );
          if (popularityCompare != 0) return popularityCompare;
          return (b.media.releaseDate ?? '').compareTo(
            a.media.releaseDate ?? '',
          );
        });
        return Collaborator(
          id: collaborator.id,
          name: collaborator.name,
          imageUrl: collaborator.imageUrl,
          count: collaborator.count,
          role: collaborator.role,
          sharedTitles: sharedTitles,
        );
      }).toList()..sort((a, b) {
        final int countCompare = b.count.compareTo(a.count);
        if (countCompare != 0) return countCompare;
        return a.name.compareTo(b.name);
      });

  updateProgress(1, 'Frequent collaborations ready.');
  return sortedCollaborators.take(5).toList();
});

List<MediaTitle> _sortedUniqueMovieCredits(PersonDetails details) {
  final Map<int, MediaTitle> uniqueMovies = <int, MediaTitle>{};
  details.creditsByDepartment.forEach((_, list) {
    for (final credit in list) {
      final media = credit.media;
      if (media.mediaType == GlobalMediaType.movie) {
        uniqueMovies[media.id] = media;
      }
    }
  });

  return uniqueMovies.values.toList()
    ..sort((a, b) => b.popularity.compareTo(a.popularity));
}

Future<List<MovieDetails>> _fetchMovieDetailsInBatches({
  required MediaRepository repository,
  required List<MediaTitle> movies,
  void Function(int completed, int total)? onProgress,
}) async {
  final List<MovieDetails> results = <MovieDetails>[];
  if (movies.isEmpty) {
    onProgress?.call(0, 0);
    return results;
  }
  for (
    int index = 0;
    index < movies.length;
    index += _collaborationMovieDetailsBatchSize
  ) {
    final int end = index + _collaborationMovieDetailsBatchSize > movies.length
        ? movies.length
        : index + _collaborationMovieDetailsBatchSize;
    final batch = movies.sublist(index, end);
    final batchResults = await Future.wait<MovieDetails?>(
      batch.map(
        (movie) => repository
            .fetchMovieDetails(movie.id, isTv: false)
            .then<MovieDetails?>((value) => value)
            .catchError((_) => null),
      ),
    );
    results.addAll(batchResults.whereType<MovieDetails>());
    onProgress?.call(end, movies.length);
  }
  return results;
}

String _roleForPersonInMovie(MovieDetails movie, int personId) {
  final List<String> roles = <String>[];
  for (final credit in movie.cast) {
    if (credit.id == personId) {
      roles.add(_displayRoleForCredit(credit));
    }
  }
  for (final credit in movie.crew) {
    if (credit.id == personId) {
      roles.add(_displayRoleForCredit(credit));
    }
  }
  return _joinUniqueRoles(roles);
}

String _displayRoleForCredit(MovieCredit credit) {
  final String characterName = (credit.characterName ?? '').trim();
  if (characterName.isNotEmpty) {
    return characterName;
  }
  final String role = credit.role.trim();
  return role.isEmpty ? 'Credit' : role;
}

String _joinUniqueRoles(List<String> roles) {
  final List<String> uniqueRoles = <String>[];
  final Set<String> seen = <String>{};
  for (final String rawRole in roles) {
    final String role = rawRole.trim();
    if (role.isEmpty) {
      continue;
    }
    final String key = role.toLowerCase();
    if (seen.add(key)) {
      uniqueRoles.add(role);
    }
  }
  if (uniqueRoles.isEmpty) {
    return 'Credit';
  }
  return uniqueRoles.take(2).join(' / ');
}
