import 'package:cineverse/domain/entities/media_review.dart';

class TmdbReviewDto {
  const TmdbReviewDto({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.authorAvatarPath,
    this.authorRating,
  });

  factory TmdbReviewDto.fromJson(Map<String, dynamic> json) {
    final authorDetails = json['author_details'] as Map<String, dynamic>?;
    
    return TmdbReviewDto(
      id: json['id'] as String,
      author: json['author'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorAvatarPath: authorDetails?['avatar_path'] as String?,
      authorRating: (authorDetails?['rating'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String author;
  final String content;
  final DateTime createdAt;
  final String? authorAvatarPath;
  final double? authorRating;

  TmdbReviewDto copyWith({
    String? id,
    String? author,
    String? content,
    DateTime? createdAt,
    String? authorAvatarPath,
    double? authorRating,
  }) {
    return TmdbReviewDto(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      authorAvatarPath: authorAvatarPath ?? this.authorAvatarPath,
      authorRating: authorRating ?? this.authorRating,
    );
  }

  MediaReview toDomain() {
    return MediaReview(
      id: id,
      author: author,
      content: content,
      createdAt: createdAt,
      authorAvatarPath: authorAvatarPath,
      authorRating: authorRating,
    );
  }
}

class TmdbReviewsResponseDto {
  const TmdbReviewsResponseDto({required this.reviews});

  factory TmdbReviewsResponseDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawResults =
        (json['results'] as List<dynamic>?) ?? <dynamic>[];

    return TmdbReviewsResponseDto(
      reviews: rawResults
          .whereType<Map<String, dynamic>>()
          .map(TmdbReviewDto.fromJson)
          .toList(growable: false),
    );
  }

  final List<TmdbReviewDto> reviews;
}
