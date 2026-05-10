import 'package:cineverse/domain/entities/global_media_filter.dart';

class MediaTitle {
  const MediaTitle({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
    this.voteAverage,
    this.mediaType,
    this.genreIds = const [],
    this.voteCount = 0,
    this.popularity = 0.0,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final double? voteAverage;
  final GlobalMediaType? mediaType;
  final List<int> genreIds;
  final int voteCount;
  final double popularity;

  MediaTitle copyWith({
    int? id,
    String? title,
    String? posterPath,
    String? releaseDate,
    double? voteAverage,
    GlobalMediaType? mediaType,
    List<int>? genreIds,
    int? voteCount,
    double? popularity,
  }) {
    return MediaTitle(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      mediaType: mediaType ?? this.mediaType,
      genreIds: genreIds ?? this.genreIds,
      voteCount: voteCount ?? this.voteCount,
      popularity: popularity ?? this.popularity,
    );
  }
}
