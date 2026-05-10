import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:cineverse/domain/usecases/use_case.dart';

class SearchMultiUseCase
    implements UseCase<List<MediaTitle>, SearchMultiParams> {
  const SearchMultiUseCase(this.repository);

  final MediaRepository repository;

  @override
  Future<List<MediaTitle>> call(SearchMultiParams params) {
    return repository.searchMulti(params.query, page: params.page);
  }
}

class SearchMultiParams {
  const SearchMultiParams({required this.query, this.page = 1});

  final String query;
  final int page;
}
