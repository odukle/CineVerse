import 'package:cineverse/domain/repositories/quotes_repository.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class QuotesRepositoryImpl implements QuotesRepository {
  final Dio _dio;
  static const String _baseUrl = 'https://en.wikiquote.org/w/api.php';

  QuotesRepositoryImpl(this._dio);

  @override
  Future<List<MediaQuote>> fetchMediaQuotes(String title, {bool isTv = false}) async {
    final article = await fetchFullWikiquoteArticle(title, isTv: isTv);
    if (article == null) return [];

    final List<MediaQuote> quotes = [];
    final blacklist = {
      'introduction',
      'overview',
      'cast',
      'external links',
      'see also',
      'references',
      'notes',
      'bibliography',
      'sources',
      'navigation',
    };

    for (final section in article.sections) {
      if (blacklist.contains(section.title.toLowerCase())) continue;

      for (final content in section.content) {
        if (content is WikiquoteText) {
          if (content.text.length > 20) {
            quotes.add(MediaQuote(
              text: content.text,
              character: content.character,
              context: section.title,
            ));
          }
        } else if (content is WikiquoteDialogue) {
          // Take the most substantial dialogue line or join them?
          // Usually, for a carousel, we want individual quotes.
          for (final line in content.lines) {
            if (line.text.length > 20) {
              quotes.add(MediaQuote(
                text: line.text,
                character: line.character,
                context: section.title,
              ));
            }
          }
        }
      }
    }

    return quotes.take(20).toList();
  }

  @override
  Future<List<MediaQuote>> fetchPersonQuotes(String name) async {
    final article = await fetchFullWikiquoteArticle(name);
    if (article == null) return [];

    final List<MediaQuote> quotes = [];
    final blacklist = {
      'introduction',
      'overview',
      'external links',
      'see also',
      'references',
      'notes',
      'bibliography',
      'sources',
      'navigation',
      'about',
    };

    for (final section in article.sections) {
      if (blacklist.contains(section.title.toLowerCase())) continue;

      for (final content in section.content) {
        if (content is WikiquoteText) {
          if (content.text.length > 20) {
            quotes.add(MediaQuote(
              text: content.text,
              character: content.character,
              context: section.title,
            ));
          }
        } else if (content is WikiquoteDialogue) {
          for (final line in content.lines) {
            if (line.text.length > 20) {
              quotes.add(MediaQuote(
                text: line.text,
                character: line.character,
                context: section.title,
              ));
            }
          }
        }
      }
    }

    return quotes.take(20).toList();
  }
  
  @override
  Future<WikiquoteArticle?> fetchFullWikiquoteArticle(
    String title, {
    bool isTv = false,
    bool isSeason = false,
    String? exactPageTitle,
  }) async {
    final pageTitle = exactPageTitle ?? await _findPageTitle(title, isTv: isTv);
    if (pageTitle == null) return null;
    return _fetchAndParseFullArticle(pageTitle);
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
        return results.firstWhere(
          (t) => !t.toString().contains('(film)') && !t.toString().contains('(TV series)'),
          orElse: () => results[0],
        );
      }

      final suffix = isTv ? '(TV series)' : '(film)';
      return results.firstWhere(
        (t) => t.toString().contains(suffix),
        orElse: () => results[0],
      );
    } catch (_) {
      return null;
    }
  }

  Future<WikiquoteArticle?> _fetchAndParseFullArticle(String pageTitle) async {
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
      final container = document.querySelector('.mw-parser-output');
      if (container == null) return null;

      final sections = <WikiquoteSection>[];
      String currentSectionTitle = 'Introduction';
      int currentLevel = 1;
      List<WikiquoteContent> currentContent = [];

      void saveSection() {
        if (currentContent.isNotEmpty) {
          sections.add(WikiquoteSection(
            title: currentSectionTitle,
            level: currentLevel,
            content: List.from(currentContent),
          ));
          currentContent.clear();
        }
      }

      for (final node in container.nodes) {
        if (node is dom.Element) {
          if (node.localName == 'h2' || node.localName == 'h3' || node.classes.contains('mw-heading')) {
            saveSection();
            final headline = node.querySelector('.mw-headline');
            currentSectionTitle = headline?.text.trim() ?? node.text.trim();
            currentLevel = (node.localName == 'h2' || node.classes.contains('mw-heading2')) ? 2 : 3;
            currentSectionTitle = currentSectionTitle.replaceAll(RegExp(r'\[edit\]'), '').trim();
          } else if (node.localName == 'ul') {
            // Find li elements that are direct children of this ul, or within ul structure
            final lis = node.querySelectorAll('li');
            for (final li in lis) {
              // Ignore TOC
              if (li.classes.contains('toclevel-1') || li.classes.contains('toclevel-2')) {
                continue;
              }
              
              String text = li.text.replaceAll(RegExp(r'\[edit\]|\[\d+\]'), '').trim();
              if (text.isEmpty) continue;

              String? character;
              String quoteText = text;
              if (quoteText.contains(': ')) {
                final parts = quoteText.split(': ');
                if (parts[0].length < 40) {
                  character = parts[0].trim();
                  quoteText = parts.sublist(1).join(': ').trim();
                }
              }
              
              bool addedLink = false;
              final aTags = li.querySelectorAll('a');
              for (final a in aTags) {
                final href = a.attributes['href'];
                if (href != null && href.startsWith('/wiki/') && href.contains(RegExp(r'\(season_\d+\)', caseSensitive: false))) {
                  currentContent.add(WikiquoteSeasonLink(title: text, pageName: href.replaceAll('/wiki/', '')));
                  addedLink = true;
                  break;
                }
              }
              
              if (!addedLink && quoteText.length > 5) {
                currentContent.add(WikiquoteText(text: quoteText, character: character));
              }
            }
          } else if (node.localName == 'dl') {
            final seasonLinks = <WikiquoteSeasonLink>[];
            for (final a in node.querySelectorAll('a')) {
              final href = a.attributes['href'];
              if (href != null && href.startsWith('/wiki/') && href.contains(RegExp(r'\(season_\d+\)', caseSensitive: false))) {
                seasonLinks.add(WikiquoteSeasonLink(title: a.text.trim(), pageName: href.replaceAll('/wiki/', '')));
              }
            }

            if (seasonLinks.isNotEmpty) {
              // Deduplicate season links just in case
              final uniqueLinks = <String, WikiquoteSeasonLink>{};
              for (final link in seasonLinks) {
                uniqueLinks[link.pageName] = link;
              }
              currentContent.addAll(uniqueLinks.values);
            } else {
              final lines = <WikiquoteDialogueLine>[];
              String? lastCharacter;
              for (final child in node.children) {
                if (child.localName == 'dt' || child.localName == 'dd') {
                   String text = child.text.replaceAll(RegExp(r'\[edit\]|\[\d+\]'), '').trim();
                   if (text.isEmpty) continue;
                   
                   String character = '';
                   if (text.contains(':')) {
                     final parts = text.split(':');
                     if (parts[0].length < 40 && !parts[0].contains('"')) {
                       character = parts[0].trim();
                       text = parts.sublist(1).join(':').trim();
                     }
                   }
                   
                   if (child.localName == 'dt' && text.isEmpty && character.isNotEmpty) {
                      lastCharacter = character;
                   } else {
                      if (character.isEmpty && lastCharacter != null && child.localName == 'dd') {
                         character = lastCharacter;
                      }
                      lines.add(WikiquoteDialogueLine(character: character, text: text));
                   }
                }
              }
              if (lines.isNotEmpty) {
                currentContent.add(WikiquoteDialogue(lines: lines));
              }
            }
          } else if (node.localName == 'p') {
            final text = node.text.replaceAll(RegExp(r'\[edit\]|\[\d+\]'), '').trim();
            if (text.isNotEmpty) {
              currentContent.add(WikiquoteText(text: text));
            }
          }
        }
      }
      saveSection();
      return WikiquoteArticle(title: pageTitle.replaceAll('_', ' '), sections: sections);
    } catch (e) {
      return null;
    }
  }
}
