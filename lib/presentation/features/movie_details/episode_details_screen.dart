import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/presentation/features/movie_details/providers/tv_details_providers.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/widgets/full_screen_image_viewer.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EpisodeDetailsScreen extends ConsumerWidget {
  const EpisodeDetailsScreen({
    super.key,
    required this.tvId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.showTitle,
  });

  final int tvId;
  final int seasonNumber;
  final int episodeNumber;
  final String showTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeAsync = ref.watch(
      tvEpisodeDetailsProvider((
        tvId: tvId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      )),
    );

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      body: episodeAsync.when(
        data: (episode) =>
            _EpisodeDetailsView(showTitle: showTitle, episode: episode),
        loading: () => const _EpisodeDetailsShimmer(),
        error: (error, _) => Scaffold(
          appBar: AppBar(backgroundColor: Colors.transparent),
          body: Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _EpisodeDetailsView extends ConsumerStatefulWidget {
  const _EpisodeDetailsView({required this.showTitle, required this.episode});

  final String showTitle;
  final TvEpisode episode;

  @override
  ConsumerState<_EpisodeDetailsView> createState() => _EpisodeDetailsViewState();
}

class _EpisodeDetailsViewState extends ConsumerState<_EpisodeDetailsView> {
  Timer? _slideshowTimer;
  List<String> _slideshowImages = [];
  int _currentImageIndex = 0;
  bool _isNextImageReady = false;

  @override
  void initState() {
    super.initState();
    _slideshowImages = widget.episode.images;
    if (_slideshowImages.isNotEmpty) {
      // Use microtask to ensure context is ready for precacheImage
      Future.microtask(() {
        if (mounted) _preloadNextImage();
      });
      _startSlideshow();
    }
  }

  void _startSlideshow() {
    _slideshowTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_slideshowImages.length > 1 && _isNextImageReady && mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _slideshowImages.length;
          _isNextImageReady = false;
          _preloadNextImage();
        });
      }
    });
  }

  void _preloadNextImage() {
    if (_slideshowImages.isEmpty || !mounted) return;
    final int nextIndex = (_currentImageIndex + 1) % _slideshowImages.length;
    final String imageUrl = _slideshowImages[nextIndex];

    precacheImage(CachedNetworkImageProvider(imageUrl), context).then((_) {
      if (mounted) {
        setState(() {
          _isNextImageReady = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.episode.airDate != null
        ? DateFormat('MMMM d, yyyy').format(DateTime.parse(widget.episode.airDate!))
        : 'Unknown Date';

    final String? backdropUrl = _slideshowImages.isNotEmpty
        ? _slideshowImages[_currentImageIndex]
        : widget.episode.stillPath;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Backdrop Slideshow
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  child: backdropUrl == null
                      ? Container(
                          key: const ValueKey('placeholder'),
                          color: Colors.white10,
                        )
                      : CachedNetworkImage(
                          key: ValueKey(backdropUrl),
                          imageUrl: backdropUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.white10),
                          errorWidget: (context, url, error) => Container(color: Colors.white10),
                        ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.cinemaBackground],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.episode.seasonNumber}x${widget.episode.episodeNumber} • $dateStr',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.episode.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.episode.voteAverage != null &&
                    widget.episode.voteAverage! > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.cinemaAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(widget.episode.voteAverage! * 10).toInt()}% User Score',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (widget.episode.overview != null &&
                    widget.episode.overview!.isNotEmpty) ...[
                  Text(
                    widget.episode.overview!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                _buildCreditsSection(context),
                const SizedBox(height: 24),
                if (widget.episode.images.isNotEmpty) _buildImagesSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditsSection(BuildContext context) {
    if (widget.episode.cast.isEmpty && widget.episode.crew.isEmpty) {
      return const SizedBox.shrink();
    }

    // Featured Crew logic: if Director/Writer present, show them
    final featuredCrew = widget.episode.crew
        .where((c) => c.role == 'Director' || c.role == 'Writer')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cast & Crew',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                context.pushNamed(
                  AppRoute.fullCastCrew.name,
                  extra: {
                    'title': widget.episode.name,
                    'cast': widget.episode.cast,
                    'crew': widget.episode.crew,
                  },
                );
              },
              child: Text(
                'View Full',
                style: TextStyle(color: AppColors.cinemaAccent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 185,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.episode.cast.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final actor = widget.episode.cast[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: MediaPosterGridCard(
                  movie: actor.toMediaTitle(),
                  sectionTitle: 'episode_cast',
                  width: 100,
                  isTvTitle: false,
                ),
              );
            },
          ),
        ),
        if (featuredCrew.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Featured Crew',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 165,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featuredCrew.length,
              itemBuilder: (context, index) {
                final member = featuredCrew[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: MediaPosterGridCard(
                    movie: member.toMediaTitle(),
                    sectionTitle: 'episode_crew',
                    width: 80,
                    isTvTitle: false,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stills',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.episode.images.length,
            itemBuilder: (context, index) {
              final image = widget.episode.images[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageViewer(
                        images: widget.episode.images,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      width: 200,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ShimmerEffect(width: 200, height: 120),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

extension on MovieCredit {
  MediaTitle toMediaTitle() {
    return MediaTitle(
      id: id,
      title: name,
      posterPath: imageUrl,
      releaseDate: characterName ?? role,
      mediaType: GlobalMediaType.person,
    );
  }
}

class _EpisodeDetailsShimmer extends StatelessWidget {
  const _EpisodeDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColors.cinemaAccent),
    );
  }
}
