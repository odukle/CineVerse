import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/presentation/features/home/movies_screen.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('movies filter pill expands and updates the list', (
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

    final Map<MovieSection, List<MediaTitle>> sections =
        <MovieSection, List<MediaTitle>>{
          MovieSection.popular: buildTitles('Popular Movie', 1),
          MovieSection.topRated: buildTitles('Top Rated Movie', 101),
          MovieSection.nowPlaying: buildTitles('In Theaters Movie', 201),
          MovieSection.upcoming: buildTitles('Coming Soon Movie', 301),
        };

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
        ],
        child: const MaterialApp(home: MoviesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Popular Movie 1'), findsOneWidget);
    expect(find.text('Top Rated'), findsNothing);

    await tester.tap(find.text('Popular'));
    await tester.pumpAndSettle();

    expect(find.text('Top Rated'), findsOneWidget);

    await tester.tap(find.text('Top Rated'));
    await tester.pumpAndSettle();

    expect(find.text('Top Rated Movie 1'), findsOneWidget);
    expect(find.text('Popular Movie 1'), findsNothing);
  });
}
