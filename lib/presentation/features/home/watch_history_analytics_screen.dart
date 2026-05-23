import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/features/home/providers/watch_history_analytics_provider.dart';
import 'package:cineverse/presentation/features/home/providers/watch_history_insights_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchHistoryAnalyticsScreen extends ConsumerWidget {
  const WatchHistoryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WatchHistoryAnalytics?> analyticsAsync = ref.watch(
      watchHistoryAnalyticsProvider,
    );
    final int watchedCount = ref
        .watch(watchedItemsProvider)
        .maybeWhen(data: (items) => items.length, orElse: () => 0);

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Watch Analytics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        body: analyticsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _AnalyticsMessage(
            title: 'Could not load analytics',
            subtitle: 'Try again after a moment.',
            actionLabel: 'Retry',
            onTap: () {
              HapticFeedback.selectionClick();
              ref.invalidate(watchHistoryAnalyticsProvider);
            },
          ),
          data: (analytics) {
            if (analytics == null) {
              final int remaining =
                  kMinimumWatchedItemsForInsights - watchedCount;
              return _AnalyticsMessage(
                title: 'Not enough data yet',
                subtitle: watchedCount <= 0
                    ? 'Add and rate at least $kMinimumWatchedItemsForInsights titles to unlock analytics.'
                    : 'You have $watchedCount/$kMinimumWatchedItemsForInsights watched titles. Add $remaining more to unlock analytics.',
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
              children: <Widget>[
                _AnimatedCard(child: _HeaderSummary(analytics: analytics)),
                const SizedBox(height: 14),
                _AnimatedCard(
                  delay: 80,
                  child: _MoviesPerMonthChart(data: analytics.moviesPerMonth),
                ),
                const SizedBox(height: 14),
                _AnimatedCard(
                  delay: 140,
                  child: _GenreDistributionChart(
                    data: analytics.genreDistribution,
                  ),
                ),
                const SizedBox(height: 14),
                _AnimatedCard(
                  delay: 200,
                  child: _RatingTrendChart(data: analytics.ratingTrends),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  const _HeaderSummary({required this.analytics});

  final WatchHistoryAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Analyzed ${analytics.analyzedTitlesCount} titles • Updated ${_formatTimestamp(analytics.generatedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.68),
          ),
        ),
      ],
    );
  }
}

class _MoviesPerMonthChart extends StatelessWidget {
  const _MoviesPerMonthChart({required this.data});

  final List<MonthlyWatchCount> data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (data.isEmpty) {
      return const _NoChartData(
        label: 'No movie watch history for recent months.',
      );
    }

    final double maxY =
        data
            .map((d) => d.count.toDouble())
            .fold<double>(0, (a, b) => a > b ? a : b) +
        1;

    return _ChartShell(
      title: 'Movies Per Month',
      subtitle: 'How many movies you watched each month',
      child: SizedBox(
        height: 240,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withValues(alpha: 0.08),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.56),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final int i = value.toInt();
                    if (i < 0 || i >= data.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        data[i].label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List<BarChartGroupData>.generate(data.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: <BarChartRodData>[
                  BarChartRodData(
                    toY: data[i].count.toDouble(),
                    color: AppColors.cinemaAccent,
                    width: 14,
                    borderRadius: BorderRadius.circular(5),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ],
              );
            }),
          ),
          duration: const Duration(milliseconds: 700),
        ),
      ),
    );
  }
}

class _GenreDistributionChart extends StatelessWidget {
  const _GenreDistributionChart({required this.data});

  final List<GenreDistributionDatum> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _NoChartData(label: 'No genre distribution available yet.');
    }

    final int total = data.fold<int>(0, (sum, d) => sum + d.count);
    final List<Color> palette = <Color>[
      const Color(0xFF7BDFF6),
      const Color(0xFFFF9E7A),
      const Color(0xFFA78BFA),
      const Color(0xFF4ADE80),
      const Color(0xFFFDE047),
      const Color(0xFFF472B6),
      const Color(0xFF94A3B8),
    ];

    return _ChartShell(
      title: 'Genre Distribution',
      subtitle: 'What genres dominate your watch history',
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 42,
                sectionsSpace: 2,
                sections: List<PieChartSectionData>.generate(data.length, (i) {
                  final GenreDistributionDatum d = data[i];
                  final double pct = total == 0 ? 0 : (d.count / total) * 100;
                  return PieChartSectionData(
                    value: d.count.toDouble(),
                    color: palette[i % palette.length],
                    radius: 60,
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  );
                }),
              ),
              duration: const Duration(milliseconds: 700),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: List<Widget>.generate(data.length, (i) {
              final GenreDistributionDatum d = data[i];
              final Color color = palette[i % palette.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${d.genre} (${d.count})',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RatingTrendChart extends StatelessWidget {
  const _RatingTrendChart({required this.data});

  final List<MonthlyRatingTrend> data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (data.isEmpty) {
      return const _NoChartData(label: 'No rating trend data available yet.');
    }

    return _ChartShell(
      title: 'Rating Trends',
      subtitle: 'How your personal ratings are shifting over time',
      child: SizedBox(
        height: 240,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 5,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withValues(alpha: 0.08),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, _) => Text(
                    value.toStringAsFixed(0),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.56),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final int i = value.toInt();
                    if (i < 0 || i >= data.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        data[i].label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: <LineChartBarData>[
              LineChartBarData(
                spots: List<FlSpot>.generate(
                  data.length,
                  (i) => FlSpot(i.toDouble(), data[i].averageRating),
                ),
                isCurved: true,
                color: AppColors.cinemaAccent,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                    radius: 3.5,
                    color: AppColors.cinemaAccent,
                    strokeColor: Colors.black26,
                    strokeWidth: 1,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AppColors.cinemaAccent.withValues(alpha: 0.25),
                      AppColors.cinemaAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 700),
        ),
      ),
    );
  }
}

class _ChartShell extends StatelessWidget {
  const _ChartShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.cinemaBorder.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.66),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _NoChartData extends StatelessWidget {
  const _NoChartData({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return _ChartShell(
      title: 'No Data',
      subtitle: label,
      child: const SizedBox(height: 80),
    );
  }
}

class _AnalyticsMessage extends StatelessWidget {
  const _AnalyticsMessage({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onTap != null) ...<Widget>[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onTap?.call();
                },
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  const _AnimatedCard({required this.child, this.delay = 0});

  final Widget child;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
    );
  }
}

String _formatTimestamp(DateTime dateTime) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final String hh = dateTime.hour.toString().padLeft(2, '0');
  final String mm = dateTime.minute.toString().padLeft(2, '0');
  return '$hh:$mm • ${dateTime.day} ${months[dateTime.month - 1]}';
}
