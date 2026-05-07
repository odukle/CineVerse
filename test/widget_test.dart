import 'package:cineverse/app/app.dart';
import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('renders the architecture shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(tmdbApiKey: 'test-key', omdbApiKey: ''),
          ),
          movieSectionProvider(
            MovieSection.popular,
          ).overrideWith((ref) async => const <MediaTitle>[]),
        ],
        child: const CineVerseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
  });
}
