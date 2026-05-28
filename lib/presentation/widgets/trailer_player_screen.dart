import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrailerPlaybackData {
  const TrailerPlaybackData({
    required this.videoKey,
    required this.title,
    this.tagline,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.runtimeMinutes,
    this.voteAverage,
    this.voteCount,
    this.categoryLabel,
    this.sourceMediaId,
    this.isTv = false,
    this.recommendations = const <MovieRecommendation>[],
  });

  final String videoKey;
  final String title;
  final String? tagline;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final int? runtimeMinutes;
  final double? voteAverage;
  final int? voteCount;
  final String? categoryLabel;
  final int? sourceMediaId;
  final bool isTv;
  final List<MovieRecommendation> recommendations;
}

class TrailerPlayerScreen extends ConsumerStatefulWidget {
  const TrailerPlayerScreen({super.key, required this.data});

  final TrailerPlaybackData data;

  @override
  ConsumerState<TrailerPlayerScreen> createState() =>
      _TrailerPlayerScreenState();
}

class _TrailerFeedItem {
  const _TrailerFeedItem({required this.mediaId, required this.data});

  final int mediaId;
  final TrailerPlaybackData data;
}

class _TrailerPlayerScreenState extends ConsumerState<TrailerPlayerScreen>
    with WidgetsBindingObserver {
  late final YoutubePlayerController _controller;
  late TrailerPlaybackData _currentData;
  final ScrollController _scrollController = ScrollController();
  final Set<int> _seenRecommendationIds = <int>{};
  bool _wasFullScreen = false;
  bool _isLoadingFeed = false;
  bool _isLoadingMoreFeed = false;
  bool _hasMoreFeed = true;
  int _nextRecommendationPage = 1;
  int _consecutiveEmptyFeedPages = 0;
  List<_TrailerFeedItem> _feedItems = const <_TrailerFeedItem>[];

  @override
  void initState() {
    super.initState();
    _currentData = widget.data;
    WidgetsBinding.instance.addObserver(this);
    _controller = YoutubePlayerController(
      initialVideoId: _currentData.videoKey,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        isLive: false,
        forceHD: false,
        useHybridComposition: true,
      ),
    )..addListener(_onPlayerStateChange);
    _scrollController.addListener(_onFeedScroll);
    unawaited(_loadRecommendationFeed(reset: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.pause();
    }
  }

  void _onPlayerStateChange() {
    final bool isFullScreen = _controller.value.isFullScreen;
    if (_wasFullScreen && !isFullScreen) {
      unawaited(_restorePortraitMode());
    }
    _wasFullScreen = isFullScreen;
  }

  Future<void> _enterFullScreenMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _restorePortraitMode() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onPlayerStateChange);
    _controller.dispose();
    _scrollController.removeListener(_onFeedScroll);
    _scrollController.dispose();
    unawaited(_restorePortraitMode());
    super.dispose();
  }

  void _onFeedScroll() {
    if (!_scrollController.hasClients ||
        _isLoadingFeed ||
        _isLoadingMoreFeed ||
        !_hasMoreFeed) {
      return;
    }
    if (_scrollController.position.extentAfter < 420) {
      unawaited(_loadRecommendationFeed());
    }
  }

  Future<void> _loadRecommendationFeed({bool reset = false}) async {
    if (reset) {
      _nextRecommendationPage = 1;
      _hasMoreFeed = true;
      _consecutiveEmptyFeedPages = 0;
      _isLoadingFeed = false;
      _isLoadingMoreFeed = false;
      _seenRecommendationIds.clear();
      setState(() {
        _feedItems = const <_TrailerFeedItem>[];
      });
    }

    if (_isLoadingFeed || _isLoadingMoreFeed || !_hasMoreFeed) {
      return;
    }

    final bool initialLoad = _feedItems.isEmpty;
    setState(() {
      if (initialLoad) {
        _isLoadingFeed = true;
      } else {
        _isLoadingMoreFeed = true;
      }
    });

    try {
      List<MovieRecommendation> candidates = const <MovieRecommendation>[];
      final bool useSeed =
          _nextRecommendationPage == 1 && widget.data.recommendations.isNotEmpty;

      if (useSeed) {
        candidates = widget.data.recommendations;
        _nextRecommendationPage = 2;
      } else if (widget.data.sourceMediaId != null) {
        candidates = await ref
            .read(mediaRepositoryProvider)
            .fetchMovieRecommendations(
              widget.data.sourceMediaId!,
              page: _nextRecommendationPage,
              isTv: widget.data.isTv,
            );
        _nextRecommendationPage += 1;
        if (candidates.length < 20) {
          _hasMoreFeed = false;
        }
      } else {
        _hasMoreFeed = false;
      }

      if (candidates.isEmpty && !useSeed) {
        _hasMoreFeed = false;
      }

      final List<MovieRecommendation> uniqueCandidates = candidates
          .where((MovieRecommendation rec) => rec.id != widget.data.sourceMediaId)
          .where((MovieRecommendation rec) => _seenRecommendationIds.add(rec.id))
          .take(12)
          .toList(growable: false);

      final List<Future<_TrailerFeedItem?>> jobs = uniqueCandidates
          .map((MovieRecommendation rec) {
            return (() async {
              try {
                final MovieDetails details = await ref
                    .read(mediaRepositoryProvider)
                    .fetchMovieDetails(rec.id, isTv: widget.data.isTv);
                final String? trailerKey = details.trailerYouTubeKey;
                if (trailerKey == null || trailerKey.isEmpty) {
                  return null;
                }
                return _TrailerFeedItem(
                  mediaId: rec.id,
                  data: TrailerPlaybackData(
                    videoKey: trailerKey,
                    title: details.title,
                    tagline: details.tagline,
                    overview: details.overview,
                    posterPath: details.posterPath ?? rec.posterPath,
                    backdropPath: details.backdropPath,
                    releaseDate: details.releaseDate ?? rec.releaseDate,
                    runtimeMinutes: details.runtimeMinutes,
                    voteAverage: details.catalogScore ?? rec.voteAverage,
                    voteCount: details.voteCount,
                    categoryLabel: widget.data.isTv
                        ? 'Recommended Series'
                        : 'Recommended Movie',
                    sourceMediaId: rec.id,
                    isTv: widget.data.isTv,
                  ),
                );
              } catch (_) {
                return null;
              }
            })().timeout(const Duration(seconds: 10), onTimeout: () => null);
          })
          .toList(growable: false);

      final List<_TrailerFeedItem> loaded = (await Future.wait(
        jobs,
      )).whereType<_TrailerFeedItem>().toList(growable: false);

      if (loaded.isEmpty) {
        _consecutiveEmptyFeedPages += 1;
        if (_consecutiveEmptyFeedPages >= 3) {
          _hasMoreFeed = false;
        }
      } else {
        _consecutiveEmptyFeedPages = 0;
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _feedItems = <_TrailerFeedItem>[..._feedItems, ...loaded];
        _isLoadingFeed = false;
        _isLoadingMoreFeed = false;
      });

      if (loaded.isEmpty && _hasMoreFeed && mounted) {
        unawaited(_loadRecommendationFeed());
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingFeed = false;
        _isLoadingMoreFeed = false;
      });
    }
  }

  Future<void> _playFromFeed(_TrailerFeedItem item) async {
    if (_controller.value.isReady) {
      _controller.load(item.data.videoKey);
    }
    setState(() {
      _currentData = item.data;
    });
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Uri get _currentYouTubeUri =>
      Uri.parse('https://www.youtube.com/watch?v=${_currentData.videoKey}');

  Future<void> _openCurrentOnYouTube() async {
    await launchUrl(_currentYouTubeUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareCurrentTrailer() async {
    await Share.share(
      'Watch "${_currentData.title}" trailer: ${_currentYouTubeUri.toString()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TrailerPlaybackData data = _currentData;
    final YoutubePlayer player = YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: AppColors.cinemaScoreRing,
      onEnded: (_) {
        if (mounted) {
          Navigator.of(context).maybePop();
        }
      },
    );

    return YoutubePlayerBuilder(
      player: player,
      onEnterFullScreen: () => unawaited(_enterFullScreenMode()),
      onExitFullScreen: () => unawaited(_restorePortraitMode()),
      builder: (BuildContext context, Widget player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: <Widget>[
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Close trailer',
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Text(
                          data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              player,
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          side: BorderSide(
                            color: AppColors.cinemaBorder.withValues(alpha: 0.45),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => unawaited(_openCurrentOnYouTube()),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('Open in YouTube'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          side: BorderSide(
                            color: AppColors.cinemaBorder.withValues(alpha: 0.45),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => unawaited(_shareCurrentTrailer()),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Text(
                        data.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    if (_buildMetaLine(data).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          _buildMetaLine(data),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ),
                    if ((data.tagline ?? '').trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Text(
                            data.tagline!.trim(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if ((data.posterPath ?? '').isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl:
                                    '${AppConstants.tmdbImageBaseUrl}${data.posterPath}',
                                width: 88,
                                height: 132,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 88,
                              height: 132,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.movie_outlined,
                                color: Colors.white54,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if ((data.overview ?? '').trim().isNotEmpty)
                                  Text(
                                    data.overview!.trim(),
                                    maxLines: 8,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      height: 1.4,
                                    ),
                                  )
                                else
                                  Text(
                                    'No description available for this trailer.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'More Trailers Like This',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (_isLoadingFeed)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    if (_isLoadingFeed)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
                        child: LinearProgressIndicator(minHeight: 2),
                      )
                    else if (_feedItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        child: Text(
                          'No additional recommendation trailers were found.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: <Widget>[
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                            itemCount: _feedItems.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (BuildContext context, int index) {
                              final _TrailerFeedItem item = _feedItems[index];
                              final bool isActive =
                                  item.data.videoKey == _currentData.videoKey;
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _playFromFeed(item),
                                  child: Ink(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: isActive ? 0.14 : 0.07,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isActive
                                            ? AppColors.cinemaAccent.withValues(
                                                alpha: 0.7,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.1,
                                              ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: 120,
                                            height: 68,
                                            child: _FeedThumbnail(data: item.data),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                item.data.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _buildMetaLine(item.data),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.72,
                                                          ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isActive
                                              ? Icons.equalizer_rounded
                                              : Icons.play_arrow_rounded,
                                          color: isActive
                                              ? AppColors.cinemaAccent
                                              : Colors.white.withValues(
                                                  alpha: 0.85,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_isLoadingMoreFeed)
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                              child: LinearProgressIndicator(minHeight: 2),
                            )
                          else
                            const SizedBox(height: 24),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildMetaLine(TrailerPlaybackData data) {
    final List<String> parts = <String>[];
    final String? year = _extractYear(data.releaseDate);
    if (year != null) {
      parts.add(year);
    }

    if (data.runtimeMinutes != null && data.runtimeMinutes! > 0) {
      final int hours = data.runtimeMinutes! ~/ 60;
      final int minutes = data.runtimeMinutes! % 60;
      if (hours > 0 && minutes > 0) {
        parts.add('${hours}h ${minutes}m');
      } else if (hours > 0) {
        parts.add('${hours}h');
      } else {
        parts.add('${minutes}m');
      }
    }

    if (data.voteAverage != null && data.voteAverage! > 0) {
      parts.add('${data.voteAverage!.toStringAsFixed(1)}/10');
    }

    if (data.voteCount != null && data.voteCount! > 0) {
      parts.add('${data.voteCount} ratings');
    }

    if ((data.categoryLabel ?? '').trim().isNotEmpty) {
      parts.add(data.categoryLabel!.trim());
    }

    return parts.join(' • ');
  }

  String? _extractYear(String? releaseDate) {
    if (releaseDate == null || releaseDate.length < 4) {
      return null;
    }
    return releaseDate.substring(0, 4);
  }
}

class _FeedThumbnail extends StatelessWidget {
  const _FeedThumbnail({required this.data});

  final TrailerPlaybackData data;

  @override
  Widget build(BuildContext context) {
    final String? backdrop = data.backdropPath;
    if (backdrop != null && backdrop.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: '${AppConstants.tmdbImageBaseUrl}$backdrop',
        fit: BoxFit.cover,
      );
    }
    final String? poster = data.posterPath;
    if (poster != null && poster.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: '${AppConstants.tmdbImageBaseUrl}$poster',
        fit: BoxFit.cover,
      );
    }
    return Container(
      color: Colors.white.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, color: Colors.white60),
    );
  }
}
