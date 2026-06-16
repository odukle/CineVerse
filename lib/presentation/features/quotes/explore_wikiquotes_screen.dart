import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/providers/quotes_provider.dart';
import 'package:cineverse/domain/repositories/quotes_repository.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:cineverse/presentation/widgets/app_back_button.dart';
import 'package:cineverse/core/utils/toast_utils.dart';
import 'package:cineverse/domain/entities/movie_details.dart';

class ExploreWikiquotesScreen extends ConsumerWidget {
  const ExploreWikiquotesScreen({
    super.key,
    required this.title,
    this.isTv = false,
    this.isSeason = false,
    this.pageName,
    this.details,
    this.seasonNumber,
  });

  final String title;
  final bool isTv;
  final bool isSeason;
  final String? pageName;
  final MovieDetails? details;
  final int? seasonNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final articleAsync = ref.watch(
      fullWikiquoteProvider((
        title: title,
        isTv: isTv,
        isSeason: isSeason,
        pageName: pageName,
      )),
    );

    return BackgroundGradient(
      child: articleAsync.when(
        data: (article) {
          if (article == null || article.sections.isEmpty) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: AppColors.cinemaGradientTop,
                leading: const AppBackButton(),
                title: Text(title),
              ),
              body: const Center(
                child: Text(
                  'No quotes found.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          }

          final displaySections = article.sections.toList();

          if (displaySections.isEmpty) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: AppColors.cinemaGradientTop,
                leading: const AppBackButton(),
                title: Text(title),
              ),
              body: const Center(
                child: Text(
                  'No sections found.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          }

          return DefaultTabController(
            length: displaySections.length,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      backgroundColor: AppColors.cinemaGradientTop,
                      leading: const AppBackButton(),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      centerTitle: false,
                      bottom: displaySections.length > 1
                          ? PreferredSize(
                              preferredSize: const Size.fromHeight(68),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: LinearGradient(
                                      colors: AppColors.cinemaPanelGradient,
                                    ),
                                    border: Border.all(
                                      color: AppColors.cinemaBorder.withValues(
                                        alpha: 0.28,
                                      ),
                                    ),
                                  ),
                                  child: TabBar(
                                    onTap: (_) =>
                                        HapticFeedback.selectionClick(),
                                    isScrollable: true,
                                    tabAlignment: TabAlignment.start,
                                    dividerColor: Colors.transparent,
                                    indicatorSize: TabBarIndicatorSize.label,
                                    indicator: BoxDecoration(
                                      color: AppColors.cinemaAccent.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.cinemaAccent
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    indicatorPadding:
                                        const EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 0,
                                        ),
                                    splashBorderRadius: BorderRadius.circular(
                                      999,
                                    ),
                                    labelColor: Colors.white,
                                    unselectedLabelColor: Colors.white70,
                                    labelStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    unselectedLabelStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    labelPadding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    tabs: displaySections.map((s) {
                                      final isIntro =
                                          s.title.toLowerCase() ==
                                          'introduction';
                                      final String label = isIntro
                                          ? 'Overview'
                                          : s.title;
                                      return Tab(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            label,
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ];
                },
                body: TabBarView(
                  children: displaySections.map((section) {
                    final isOverview =
                        section.title.toLowerCase() == 'introduction';
                    final content = isOverview
                        ? section.content
                              .where((c) => c is! WikiquoteSeasonLink)
                              .toList()
                        : section.content;

                    if (content.isEmpty && isOverview) {
                      return const SizedBox.shrink();
                    }

                    return ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 32),
                      children: [
                        _buildSectionContent(
                          context,
                          section.copyWith(content: content),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
        loading: () => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: AppColors.cinemaGradientTop,
            leading: const AppBackButton(),
            title: Text(title),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, st) => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: AppColors.cinemaGradientTop,
            leading: const AppBackButton(),
            title: Text(title),
          ),
          body: Center(
            child: Text(
              'Error loading quotes.',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, WikiquoteSection section) {
    // Check if the section only contains seasons
    bool isSeasonsSection =
        section.content.isNotEmpty &&
        section.content.every((c) => c is WikiquoteSeasonLink);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSeasonsSection)
            Container(
              decoration: BoxDecoration(
                color: AppColors.detailsCard.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: section.content.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  return _buildContentItem(context, section.content[index]);
                },
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: section.content
                  .map((c) => _buildContentItem(context, c))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildContentItem(BuildContext context, WikiquoteContent content) {
    final theme = Theme.of(context);

    if (content is WikiquoteText) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              content.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (content.character != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '— ${content.character}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.cinemaAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (details != null && content.text.length < 300)
                  IconButton(
                    onPressed: () {
                      context.push(
                        '/quote_share_editor',
                        extra: {
                          'details': details,
                          'isTv': isTv,
                          'initialQuote': MediaQuote(
                            text: content.text,
                            character: content.character,
                          ),
                          'seasonNumber': seasonNumber,
                        },
                      );
                    },
                    icon: Icon(
                      Icons.share_rounded,
                      color: AppColors.cinemaAccent.withValues(alpha: 0.8),
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Share quote',
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final textToCopy = content.character != null
                        ? '"${content.text}" — ${content.character}'
                        : content.text;
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    ToastUtils.showToast(context, 'Quote copied to clipboard');
                  },
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Copy quote',
                ),
              ],
            ),
          ],
        ),
      );
    } else if (content is WikiquoteDialogue) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...content.lines.map((line) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: SelectableText.rich(
                  TextSpan(
                    children: [
                      if (line.character.isNotEmpty)
                        TextSpan(
                          text: '${line.character}: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.cinemaAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      TextSpan(
                        text: line.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (details != null &&
                      content.lines.map((l) => l.text).join('\n').length < 300)
                    IconButton(
                      onPressed: () {
                        final dialogueText = content.lines
                            .map(
                              (l) => l.character.isNotEmpty
                                  ? '${l.character}: ${l.text}'
                                  : l.text,
                            )
                            .join('\n');
                        context.push(
                          '/quote_share_editor',
                          extra: {
                            'details': details,
                            'isTv': isTv,
                            'initialQuote': MediaQuote(
                              text: dialogueText,
                              character: null,
                            ),
                            'seasonNumber': seasonNumber,
                          },
                        );
                      },
                      icon: Icon(
                        Icons.share_rounded,
                        color: AppColors.cinemaAccent.withValues(alpha: 0.8),
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Share dialogue',
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      final dialogueText = content.lines
                          .map(
                            (l) => l.character.isNotEmpty
                                ? '${l.character}: ${l.text}'
                                : l.text,
                          )
                          .join('\n');
                      Clipboard.setData(ClipboardData(text: dialogueText));
                      ToastUtils.showToast(
                        context,
                        'Dialogue copied to clipboard',
                      );
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: Colors.white54,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy dialogue',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (content is WikiquoteSeasonLink) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Material(
          color: AppColors.detailsCard,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              context.push(
                '/explore_quotes',
                extra: {
                  'title': content.title,
                  'isTv': isTv,
                  'isSeason': true,
                  'pageName': content.pageName,
                  'details': details,
                  'seasonNumber': _parseSeasonNumber(content.title),
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      content.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white54,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  int? _parseSeasonNumber(String title) {
    final regExp = RegExp(r'Season\s+(\d+)', caseSensitive: false);
    final match = regExp.firstMatch(title);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }
}
