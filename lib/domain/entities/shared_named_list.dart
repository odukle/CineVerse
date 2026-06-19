import 'package:cineverse/domain/entities/global_media_filter.dart';

class SharedNamedList {
  const SharedNamedList({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
    this.ownerDisplayName,
  });

  final String id;
  final String name;
  final List<SharedNamedListItem> items;
  final DateTime? createdAt;
  final String? ownerDisplayName;
}

class SharedNamedListItem {
  const SharedNamedListItem({
    required this.mediaId,
    required this.title,
    this.posterPath,
    this.releaseDate,
    required this.mediaType,
    this.voteAverage,
  });

  final int mediaId;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final GlobalMediaType mediaType;
  final double? voteAverage;
}
