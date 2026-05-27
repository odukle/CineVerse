import 'dart:async';
import 'dart:io';

import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/features/home/providers/watch_history_analytics_provider.dart';
import 'package:cineverse/presentation/features/home/providers/watch_history_insights_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class WatchHistoryAnalyticsScreen extends ConsumerWidget {
  const WatchHistoryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WatchHistoryAnalytics?> analyticsAsync = ref.watch(
      watchHistoryAnalyticsProvider,
    );
    final AsyncValue<WatchHistoryInsights?> insightsAsync = ref.watch(
      watchHistoryInsightsProvider,
    );
    final List<String> watchedPosterPaths = ref
        .watch(watchedItemsProvider)
        .maybeWhen(
          data: (items) => items
              .map((item) => item.posterPath?.trim() ?? '')
              .where((path) => path.isNotEmpty)
              .toSet()
              .take(8)
              .toList(growable: false),
          orElse: () => const <String>[],
        );
    final WatchHistoryAnalytics? analyticsValue = analyticsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final WatchHistoryInsights? insightsValue = insightsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
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
          actions: <Widget>[
            if (analyticsValue != null)
              IconButton(
                tooltip: 'Share analytics',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  WatchAnalyticsShareBottomSheet.show(
                    context,
                    analytics: analyticsValue,
                    insights: insightsValue,
                    posterPaths: watchedPosterPaths,
                  );
                },
                icon: const Icon(Icons.share_rounded, color: Colors.white),
              ),
          ],
        ),
        body: analyticsAsync.when(
          loading: () => const _AnalyticsLoadingState(),
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
                insightsAsync.when(
                  data: (insights) {
                    if (insights == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AnimatedCard(
                          delay: 40,
                          child: _WatchHistoryInsightsSection(insights: insights),
                        ),
                        const SizedBox(height: 14),
                      ],
                    );
                  },
                  loading: () => const Column(
                    children: [
                      _AnimatedCard(
                        delay: 40,
                        child: _WatchHistoryInsightsShimmer(),
                      ),
                      SizedBox(height: 14),
                    ],
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
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

class _AnalyticsLoadingState extends StatefulWidget {
  const _AnalyticsLoadingState();

  @override
  State<_AnalyticsLoadingState> createState() => _AnalyticsLoadingStateState();
}

class _AnalyticsLoadingStateState extends State<_AnalyticsLoadingState> {
  static const List<String> _steps = <String>[
    'Reading your watched history...',
    'Finding your top genres and patterns...',
    'Building monthly and rating trends...',
    'Writing your personalized insights...',
  ];

  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _index = (_index + 1) % _steps.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.cinemaBorder.withValues(alpha: 0.28),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.cinemaGlow.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: -10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Generating Watch Analytics',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _steps[_index],
                  key: ValueKey<int>(_index),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 7,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: (_index % _steps.length) / _steps.length,
                      end: ((_index + 1) % _steps.length) / _steps.length,
                    ),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeInOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value == 0 ? 0.02 : value,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.cinemaAccent,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'This usually takes a few seconds.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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

class WatchAnalyticsShareBottomSheet extends StatefulWidget {
  const WatchAnalyticsShareBottomSheet({
    super.key,
    required this.analytics,
    this.insights,
    this.posterPaths = const <String>[],
  });

  final WatchHistoryAnalytics analytics;
  final WatchHistoryInsights? insights;
  final List<String> posterPaths;

  static void show(
    BuildContext context, {
    required WatchHistoryAnalytics analytics,
    WatchHistoryInsights? insights,
    List<String> posterPaths = const <String>[],
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WatchAnalyticsShareBottomSheet(
        analytics: analytics,
        insights: insights,
        posterPaths: posterPaths,
      ),
    );
  }

  @override
  State<WatchAnalyticsShareBottomSheet> createState() =>
      _WatchAnalyticsShareBottomSheetState();
}

class _WatchAnalyticsShareBottomSheetState
    extends State<WatchAnalyticsShareBottomSheet> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareVisualCard() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final Uint8List imageBytes = await _screenshotController.captureFromWidget(
        _AnalyticsShareableCard(
          analytics: widget.analytics,
          insights: widget.insights,
          posterPaths: widget.posterPaths,
        ),
        context: context,
        delay: const Duration(milliseconds: 350),
        targetSize: const Size(1080, 1920),
      );

      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File(
        '${tempDir.path}/lumi_watch_analytics_share.png',
      ).create();
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        <XFile>[XFile(file.path)],
        text: 'My latest watch analytics on Lumi',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share analytics card.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _shareInsightsCard() async {
    final WatchHistoryInsights? insights = widget.insights;
    if (insights == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Watch insights are not ready yet.')),
      );
      return;
    }
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final Uint8List imageBytes = await _screenshotController.captureFromWidget(
        _WatchInsightsShareableCard(insights: insights),
        context: context,
        delay: const Duration(milliseconds: 350),
        targetSize: const Size(1080, 1350),
      );

      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File(
        '${tempDir.path}/lumi_watch_insights_share.png',
      ).create();
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        <XFile>[XFile(file.path)],
        text: 'My watch insights on Lumi',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share watch insights.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.cinemaSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Share Analytics',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _AnalyticsShareOptionItem(
            icon: Icons.auto_awesome_rounded,
            title: 'Infographics Card',
            subtitle: 'Styled card with your watch stats',
            color: AppColors.cinemaAccent,
            onTap: _isSharing
                ? null
                : () {
                    Navigator.pop(context);
                    _shareVisualCard();
                  },
          ),
          _AnalyticsShareOptionItem(
            icon: Icons.auto_graph_rounded,
            title: 'Watch Insights Snapshot',
            subtitle: widget.insights == null
                ? 'Available once insights are ready'
                : 'Share your watch insights card',
            color: Colors.blueAccent,
            onTap: widget.insights == null
                ? null
                : () {
                    Navigator.pop(context);
                    _shareInsightsCard();
                  },
          ),
        ],
      ),
    );
  }
}

