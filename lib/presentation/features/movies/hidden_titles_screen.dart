import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/presentation/features/movies/providers/hidden_titles_provider.dart';

class HiddenTitlesScreen extends ConsumerWidget {
  const HiddenTitlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final hiddenTitlesAsync = ref.watch(hiddenTitlesProvider);

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              HapticFeedback.selectionClick();
              context.pop();
            },
          ),
          title: Text(
            context.l10n.hiddenTitles,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: hiddenTitlesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text(
              context.l10n.errorGeneric(error.toString()),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          data: (hiddenTitles) {
            if (hiddenTitles.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.cinemaPanelGradient,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.cinemaBorder.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.cinemaAccent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.visibility_off_outlined,
                            color: Colors.white60,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          context.l10n.noHiddenTitles,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.hiddenTitlesDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: hiddenTitles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = hiddenTitles[index];
                final String formattedDate = DateFormat('MMM d, yyyy').format(item.hiddenAt);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.pushNamed(
                        AppRoute.movieDetails.name,
                        pathParameters: <String, String>{
                          'movieId': item.id.toString(),
                        },
                        queryParameters: <String, String>{
                          'isTv': item.isTv.toString(),
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.cinemaPanelGradient,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.cinemaBorder.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Poster image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.posterPath != null
                                ? CachedNetworkImage(
                                    imageUrl: 'https://image.tmdb.org/t/p/w92${item.posterPath}',
                                    width: 50,
                                    height: 75,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.white10,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(Colors.white30),
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.white10,
                                      child: const Icon(Icons.movie_outlined, color: Colors.white30),
                                    ),
                                  )
                                : Container(
                                    color: Colors.white10,
                                    width: 50,
                                    height: 75,
                                    child: const Icon(Icons.movie_outlined, color: Colors.white30),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          // Title & metadata
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.isTv
                                            ? Colors.purple.withValues(alpha: 0.2)
                                            : Colors.blue.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.isTv ? context.l10n.tvShow : context.l10n.movie,
                                        style: TextStyle(
                                          color: item.isTv
                                              ? Colors.purpleAccent
                                              : Colors.blueAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.l10n.hiddenDate(formattedDate),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Unhide Button
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_rounded,
                              color: Colors.white60,
                            ),
                            tooltip: context.l10n.tooltipUnhide,
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              await ref.read(hiddenTitlesProvider.notifier).unhideTitle(item.id, item.isTv);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.l10n.titleRestoredToSpotlight(item.title)),
                                    backgroundColor: AppColors.detailsCard,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
