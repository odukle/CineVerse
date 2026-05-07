import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/usecases/get_popular_movies_use_case.dart';
import 'package:cineverse/domain/usecases/use_case.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getPopularMoviesUseCaseProvider = Provider<GetPopularMoviesUseCase>((
  ref,
) {
  return GetPopularMoviesUseCase(ref.watch(mediaRepositoryProvider));
});

final popularMoviesProvider = FutureProvider<List<MediaTitle>>((ref) async {
  final GetPopularMoviesUseCase useCase = ref.watch(
    getPopularMoviesUseCaseProvider,
  );

  try {
    return await useCase(const NoParams());
  } catch (error, stackTrace) {
    debugPrint('[popularMoviesProvider] $error');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
});
