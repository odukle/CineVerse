class MediaReview {
  const MediaReview({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.authorAvatarPath,
    this.authorRating,
  });

  final String id;
  final String author;
  final String content;
  final DateTime createdAt;
  final String? authorAvatarPath;
  final double? authorRating;
}
