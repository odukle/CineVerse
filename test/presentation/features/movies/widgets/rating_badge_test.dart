import 'package:cineverse/presentation/features/movies/widgets/rating_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loading badge shows three animated dots', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RatingBadge.loading(size: 54))),
    );

    expect(
      find.byKey(const ValueKey<String>('rating-badge-loading-dot-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('rating-badge-loading-dot-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('rating-badge-loading-dot-2')),
      findsOneWidget,
    );
    expect(find.text('NA'), findsNothing);

    final Finder firstDot = find.byKey(
      const ValueKey<String>('rating-badge-loading-dot-0'),
    );
    final double initialScale = tester.getSize(firstDot).width;
    await tester.pump(const Duration(milliseconds: 450));
    final double updatedScale = tester.getSize(firstDot).width;
    expect(updatedScale, equals(initialScale));
  });

  testWidgets('rottent tomatoes badge keeps tomato icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingBadge.rottenTomatoes(label: '87%', size: 54),
        ),
      ),
    );

    expect(find.text('🍅'), findsOneWidget);
    expect(find.text('87%'), findsOneWidget);
    expect(find.text('TMDB'), findsNothing);
  });

  testWidgets('tmdb badge shows circular score fallback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RatingBadge.tmdb(catalogScore: 6.0, size: 54)),
      ),
    );

    expect(find.text('🍅'), findsNothing);
    expect(find.text('TMDB'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
  });
}
