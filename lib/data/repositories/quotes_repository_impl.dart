import 'package:cineverse/domain/repositories/quotes_repository.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

class QuotesRepositoryImpl implements QuotesRepository {
  final Dio _dio;
  static const String _baseUrl = 'https://en.wikiquote.org/w/api.php';

  QuotesRepositoryImpl(this._dio);

  @override
  Future<List<MediaQuote>> fetchMediaQuotes(String title, {bool isTv = false}) async {
    final pageTitle = await _findPageTitle(title, isTv: isTv);
    if (pageTitle == null) return [];
    return _fetchAndParseQuotes(pageTitle);
  }

  @override
  Future<List<MediaQuote>> fetchPersonQuotes(String name) async {
    final pageTitle = await _findPageTitle(name, isPerson: true);
    if (pageTitle == null) return [];
    return _fetchAndParseQuotes(pageTitle);
  }

  Future<String?> _findPageTitle(String query, {bool isTv = false, bool isPerson = false}) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'action': 'opensearch',
          'search': query,
          'limit': '5',
          'format': 'json',
          'origin': '*',
        },
      );

      final List<dynamic> results = response.data[1];
      if (results.isEmpty) return null;

      if (isPerson) {
        // For persons, we usually want the exact match or the first one if it doesn't look like a film
        return results.firstWhere(
          (t) => !t.toString().contains('(film)') && !t.toString().contains('(TV series)'),
          orElse: () => results[0],
        );
      }

      final suffix = isTv ? '(TV series)' : '(film)';
      // Try to find one with the correct suffix first
      return results.firstWhere(
        (t) => t.toString().contains(suffix),
        orElse: () => results[0],
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<MediaQuote>> _fetchAndParseQuotes(String pageTitle) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'action': 'parse',
          'page': pageTitle,
          'prop': 'text',
          'format': 'json',
          'origin': '*',
        },
      );

      final html = response.data['parse']['text']['*'];
      final document = parse(html);
      
      final List<MediaQuote> quotes = [];
      
      // Wikiquote usually uses <li> for quotes. 
      // Sometimes they are inside <div class="mw-parser-output">
      final liElements = document.querySelectorAll('.mw-parser-output li');
      
      for (final li in liElements) {
        // Skip navigation, small text, or items that are likely not quotes
        if (li.classes.contains('toclevel-1') || 
            li.querySelector('sup') != null ||
            li.text.trim().length < 20) {
          continue;
        }

        // Clean text - remove [edit], citations like [1], etc.
        String text = li.text.replaceAll(RegExp(r'\[edit\]'), '').trim();
        text = text.replaceAll(RegExp(r'\[\d+\]'), '').trim();

        // Simple character extraction attempt: "Character: Quote"
        String? character;
        if (text.contains(': ')) {
          final parts = text.split(': ');
          if (parts[0].length < 30) { // Likely a name
            character = parts[0];
            text = parts.sublist(1).join(': ');
          }
        }

        if (text.isNotEmpty) {
          quotes.add(MediaQuote(text: text, character: character));
        }
      }

      // Limit to 20 quotes to avoid overwhelming the UI
      return quotes.take(20).toList();
    } catch (_) {
      return [];
    }
  }
}
