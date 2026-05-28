import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/presentation/features/home/tv_shows_screen.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tv shows screen switches between popular and genre tabs', (
    WidgetTester tester,
  ) async {
    List<MediaTitle> buildTitles(String prefix, int startId) {
      return List<MediaTitle>.generate(
        4,
        (index) => MediaTitle(
          id: startId + index,
          title: '$prefix ${index + 1}',
          posterPath: null,
          releaseDate: '2024-02-${(index % 28) + 1}'.padLeft(10, '0'),
        ),
      );
    }

    const genres = <MovieGenre>[
      MovieGenre(id: 18, name: 'Drama'),
      MovieGenre(id: 9648, name: 'Mystery'),
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
          tvGenresProvider.overrideWith((ref) async => genres),
          movieSectionProvider(
            MovieSection.tvPopular,
          ).overrideWith((ref) async => buildTitles('Popular Show', 1)),
          genreSectionProvider((
            id: 18,
            isTv: true,
          )).overrideWith((ref) async => buildTitles('Drama Show', 101)),
          genreSectionProvider((
            id: 9648,
            isTv: true,
          )).overrideWith((ref) async => buildTitles('Mystery Show', 201)),
        ],
        child: const MaterialApp(home: Scaffold(body: TvShowsScreen())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Popular Show 1'), findsOneWidget);
    expect(find.text('DRAMA'), findsOneWidget);
    expect(find.text('Drama Show 1'), findsNothing);

    await tester.tap(find.text('DRAMA'));
    await tester.pumpAndSettle();

    expect(find.text('Drama Show 1'), findsOneWidget);
    expect(find.text('Popular Show 1'), findsNothing);
  });
}
