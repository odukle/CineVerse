import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/media_review.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ReviewArg = ({int id, bool isTv});

final Map<ReviewArg, List<MediaReview>> _reviewsCache = {};
final Map<ReviewArg, int> _reviewsLoadedPages = {};
final Map<ReviewArg, bool> _reviewsExhausted = {};
final Map<ReviewArg, int> _reviewsTargetPages = {};

void loadNextReviewsPage(WidgetRef ref, ReviewArg arg) {
  if (_reviewsExhausted[arg] == true) return;
  _reviewsTargetPages[arg] = (_reviewsTargetPages[arg] ?? 1) + 1;
  ref.invalidate(mediaReviewsProvider(arg));
}

final mediaReviewsExhaustedProvider = Provider.family<bool, ReviewArg>((ref, arg) {
  return _reviewsExhausted[arg] ?? false;
});

final mediaReviewsProvider =
    FutureProvider.autoDispose.family<List<MediaReview>, ReviewArg>((ref, arg) async {
  final repository = ref.watch(mediaRepositoryProvider);
  
  final int targetPage = _reviewsTargetPages[arg] ?? 1;
  int loadedPage = _reviewsLoadedPages[arg] ?? 0;

  if (loadedPage >= targetPage) {
    return _reviewsCache[arg] ?? [];
  }

  final List<MediaReview> results = List<MediaReview>.from(
    _reviewsCache[arg] ?? const <MediaReview>[],
  );

  for (int p = loadedPage + 1; p <= targetPage; p++) {
    final List<MediaReview> pageResults = await repository.fetchMediaReviews(
      arg.id,
      isTv: arg.isTv,
      page: p,
    );

    if (pageResults.isEmpty) {
      _reviewsExhausted[arg] = true;
      break;
    }

    results.addAll(pageResults);
    _reviewsLoadedPages[arg] = p;
  }

  _reviewsCache[arg] = results;
  return results;
});
