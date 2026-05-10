class SearchHistory {
  const SearchHistory({
    required this.id,
    required this.query,
    required this.createdAt,
  });

  final int id;
  final String query;
  final DateTime createdAt;
}
