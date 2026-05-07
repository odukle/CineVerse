import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:cineverse/domain/usecases/use_case.dart';

class GetPopularMoviesUseCase implements UseCase<List<MediaTitle>, NoParams> {
  const GetPopularMoviesUseCase(this.repository);

  final MediaRepository repository;

  @override
  Future<List<MediaTitle>> call(NoParams params) async {
    return repository.fetchPopularMovies();
  }
}
