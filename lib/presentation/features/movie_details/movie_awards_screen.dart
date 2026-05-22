import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/features/movie_details/widgets/movie_awards_helper.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:flutter/material.dart';

class MovieAwardsScreen extends StatelessWidget {
  const MovieAwardsScreen({
    super.key,
    required this.awards,
    required this.movieTitle,
  });

  final MovieAwards awards;
  final String movieTitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> detailLines = awards.detailLines;

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Awards & Accolades',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                movieTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Top Summary Card
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.detailsCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.cinemaAccent.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cinemaAccent.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          size: 48,
                          color: Color(0xFFFFD700), // Gold
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Accolade Summary',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSummaryStat(
                              theme: theme,
                              count: awards.totalWins,
                              label: awards.totalWins == 1 ? 'Win' : 'Wins',
                              icon: Icons.emoji_events_rounded,
                              iconColor: const Color(0xFFFFD700),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white24,
                            ),
                            _buildSummaryStat(
                              theme: theme,
                              count: awards.totalNominations,
                              label:
                                  awards.totalNominations == 1
                                      ? 'Nomination'
                                      : 'Nominations',
                              icon: Icons.workspace_premium_rounded,
                              iconColor: const Color(0xFFB0C4DE),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // List Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Accolade Details',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                // Detail Cards List
                if (detailLines.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Text(
                        'No detailed awards info available.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final String line = detailLines[index];
                        return _buildDetailItem(theme, line);
                      },
                      childCount: detailLines.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat({
    required ThemeData theme,
    required int count,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(ThemeData theme, String text) {
    final String lower = text.toLowerCase();

    // Determine the icon and accent color based on award type
    IconData iconData = Icons.star_rounded;
    Color accentColor = AppColors.cinemaAccent;

    if (lower.contains('oscar')) {
      iconData = Icons.emoji_events_rounded;
      accentColor = const Color(0xFFFFD700); // Gold
    } else if (lower.contains('golden globe')) {
      iconData = Icons.emoji_events_outlined;
      accentColor = const Color(0xFFFFA500); // Orange / Gold
    } else if (lower.contains('bafta')) {
      iconData = Icons.workspace_premium_rounded;
      accentColor = const Color(0xFF40E0D0); // Turquoise
    } else if (lower.contains('win')) {
      iconData = Icons.emoji_events_rounded;
      accentColor = const Color(0xFFFFD700);
    } else if (lower.contains('nominated') || lower.contains('nomination')) {
      iconData = Icons.workspace_premium_rounded;
      accentColor = const Color(0xFFB0C4DE);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.detailsCard.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
