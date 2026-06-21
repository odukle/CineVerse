import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:cineverse/presentation/widgets/full_screen_image_viewer.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:cineverse/presentation/providers/quotes_provider.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/presentation/features/person/providers/person_details_provider.dart';
import 'package:cineverse/domain/entities/person_details.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:go_router/go_router.dart';
import 'package:cineverse/app/router/app_router.dart';

class PersonDetailsScreen extends ConsumerStatefulWidget {
  const PersonDetailsScreen({super.key, required this.personId, this.heroTag});

  final int personId;
  final String? heroTag;

  @override
  ConsumerState<PersonDetailsScreen> createState() =>
      _PersonDetailsScreenState();
}

class _PersonDetailsScreenState extends ConsumerState<PersonDetailsScreen> {
  String _activeFilter = 'all';
  String _activeSort = 'popularity';

  String _calculateAge(String birthday, String? deathday) {
    try {
      final birthDate = DateTime.parse(birthday.trim());
      if (deathday == null || deathday.trim().isEmpty) {
        final now = DateTime.now();
        int age = now.year - birthDate.year;
        if (now.month < birthDate.month ||
            (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
        return ' (age $age)';
      }
    } catch (_) {}
    return '';
  }

  String _calculateLifespan(String birthday, String deathday) {
    try {
      final birthDate = DateTime.parse(birthday.trim());
      final deathDate = DateTime.parse(deathday.trim());
      int age = deathDate.year - birthDate.year;
      if (deathDate.month < birthDate.month ||
          (deathDate.month == birthDate.month &&
              deathDate.day < birthDate.day)) {
        age--;
      }
      return ' (aged $age)';
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personDetails = ref.watch(personDetailsProvider(widget.personId));

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: personDetails.when(
          data: (details) {
            final departments = details.creditsByDepartment.keys.toList()
              ..sort();
            final knownDept = details.knownForDepartment;
            final initialIndex = departments.contains(knownDept)
                ? departments.indexOf(knownDept!)
                : 0;

            return DefaultTabController(
              length: departments.length,
              initialIndex: initialIndex,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                      sliver: SliverAppBar(
                        pinned: true,
                        backgroundColor: AppColors.cinemaGradientTop,
                        elevation: 0,
                        leading: IconButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              details.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (details.alsoKnownAs != null &&
                                details.alsoKnownAs!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                details.alsoKnownAs!.first,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Profile Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          16 + MediaQuery.paddingOf(context).top + kToolbarHeight,
                          16,
                          16,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: widget.heroTag ?? 'person-${details.id}',
                                  child: Container(
                                    width: 120,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: details.profilePath != null
                                          ? CachedNetworkImage(
                                              imageUrl: details.profilePath!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const ShimmerEffect(
                                                    width: 120,
                                                    height: 180,
                                                    borderRadius: 16,
                                                  ),
                                            )
                                          : Container(
                                              color: Colors.white10,
                                              child: const Icon(
                                                Icons.person,
                                                size: 64,
                                                color: Colors.white24,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (details.birthday != null)
                                        _InfoItem(
                                          label: context.l10n.born,
                                          value:
                                              '${details.birthday!}${details.deathday == null ? _calculateAge(details.birthday!, null) : ""}',
                                        ),
                                      if (details.placeOfBirth != null)
                                        _InfoItem(
                                          label: context.l10n.birthplace,
                                          value: details.placeOfBirth!,
                                        ),
                                      if (details.deathday != null)
                                        _InfoItem(
                                          label: context.l10n.died,
                                          value:
                                              '${details.deathday!}${_calculateLifespan(details.birthday ?? "", details.deathday!)}',
                                        ),
                                      if (details.knownForDepartment != null)
                                        _InfoItem(
                                          label: context.l10n.knownFor,
                                          value: details.knownForDepartment!,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (details.hasSocialHandles) ...[
                              const SizedBox(height: 14),
                              _PersonSocialLinks(details: details),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Biography
                    if (details.biography != null &&
                        details.biography!.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _ExpandableBiographyCard(
                          biography: details.biography!,
                        ),
                      ),
                    if ((details.alsoKnownAs ?? const <String>[]).isNotEmpty)
                      SliverToBoxAdapter(
                        child: _AlsoKnownAsSection(
                          aliases: details.alsoKnownAs ?? const <String>[],
                        ),
                      ),

                    SliverToBoxAdapter(
                      child: _PersonStatsDashboard(personId: details.id),
                    ),

                    SliverToBoxAdapter(
                      child: _FrequentCollaboratorsSection(
                        personId: details.id,
                        personName: details.name,
                        personProfilePath: details.profilePath,
                      ),
                    ),

                    // Known For Carousel
                    SliverToBoxAdapter(
                      child: _KnownForCarousel(
                        creditsByDepartment: details.creditsByDepartment,
                        knownForDepartment: details.knownForDepartment,
                      ),
                    ),

                    // Images Section
                    SliverToBoxAdapter(
                      child: _PersonImagesCarousel(personId: details.id),
                    ),

                    // Quotes Section
                    SliverToBoxAdapter(
                      child: _PersonQuotes(name: details.name),
                    ),

                    if (departments.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          minHeight: 180,
                          maxHeight: 180,
                          child: Container(
                            color: AppColors.cinemaGradientTop,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    16,
                                    8,
                                  ),
                                  child: Text(
                                    context.l10n.credits,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
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
                                        color: AppColors.cinemaBorder
                                            .withValues(alpha: 0.28),
                                      ),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: AppColors.cinemaGlow
                                              .withValues(alpha: 0.12),
                                          blurRadius: 22,
                                          spreadRadius: -12,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    child: TabBar(
                                      onTap: (_) =>
                                          HapticFeedback.selectionClick(),
                                      isScrollable: true,
                                      tabAlignment: TabAlignment.start,
                                      dividerColor: Colors.transparent,
                                      indicatorSize: TabBarIndicatorSize.label,
                                      indicator: BoxDecoration(
                                        color: AppColors.cinemaAccent
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
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
                                      unselectedLabelColor: Colors.white
                                          .withValues(alpha: 0.7),
                                      labelStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      unselectedLabelStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      tabs: departments
                                          .map(
                                            (d) => Tab(
                                              child: SizedBox(
                                                height: 28,
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                        ),
                                                    child: Text(
                                                      departments.length > 5
                                                          ? d
                                                          : d.toUpperCase(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          _FilterChip(
                                            label: context.l10n.all,
                                            isActive: _activeFilter == 'all',
                                            onTap: () => setState(() {
                                              HapticFeedback.selectionClick();
                                              _activeFilter = 'all';
                                            }),
                                          ),
                                          const SizedBox(width: 8),
                                          _FilterChip(
                                            label: context.l10n.toggleMovies,
                                            isActive: _activeFilter == 'movie',
                                            onTap: () => setState(() {
                                              HapticFeedback.selectionClick();
                                              _activeFilter = 'movie';
                                            }),
                                          ),
                                          const SizedBox(width: 8),
                                          _FilterChip(
                                            label: context.l10n.toggleTv,
                                            isActive: _activeFilter == 'tv',
                                            onTap: () => setState(() {
                                              HapticFeedback.selectionClick();
                                              _activeFilter = 'tv';
                                            }),
                                          ),
                                        ],
                                      ),
                                      _SortSelector(
                                        activeSort: _activeSort,
                                        showRevenue: _activeFilter == 'movie',
                                        onSortChanged: (sort) =>
                                            setState(() => _activeSort = sort),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ];
                },
                body: Builder(
                  builder: (context) {
                    return TabBarView(
                      children: departments.map((dept) {
                        final rawCredits =
                            details.creditsByDepartment[dept] ?? [];

                        // 1. Filter
                        List<PersonCredit> credits = rawCredits;
                        if (_activeFilter == 'movie') {
                          credits = rawCredits
                              .where(
                                (c) =>
                                    c.media.mediaType == GlobalMediaType.movie,
                              )
                              .toList();
                        } else if (_activeFilter == 'tv') {
                          credits = rawCredits
                              .where(
                                (c) => c.media.mediaType == GlobalMediaType.tv,
                              )
                              .toList();
                        }

                        // 2. Sort
                        credits = List.from(credits); // mutable copy
                        if (_activeSort == 'popularity') {
                          credits.sort(
                            (a, b) => b.media.popularity.compareTo(
                              a.media.popularity,
                            ),
                          );
                        } else if (_activeSort == 'releaseDate') {
                          credits.sort((a, b) {
                            final dateA = a.media.releaseDate ?? '';
                            final dateB = b.media.releaseDate ?? '';
                            if (dateA.isEmpty && dateB.isEmpty) return 0;
                            if (dateA.isEmpty) return 1;
                            if (dateB.isEmpty) return -1;
                            return dateB.compareTo(dateA); // newest first
                          });
                        } else if (_activeSort == 'voteAverage') {
                          credits.sort((a, b) {
                            final scoreA = a.media.voteAverage ?? 0.0;
                            final scoreB = b.media.voteAverage ?? 0.0;
                            return scoreB.compareTo(
                              scoreA,
                            ); // highest rated first
                          });
                        } else if (_activeSort == 'revenue') {
                          credits.sort((a, b) {
                            final revenueA = a.media.revenue ?? 0;
                            final revenueB = b.media.revenue ?? 0;
                            return revenueB.compareTo(revenueA);
                          });
                        }

                        if (credits.isEmpty) {
                          return CustomScrollView(
                            key: PageStorageKey<String>('$dept-empty'),
                            slivers: [
                              SliverOverlapInjector(
                                handle:
                                    NestedScrollView.sliverOverlapAbsorberHandleFor(
                                      context,
                                    ),
                              ),
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.movie_filter_rounded,
                                        color: Colors.white24,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        context.l10n.noProductionsFound,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return CustomScrollView(
                          key: PageStorageKey<String>(
                            '$dept-$_activeFilter-$_activeSort',
                          ),
                          slivers: [
                            SliverOverlapInjector(
                              handle:
                                  NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context,
                                  ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.55,
                                    ),
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final credit = credits[index];
                                  final double cardWidth =
                                      (MediaQuery.sizeOf(context).width -
                                          (16 * 2) -
                                          (12 * 2)) /
                                      3;
                                  final int? hydratedRevenue =
                                      _activeSort == 'revenue' &&
                                          credit.media.mediaType ==
                                              GlobalMediaType.movie
                                      ? ref
                                            .watch(
                                              mediaRevenueProvider(
                                                credit.media.id,
                                              ),
                                            )
                                            .value
                                      : null;
                                  final String? subtitleOverride =
                                      _buildCreditSubtitleForSort(
                                        context,
                                        credit,
                                        _activeSort,
                                        hydratedRevenue: hydratedRevenue,
                                      );

                                  return MediaPosterGridCard(
                                    movie: credit.media,
                                    sectionTitle: 'credits-$dept',
                                    width: cardWidth,
                                    subtitleOverride: subtitleOverride,
                                    disableSortBasedSubtitle: true,
                                    subtitleMaxLines: 2,
                                  );
                                }, childCount: credits.length),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 40),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            );
          },
          loading: () => const _PersonDetailsShimmer(),
          error: (err, _) =>
              Center(child: Text(context.l10n.errorGeneric(err.toString()))),
        ),
      ),
    );
  }
}

String? _buildCreditSubtitle(BuildContext context, PersonCredit credit) {
  final List<String> segments = <String>[];
  final String role = (credit.role ?? '').trim();
  final String department = (credit.department ?? '').trim();

  if (role.isNotEmpty) {
    segments.add(role);
  } else if (department.isNotEmpty) {
    segments.add(department);
  }

  final bool isTv = credit.media.mediaType == GlobalMediaType.tv;
  if (isTv && (credit.episodeCount ?? 0) > 0) {
    final count = credit.episodeCount!;
    segments.add(context.l10n.episodeCount(count));
  }

  if (credit.isCastCredit && credit.billingOrder != null) {
    segments.add(context.l10n.billingOrder('${credit.billingOrder! + 1}'));
  }

  final String subtitle = segments.join(' • ').trim();
  return subtitle.isEmpty ? null : subtitle;
}

String? _buildCreditSubtitleForSort(
  BuildContext context,
  PersonCredit credit,
  String activeSort, {
  int? hydratedRevenue,
}) {
  switch (activeSort) {
    case 'releaseDate':
      return credit.media.releaseDate;
    case 'voteAverage':
      final double? rating = credit.media.voteAverage;
      if (rating == null || rating <= 0) {
        return credit.media.voteCount > 0
            ? '${credit.media.voteCount} votes'
            : null;
      }
      final String ratingText = rating.toStringAsFixed(1);
      if (credit.media.voteCount > 0) {
        return '$ratingText/10 • ${credit.media.voteCount} votes';
      }
      return '$ratingText/10';
    case 'revenue':
      final int revenue = hydratedRevenue ?? credit.media.revenue ?? 0;
      if (revenue <= 0) {
        return null;
      }
      return NumberFormat.compactCurrency(
        symbol: '\$',
        decimalDigits: 1,
      ).format(revenue);
    case 'popularity':
    default:
      return _buildCreditSubtitle(context, credit);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonSocialLinks extends StatelessWidget {
  const _PersonSocialLinks({required this.details});

  final PersonDetails details;

  @override
  Widget build(BuildContext context) {
    final List<_PersonSocialLinkItem> links =
        <_PersonSocialLinkItem>[
              _PersonSocialLinkItem(
                label: context.l10n.instagram,
                icon: const FaIcon(FontAwesomeIcons.instagram),
                url: _personSocialProfileUrl('instagram', details.instagramId),
              ),
              _PersonSocialLinkItem(
                label: context.l10n.twitterX,
                icon: const FaIcon(FontAwesomeIcons.xTwitter),
                url: _personSocialProfileUrl('x', details.twitterId),
              ),
              _PersonSocialLinkItem(
                label: context.l10n.facebook,
                icon: const FaIcon(FontAwesomeIcons.facebook),
                url: _personSocialProfileUrl('facebook', details.facebookId),
              ),
              _PersonSocialLinkItem(
                label: context.l10n.tikTok,
                icon: const FaIcon(FontAwesomeIcons.tiktok),
                url: _personSocialProfileUrl('tiktok', details.tiktokId),
              ),
              _PersonSocialLinkItem(
                label: context.l10n.youtube,
                icon: const FaIcon(FontAwesomeIcons.youtube),
                url: _personSocialProfileUrl('youtube', details.youtubeId),
              ),
              _PersonSocialLinkItem(
                label: context.l10n.website,
                icon: const Icon(Icons.language_rounded),
                url: details.homepage?.trim(),
              ),
            ]
            .where((item) => item.url != null && item.url!.isNotEmpty)
            .toList(growable: false);

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: links
            .map(
              (link) => _PersonSocialChip(
                label: link.label,
                icon: link.icon,
                url: link.url!,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _PersonSocialLinkItem {
  const _PersonSocialLinkItem({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final Widget icon;
  final String? url;
}

class _PersonSocialChip extends StatelessWidget {
  const _PersonSocialChip({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final Widget icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.detailsCard.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final Uri uri = Uri.parse(url);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {}
        },
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme(
                data: IconThemeData(
                  size: 15.5,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
                child: icon,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _personSocialProfileUrl(String platform, String? rawId) {
  final String id = (rawId ?? '').trim();
  if (id.isEmpty) return null;
  switch (platform) {
    case 'instagram':
      return 'https://www.instagram.com/$id';
    case 'x':
      return 'https://x.com/$id';
    case 'facebook':
      return 'https://www.facebook.com/$id';
    case 'tiktok':
      final String handle = id.startsWith('@') ? id : '@$id';
      return 'https://www.tiktok.com/$handle';
    case 'youtube':
      if (id.startsWith('UC')) {
        return 'https://www.youtube.com/channel/$id';
      }
      final String handle = id.startsWith('@') ? id : '@$id';
      return 'https://www.youtube.com/$handle';
    case 'imdb':
      return id.startsWith('nm') ? 'https://www.imdb.com/name/$id/' : null;
    default:
      return null;
  }
}

class _AlsoKnownAsSection extends StatelessWidget {
  const _AlsoKnownAsSection({required this.aliases});

  final List<String> aliases;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.alsoKnownAs,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: aliases
                  .take(8)
                  .map(
                    (alias) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withValues(alpha: 0.07),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.11),
                        ),
                      ),
                      child: Text(
                        alias,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonImagesCarousel extends ConsumerWidget {
  const _PersonImagesCarousel({required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(personImagesProvider(personId));

    return imagesAsync.when(
      data: (images) {
        final List<String> profiles = images.profiles.isNotEmpty
            ? images.profiles
            : images.posters;
        final List<String> tagged = images.taggedImagesOrEmpty;
        if (profiles.isEmpty && tagged.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profiles.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  context.l10n.photos,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: profiles.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final imageUrl = profiles[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageViewer(
                              images: profiles,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (tagged.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  context.l10n.taggedImages,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tagged.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final imageUrl = tagged[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageViewer(
                              images: tagged,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _PersonQuotes extends ConsumerWidget {
  const _PersonQuotes({required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(personQuotesProvider(name));
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
                  Text(
                    context.l10n.notableQuotes,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.mayIncludeMismatches,
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
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontStyle: FontStyle.italic,
                              height: 1.4,
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

class _PersonDetailsShimmer extends StatelessWidget {
  const _PersonDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Row(
            children: [
              const ShimmerEffect(width: 120, height: 180, borderRadius: 16),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ShimmerEffect.textLine(width: double.infinity),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ShimmerEffect.textLine(width: 150, height: 24),
          const SizedBox(height: 12),
          ShimmerEffect.textLine(width: double.infinity, height: 100),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppColors.cinemaAccent,
                    AppColors.cinemaAccent.withValues(alpha: 0.7),
                  ],
                )
              : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: isActive
                ? AppColors.cinemaAccent.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SortSelector extends StatelessWidget {
  const _SortSelector({
    required this.activeSort,
    required this.onSortChanged,
    required this.showRevenue,
  });

  final String activeSort;
  final ValueChanged<String> onSortChanged;
  final bool showRevenue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String getSortLabel(String value) {
      switch (value) {
        case 'popularity':
          return context.l10n.popularity;
        case 'releaseDate':
          return context.l10n.releaseDate;
        case 'voteAverage':
          return context.l10n.rating;
        case 'revenue':
          return context.l10n.revenue;
        default:
          return context.l10n.popularity;
      }
    }

    return Theme(
      data: theme.copyWith(cardColor: AppColors.cinemaPanelMid),
      child: PopupMenuButton<String>(
        initialValue: activeSort,
        onSelected: onSortChanged,
        offset: const Offset(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.cinemaBorder.withValues(alpha: 0.2),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sort_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                getSortLabel(activeSort),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'popularity',
            child: Text(
              context.l10n.popularity,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          PopupMenuItem(
            value: 'releaseDate',
            child: Text(
              context.l10n.releaseDate,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          PopupMenuItem(
            value: 'voteAverage',
            child: Text(
              context.l10n.rating,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          if (showRevenue)
            PopupMenuItem(
              value: 'revenue',
              child: Text(
                context.l10n.revenue,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpandableBiographyCard extends StatefulWidget {
  const _ExpandableBiographyCard({required this.biography});

  final String biography;

  @override
  State<_ExpandableBiographyCard> createState() =>
      _ExpandableBiographyCardState();
}

class _ExpandableBiographyCardState extends State<_ExpandableBiographyCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = widget.biography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
            border: Border.all(
              color: AppColors.cinemaBorder.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.biography,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.cinemaAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Text(
                    text,
                    maxLines: _isExpanded ? null : 5,
                    overflow: _isExpanded
                        ? TextOverflow.clip
                        : TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                      fontSize: 14,
                    ),
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

class _KnownForCarousel extends StatelessWidget {
  const _KnownForCarousel({
    required this.creditsByDepartment,
    this.knownForDepartment,
  });

  final Map<String, List<PersonCredit>> creditsByDepartment;
  final String? knownForDepartment;

  @override
  Widget build(BuildContext context) {
    final String? preferredDepartment = _resolvePreferredDepartment();
    final bool actingPrimary =
        preferredDepartment?.trim().toLowerCase() == 'acting';
    final List<PersonCredit> sourceCredits =
        preferredDepartment != null &&
            creditsByDepartment[preferredDepartment]?.isNotEmpty == true
        ? creditsByDepartment[preferredDepartment]!
        : creditsByDepartment.values.expand((list) => list).toList();

    final List<PersonCredit> topCredits = actingPrimary
        ? _buildActingKnownForCredits(sourceCredits, preferredDepartment)
        : _rankKnownForCredits(
            sourceCredits,
            preferredDepartment,
          ).take(12).toList();

    if (topCredits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            context.l10n.knownFor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topCredits.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final credit = topCredits[index];
              return MediaPosterGridCard(
                movie: credit.media,
                sectionTitle: 'known-for',
                width: 110,
                isTvTitle: credit.media.mediaType == GlobalMediaType.tv,
              );
            },
          ),
        ),
      ],
    );
  }

  List<PersonCredit> _buildActingKnownForCredits(
    List<PersonCredit> sourceCredits,
    String? preferredDepartment,
  ) {
    final List<PersonCredit> movieCredits = sourceCredits
        .where((credit) => credit.media.mediaType == GlobalMediaType.movie)
        .toList();
    final List<PersonCredit> tvCredits = sourceCredits
        .where((credit) => credit.media.mediaType == GlobalMediaType.tv)
        .toList();

    final List<PersonCredit> rankedMovies = _rankKnownForCredits(
      movieCredits,
      preferredDepartment,
    );
    if (rankedMovies.length >= 8) {
      return rankedMovies.take(12).toList();
    }

    final List<PersonCredit> rankedTv = _rankKnownForCredits(
      tvCredits,
      preferredDepartment,
    );
    return <PersonCredit>[...rankedMovies, ...rankedTv].take(12).toList();
  }

  String? _resolvePreferredDepartment() {
    final String normalized = (knownForDepartment ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    for (final String department in creditsByDepartment.keys) {
      if (department.trim().toLowerCase() == normalized) {
        return department;
      }
    }
    return null;
  }

  List<PersonCredit> _rankKnownForCredits(
    List<PersonCredit> credits,
    String? preferredDepartment,
  ) {
    final Map<int, PersonCredit> bestCreditById = <int, PersonCredit>{};
    for (final credit in credits) {
      final PersonCredit? existing = bestCreditById[credit.media.id];
      if (existing == null ||
          _knownForScore(credit, preferredDepartment) >
              _knownForScore(existing, preferredDepartment)) {
        bestCreditById[credit.media.id] = credit;
      }
    }

    final List<PersonCredit> uniqueCredits = bestCreditById.values.toList()
      ..sort(
        (a, b) => _knownForScore(
          b,
          preferredDepartment,
        ).compareTo(_knownForScore(a, preferredDepartment)),
      );
    return uniqueCredits;
  }

  double _knownForScore(PersonCredit credit, String? preferredDepartment) {
    final double popularity = credit.media.popularity;
    final double voteAverage = credit.media.voteAverage ?? 0;
    final int voteCount = credit.media.voteCount;
    final double ratingScore = voteAverage * 8;
    final double voteConfidence = math.log(voteCount + 1) * 2.2;
    final double castBonus = credit.isCastCredit ? 18 : 0;
    final double billingBonus = credit.billingOrder != null
        ? math.max(0, 12 - credit.billingOrder!.toDouble())
        : 0;
    final bool actingPrimary =
        preferredDepartment?.trim().toLowerCase() == 'acting';
    final double movieBias =
        actingPrimary && credit.media.mediaType == GlobalMediaType.movie
        ? 6
        : 0;
    final double tvBias = 0;

    return popularity +
        ratingScore +
        voteConfidence +
        castBonus +
        billingBonus +
        movieBias +
        tvBias;
  }
}

class _PersonStatsDashboard extends ConsumerWidget {
  const _PersonStatsDashboard({required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(personAnalyticsProvider(personId));
    final theme = Theme.of(context);

    return analyticsAsync.when(
      data: (data) {
        final Map<String, int> creditCounts = {
          'Acting': data.actingCount,
          'Directing': data.directingCount,
          'Writing': data.writingCount,
        };
        if (data.otherCount > 0) {
          creditCounts['Other'] = data.otherCount;
        }

        final maxCreditsEntry = creditCounts.entries
            .fold<MapEntry<String, int>?>(
              null,
              (max, entry) =>
                  max == null || entry.value > max.value ? entry : max,
            );

        final highestGrossMovieTitle =
            data.highestGrossingMovie?.title ??
            data.fallbackHighestGrossing?.title ??
            'N/A';
        final highestGrossMovieRevenue =
            data.highestGrossingMovie?.revenue ?? 0;
        final revenueStr = highestGrossMovieRevenue > 0
            ? '\$${(highestGrossMovieRevenue / 1000000).toStringAsFixed(1)}M'
            : 'N/A';

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.detailsCard.withValues(alpha: 0.6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.careerStatistics,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.movie_outlined,
                        title: context.l10n.primaryRole,
                        value: maxCreditsEntry?.key ?? 'N/A',
                        subtitle: context.l10n.creditsCount(
                          '${maxCreditsEntry?.value ?? 0}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star_border_rounded,
                        title: context.l10n.averageRating,
                        value: data.averageRating > 0
                            ? '${data.averageRating.toStringAsFixed(1)}/10'
                            : 'N/A',
                        subtitle: context.l10n.acrossFilmography,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.category_outlined,
                        title: context.l10n.topGenre,
                        value: data.mostFrequentGenre,
                        subtitle: data.mostFrequentGenrePercent > 0
                            ? context.l10n.percentOfTitles(
                                data.mostFrequentGenrePercent.toString(),
                              )
                            : 'N/A',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up_rounded,
                        title: context.l10n.peakBoxOffice,
                        value: revenueStr,
                        subtitle: highestGrossMovieTitle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => _AnalyticsProgressCard(
        title: context.l10n.careerStatistics,
        progress: ref.watch(personAnalyticsProgressProvider(personId)),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      ),
      error: (error, stackTrace) => _AnalyticsInfoCard(
        title: context.l10n.careerStatistics,
        message: context.l10n.errorGeneric(error.toString()),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      ),
    );
  }
}

class _AnalyticsProgressCard extends StatelessWidget {
  const _AnalyticsProgressCard({
    required this.title,
    required this.progress,
    required this.padding,
  });

  final String title;
  final PersonAnalyticsProgress progress;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double value = progress.value.clamp(0, 1);
    final int percent = (value * 100).round();

    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.detailsCard.withValues(alpha: 0.6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: value <= 0 ? null : value,
              minHeight: 7,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cinemaAccent),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.74),
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$percent%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.cinemaAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsInfoCard extends StatelessWidget {
  const _AnalyticsInfoCard({
    required this.title,
    required this.message,
    required this.padding,
  });

  final String title;
  final String message;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.detailsCard.withValues(alpha: 0.6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.68),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.cinemaAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white38,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
class _FrequentCollaboratorsSection extends ConsumerWidget {
  const _FrequentCollaboratorsSection({
    required this.personId,
    required this.personName,
    required this.personProfilePath,
  });

  final int personId;
  final String personName;
  final String? personProfilePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collaboratorsAsync = ref.watch(personCollaboratorsProvider(personId));
    final theme = Theme.of(context);

    return collaboratorsAsync.when(
      data: (collaborators) {
        if (collaborators.isEmpty) {
          return _AnalyticsInfoCard(
            title: context.l10n.frequentlyCollaboratesWith,
            message: 'No frequent movie collaborations found.',
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.frequentlyCollaboratesWith,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: collaborators.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final collaborator = collaborators[index];
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => _CollaboratorTitlesScreen(
                              collaborator: collaborator,
                              personName: personName,
                              personId: personId,
                              personProfilePath: personProfilePath,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.detailsCard.withValues(alpha: 0.4),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: collaborator.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: collaborator.imageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const ShimmerEffect(
                                            width: 50,
                                            height: 50,
                                            borderRadius: 999,
                                          ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.white10,
                                      child: const Icon(
                                        Icons.person,
                                        size: 24,
                                        color: Colors.white24,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              collaborator.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${collaborator.count} ${collaborator.count == 1 ? "time" : "times"}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.cinemaAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _AnalyticsProgressCard(
        title: context.l10n.frequentlyCollaboratesWith,
        progress: ref.watch(personAnalyticsProgressProvider(personId)),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      ),
      error: (error, stackTrace) => _AnalyticsInfoCard(
        title: context.l10n.frequentlyCollaboratesWith,
        message: context.l10n.errorGeneric(error.toString()),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      ),
    );
  }
}

class _CollaboratorTitlesScreen extends StatelessWidget {
  const _CollaboratorTitlesScreen({
    required this.collaborator,
    required this.personName,
    required this.personId,
    required this.personProfilePath,
  });

  final Collaborator collaborator;
  final String personName;
  final int personId;
  final String? personProfilePath;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<SharedCollaborationTitle> sharedTitles =
        collaborator.sharedTitles;

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.cinemaGradientTop,
          elevation: 0,
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                collaborator.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                context.l10n.sharedTitleCount(sharedTitles.length.toString()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.74),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MediaPosterGridCard(
                    movie: MediaTitle(
                      id: personId,
                      title: personName,
                      posterPath: personProfilePath,
                      mediaType: GlobalMediaType.person,
                      subtitle: '',
                    ),
                    sectionTitle: 'collaborator_titles',
                    width: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'And',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.cinemaAccent,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  MediaPosterGridCard(
                    movie: MediaTitle(
                      id: collaborator.id,
                      title: collaborator.name,
                      posterPath: collaborator.imageUrl,
                      mediaType: GlobalMediaType.person,
                      subtitle: '',
                    ),
                    sectionTitle: 'collaborator_titles',
                    width: 100,
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.white10,
            ),
            Expanded(
              child: sharedTitles.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.noSharedTitlesAvailable,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: sharedTitles.length,
                      itemBuilder: (context, index) {
                        final SharedCollaborationTitle sharedTitle =
                            sharedTitles[index];
                        return _CollaborationTitleListCard(
                          sharedTitle: sharedTitle,
                          personName: personName,
                          collaboratorName: collaborator.name,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollaborationTitleListCard extends StatelessWidget {
  const _CollaborationTitleListCard({
    required this.sharedTitle,
    required this.personName,
    required this.collaboratorName,
  });

  final SharedCollaborationTitle sharedTitle;
  final String personName;
  final String collaboratorName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = sharedTitle.media;
    final year = media.releaseDate != null && media.releaseDate!.length >= 4
        ? ' (${media.releaseDate!.substring(0, 4)})'
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.detailsCard.withValues(alpha: 0.8),
            AppColors.detailsCard.withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.pushNamed(
                AppRoute.movieDetails.name,
                pathParameters: <String, String>{
                  'movieId': media.id.toString(),
                },
                queryParameters: <String, String>{
                  'isTv': 'false',
                  'heroTag': 'collaboration-list-${media.id}',
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  Hero(
                    tag: 'collaboration-list-${media.id}',
                    child: Container(
                      width: 70,
                      height: 105,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: media.posterPath != null
                            ? CachedNetworkImage(
                                imageUrl: media.posterPath!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const ColoredBox(
                                  color: Colors.white10,
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.white30),
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const ColoredBox(
                                  color: Colors.white10,
                                  child: Icon(Icons.broken_image, color: Colors.white24),
                                ),
                              )
                            : const ColoredBox(
                                color: Colors.white10,
                                child: Icon(Icons.movie_outlined, color: Colors.white24),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          '${media.title}$year',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Rating & Votes
                        Row(
                          children: [
                            if (media.voteAverage != null && media.voteAverage! > 0) ...[
                              Icon(Icons.star_rounded, color: AppColors.cinemaAccent, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                media.voteAverage!.toStringAsFixed(1),
                                style: TextStyle(
                                  color: AppColors.cinemaAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (media.popularity > 0)
                              Text(
                                'Pop: ${media.popularity.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Collaborative Roles comparison
                        Row(
                          children: [
                            // Person 1 (Main Person)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.06),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      personName,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      sharedTitle.personRole,
                                      style: TextStyle(
                                        color: AppColors.cinemaAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Link Indicator
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                color: Colors.white.withValues(alpha: 0.24),
                                size: 18,
                              ),
                            ),
                            // Person 2 (Collaborator)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.06),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      collaboratorName,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      sharedTitle.collaboratorRole,
                                      style: TextStyle(
                                        color: AppColors.cinemaAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
