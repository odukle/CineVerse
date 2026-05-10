import 'package:cineverse/domain/entities/global_media_filter.dart';

class WatchedItem {
  const WatchedItem({
    required this.id,
    required this.title,
    this.posterPath,
    required this.mediaType,
    required this.watchDate,
    required this.rating,
    this.rewatchCount = 0,
    this.voteAverage,
  });

  final int id;
  final String title;
  final String? posterPath;
  final GlobalMediaType mediaType;
  final DateTime watchDate;
  final int rating; // 1-5
  final int rewatchCount;
  final double? voteAverage;

  WatchedItem copyWith({
    int? id,
    String? title,
    String? posterPath,
    GlobalMediaType? mediaType,
    DateTime? watchDate,
    int? rating,
    int? rewatchCount,
    double? voteAverage,
  }) {
    return WatchedItem(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      mediaType: mediaType ?? this.mediaType,
      watchDate: watchDate ?? this.watchDate,
      rating: rating ?? this.rating,
      rewatchCount: rewatchCount ?? this.rewatchCount,
      voteAverage: voteAverage ?? this.voteAverage,
    );
  }
}
