import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';

class GetTvSeasonDetailsUseCase {
  GetTvSeasonDetailsUseCase(this._repository);
  final MediaRepository _repository;

  Future<TvSeason> call(int tvId, int seasonNumber) =>
      _repository.fetchTvSeasonDetails(tvId, seasonNumber);
}

class GetTvEpisodeDetailsUseCase {
  GetTvEpisodeDetailsUseCase(this._repository);
  final MediaRepository _repository;

  Future<TvEpisode> call(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) =>
      _repository.fetchTvEpisodeDetails(tvId, seasonNumber, episodeNumber);
}
