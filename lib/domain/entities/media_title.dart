class MediaTitle {
  const MediaTitle({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
}
