import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/presentation/features/home/movies_screen.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  testWidgets('movies screen switches between popular and genre tabs', (
    WidgetTester tester,
  ) async {
    List<MediaTitle> buildTitles(String prefix, int startId) {
      return List<MediaTitle>.generate(
        4,
        (index) => MediaTitle(
          id: startId + index,
          title: '$prefix ${index + 1}',
          posterPath: null,
          releaseDate: '2024-01-${(index % 28) + 1}'.padLeft(10, '0'),
        ),
      );
    }

    const genres = <MovieGenre>[
      MovieGenre(id: 28, name: 'Action'),
      MovieGenre(id: 35, name: 'Comedy'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(
              movieProxyBaseUrl:
                  'https://cineverse-tmdb-proxy.sodukle.workers.dev',
            ),
          ),
          movieGenresProvider.overrideWith((ref) async => genres),
          movieSectionProvider(
            MovieSection.popular,
          ).overrideWith((ref) async => buildTitles('Popular Movie', 1)),
          genreSectionProvider((
            id: 28,
            isTv: false,
          )).overrideWith((ref) async => buildTitles('Action Movie', 101)),
          genreSectionProvider((
            id: 35,
            isTv: false,
          )).overrideWith((ref) async => buildTitles('Comedy Movie', 201)),
        ],
        child: const MaterialApp(
          localizationsDelegates: localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MoviesScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Popular Movie 1'), findsOneWidget);
    expect(find.text('ACTION'), findsOneWidget);
    expect(find.text('Action Movie 1'), findsNothing);

    await tester.tap(find.text('ACTION'));
    await tester.pumpAndSettle();

    expect(find.text('Action Movie 1'), findsOneWidget);
    expect(find.text('Popular Movie 1'), findsNothing);
  });
}
