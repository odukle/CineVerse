import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/providers/quotes_provider.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cineverse/domain/entities/movie_details.dart';

class QuotesCarousel extends ConsumerWidget {
  const QuotesCarousel({super.key, required this.details, required this.isTv});

  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(
      mediaQuotesProvider((title: details.title, isTv: isTv)),
    );
    final theme = Theme.of(context);

    return quotesAsync.when(
      data: (quotes) {
        if (quotes.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quotes',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(
                            '/explore_quotes',
                            extra: {
                              'title': details.title,
                              'isTv': isTv,
                              'details': details,
                            },
                          );
                        },
                        child: Text(
                          'Explore',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.cinemaAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'May include occasional mismatches due to lexical quote search.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.64),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: quotes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final quote = quotes[index];
                  return Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: theme.cardTheme.shape is RoundedRectangleBorder
                          ? Border.fromBorderSide(
                              (theme.cardTheme.shape as RoundedRectangleBorder)
                                  .side,
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          color: Colors.white24,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            quote.text,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (quote.character != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '— ${quote.character}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.cinemaAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
            child: ShimmerEffect.textLine(width: 100, height: 24),
          ),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) =>
                  ShimmerEffect(width: 280, height: 180, borderRadius: 20),
            ),
          ),
        ],
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
