import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:cineverse/domain/usecases/use_case.dart';

class GetMovieSectionUseCase
    implements UseCase<List<MediaTitle>, MovieSection> {
  const GetMovieSectionUseCase(this.repository);

  final MediaRepository repository;

  @override
  Future<List<MediaTitle>> call(MovieSection params, {int page = 1, MediaFilter? filter}) {
    return repository.fetchMoviesForSectionPage(params, page: page, filter: filter);
  }
}
