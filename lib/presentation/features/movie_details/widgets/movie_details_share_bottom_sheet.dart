import 'dart:io';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cineverse/presentation/features/movie_details/quote_share_editor_screen.dart';

class MovieDetailsShareBottomSheet extends StatefulWidget {
  const MovieDetailsShareBottomSheet({
    super.key,
    required this.details,
    required this.isTv,
    this.userRating,
    this.userNote,
  });

  final MovieDetails details;
  final bool isTv;
  final int? userRating;
  final String? userNote;

  static void show(
    BuildContext context, {
    required MovieDetails details,
    required bool isTv,
    int? userRating,
    String? userNote,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MovieDetailsShareBottomSheet(
        details: details,
        isTv: isTv,
        userRating: userRating,
        userNote: userNote,
      ),
    );
  }

  @override
  State<MovieDetailsShareBottomSheet> createState() =>
      _MovieDetailsShareBottomSheetState();
}

class _MovieDetailsShareBottomSheetState
    extends State<MovieDetailsShareBottomSheet> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareVisualCard() async {
    final imageBytes = await _screenshotController.captureFromWidget(
      _ShareableCard(details: widget.details, isTv: widget.isTv),
      context: context,
      delay: const Duration(milliseconds: 500),
    );

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/cineverse_share.png').create();
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Recommended on Lumi: ${widget.details.title}');
  }

  Future<void> _shareDeepLink() async {
    final mediaType = widget.isTv ? 'tv' : 'movie';
    final deepLink = 'cineverse://$mediaType/${widget.details.id}';
    final storeLink = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.odukle.cineverse'
        : 'https://apps.apple.com/app/id6775792556';

    final shareText =
        'Check out "${widget.details.title}" on Lumi!\n\n'
        'Open in App: $deepLink\n\n'
        'Get Lumi: $storeLink';

    await Share.share(shareText);
  }

  Future<void> _shareDirectLink() async {
    final tmdbLink =
        'https://www.themoviedb.org/${widget.isTv ? 'tv' : 'movie'}/${widget.details.id}';
    await Share.share('Check out "${widget.details.title}" on TMDB: $tmdbLink');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.cinemaSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            'Share Movie',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _ShareOptionItem(
            icon: Icons.auto_awesome_rounded,
            title: 'Visual Movie Card',
            subtitle: 'Beautiful styled card for social stories',
            color: AppColors.cinemaAccent,
            onTap: () {
              Navigator.pop(context);
              _shareVisualCard();
            },
          ),
          _ShareOptionItem(
            icon: Icons.link_rounded,
            title: 'Smart Deep Link',
            subtitle: 'Directly opens in Lumi app',
            color: Colors.blueAccent,
            onTap: () {
              Navigator.pop(context);
              _shareDeepLink();
            },
          ),
          _ShareOptionItem(
            icon: Icons.format_quote_rounded,
            title: "Share quotes",
            subtitle: 'Place your favorite quote on a movie backdrop',
            color: Colors.orangeAccent,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuoteShareEditorScreen(
                    details: widget.details,
                    isTv: widget.isTv,
                  ),
                ),
              );
            },
          ),
          _ShareOptionItem(
            icon: Icons.open_in_new_rounded,
            title: 'Direct TMDB Link',
            subtitle: 'Standard link to movie database',
            color: Colors.greenAccent,
            onTap: () {
              Navigator.pop(context);
              _shareDirectLink();
            },
          ),
        ],
      ),
    );
  }
}

class _ShareOptionItem extends StatelessWidget {
  const _ShareOptionItem({
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
  final VoidCallback onTap;

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

class _ShareableCard extends StatelessWidget {
  const _ShareableCard({required this.details, required this.isTv});

  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 480,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Background Backdrop (Blurred)
          if (details.backdropPath != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: CachedNetworkImage(
                  imageUrl: details.backdropPath!,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.8),
                    const Color(0xFF0F0F0F),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/logos/logo.svg',
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        AppColors.cinemaAccent,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Poster
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: details.posterPath != null
                        ? CachedNetworkImage(
                            imageUrl: details.posterPath!,
                            width: 160,
                            height: 240,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 160,
                            height: 240,
                            color: Colors.white10,
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white24,
                              size: 48,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  details.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Mood/Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cinemaAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.cinemaAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.cinemaAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${details.catalogScore?.toStringAsFixed(1) ?? 'N/A'}/10',
                        style: TextStyle(
                          color: AppColors.cinemaAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                const Text(
                  'DISCOVER ON LUMI',
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
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
