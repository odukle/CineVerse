class MediaTitle {
  const MediaTitle({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
    this.voteAverage,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final double? voteAverage;
}
