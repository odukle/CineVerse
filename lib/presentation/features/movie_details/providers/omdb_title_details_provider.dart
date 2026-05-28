import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/data/models/omdb_title_details_dto.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OmdbTitleDetailsRequest {
  const OmdbTitleDetailsRequest({
    required this.imdbId,
    required this.fallbackTitle,
  });

  final String imdbId;
  final String fallbackTitle;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OmdbTitleDetailsRequest &&
        other.imdbId.trim() == imdbId.trim() &&
        other.fallbackTitle.trim() == fallbackTitle.trim();
  }

  @override
  int get hashCode => Object.hash(imdbId.trim(), fallbackTitle.trim());
}

final omdbTitleDetailsProvider =
    FutureProvider.family<OmdbTitleDetailsDto, OmdbTitleDetailsRequest>((
      ref,
      request,
    ) async {
      final AppConfig appConfig = ref.watch(appConfigProvider);
      if (!appConfig.hasOmdbResolverApiUrl || request.imdbId.trim().isEmpty) {
        throw StateError('OMDb full plot is unavailable for this title.');
      }

      final omdbApiClient = ref.watch(omdbApiClientProvider);
      final OmdbTitleDetailsDto? details = await omdbApiClient
          .fetchTitleDetails(request.imdbId, fullPlot: true);
      if (details == null) {
        throw StateError('OMDb full plot is unavailable for this title.');
      }
      return details;
    });
