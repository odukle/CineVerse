import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExploreMediaType { movie, tv }

class ExploreMediaTypeNotifier extends Notifier<ExploreMediaType> {
  @override
  ExploreMediaType build() => ExploreMediaType.movie;

  void setType(ExploreMediaType type) {
    state = type;
  }
}

final exploreMediaTypeProvider =
    NotifierProvider<ExploreMediaTypeNotifier, ExploreMediaType>(
  ExploreMediaTypeNotifier.new,
);
