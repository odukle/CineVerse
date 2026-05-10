import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/person_details.dart';
import 'package:cineverse/presentation/features/person/providers/person_details_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:cineverse/presentation/widgets/full_screen_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/app/router/app_router.dart' show AppRoute;
import 'package:go_router/go_router.dart';

class PersonDetailsScreen extends ConsumerWidget {
  const PersonDetailsScreen({super.key, required this.personId, this.heroTag});

  final int personId;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personDetails = ref.watch(personDetailsProvider(personId));

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      body: personDetails.when(
        skipLoadingOnReload: !personDetails.hasError,
        loading: () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60), // AppBar space
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerEffect.poster(width: 120, height: 180),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerEffect.textLine(width: 150, height: 24),
                          const SizedBox(height: 12),
                          ShimmerEffect.textLine(width: 100, height: 16),
                          const SizedBox(height: 24),
                          ShimmerEffect.textLine(
                            width: double.infinity,
                            height: 12,
                          ),
                          const SizedBox(height: 8),
                          ShimmerEffect.textLine(
                            width: double.infinity,
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerEffect.textLine(
                  width: double.infinity,
                  height: 100,
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error: $error',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(personDetailsProvider(personId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cinemaAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (details) =>
            _PersonDetailsView(details: details, heroTag: heroTag),
      ),
    );
  }
}

class _PersonDetailsView extends ConsumerStatefulWidget {
  const _PersonDetailsView({required this.details, this.heroTag});

  final PersonDetails details;
  final String? heroTag;

  @override
  ConsumerState<_PersonDetailsView> createState() => _PersonDetailsViewState();
}

class _PersonDetailsViewState extends ConsumerState<_PersonDetailsView> {
  String? _selectedDepartment;
  bool _isBiographyExpanded = false;

