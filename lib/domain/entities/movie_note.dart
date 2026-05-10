import 'package:cineverse/domain/entities/global_media_filter.dart';

class MovieNote {
  const MovieNote({
    required this.id,
    required this.movieId,
    required this.mediaType,
    required this.text,
    required this.createdAt,
  });

  final int id;
  final int movieId;
  final GlobalMediaType mediaType;
  final String text;
  final DateTime createdAt;
}
