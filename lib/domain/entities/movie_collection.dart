import 'package:cineverse/domain/entities/media_title.dart';

class MovieCollection {
  const MovieCollection({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    required this.parts,
  });

  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final List<MediaTitle> parts;
}