  @override
  void initState() {
    super.initState();
    final departments = widget.details.creditsByDepartment.keys.toList();

    // Sort credits within each department by release date (newest first)
    for (final dept in departments) {
      final credits = widget.details.creditsByDepartment[dept]!;
      credits.sort((a, b) {
        final dateA = a.media.releaseDate ?? '';
        final dateB = b.media.releaseDate ?? '';
        if (dateA.isEmpty && dateB.isEmpty) return 0;
        if (dateA.isEmpty) return 1;
        if (dateB.isEmpty) return -1;
        return dateB.compareTo(dateA);
      });
    }

    if (departments.isNotEmpty) {
      // Use the same sorting logic as in build to pick the first one
      final knownDept = widget.details.knownForDepartment;
      departments.sort((a, b) {
        String getBase(String s) =>
            s.contains(' (') ? s.substring(0, s.indexOf(' (')) : s;

        final baseA = getBase(a);
        final baseB = getBase(b);

        if (baseA == baseB) {
          return a.contains('(Movies)') ? -1 : 1;
        }

        if (knownDept != null) {
          if (baseA == knownDept) return -1;
          if (baseB == knownDept) return 1;
        }

        if (baseA == 'Acting') return -1;
        if (baseB == 'Acting') return 1;

        return baseA.compareTo(baseB);
      });
      _selectedDepartment = departments.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final departments = widget.details.creditsByDepartment.keys.toList();

    // Sort departments: prioritize known department pairs, then Acting pairs, then others
    final knownDept = widget.details.knownForDepartment;

    departments.sort((a, b) {
      String getBase(String s) =>
          s.contains(' (') ? s.substring(0, s.indexOf(' (')) : s;

      final baseA = getBase(a);
      final baseB = getBase(b);

      if (baseA == baseB) {
        // Same department, Movies should come before TV
        return a.contains('(Movies)') ? -1 : 1;
      }

      if (knownDept != null) {
        if (baseA == knownDept) return -1;
        if (baseB == knownDept) return 1;
      }

      if (baseA == 'Acting') return -1;
      if (baseB == 'Acting') return 1;

      return baseA.compareTo(baseB);
    });

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.cinemaGradient,
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 56,
            backgroundColor: AppColors.cinemaGradientTop,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            title: SizedBox(
              height: 24,
              child: SvgPicture.asset(
                'assets/logos/logo.svg',
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                semanticsLabel: AppConstants.appName,
              ),
            ),
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag:
                            widget.heroTag ??
                            'person-profile-${widget.details.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 120,
                            height: 180,
                            child: widget.details.profilePath != null
                                ? CachedNetworkImage(
                                    imageUrl: widget.details.profilePath!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const ShimmerEffect(
                                          width: 120,
                                          height: 180,
                                          borderRadius: 12,
                                        ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white54,
                                        ),
                                  )
                                : const ColoredBox(
                                    color: AppColors.detailsPosterSurface,
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white54,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.details.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.details.knownForDepartment != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  widget.details.knownForDepartment!,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            _PersonalInfoItem(
                              label: 'Birthday',
                              value: widget.details.birthday,
                            ),
                            _PersonalInfoItem(
                              label: 'Place of Birth',
                              value: widget.details.placeOfBirth,
                            ),
                            if (widget.details.deathday != null)
                              _PersonalInfoItem(
                                label: 'Deathday',
                                value: widget.details.deathday,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.details.biography != null &&
                      widget.details.biography!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Biography',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: Text(
                        widget.details.biography!,
                        maxLines: _isBiographyExpanded ? null : 10,
                        overflow: _isBiographyExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => setState(
                        () => _isBiographyExpanded = !_isBiographyExpanded,
                      ),
                      child: Text(
                        _isBiographyExpanded ? 'Read less' : 'Read more...',
                        style: const TextStyle(
                          color: AppColors.cinemaAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Images Section
          SliverToBoxAdapter(
            child: _PersonImagesCarousel(personId: widget.details.id),
          ),

          if (departments.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: departments.map((dept) {
                          final isSelected = _selectedDepartment == dept;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(dept),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedDepartment = dept);
                                }
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.05,
                              ),
                              selectedColor: AppColors.cinemaAccent,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.white24,
                              ),
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (_selectedDepartment != null)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.02, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                      child: GridView.builder(
                        key: ValueKey<String>(_selectedDepartment!),
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.55,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                            ),
                        itemCount:
                            widget
                                .details
                                .creditsByDepartment[_selectedDepartment!]
                                ?.length ??
                            0,
                        itemBuilder: (context, index) {
                          final credit = widget
                              .details
                              .creditsByDepartment[_selectedDepartment!]![index];
                          return _CreditCard(credit: credit);
                        },
                      ),
                    ),
                ],
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
    final ThemeData theme = Theme.of(context);

    return imagesAsync.when(
      data: (images) {
        if (images.posters.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
              child: Text(
                'Images',
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
                itemCount: images.posters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final String imageUrl = images.posters[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(
                            images: images.posters,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.detailsPosterSurface,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Hero(
                        tag: imageUrl,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            color: Colors.white24,
                          ),
                        ),
                      ),
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
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => const ShimmerEffect(
                width: 120,
                height: 180,
                borderRadius: 12,
              ),
            ),
          ),
        ],
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _PersonalInfoItem extends StatelessWidget {
  const _PersonalInfoItem({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
          Text(
            value!,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.credit});

  final PersonCredit credit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = credit.media;

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoute.movieDetails.name,
          pathParameters: {'movieId': media.id.toString()},
          queryParameters: {
            'isTv': (media.mediaType == GlobalMediaType.tv).toString(),
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: media.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: media.posterPath!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerEffect(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 8,
                      ),
                      errorWidget: (context, url, error) =>
                          const SizedBox.expand(
                            child: ColoredBox(
                              color: AppColors.detailsPosterSurface,
                              child: Icon(
                                Icons.movie_outlined,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                    )
                  : const SizedBox.expand(
                      child: ColoredBox(
                        color: AppColors.detailsPosterSurface,
                        child: Icon(
                          Icons.movie_outlined,
                          color: Colors.white24,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            media.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (credit.role != null && credit.role!.isNotEmpty)
            Builder(
              builder: (context) {
                final year =
                    media.releaseDate != null && media.releaseDate!.length >= 4
                    ? media.releaseDate!.substring(0, 4)
                    : null;
                return Text(
                  '${year != null ? '$year • ' : ''}${credit.role!}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white54,
                    fontSize: 10,
                    height: 1.2,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
