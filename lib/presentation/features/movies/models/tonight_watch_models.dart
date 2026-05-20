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

const List<String> tonightPromptExamples = <String>[
  'I want something like Interstellar, but not sci-fi.',
  'A thriller under 2 hours with an insane twist in the end.',
  'A feel-good movie for tonight with great visuals.',
  'Give me intense Korean shows like Dark, but faster paced.',
];
