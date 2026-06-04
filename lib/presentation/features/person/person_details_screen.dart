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
import 'package:url_launcher/url_launcher.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:cineverse/presentation/providers/quotes_provider.dart';
import 'package:cineverse/presentation/features/person/providers/person_details_provider.dart';
import 'package:cineverse/domain/entities/person_details.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:go_router/go_router.dart';

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
                      sliver: MultiSliver(
                        children: [
                          SliverAppBar(
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
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
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

                          // Profile Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Hero(
                                        tag:
                                            widget.heroTag ??
                                            'person-${details.id}',
                                        child: Container(
                                          width: 120,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: details.profilePath != null
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        details.profilePath!,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
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
                                                label: 'Born',
                                                value:
                                                    '${details.birthday!}${details.deathday == null ? _calculateAge(details.birthday!, null) : ""}',
                                              ),
                                            if (details.placeOfBirth != null)
                                              _InfoItem(
                                                label: 'Birthplace',
                                                value: details.placeOfBirth!,
                                              ),
                                            if (details.deathday != null)
                                              _InfoItem(
                                                label: 'Died',
                                                value:
                                                    '${details.deathday!}${_calculateLifespan(details.birthday ?? "", details.deathday!)}',
                                              ),
                                            if (details.knownForDepartment !=
                                                null)
                                              _InfoItem(
                                                label: 'Known For',
                                                value:
                                                    details.knownForDepartment!,
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
                          if ((details.alsoKnownAs ?? const <String>[])
                              .isNotEmpty)
                            SliverToBoxAdapter(
                              child: _AlsoKnownAsSection(
                                aliases:
                                    details.alsoKnownAs ?? const <String>[],
                              ),
                            ),

                          SliverToBoxAdapter(
                            child: _PersonStatsDashboard(personId: details.id),
                          ),

                          SliverToBoxAdapter(
                            child: _FrequentCollaboratorsSection(
                              personId: details.id,
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
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _SliverAppBarDelegate(
                                minHeight: 180,
                                maxHeight: 180,
                                child: Container(
                                  color: AppColors.cinemaGradientTop,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          12,
                                          16,
                                          8,
                                        ),
                                        child: Text(
                                          'Credits',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
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
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            gradient: LinearGradient(
                                              colors:
                                                  AppColors.cinemaPanelGradient,
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
                                            indicatorSize:
                                                TabBarIndicatorSize.label,
                                            indicator: BoxDecoration(
                                              color: AppColors.cinemaAccent
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(999),
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
                                            splashBorderRadius:
                                                BorderRadius.circular(999),
                                            labelColor: Colors.white,
                                            unselectedLabelColor: Colors.white
                                                .withValues(alpha: 0.7),
                                            labelStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            unselectedLabelStyle:
                                                const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            labelPadding:
                                                const EdgeInsets.symmetric(
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
                                                            departments.length >
                                                                    5
                                                                ? d
                                                                : d.toUpperCase(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
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
                                                  label: 'All',
                                                  isActive:
                                                      _activeFilter == 'all',
                                                  onTap: () => setState(() {
                                                    HapticFeedback.selectionClick();
                                                    _activeFilter = 'all';
                                                  }),
                                                ),
                                                const SizedBox(width: 8),
                                                _FilterChip(
                                                  label: 'Movies',
                                                  isActive:
                                                      _activeFilter == 'movie',
                                                  onTap: () => setState(() {
                                                    HapticFeedback.selectionClick();
                                                    _activeFilter = 'movie';
                                                  }),
                                                ),
                                                const SizedBox(width: 8),
                                                _FilterChip(
                                                  label: 'TV',
                                                  isActive:
                                                      _activeFilter == 'tv',
                                                  onTap: () => setState(() {
                                                    HapticFeedback.selectionClick();
                                                    _activeFilter = 'tv';
                                                  }),
                                                ),
                                              ],
                                            ),
                                            _SortSelector(
                                              activeSort: _activeSort,
                                              onSortChanged: (sort) => setState(
                                                () => _activeSort = sort,
                                              ),
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
                        ],
                      ),
                    ),
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
                                      const Text(
                                        'No credits found for this filter.',
                                        style: TextStyle(
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
                                  final bool sortByReleaseDate =
                                      _activeSort == 'releaseDate';
                                  final String? subtitleOverride =
                                      sortByReleaseDate
                                      ? credit.media.releaseDate
                                      : _buildCreditSubtitle(credit);

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
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

String? _buildCreditSubtitle(PersonCredit credit) {
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
    segments.add('$count ${count == 1 ? 'episode' : 'episodes'}');
  }

  if (credit.isCastCredit && credit.billingOrder != null) {
    segments.add('Billed #${credit.billingOrder! + 1}');
  }

  final String subtitle = segments.join(' • ').trim();
  return subtitle.isEmpty ? null : subtitle;
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
                label: 'Instagram',
                icon: const FaIcon(FontAwesomeIcons.instagram),
                url: _personSocialProfileUrl('instagram', details.instagramId),
              ),
              _PersonSocialLinkItem(
                label: 'X',
                icon: const FaIcon(FontAwesomeIcons.xTwitter),
                url: _personSocialProfileUrl('x', details.twitterId),
              ),
              _PersonSocialLinkItem(
                label: 'Facebook',
                icon: const FaIcon(FontAwesomeIcons.facebook),
                url: _personSocialProfileUrl('facebook', details.facebookId),
              ),
              _PersonSocialLinkItem(
                label: 'TikTok',
                icon: const FaIcon(FontAwesomeIcons.tiktok),
                url: _personSocialProfileUrl('tiktok', details.tiktokId),
              ),
              _PersonSocialLinkItem(
                label: 'YouTube',
                icon: const FaIcon(FontAwesomeIcons.youtube),
                url: _personSocialProfileUrl('youtube', details.youtubeId),
              ),
              _PersonSocialLinkItem(
                label: 'Website',
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
              'Also Known As',
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
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Photos',
                  style: TextStyle(
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
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'Tagged Images',
                  style: TextStyle(
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
                    'Notable Quotes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
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
  const _SortSelector({required this.activeSort, required this.onSortChanged});

  final String activeSort;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String getSortLabel(String value) {
      switch (value) {
        case 'popularity':
          return 'Popularity';
        case 'releaseDate':
          return 'Release Date';
        case 'voteAverage':
          return 'Rating';
        default:
          return 'Popularity';
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
          const PopupMenuItem(
            value: 'popularity',
            child: Text(
              'Popularity',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const PopupMenuItem(
            value: 'releaseDate',
            child: Text(
              'Release Date',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const PopupMenuItem(
            value: 'voteAverage',
            child: Text(
              'Rating',
              style: TextStyle(color: Colors.white, fontSize: 13),
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
                      'Biography',
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
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Known For',
            style: TextStyle(
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
                  'Career Statistics',
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
                        title: 'Primary Role',
                        value: maxCreditsEntry?.key ?? 'N/A',
                        subtitle: '${maxCreditsEntry?.value ?? 0} Credits',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star_border_rounded,
                        title: 'Average Rating',
                        value: data.averageRating > 0
                            ? '${data.averageRating.toStringAsFixed(1)}/10'
                            : 'N/A',
                        subtitle: 'Across filmography',
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
                        title: 'Top Genre',
                        value: data.mostFrequentGenre,
                        subtitle: data.mostFrequentGenrePercent > 0
                            ? '${data.mostFrequentGenrePercent}% of titles'
                            : 'N/A',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up_rounded,
                        title: 'Peak Box Office',
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
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ShimmerEffect(
          width: double.infinity,
          height: 180,
          borderRadius: 16,
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
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
  const _FrequentCollaboratorsSection({required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(personAnalyticsProvider(personId));
    final theme = Theme.of(context);

    return analyticsAsync.when(
      data: (data) {
        if (data.collaborators.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Collaborates With',
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
                  itemCount: data.collaborators.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final collaborator = data.collaborators[index];
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.pushNamed(
                          AppRoute.personDetails.name,
                          pathParameters: {
                            'personId': collaborator.id.toString(),
                          },
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
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ShimmerEffect(
          width: double.infinity,
          height: 120,
          borderRadius: 12,
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
