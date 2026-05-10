import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/usecases/get_tv_details_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getTvSeasonDetailsUseCaseProvider = Provider<GetTvSeasonDetailsUseCase>((ref) {
  return GetTvSeasonDetailsUseCase(ref.watch(mediaRepositoryProvider));
});

final getTvEpisodeDetailsUseCaseProvider = Provider<GetTvEpisodeDetailsUseCase>((ref) {
  return GetTvEpisodeDetailsUseCase(ref.watch(mediaRepositoryProvider));
});

typedef TvSeasonParams = ({int tvId, int seasonNumber});

final tvSeasonDetailsProvider =
    FutureProvider.family<TvSeason, TvSeasonParams>((ref, params) async {
  return ref
      .watch(getTvSeasonDetailsUseCaseProvider)
      .call(params.tvId, params.seasonNumber);
});

typedef TvEpisodeParams = ({int tvId, int seasonNumber, int episodeNumber});

final tvEpisodeDetailsProvider =
    FutureProvider.family<TvEpisode, TvEpisodeParams>((ref, params) async {
  return ref.watch(getTvEpisodeDetailsUseCaseProvider).call(
        params.tvId,
        params.seasonNumber,
        params.episodeNumber,
      );
});
