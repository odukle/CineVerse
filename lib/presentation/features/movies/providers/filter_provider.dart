import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsFilteringNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setState(bool value) => state = value;
}

final isFilteringProvider = NotifierProvider<IsFilteringNotifier, bool>(IsFilteringNotifier.new);

class MovieFilterNotifier extends Notifier<MediaFilter> {
  @override
  MediaFilter build() => const MediaFilter();

  void updateFilter(MediaFilter newFilter) => state = newFilter;
  void reset() => state = const MediaFilter();
}

final movieFilterProvider = NotifierProvider<MovieFilterNotifier, MediaFilter>(MovieFilterNotifier.new);

class TvFilterNotifier extends Notifier<MediaFilter> {
  @override
  MediaFilter build() => const MediaFilter();

  void updateFilter(MediaFilter newFilter) => state = newFilter;
  void reset() => state = const MediaFilter();
}

final tvFilterProvider = NotifierProvider<TvFilterNotifier, MediaFilter>(TvFilterNotifier.new);
