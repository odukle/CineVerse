import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/media_images.dart';
import 'package:cineverse/domain/entities/movie_mood.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart';
import 'package:cineverse/presentation/features/movies/explore_screen.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('movie screen renders curated shelves and mood section', (
    WidgetTester tester,
  ) async {
    final Finder verticalScrollable = find.byWidgetPredicate(
      (Widget widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );

    List<MediaTitle> buildMovies(String prefix, int startingId) {
      return List<MediaTitle>.generate(
        4,
        (index) => MediaTitle(
          id: startingId + index,
          title: '$prefix ${index + 1}',
          posterPath: null,
          releaseDate: '2024-01-${(index % 28) + 1}'.padLeft(10, '0'),
        ),
      );
    }

    final Map<MovieSection, List<MediaTitle>> sections =
        <MovieSection, List<MediaTitle>>{
          MovieSection.discover: buildMovies('Discover Movie', 1),
          MovieSection.trendingDay: buildMovies('Trending Day Movie', 91),
          MovieSection.trendingWeek: buildMovies('Trending Week Movie', 101),
          MovieSection.popular: buildMovies('Popular Movie', 201),
          MovieSection.topRated: buildMovies('Top Rated Movie', 11),
          MovieSection.nowPlaying: buildMovies('Now Playing Movie', 21),
          MovieSection.upcoming: buildMovies('Upcoming Movie', 301),
          MovieSection.action: buildMovies('Action Movie', 31),
          MovieSection.drama: buildMovies('Drama Movie', 41),
          MovieSection.thriller: buildMovies('Thriller Movie', 51),
        };

    final List<MediaTitle> discoverPool = buildMovies(
      'Discover Spotlight',
      901,
    );
    final Iterable<int> allIds = <MediaTitle>[
      ...sections.values.expand((movies) => movies),
      ...discoverPool,
    ].map((movie) => movie.id);
    final Map<MovieMood, List<MediaTitle>> moodSections =
        <MovieMood, List<MediaTitle>>{
          MovieMood.mindBending: buildMovies('Mind Bending Movie', 1201),
          MovieMood.feelGood: buildMovies('Feel Good Movie', 1301),
          MovieMood.dark: buildMovies('Dark Movie', 1401),
          MovieMood.fastPaced: buildMovies('Fast Paced Movie', 1501),
          MovieMood.edgeOfYourSeat: buildMovies('Edge Movie', 1601),
          MovieMood.cinematic: buildMovies('Cinematic Movie', 1701),
          MovieMood.indie: buildMovies('Indie Movie', 1801),
        };
    const List<MovieGenre> genres = <MovieGenre>[
      MovieGenre(id: 28, name: 'Action'),
      MovieGenre(id: 18, name: 'Drama'),
      MovieGenre(id: 53, name: 'Thriller'),
      MovieGenre(id: 35, name: 'Comedy'),
      MovieGenre(id: 80, name: 'Crime'),
      MovieGenre(id: 10751, name: 'Family'),
    ];

    Future<MovieDetails> buildDetails(int movieId) async {
      return MovieDetails(
        id: movieId,
        title: 'Movie $movieId',
        externalRatings: const <MovieRating>[
          MovieRating(source: 'IMDb', value: '8.7/10'),
          MovieRating(source: 'Rotten Tomatoes', value: '91%'),
        ],
      );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(tmdbApiKey: 'test-key', omdbApiKey: ''),
          ),
          for (final MapEntry<MovieSection, List<MediaTitle>> entry
              in sections.entries)
            movieSectionProvider(
              entry.key,
            ).overrideWith((ref) async => entry.value),
          movieGenresProvider.overrideWith((ref) async => genres),
          for (final int genreId in <int>[28, 18, 53, 35, 80, 10751])
            genreSectionProvider((id: genreId, isTv: false)).overrideWith(
              (ref) async => buildMovies('Genre $genreId Movie', genreId),
            ),
          for (final MapEntry<MovieMood, List<MediaTitle>> entry
              in moodSections.entries)
            moodSectionProvider((
              mood: entry.key,
              isTv: false,
            )).overrideWith((ref) async => entry.value),
          discoverPoolProvider.overrideWith((ref) async => discoverPool),
          for (final int id in allIds)
            movieDetailsProvider(
              GetMovieDetailsParams(movieId: id),
            ).overrideWith((ref) => buildDetails(id)),
          for (final int id in allIds)
            mediaImagesProvider((
              id: id,
              isTv: false,
            )).overrideWith((ref) async => MediaImages.empty),
        ],
        child: const MaterialApp(home: Scaffold(body: ExploreScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.byIcon(Icons.casino_outlined), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Trending'),
      300,
      scrollable: verticalScrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Trending'), findsAtLeastNWidgets(1));

    await tester.scrollUntilVisible(
      find.text("What's Popular"),
      400,
      scrollable: verticalScrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text("What's Popular"), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Now Playing'),
      400,
      scrollable: verticalScrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Now Playing'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Discover by Mood'),
      400,
      scrollable: verticalScrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Discover by Mood'), findsOneWidget);
    expect(find.text('Mind-bending'), findsOneWidget);
    expect(find.byType(ListView), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 8));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('trending shelf renders its initial filter state', (
    WidgetTester tester,
  ) async {
    final Finder verticalScrollable = find.byWidgetPredicate(
      (Widget widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );

    List<MediaTitle> buildMovies(String prefix, int startingId) {
      return List<MediaTitle>.generate(
        4,
        (index) => MediaTitle(
          id: startingId + index,
          title: '$prefix ${index + 1}',
          posterPath: null,
          releaseDate: '2024-01-${(index % 28) + 1}'.padLeft(10, '0'),
        ),
      );
    }

    final Map<MovieSection, List<MediaTitle>> sections =
        <MovieSection, List<MediaTitle>>{
          MovieSection.discover: buildMovies('Today Movie', 1),
          MovieSection.trendingDay: buildMovies('Day Movie', 51),
          MovieSection.trendingWeek: buildMovies('Week Movie', 101),
          MovieSection.popular: buildMovies('Popular Movie', 201),
          MovieSection.topRated: buildMovies('Top Rated Movie', 301),
          MovieSection.nowPlaying: buildMovies('Now Playing Movie', 401),
          MovieSection.upcoming: buildMovies('Upcoming Movie', 501),
          MovieSection.action: buildMovies('Action Movie', 601),
          MovieSection.drama: buildMovies('Drama Movie', 701),
          MovieSection.thriller: buildMovies('Thriller Movie', 801),
        };

    Future<MovieDetails> buildDetails(int movieId) async {
      return MovieDetails(
        id: movieId,
        title: 'Movie $movieId',
        externalRatings: const <MovieRating>[
          MovieRating(source: 'IMDb', value: '8.7/10'),
        ],
      );
    }

    final Map<MovieMood, List<MediaTitle>> moodSections =
        <MovieMood, List<MediaTitle>>{
          MovieMood.mindBending: buildMovies('Mind Bending Movie', 1201),
          MovieMood.feelGood: buildMovies('Feel Good Movie', 1301),
          MovieMood.dark: buildMovies('Dark Movie', 1401),
          MovieMood.fastPaced: buildMovies('Fast Paced Movie', 1501),
          MovieMood.edgeOfYourSeat: buildMovies('Edge Movie', 1601),
          MovieMood.cinematic: buildMovies('Cinematic Movie', 1701),
          MovieMood.indie: buildMovies('Indie Movie', 1801),
        };
    final List<MediaTitle> discoverPool = buildMovies(
      'Discover Spotlight',
      901,
    );
    final Iterable<int> allIds = <MediaTitle>[
      ...sections.values.expand((movies) => movies),
      ...discoverPool,
    ].map((movie) => movie.id);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(tmdbApiKey: 'test-key', omdbApiKey: ''),
          ),
          for (final MapEntry<MovieSection, List<MediaTitle>> entry
              in sections.entries)
            movieSectionProvider(
              entry.key,
            ).overrideWith((ref) async => entry.value),
          movieGenresProvider.overrideWith(
            (ref) async => const <MovieGenre>[
              MovieGenre(id: 28, name: 'Action'),
              MovieGenre(id: 18, name: 'Drama'),
              MovieGenre(id: 53, name: 'Thriller'),
              MovieGenre(id: 35, name: 'Comedy'),
              MovieGenre(id: 80, name: 'Crime'),
              MovieGenre(id: 10751, name: 'Family'),
            ],
          ),
          for (final int genreId in <int>[28, 18, 53, 35, 80, 10751])
            genreSectionProvider((id: genreId, isTv: false)).overrideWith(
              (ref) async => buildMovies('Genre $genreId Movie', genreId),
            ),
          for (final MapEntry<MovieMood, List<MediaTitle>> entry
              in moodSections.entries)
            moodSectionProvider((
              mood: entry.key,
              isTv: false,
            )).overrideWith((ref) async => entry.value),
          discoverPoolProvider.overrideWith((ref) async => discoverPool),
          for (final int id in allIds)
            movieDetailsProvider(
              GetMovieDetailsParams(movieId: id),
            ).overrideWith((ref) => buildDetails(id)),
          for (final int id in allIds)
            mediaImagesProvider((
              id: id,
              isTv: false,
            )).overrideWith((ref) async => MediaImages.empty),
        ],
        child: const MaterialApp(home: Scaffold(body: ExploreScreen())),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Trending'),
      300,
      scrollable: verticalScrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('Day Movie 1'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('This Week'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 8));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('discover spotlight dice shows another discover movie', (
    WidgetTester tester,
  ) async {
    List<MediaTitle> buildMovies(String prefix, int startingId) {
      return List<MediaTitle>.generate(
        6,
        (index) => MediaTitle(
          id: startingId + index,
          title: '$prefix ${index + 1}',
          posterPath: null,
          releaseDate: '2024-01-${(index % 28) + 1}'.padLeft(10, '0'),
        ),
      );
    }

    final List<MediaTitle> discoverPool = buildMovies(
      'Discover Spotlight',
      1001,
    );
    final Map<MovieSection, List<MediaTitle>> sections =
        <MovieSection, List<MediaTitle>>{
          MovieSection.discover: buildMovies('Discover Movie', 1),
          MovieSection.trendingDay: buildMovies('Trending Day Movie', 51),
          MovieSection.trendingWeek: buildMovies('Trending Week Movie', 101),
          MovieSection.popular: buildMovies('Popular Movie', 201),
          MovieSection.topRated: buildMovies('Top Rated Movie', 301),
          MovieSection.nowPlaying: buildMovies('Now Playing Movie', 401),
          MovieSection.upcoming: buildMovies('Upcoming Movie', 501),
          MovieSection.action: buildMovies('Action Movie', 601),
          MovieSection.drama: buildMovies('Drama Movie', 701),
          MovieSection.thriller: buildMovies('Thriller Movie', 801),
        };

    Future<MovieDetails> buildDetails(int movieId) async {
      return MovieDetails(
        id: movieId,
        title: 'Movie $movieId',
        externalRatings: const <MovieRating>[
          MovieRating(source: 'IMDb', value: '8.7/10'),
        ],
      );
    }

    final Map<MovieMood, List<MediaTitle>> moodSections =
        <MovieMood, List<MediaTitle>>{
          MovieMood.mindBending: buildMovies('Mind Bending Movie', 1201),
          MovieMood.feelGood: buildMovies('Feel Good Movie', 1301),
          MovieMood.dark: buildMovies('Dark Movie', 1401),
          MovieMood.fastPaced: buildMovies('Fast Paced Movie', 1501),
          MovieMood.edgeOfYourSeat: buildMovies('Edge Movie', 1601),
          MovieMood.cinematic: buildMovies('Cinematic Movie', 1701),
          MovieMood.indie: buildMovies('Indie Movie', 1801),
        };
    final Iterable<int> allIds = <MediaTitle>[
      ...sections.values.expand((movies) => movies),
      ...discoverPool,
    ].map((movie) => movie.id);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(tmdbApiKey: 'test-key', omdbApiKey: ''),
          ),
          for (final MapEntry<MovieSection, List<MediaTitle>> entry
              in sections.entries)
            movieSectionProvider(
              entry.key,
            ).overrideWith((ref) async => entry.value),
          movieGenresProvider.overrideWith(
            (ref) async => const <MovieGenre>[
              MovieGenre(id: 28, name: 'Action'),
              MovieGenre(id: 18, name: 'Drama'),
              MovieGenre(id: 53, name: 'Thriller'),
              MovieGenre(id: 35, name: 'Comedy'),
              MovieGenre(id: 80, name: 'Crime'),
              MovieGenre(id: 10751, name: 'Family'),
            ],
          ),
          for (final int genreId in <int>[28, 18, 53, 35, 80, 10751])
            genreSectionProvider((id: genreId, isTv: false)).overrideWith(
              (ref) async => buildMovies('Genre $genreId Movie', genreId),
            ),
          for (final MapEntry<MovieMood, List<MediaTitle>> entry
              in moodSections.entries)
            moodSectionProvider((
              mood: entry.key,
              isTv: false,
            )).overrideWith((ref) async => entry.value),
          discoverPoolProvider.overrideWith((ref) async => discoverPool),
          for (final int id in allIds)
            movieDetailsProvider(
              GetMovieDetailsParams(movieId: id),
            ).overrideWith((ref) => buildDetails(id)),
          for (final int id in allIds)
            mediaImagesProvider((
              id: id,
              isTv: false,
            )).overrideWith((ref) async => MediaImages.empty),
        ],
        child: const MaterialApp(home: Scaffold(body: ExploreScreen())),
      ),
    );

    await tester.pumpAndSettle();

    final Finder discoverTitleFinder = find.textContaining(
      'Discover Spotlight',
    );
    expect(discoverTitleFinder, findsOneWidget);
    final String initialTitle = tester.widget<Text>(discoverTitleFinder).data!;

    await tester.ensureVisible(find.byIcon(Icons.casino_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.casino_outlined));
    await tester.pumpAndSettle();

    final String updatedTitle = tester
        .widget<Text>(find.textContaining('Discover Spotlight'))
        .data!;
    expect(updatedTitle, isNot(initialTitle));

    await tester.pump(const Duration(seconds: 8));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
