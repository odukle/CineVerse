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

abstract class QuotesRepository {
  Future<List<MediaQuote>> fetchMediaQuotes(String title, {bool isTv = false});
  Future<List<MediaQuote>> fetchPersonQuotes(String name);
}
