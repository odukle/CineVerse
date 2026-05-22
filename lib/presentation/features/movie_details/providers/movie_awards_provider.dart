import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/presentation/features/movie_details/widgets/movie_awards_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final movieAwardsProvider =
    FutureProvider.family<MovieAwards, String>((ref, imdbId) async {
      if (imdbId.trim().isEmpty) {
        return MovieAwards.parse(null);
      }

      final omdbApiClient = ref.watch(omdbApiClientProvider);
      try {
        final dto = await omdbApiClient.fetchMovieRatings(imdbId);
        return MovieAwards.parse(dto?.awards);
      } catch (_) {
        return MovieAwards.parse(null);
      }
    });
