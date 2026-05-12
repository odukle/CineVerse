import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieFilterNotifier extends Notifier<MediaFilter> {
  @override
  MediaFilter build() => const MediaFilter();

  void updateFilter(MediaFilter newFilter) => state = newFilter;
  void reset() => state = const MediaFilter();
}

final movieFilterProvider = NotifierProvider<MovieFilterNotifier, MediaFilter>(MovieFilterNotifier.new);

final isMovieFilteredProvider = Provider<bool>((ref) {
  return !ref.watch(movieFilterProvider).isDefault;
});

class TvFilterNotifier extends Notifier<MediaFilter> {
  @override
  MediaFilter build() => const MediaFilter();

  void updateFilter(MediaFilter newFilter) => state = newFilter;
  void reset() => state = const MediaFilter();
}

final tvFilterProvider = NotifierProvider<TvFilterNotifier, MediaFilter>(TvFilterNotifier.new);

final isTvFilteredProvider = Provider<bool>((ref) {
  return !ref.watch(tvFilterProvider).isDefault;
});
