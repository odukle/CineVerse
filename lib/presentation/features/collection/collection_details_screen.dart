import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_collection.dart';
import 'package:cineverse/presentation/features/movies/widgets/rating_badge.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final collectionDetailsProvider = FutureProvider.family<MovieCollection, int>((
  ref,
  collectionId,
) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return await repository.fetchMovieCollectionDetails(collectionId);
});

class CollectionDetailsScreen extends ConsumerWidget {
  const CollectionDetailsScreen({super.key, required this.collectionId});

  final int collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionDetailsProvider(collectionId));

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      body: collectionAsync.when(
        data: (collection) => _CollectionDetailsContent(collection: collection),
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.cinemaAccent),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white30,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load collection details',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(collectionDetailsProvider(collectionId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cinemaAccent,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionDetailsContent extends ConsumerWidget {
  const _CollectionDetailsContent({required this.collection});

  final MovieCollection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    // Calculate watch progress
    int watchedCount = 0;
    for (final part in collection.parts) {
      final isWatched =
          ref
              .watch(
                isWatchedProvider((
                  id: part.id,
                  type: part.mediaType ?? GlobalMediaType.movie,
                )),
              )
              .value ??
          false;
      if (isWatched) watchedCount++;
    }

    final double progress = collection.parts.isNotEmpty
        ? watchedCount / collection.parts.length
        : 0.0;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: size.height * 0.35,
          pinned: true,
          backgroundColor: AppColors.cinemaBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              context.pop();
            },
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (collection.backdropPath != null)
                  CachedNetworkImage(
                    imageUrl: collection.backdropPath!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.cinemaPlaceholder),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.cinemaPlaceholder),
                  )
                else
                  Container(color: AppColors.cinemaPlaceholder),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        AppColors.cinemaBackground,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collection Name
                Text(
                  collection.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Overview
                if (collection.overview != null &&
                    collection.overview!.isNotEmpty) ...[
                  Text(
                    collection.overview!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Watch Progress Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: AppColors.cinemaPanelGradient,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Franchise Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$watchedCount of ${collection.parts.length} Watched',
                            style: TextStyle(
                              color: AppColors.cinemaAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          color: AppColors.cinemaAccent,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Parts Title
                Text(
                  'Movies in this Collection',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final part = collection.parts[index];
              final isWatched =
                  ref
                      .watch(
                        isWatchedProvider((
                          id: part.id,
                          type: part.mediaType ?? GlobalMediaType.movie,
                        )),
                      )
                      .value ??
                  false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.pushNamed(
                      AppRoute.movieDetails.name,
                      pathParameters: {'movieId': part.id.toString()},
                      queryParameters: {
                        'isTv': (part.mediaType == GlobalMediaType.tv)
                            .toString(),
                      },
                    );
                  },
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.detailsCard,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                          child: SizedBox(
                            width: 74,
                            height: 110,
                            child: part.posterPath != null
                                ? CachedNetworkImage(
                                    imageUrl: part.posterPath!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => Container(
                                      color: AppColors.cinemaPlaceholder,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (_, _, _) => Container(
                                      color: AppColors.cinemaPlaceholder,
                                      child: const Icon(
                                        Icons.movie_outlined,
                                        color: Colors.white30,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: AppColors.cinemaPlaceholder,
                                    child: const Icon(
                                      Icons.movie_outlined,
                                      color: Colors.white30,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  part.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (part.releaseDate != null &&
                                        part.releaseDate!.length >= 4) ...[
                                      Text(
                                        part.releaseDate!.substring(0, 4),
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (part.voteAverage != null &&
                                        part.voteAverage! > 0)
                                      RatingBadge.tmdb(
                                        catalogScore: part.voteAverage,
                                        size: 16,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isWatched)
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cinemaAccent.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.cinemaAccent.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    color: AppColors.cinemaAccent,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Watched',
                                    style: TextStyle(
                                      color: AppColors.cinemaAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white30,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: collection.parts.length),
          ),
        ),
      ],
    );
  }
}
