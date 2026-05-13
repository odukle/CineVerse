class MediaQuote {
  final String text;
  final String? character;
  final String? context; // e.g. "Season 1, Episode 5"

  const MediaQuote({
    required this.text,
    this.character,
    this.context,
  });
}

abstract class WikiquoteContent {}

class WikiquoteText implements WikiquoteContent {
  final String text;
  final String? character;

  const WikiquoteText({required this.text, this.character});
}

class WikiquoteDialogue implements WikiquoteContent {
  final List<WikiquoteDialogueLine> lines;

  const WikiquoteDialogue({required this.lines});
}

class WikiquoteDialogueLine {
  final String character;
  final String text;

  const WikiquoteDialogueLine({required this.character, required this.text});
}

class WikiquoteSeasonLink implements WikiquoteContent {
  final String title;
  final String pageName;

  const WikiquoteSeasonLink({required this.title, required this.pageName});
}

class WikiquoteSection {
  final String title;
  final int level;
  final List<WikiquoteContent> content;

  const WikiquoteSection({
    required this.title,
    required this.level,
    required this.content,
  });

  WikiquoteSection copyWith({
    String? title,
    int? level,
    List<WikiquoteContent>? content,
  }) {
    return WikiquoteSection(
      title: title ?? this.title,
      level: level ?? this.level,
      content: content ?? this.content,
    );
  }
}

class WikiquoteArticle {
  final String title;
  final List<WikiquoteSection> sections;

  const WikiquoteArticle({
    required this.title,
    required this.sections,
  });
}

abstract class QuotesRepository {
  Future<List<MediaQuote>> fetchMediaQuotes(String title, {bool isTv = false});
  Future<List<MediaQuote>> fetchPersonQuotes(String name);
  
  Future<WikiquoteArticle?> fetchFullWikiquoteArticle(
    String title, {
    bool isTv = false,
    bool isSeason = false,
    String? exactPageTitle,
  });
}
