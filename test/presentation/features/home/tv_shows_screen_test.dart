import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/presentation/features/home/tv_shows_screen.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'tv shows screen loads live sections and filter pill updates list',
    (WidgetTester tester) async {
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

      final Map<MovieSection, List<MediaTitle>> sections =
          <MovieSection, List<MediaTitle>>{
            MovieSection.tvPopular: buildTitles('Popular Show', 1),
            MovieSection.tvTopRated: buildTitles('Top Rated Show', 101),
            MovieSection.tvOnTheAir: buildTitles('On The Air Show', 201),
            MovieSection.tvAiringToday: buildTitles('Airing Today Show', 301),
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
          child: const MaterialApp(home: TvShowsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('TV Shows'), findsAtLeastNWidgets(1));
      expect(find.text('Popular Show 1'), findsOneWidget);
      expect(find.text('Top Rated'), findsNothing);

      await tester.tap(find.text('Popular'));
      await tester.pumpAndSettle();

      expect(find.text('Top Rated'), findsOneWidget);

      await tester.tap(find.text('Top Rated'));
      await tester.pumpAndSettle();

      expect(find.text('Top Rated Show 1'), findsOneWidget);
      expect(find.text('Popular Show 1'), findsNothing);
    },
  );
}
