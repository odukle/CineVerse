import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';

class DiscoverMediaParams {
  const DiscoverMediaParams({
    required this.isTv,
    required this.filter,
    this.page = 1,
  });

  final bool isTv;
  final MediaFilter filter;
  final int page;
}

class DiscoverMediaUseCase {
  const DiscoverMediaUseCase(this.repository);

  final MediaRepository repository;

  Future<List<MediaTitle>> call(DiscoverMediaParams params) {
    return repository.discoverMedia(
      isTv: params.isTv,
      filter: params.filter,
      page: params.page,
    );
  }
}
