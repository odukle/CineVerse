import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/domain/entities/media_review.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_reviews_provider.dart';
import 'package:cineverse/presentation/widgets/app_back_button.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class AllReviewsScreen extends ConsumerStatefulWidget {
  const AllReviewsScreen({
    required this.mediaId,
    required this.isTv,
    super.key,
  });

  final int mediaId;
  final bool isTv;

  @override
  ConsumerState<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends ConsumerState<AllReviewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final arg = (id: widget.mediaId, isTv: widget.isTv);
    final reviewsValue = ref.read(mediaReviewsProvider(arg));
    if (reviewsValue.isLoading) return;
    if (ref.read(mediaReviewsExhaustedProvider(arg))) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      loadNextReviewsPage(ref, arg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arg = (id: widget.mediaId, isTv: widget.isTv);
    final reviewsAsync = ref.watch(mediaReviewsProvider(arg));
    final isExhausted = ref.watch(mediaReviewsExhaustedProvider(arg));

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(context.l10n.userReviews),
      ),
      body: reviewsAsync.when(
        skipLoadingOnReload: true,
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(child: Text(context.l10n.noReviewsYet));
          }

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length + (isExhausted ? 0 : 1),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == reviews.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final review = reviews[index];
              return _ReviewCard(review: review);
            },
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => const _ReviewShimmer(),
        ),
        error: (err, stack) => Center(child: Text(context.l10n.errorGeneric(err.toString()))),
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  const _ReviewCard({required this.review});

  final MediaReview review;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.review.authorAvatarPath != null)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: CachedNetworkImageProvider(
                    widget.review.authorAvatarPath!,
                  ),
                )
              else
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 20),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.review.author,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat.yMMMd().format(widget.review.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.review.authorRating != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cinemaAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        widget.review.authorRating!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final textSpan = TextSpan(
                text: widget.review.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              );

              final textPainter = TextPainter(
                text: textSpan,
                textDirection: Directionality.of(context),
                maxLines: 10,
              )..layout(maxWidth: constraints.maxWidth);

              final isLongText = textPainter.didExceedMaxLines;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: Text(
                      widget.review.content,
                      maxLines: _isExpanded ? null : 10,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.6,
                      ),
                    ),
                  ),
                  if (isLongText)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _isExpanded ? 'See Less' : 'See More',
                          style: TextStyle(
                            color: AppColors.cinemaAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReviewShimmer extends StatelessWidget {
  const _ReviewShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerEffect(width: 32, height: 32, borderRadius: 16),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerEffect.textLine(width: 100, height: 14),
                  const SizedBox(height: 4),
                  ShimmerEffect.textLine(width: 60, height: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShimmerEffect.textLine(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          ShimmerEffect.textLine(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          ShimmerEffect.textLine(width: 200, height: 14),
        ],
      ),
    );
  }
}
