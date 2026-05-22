import 'package:cineverse/domain/entities/media_images.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart';
import 'package:cineverse/presentation/features/movie_details/movie_details_screen.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_awards_provider.dart';
import 'package:cineverse/presentation/features/movie_details/widgets/movie_awards_helper.dart';
import 'package:cineverse/presentation/features/movie_details/movie_awards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('movie details renders watch providers between overview and cast', (
    WidgetTester tester,
  ) async {
    const MovieDetails details = MovieDetails(
      id: 231,
      title: 'Titanic',
      posterPath: null,
      backdropPath: null,
      overview: 'Jack and Rose are young lovers aboard the Titanic.',
      releaseDate: '1997-12-19',
      genres: <String>['Drama', 'Romance'],
      runtimeMinutes: 194,
      catalogScore: 7.3,
      contentRating: 'PG-13',
      contentRatingDescription: 'Suitable for viewers aged 13 and over.',
      externalRatings: <MovieRating>[
        MovieRating(source: 'Rotten Tomatoes', value: '88%'),
        MovieRating(source: 'IMDb', value: '7.9/10'),
      ],
      cast: <MovieCredit>[
        MovieCredit(
          id: 0,
          name:
              'Leonardo Wilhelm DiCaprio With A Deliberately Long Display Name',
          role: 'Actor',
          characterName:
              'Jack Dawson With An Intentionally Long Character Name',
        ),
      ],
      crew: <MovieCredit>[MovieCredit(id: 0, name: 'James Cameron', role: 'Director')],
      watchAvailability: MovieWatchAvailability(
        streaming: <MovieWatchProvider>[
          MovieWatchProvider(id: 8, name: 'Netflix'),
        ],
        rent: <MovieWatchProvider>[MovieWatchProvider(id: 2, name: 'Apple TV')],
        buy: <MovieWatchProvider>[
          MovieWatchProvider(id: 3, name: 'Google Play Movies'),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieDetailsProvider(
            const GetMovieDetailsParams(movieId: 231),
          ).overrideWith((ref) async => details),
          mediaImagesProvider((id: 231, isTv: false)).overrideWith(
            (ref) async => MediaImages.empty,
          ),
        ],
        child: const MaterialApp(home: MovieDetailsScreen(movieId: 231)),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final Finder verticalScrollable = find.byWidgetPredicate(
      (Widget widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    final Finder overviewFinder = find.text('Overview', skipOffstage: false);
    final Finder watchFinder = find.text('Where to Watch', skipOffstage: false);
    final Finder castFinder = find.text('Top Billed Cast', skipOffstage: false);

    expect(find.textContaining('Titanic (1997)'), findsOneWidget);
    expect(overviewFinder, findsOneWidget);
    expect(watchFinder, findsOneWidget);
    await tester.scrollUntilVisible(
      watchFinder,
      300,
      scrollable: verticalScrollable,
    );
    await tester.pump();
    expect(find.text('Stream'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Apple TV'), findsOneWidget);
    expect(find.text('Google Play Movies'), findsOneWidget);
    expect(castFinder, findsOneWidget);
    expect(
      find.textContaining('Leonardo Wilhelm DiCaprio', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('James Cameron', skipOffstage: false), findsOneWidget);
    expect(find.text('Availability data by JustWatch.'), findsOneWidget);

    final double overviewTop = tester.getTopLeft(overviewFinder).dy;
    final double watchTop = tester.getTopLeft(watchFinder).dy;
    final double castTop = tester.getTopLeft(castFinder).dy;

    expect(overviewTop, lessThan(watchTop));
    expect(watchTop, lessThan(castTop));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('movie details header does not overflow with long title', (
    WidgetTester tester,
  ) async {
    const MovieDetails details = MovieDetails(
      id: 77,
      title: 'John Wick: Chapter 3 - Parabellum With A Very Long Title',
      posterPath: null,
      backdropPath: null,
      overview: 'Long overview text.',
      releaseDate: '2019-05-15',
      genres: <String>['Action', 'Crime', 'Thriller'],
      contentRating: 'R',
    );

    await tester.binding.setSurfaceSize(const Size(360, 800));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieDetailsProvider(
            const GetMovieDetailsParams(movieId: 77),
          ).overrideWith((ref) async => details),
          mediaImagesProvider((id: 77, isTv: false)).overrideWith(
            (ref) async => MediaImages.empty,
          ),
        ],
        child: const MaterialApp(home: MovieDetailsScreen(movieId: 77)),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('John Wick: Chapter 3'), findsOneWidget);
    expect(find.text('Where to Watch'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });

  testWidgets('movie details screen displays pre-fetched awards', (
    WidgetTester tester,
  ) async {
    const MovieDetails details = MovieDetails(
      id: 231,
      title: 'Titanic',
      imdbId: 'tt0120338',
      posterPath: null,
      backdropPath: null,
      releaseDate: '1997-12-19',
      awards: 'Won 11 Oscars. Another 116 wins & 83 nominations.',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieDetailsProvider(
            const GetMovieDetailsParams(movieId: 231),
          ).overrideWith((ref) async => details),
          mediaImagesProvider((id: 231, isTv: false)).overrideWith(
            (ref) async => MediaImages.empty,
          ),
        ],
        child: const MaterialApp(home: MovieDetailsScreen(movieId: 231)),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('127 wins & 83 nominations'), findsOneWidget);
    expect(find.text('Awards & Nominations'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
  });

  testWidgets('movie details screen lazy-loads awards when awards field is null', (
    WidgetTester tester,
  ) async {
    const MovieDetails details = MovieDetails(
      id: 231,
      title: 'Titanic',
      imdbId: 'tt0120338',
      posterPath: null,
      backdropPath: null,
      releaseDate: '1997-12-19',
      awards: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieDetailsProvider(
            const GetMovieDetailsParams(movieId: 231),
          ).overrideWith((ref) async => details),
          mediaImagesProvider((id: 231, isTv: false)).overrideWith(
            (ref) async => MediaImages.empty,
          ),
          movieAwardsProvider('tt0120338').overrideWith(
            (ref) async => const MovieAwards(
              rawAwards: 'Won 11 Oscars. Another 116 wins & 83 nominations.',
              oscarWins: 11,
              oscarNominations: 0,
              globeWins: 0,
              globeNominations: 0,
              baftaWins: 0,
              baftaNominations: 0,
              otherWins: 116,
              otherNominations: 83,
            ),
          ),
        ],
        child: const MaterialApp(home: MovieDetailsScreen(movieId: 231)),
      ),
    );

    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_AwardsShimmer',
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('127 wins & 83 nominations'), findsOneWidget);
    expect(find.text('Awards & Nominations'), findsOneWidget);
  });

  testWidgets('MovieAwardsScreen renders awards details correctly', (
    WidgetTester tester,
  ) async {
    const MovieAwards awards = MovieAwards(
      rawAwards: 'Won 11 Oscars. Another 116 wins & 83 nominations.',
      oscarWins: 11,
      oscarNominations: 0,
      globeWins: 4,
      globeNominations: 2,
      baftaWins: 0,
      baftaNominations: 0,
      otherWins: 116,
      otherNominations: 83,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: MovieAwardsScreen(
          awards: awards,
          movieTitle: 'Titanic',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Awards & Accolades'), findsOneWidget);
    expect(find.text('Titanic'), findsOneWidget);
    expect(find.text('Accolade Summary'), findsOneWidget);
    expect(find.text('131'), findsOneWidget);
    expect(find.text('85'), findsOneWidget);
    expect(find.text('Won 11 Oscars'), findsOneWidget);
    expect(find.text('Another 116 wins & 83 nominations'), findsOneWidget);
  });
}
