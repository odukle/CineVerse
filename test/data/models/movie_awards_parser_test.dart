import 'package:cineverse/presentation/features/movie_details/widgets/movie_awards_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovieAwards.parse', () {
    test('handles null, empty, or N/A awards string', () {
      final nullAwards = MovieAwards.parse(null);
      expect(nullAwards.rawAwards, '');
      expect(nullAwards.totalWins, 0);
      expect(nullAwards.totalNominations, 0);
      expect(nullAwards.hasAwards, false);

      final emptyAwards = MovieAwards.parse('');
      expect(emptyAwards.totalWins, 0);
      expect(emptyAwards.hasAwards, false);

      final naAwards = MovieAwards.parse('N/A');
      expect(naAwards.totalWins, 0);
      expect(naAwards.hasAwards, false);
    });

    test('parses Oscar wins and other accolades', () {
      final awards = MovieAwards.parse(
        'Won 6 Oscars. Another 50 wins & 28 nominations.',
      );
      expect(awards.oscarWins, 6);
      expect(awards.oscarNominations, 0);
      expect(awards.otherWins, 50);
      expect(awards.otherNominations, 28);
      expect(awards.totalWins, 56);
      expect(awards.totalNominations, 28);
      expect(awards.hasAwards, true);
      expect(awards.displaySummary, '56 wins & 28 nominations');
      expect(awards.detailLines, [
        'Won 6 Oscars',
        'Another 50 wins & 28 nominations',
      ]);
    });

    test('parses Oscar nominations and other accolades', () {
      final awards = MovieAwards.parse(
        'Nominated for 1 Oscar. Another 2 wins & 10 nominations.',
      );
      expect(awards.oscarWins, 0);
      expect(awards.oscarNominations, 1);
      expect(awards.otherWins, 2);
      expect(awards.otherNominations, 10);
      expect(awards.totalWins, 2);
      expect(awards.totalNominations, 11);
    });

    test('parses Golden Globe wins and general accolades', () {
      final awards = MovieAwards.parse(
        'Won 3 Golden Globes. Another 12 wins & 45 nominations.',
      );
      expect(awards.globeWins, 3);
      expect(awards.globeNominations, 0);
      expect(awards.otherWins, 12);
      expect(awards.otherNominations, 45);
      expect(awards.totalWins, 15);
      expect(awards.totalNominations, 45);
    });

    test('parses BAFTA Film Awards and general accolades', () {
      final awards = MovieAwards.parse(
        'Won 1 BAFTA Film Award. Another 4 wins & 8 nominations.',
      );
      expect(awards.baftaWins, 1);
      expect(awards.baftaNominations, 0);
      expect(awards.otherWins, 4);
      expect(awards.otherNominations, 8);
      expect(awards.totalWins, 5);
      expect(awards.totalNominations, 8);
    });

    test('parses simple wins and nominations format', () {
      final awards = MovieAwards.parse('1 win & 2 nominations.');
      expect(awards.totalWins, 1);
      expect(awards.totalNominations, 2);
      expect(awards.otherWins, 1);
      expect(awards.otherNominations, 2);
      expect(awards.displaySummary, '1 win & 2 nominations');
    });

    test('parses wins only or nominations only', () {
      final winsOnly = MovieAwards.parse('5 wins.');
      expect(winsOnly.totalWins, 5);
      expect(winsOnly.totalNominations, 0);
      expect(winsOnly.displaySummary, '5 wins');

      final nomsOnly = MovieAwards.parse('12 nominations.');
      expect(nomsOnly.totalWins, 0);
      expect(nomsOnly.totalNominations, 12);
      expect(nomsOnly.displaySummary, '12 nominations');
    });

    test('uses resolver totals when detail lines do not contain numeric summary', () {
      final awards = MovieAwards.fromResolverPayload({
        'awardsText':
            'Nominee: Best Actress (Academy Awards). Nominee: Best Original Score (Golden Globes).',
        'totalWins': 65,
        'totalNominations': 192,
        'detailItems': [
          {
            'text': 'Nominee: Best Actress (Academy Awards)',
            'awardName': 'Academy Awards',
          },
          {
            'text': 'Nominee: Best Original Score (Golden Globes)',
            'awardName': 'Golden Globes',
          },
        ],
      });

      expect(awards.totalWins, 65);
      expect(awards.totalNominations, 192);
      expect(awards.displaySummary, '65 wins & 192 nominations');
      expect(awards.hasAwards, true);
    });
  });
}
