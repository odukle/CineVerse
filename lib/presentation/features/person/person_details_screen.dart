import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:cineverse/presentation/widgets/full_screen_image_viewer.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:cineverse/presentation/providers/quotes_provider.dart';
import 'package:cineverse/presentation/features/person/providers/person_details_provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PersonDetailsScreen extends ConsumerStatefulWidget {
  const PersonDetailsScreen({super.key, required this.personId, this.heroTag});

  final int personId;
  final String? heroTag;

  @override
  ConsumerState<PersonDetailsScreen> createState() =>
      _PersonDetailsScreenState();
}

class _PersonDetailsScreenState extends ConsumerState<PersonDetailsScreen> {
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
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              details.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Profile Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag:
                                        widget.heroTag ??
                                        'person-${details.id}',
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
                                            label: 'Born',
                                            value: details.birthday!,
                                          ),
                                        if (details.placeOfBirth != null)
                                          _InfoItem(
                                            label: 'Birthplace',
                                            value: details.placeOfBirth!,
                                          ),
                                        if (details.deathday != null)
                                          _InfoItem(
                                            label: 'Died',
                                            value: details.deathday!,
                                          ),
                                        if (details.knownForDepartment != null)
                                          _InfoItem(
                                            label: 'Known For',
                                            value: details.knownForDepartment!,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Biography
                          if (details.biography != null &&
                              details.biography!.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Biography',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      details.biography!,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            height: 1.5,
                                          ),
                                    ),
                                  ],
                                ),
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
                                minHeight: 126,
                                maxHeight: 126,
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
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              26,
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
                                            isScrollable: true,
                                            tabAlignment: TabAlignment.start,
                                            dividerColor: Colors.transparent,
                                            indicatorPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 2,
                                                ),
                                            labelPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
                                            tabs: departments
                                                .map(
                                                  (d) => Tab(
                                                    text: departments.length > 5
                                                        ? d
                                                        : d.toUpperCase(),
                                                  ),
                                                )
                                                .toList(),
                                          ),
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
                        final credits = details.creditsByDepartment[dept]!;
                        return CustomScrollView(
                          key: PageStorageKey<String>(dept),
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

                                  return MediaPosterGridCard(
                                    movie: credit.media,
                                    sectionTitle: 'credits-$dept',
                                    width: cardWidth,
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
        if (profiles.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                separatorBuilder: (context, index) => const SizedBox(width: 12),
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
              child: Text(
                'Notable Quotes',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
