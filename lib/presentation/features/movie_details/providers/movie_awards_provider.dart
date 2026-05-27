import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/core/network/dio_provider.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/presentation/features/movie_details/widgets/movie_awards_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieAwardsRequest {
  const MovieAwardsRequest({required this.movieId, this.imdbId});

  final int movieId;
  final String? imdbId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieAwardsRequest &&
        other.movieId == movieId &&
        (other.imdbId ?? '').trim() == (imdbId ?? '').trim();
  }

  @override
  int get hashCode => Object.hash(movieId, (imdbId ?? '').trim());
}

final movieAwardsProvider =
    FutureProvider.family<MovieAwards, MovieAwardsRequest>((ref, request) async {
      final Dio client = ref.watch(dioProvider);
      final AppConfig appConfig = ref.watch(appConfigProvider);
      final String imdbId = (request.imdbId ?? '').trim();

      if (request.movieId > 0 && appConfig.hasMovieAwardsResolverApiUrl) {
        try {
          final Response<Map<String, dynamic>> response =
              await client.post<Map<String, dynamic>>(
                appConfig.movieAwardsResolverApiUrl,
                data: <String, dynamic>{
                  'movieId': request.movieId,
                  if (imdbId.isNotEmpty) 'imdbId': imdbId,
                },
              );
          final Map<String, dynamic>? payload = response.data;
          final String awardsText =
              (payload?['awardsText'] as String? ?? '').trim();
          if (awardsText.isNotEmpty) {
            return MovieAwards.fromResolverPayload(payload);
          }
        } catch (_) {
          // Fall back to OMDb below.
        }
      }

      if (imdbId.isEmpty) {
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
