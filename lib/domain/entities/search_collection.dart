class SearchCollection {
  const SearchCollection({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
    this.overview,
  });

  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
}