class _AnalyticsShareOptionItem extends StatelessWidget {
  const _AnalyticsShareOptionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
    );
  }
}

class _AnalyticsShareableCard extends StatelessWidget {
  const _AnalyticsShareableCard({
    required this.analytics,
    this.insights,
    this.posterPaths = const <String>[],
  });

  final WatchHistoryAnalytics analytics;
  final WatchHistoryInsights? insights;
  final List<String> posterPaths;

  @override
  Widget build(BuildContext context) {
    final List<GenreDistributionDatum> topGenres = analytics.genreDistribution
        .take(6)
        .toList(growable: false);
    final String favGenres = (insights?.favoriteGenres ?? <String>[])
        .take(3)
        .join(' • ');

    return Material(
      color: Colors.transparent,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topLeft,
        child: Container(
          width: 1080,
          height: 1920,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                const Color(0xFF0D1220),
                AppColors.cinemaSurface,
                const Color(0xFF121B2F),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(56, 56, 56, 46),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.cinemaAccent.withValues(alpha: 0.14),
                      border: Border.all(
                        color: AppColors.cinemaAccent.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'LUMI WATCH ANALYTICS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.cinemaAccent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formatTimestamp(analytics.generatedAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Your Screen Story',
              style: TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w800,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'A snapshot of how and what you watch',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            _ShareSectionCard(
              title: 'Recently Watched Vibe',
              child: _PosterCollage(posterPaths: posterPaths),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _ShareStatCard(
                  label: 'Titles Analyzed',
                  value: '${analytics.analyzedTitlesCount}',
                ),
                const SizedBox(width: 18),
                _ShareStatCard(
                  label: 'Preferred Runtime',
                  value: insights?.preferredRuntimeLabel ?? 'Balanced',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ShareSectionCard(
              title: 'Favorite Genres',
              child: Text(
                favGenres.isEmpty ? 'Mixed across genres' : favGenres,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ShareSectionCard(
              title: 'Genre Distribution',
              child: _ShareGenreDistributionPieChart(data: topGenres),
            ),
            const SizedBox(height: 12),
            _ShareSectionCard(
              title: 'Movies / Month',
              child: SizedBox(
                height: 250,
                child: _ShareMoviesPerMonthChart(data: analytics.moviesPerMonth),
              ),
            ),
            const SizedBox(height: 12),
            _ShareSectionCard(
              title: 'Rating Trend',
              child: SizedBox(
                height: 250,
                child: _ShareRatingTrendChart(data: analytics.ratingTrends),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Built with Lumi',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareGenreDistributionPieChart extends StatelessWidget {
  const _ShareGenreDistributionPieChart({required this.data});

  final List<GenreDistributionDatum> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Text(
        'No genre distribution available yet.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.72),
          fontSize: 16,
        ),
      );
    }
    final int total = data.fold<int>(0, (sum, d) => sum + d.count);
    final List<Color> palette = <Color>[
      const Color(0xFF7BDFF6),
      const Color(0xFFFF9E7A),
      const Color(0xFFA78BFA),
      const Color(0xFF4ADE80),
      const Color(0xFFFDE047),
      const Color(0xFFF472B6),
    ];
    return Column(
      children: <Widget>[
        SizedBox(
          height: 165,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 30,
              sectionsSpace: 2,
              sections: List<PieChartSectionData>.generate(data.length, (i) {
                final GenreDistributionDatum d = data[i];
                final double pct = total == 0 ? 0 : (d.count / total) * 100;
                return PieChartSectionData(
                  value: d.count.toDouble(),
                  color: palette[i % palette.length],
                  radius: 48,
                  title: '${pct.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                );
              }),
            ),
            duration: const Duration(milliseconds: 700),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: List<Widget>.generate(data.length, (i) {
            final GenreDistributionDatum d = data[i];
            final Color color = palette[i % palette.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${d.genre} (${d.count})',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _ShareMoviesPerMonthChart extends StatelessWidget {
  const _ShareMoviesPerMonthChart({required this.data});

  final List<MonthlyWatchCount> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No movie watch history for recent months.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 15,
          ),
        ),
      );
    }
    final double maxY =
        data
            .map((d) => d.count.toDouble())
            .fold<double>(0, (a, b) => a > b ? a : b) +
        1;
    return BarChart(
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
              reservedSize: 20,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.56),
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    data[i].label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 10,
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
                width: 10,
                borderRadius: BorderRadius.circular(4),
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
    );
  }
}

class _ShareRatingTrendChart extends StatelessWidget {
  const _ShareRatingTrendChart({required this.data});

  final List<MonthlyRatingTrend> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No rating trend data available yet.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 15,
          ),
        ),
      );
    }
    return LineChart(
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
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, _) => Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.56),
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final int i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    data[i].label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 10,
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
                radius: 2.8,
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
    );
  }
}

class _PosterCollage extends StatelessWidget {
  const _PosterCollage({required this.posterPaths});

