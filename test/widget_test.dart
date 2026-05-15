import 'package:cineverse/app/app.dart';
import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/presentation/providers/sync_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('renders the architecture shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith((ref) => const AppConfig()),
          syncInitializationProvider.overrideWith((ref) {}),
        ],
        child: const LumiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Movie API configuration required'), findsOneWidget);
  });
}
