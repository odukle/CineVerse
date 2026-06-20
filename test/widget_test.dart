import 'package:cineverse/app/app.dart';
import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/presentation/providers/sync_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'test_helpers.dart';

void main() {
  setUp(setupFakeHttpClient);

  testWidgets('renders the architecture shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(movieProxyBaseUrl: ''),
          ),
          syncInitializationProvider.overrideWith((ref) {}),
        ],
        child: const LumiApp(),
      ),
    );

    // The splash screen has a continuous animation, so pumpAndSettle will
    // time out. Pump through the splash navigation instead.
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Movie API configuration required'), findsOneWidget);
  });
}