  final List<String> posterPaths;

  @override
  Widget build(BuildContext context) {
    final List<String> paths = posterPaths.take(4).toList(growable: false);
    if (paths.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.centerLeft,
        child: Text(
          'Keep watching to build your visual profile.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return SizedBox(
      height: 150,
      child: Row(
        children: List<Widget>.generate(paths.length, (i) {
          final double angle = (-0.07 + (i * 0.05));
          return Expanded(
            child: Transform.rotate(
              angle: angle,
              child: Container(
                margin: EdgeInsets.only(right: i == paths.length - 1 ? 0 : 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    paths[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.white10,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.movie_creation_outlined,
                        color: Colors.white38,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ShareStatCard extends StatelessWidget {
  const _ShareStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareSectionCard extends StatelessWidget {
  const _ShareSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _WatchInsightsShareableCard extends StatelessWidget {
  const _WatchInsightsShareableCard({required this.insights});

  final WatchHistoryInsights insights;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 1080,
        height: 1350,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              const Color(0xFF0D1220),
              AppColors.cinemaSurface,
              const Color(0xFF121B2F),
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(52, 52, 52, 42),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'WATCH INSIGHTS',
              style: TextStyle(
                color: AppColors.cinemaAccent,
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Shared with Lumi',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _WatchHistoryInsightsSection(
                insights: insights,
                shareStyle: true,
              ),
            ),
          ],
        ),
      ),
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

class _WatchHistoryInsightsSection extends StatelessWidget {
  const _WatchHistoryInsightsSection({
    required this.insights,
    this.shareStyle = false,
  });

  final WatchHistoryInsights insights;
  final bool shareStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(shareStyle ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cinemaPanelGradient,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.cinemaBorder.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cinemaGlow.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cinemaAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.cinemaAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.cinemaAccent,
                  size: shareStyle ? 22 : 20,
                ),
              ),
              SizedBox(width: shareStyle ? 14 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Watch Insights',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: shareStyle ? 24 : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Personalized viewing patterns',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: shareStyle ? 15 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: shareStyle ? 18 : 16),
          Text(
            insights.insightsText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: shareStyle ? 1.45 : 1.4,
              fontSize: shareStyle ? 18 : 14,
            ),
          ),
          if (insights.favoriteGenres.isNotEmpty) ...[
            SizedBox(height: shareStyle ? 18 : 16),
            Text(
              'Your Favorite Genres',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
                fontSize: shareStyle ? 20 : null,
              ),
            ),
            SizedBox(height: shareStyle ? 10 : 8),
            Wrap(
              spacing: shareStyle ? 10 : 8,
              runSpacing: shareStyle ? 10 : 8,
              children: insights.favoriteGenres
                  .map(
                    (genre) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: shareStyle ? 13 : 12,
                        vertical: shareStyle ? 7 : 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.cinemaAccent.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.cinemaAccent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        genre,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: shareStyle ? 16 : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (insights.averageRatingPerGenre.isNotEmpty) ...[
            SizedBox(height: shareStyle ? 20 : 18),
            Text(
              'Genre Performance (Highest Rated)',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
                fontSize: shareStyle ? 20 : null,
              ),
            ),
            SizedBox(height: shareStyle ? 10 : 8),
            ...insights.averageRatingPerGenre.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: shareStyle ? 6 : 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.genre,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: shareStyle ? 16 : 13,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: entry.averageRating / 5.0,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(
                              AppColors.cinemaAccent,
                              AppColors.cinemaWarmGlow,
                              entry.averageRating / 5.0,
                            )!,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.averageRating.toStringAsFixed(1)}/5',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: shareStyle ? 16 : 13,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (insights.averageRuntimeMinutes > 0) ...[
            SizedBox(height: shareStyle ? 20 : 18),
            Container(
              padding: EdgeInsets.all(shareStyle ? 14 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: AppColors.cinemaAccent.withValues(alpha: 0.8),
                    size: shareStyle ? 20 : 18,
                  ),
                  SizedBox(width: shareStyle ? 12 : 10),
                  Expanded(
                    child: Text(
                      'Preferred runtime is ~${insights.averageRuntimeMinutes} mins (${insights.preferredRuntimeLabel})',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: shareStyle ? 15 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WatchHistoryInsightsShimmer extends StatelessWidget {
  const _WatchHistoryInsightsShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.detailsCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.cinemaBorder.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerEffect(width: 36, height: 36, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerEffect.textLine(width: 120, height: 16),
                    const SizedBox(height: 6),
                    ShimmerEffect.textLine(width: 180, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
