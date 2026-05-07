import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getMovieDetailsUseCaseProvider = Provider<GetMovieDetailsUseCase>((ref) {
  return GetMovieDetailsUseCase(ref.watch(mediaRepositoryProvider));
});

final movieDetailsProvider =
    FutureProvider.family<MovieDetails, GetMovieDetailsParams>((
      ref,
      params,
    ) async {
      final GetMovieDetailsUseCase useCase = ref.watch(
        getMovieDetailsUseCaseProvider,
      );

      return useCase(params);
    });
