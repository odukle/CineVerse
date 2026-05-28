import 'dart:io';

import 'package:cineverse/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _waitForUi(WidgetTester tester, {int ms = 1800}) async {
  final int slices = (ms / 120).ceil().clamp(1, 50);
  for (int i = 0; i < slices; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _capture(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester, {
  required String name,
}) async {
  // ignore: avoid_print
  print('Capturing $name');
  await _waitForUi(tester);
  await binding.takeScreenshot(name);
}

Future<void> _openTab(
  WidgetTester tester, {
  required String label,
  required List<Finder> finders,
}) async {
  Finder? selectedFinder;
  for (final finder in finders) {
    if (finder.evaluate().isNotEmpty) {
      selectedFinder = finder;
      break;
    }
  }
  if (selectedFinder == null) {
    // ignore: avoid_print
    print('Tab not found: $label');
    return;
  }
  // ignore: avoid_print
  print('Opening tab: $label');
  await tester.tap(selectedFinder.first);
  await _waitForUi(tester);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture Play Store screenshots', (WidgetTester tester) async {
    app.main();
    await _waitForUi(tester, ms: 2800);

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    await _capture(binding, tester, name: '01_explore');

    await _openTab(
      tester,
      label: 'Movies',
      finders: <Finder>[
        find.byIcon(Icons.movie_creation_outlined),
        find.byIcon(Icons.movie_creation_rounded),
        find.text('Movies'),
      ],
    );
    await _capture(binding, tester, name: '02_movies');

    await _openTab(
      tester,
      label: 'TV Shows',
      finders: <Finder>[
        find.byIcon(Icons.tv_outlined),
        find.byIcon(Icons.tv_rounded),
        find.text('TV Shows'),
      ],
    );
    await _capture(binding, tester, name: '03_tv_shows');

    await _openTab(
      tester,
      label: 'Library',
      finders: <Finder>[
        find.byIcon(Icons.bookmark_outline_rounded),
        find.byIcon(Icons.bookmark_rounded),
        find.text('Library'),
      ],
    );
    await _capture(binding, tester, name: '04_library');

    await _openTab(
      tester,
      label: 'Account',
      finders: <Finder>[
        find.byIcon(Icons.person_outline_rounded),
        find.byIcon(Icons.person_rounded),
        find.text('Account'),
      ],
    );
    await _capture(binding, tester, name: '05_account');
  });
}
