import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';

class TonightPromptRequest {
  const TonightPromptRequest({
    required this.isTv,
    required this.prompt,
    this.requestNonce = 0,
  });

  final bool isTv;
  final String prompt;
  final int requestNonce;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TonightPromptRequest &&
            runtimeType == other.runtimeType &&
            isTv == other.isTv &&
            prompt.trim().toLowerCase() == other.prompt.trim().toLowerCase() &&
            requestNonce == other.requestNonce;
  }

  @override
  int get hashCode =>
      Object.hash(isTv, prompt.trim().toLowerCase(), requestNonce);
}

class TonightRecommendationItem {
  const TonightRecommendationItem({
    required this.title,
    required this.details,
    required this.matchReason,
    required this.score,
  });

  final MediaTitle title;
  final MovieDetails details;
  final String matchReason;
  final double score;
}

class TonightPromptResult {
  const TonightPromptResult({
    required this.interpretedIntent,
    required this.recommendations,
    this.queryPlanChips,
  });

  final String interpretedIntent;
  final List<TonightRecommendationItem> recommendations;
  final List<String>? queryPlanChips;
}

const List<String> tonightMoviePromptExamples = <String>[
  'I want something like Interstellar, but not sci-fi.',
  'A thriller under 2 hours with an insane twist in the end.',
  'A feel-good movie for tonight with great visuals.',
  'A gripping mystery with no supernatural elements.',
  'A smart heist movie with high ratings, no sequels.',
  'A comforting coming-of-age movie with strong characters.',
  'A dark crime drama that is not too violent.',
  'A visually stunning adventure movie for family night.',
  'A mind-bending movie like Memento, but easier to follow.',
  'An emotional drama with a hopeful ending.',
];

const List<String> tonightTvPromptExamples = <String>[
  'Give me intense Korean shows like Dark, but faster paced.',
  'A short thriller mini-series with a satisfying ending.',
  'A smart detective show with low filler episodes.',
  'A binge-worthy drama with strong female leads.',
  'A light comedy series under 30 minutes per episode.',
  'A suspense show like Mindhunter, but less disturbing.',
  'A feel-good show to unwind after work.',
  'A sci-fi series with deep world building and strong ratings.',
];

const List<String> tonightPromptExamples = <String>[
  ...tonightMoviePromptExamples,
  ...tonightTvPromptExamples,
];
