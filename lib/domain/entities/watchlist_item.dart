import 'package:cineverse/domain/entities/global_media_filter.dart';

class WatchlistItem {
  const WatchlistItem({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
    required this.mediaType,
    required this.addedDate,
    this.voteAverage,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final GlobalMediaType mediaType;
  final DateTime addedDate;
  final double? voteAverage;
}
