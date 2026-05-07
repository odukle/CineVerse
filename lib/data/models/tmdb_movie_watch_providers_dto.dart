import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/domain/entities/movie_details.dart';

class TmdbMovieWatchProvidersDto {
  const TmdbMovieWatchProvidersDto({
    this.link,
    this.streaming = const <MovieWatchProvider>[],
    this.free = const <MovieWatchProvider>[],
    this.rent = const <MovieWatchProvider>[],
    this.buy = const <MovieWatchProvider>[],
  });

  factory TmdbMovieWatchProvidersDto.fromJson(
    Map<String, dynamic> json, {
    required String preferredRegionCode,
  }) {
    final Map<String, dynamic> results =
        (json['results'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final Map<String, dynamic>? region = _selectRegionResult(
      results,
      preferredRegionCode,
    );

    return TmdbMovieWatchProvidersDto(
      link: _optionalText(region?['link']),
      streaming: _resolveProviders(
        (region?['flatrate'] as List<dynamic>?) ?? const <dynamic>[],
      ),
      free: _resolveProviders(
        (region?['free'] as List<dynamic>?) ?? const <dynamic>[],
      ),
      rent: _resolveProviders(
        (region?['rent'] as List<dynamic>?) ?? const <dynamic>[],
      ),
      buy: _resolveProviders(
        (region?['buy'] as List<dynamic>?) ?? const <dynamic>[],
      ),
    );
  }

  final String? link;
  final List<MovieWatchProvider> streaming;
  final List<MovieWatchProvider> free;
  final List<MovieWatchProvider> rent;
  final List<MovieWatchProvider> buy;

  MovieWatchAvailability? toDomain() {
    final MovieWatchAvailability availability = MovieWatchAvailability(
      link: link,
      streaming: streaming,
      free: free,
      rent: rent,
      buy: buy,
    );

    if (!availability.hasProviders && availability.link == null) {
      return null;
    }

    return availability;
  }

  static Map<String, dynamic>? _selectRegionResult(
    Map<String, dynamic> rawResults,
    String preferredRegionCode,
  ) {
    final Map<String, dynamic>? preferredRegion =
        rawResults[preferredRegionCode] as Map<String, dynamic>?;
    if (_hasAvailability(preferredRegion)) {
      return preferredRegion;
    }

    for (final Object? value in rawResults.values) {
      final Map<String, dynamic>? region = value as Map<String, dynamic>?;
      if (_hasAvailability(region)) {
        return region;
      }
    }

    return preferredRegion;
  }

  static bool _hasAvailability(Map<String, dynamic>? region) {
    if (region == null) {
      return false;
    }

    return ((region['flatrate'] as List<dynamic>?)?.isNotEmpty ?? false) ||
        ((region['free'] as List<dynamic>?)?.isNotEmpty ?? false) ||
        ((region['rent'] as List<dynamic>?)?.isNotEmpty ?? false) ||
        ((region['buy'] as List<dynamic>?)?.isNotEmpty ?? false) ||
        _optionalText(region['link']) != null;
  }

  static List<MovieWatchProvider> _resolveProviders(
    List<dynamic> rawProviders,
  ) {
    final Set<int> seenProviderIds = <int>{};

    return rawProviders
        .whereType<Map<String, dynamic>>()
        .map(
          (provider) => MovieWatchProvider(
            id: (provider['provider_id'] as num?)?.toInt() ?? 0,
            name: _optionalText(provider['provider_name']) ?? '',
            logoPath: _normalizeImagePath(
              provider['logo_path'] as String?,
              size: 'w92',
            ),
          ),
        )
        .where(
          (provider) =>
              provider.id > 0 &&
              provider.name.isNotEmpty &&
              seenProviderIds.add(provider.id),
        )
        .toList(growable: false);
  }

  static String? _optionalText(Object? value) {
    final String? text = value as String?;
    if (text == null) {
      return null;
    }

    final String trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _normalizeImagePath(
    String? rawImagePath, {
    required String size,
  }) {
    if (rawImagePath == null || rawImagePath.isEmpty) {
      return null;
    }

    if (rawImagePath.startsWith('http://') ||
        rawImagePath.startsWith('https://')) {
      return rawImagePath;
    }

    return '${AppConstants.tmdbImageBaseUrl}/$size$rawImagePath';
  }
}
