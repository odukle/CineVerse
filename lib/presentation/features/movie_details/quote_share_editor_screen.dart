import 'dart:io';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/repositories/quotes_repository.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/providers/quotes_provider.dart';
import 'package:cineverse/domain/entities/media_images.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gal/gal.dart';
import 'package:cineverse/core/utils/toast_utils.dart';

enum ShareAspectRatio { portrait, landscape }

enum EditMode { text, background }

class QuoteShareEditorScreen extends ConsumerStatefulWidget {
  const QuoteShareEditorScreen({
    super.key,
    required this.details,
    required this.isTv,
    this.initialQuote,
    this.seasonNumber,
  });

  final MovieDetails details;
  final bool isTv;
  final MediaQuote? initialQuote;
  final int? seasonNumber;

  @override
  ConsumerState<QuoteShareEditorScreen> createState() =>
      _QuoteShareEditorScreenState();
}

class _QuoteShareEditorScreenState
    extends ConsumerState<QuoteShareEditorScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  MediaQuote? _selectedQuote;
  String? _selectedBackdrop;

  @override
  void initState() {
    super.initState();
    _selectedQuote = widget.initialQuote;
  }

  // Interactive viewer state
  ShareAspectRatio _aspectRatio = ShareAspectRatio.portrait;
  EditMode _editMode = EditMode.text;

  Offset _quotePosition = Offset.zero;
  Offset _logicalQuotePosition = Offset.zero;
  double _quoteScale = 1.0;
  double _initialQuoteScale = 1.0;
  bool _isSnappedX = false;
  bool _isSnappedY = false;

  double _bgAlignmentX = 0.0;

  TextAlign _textAlign = TextAlign.center;
  int _maxCharsPerLine = 30;
  double _dragAccumulator = 0;

  bool _isCapturing = false;
  bool _showEditorMarkers = true;

  Future<void> _shareImage() async {
    setState(() {
      _isCapturing = true;
    });

    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );
      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/lumi_quote.png').create();
        await file.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Check out this quote from "${widget.details.title}" on Lumi!',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showToast(context, context.l10n.errorGeneric(''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _saveImage() async {
    setState(() {
      _isCapturing = true;
    });

    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );
      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/lumi_quote_${DateTime.now().millisecondsSinceEpoch}.png',
        ).create();
        await file.writeAsBytes(imageBytes);

        await Gal.putImage(file.path);

        if (mounted) {
          ToastUtils.showToast(context, context.l10n.tooltipSaveToGallery);
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showToast(context, context.l10n.errorGeneric(''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  String _wrapText(String text, int maxLength) {
    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';

    for (final word in words) {
      if ((currentLine + (currentLine.isEmpty ? '' : ' ') + word).length <=
          maxLength) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        if (currentLine.isNotEmpty) lines.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quotesAsync = ref.watch(
      mediaQuotesProvider((title: widget.details.title, isTv: widget.isTv)),
    );
    final imagesAsync = ref.watch(
      mediaImagesProvider((id: widget.details.id, isTv: widget.isTv)),
    );
    final seasonImagesAsync = widget.isTv && widget.seasonNumber != null
        ? ref.watch(
            tvSeasonImagesProvider((
              tvId: widget.details.id,
              seasonNumber: widget.seasonNumber!,
            )),
          )
        : null;

    final AsyncValue<MediaImages> combinedImagesAsync = imagesAsync.whenData((
      main,
    ) {
      if (seasonImagesAsync == null) return main;
      return seasonImagesAsync.maybeWhen(
        data: (season) => MediaImages(
          backdrops: [...main.backdrops, ...season.backdrops],
          posters: [...main.posters, ...season.posters],
          logos: main.logos,
        ),
        orElse: () => main,
      );
    });

    if (_selectedQuote == null) {
      // Step 1: Select a quote
      return Scaffold(
        backgroundColor: AppColors.cinemaBackground,
        appBar: AppBar(
          backgroundColor: AppColors.cinemaBackground,
          title: Text(context.l10n.selectAQuote),
          actions: [
            TextButton(
              onPressed: () {
                context.push(
                  '/explore_quotes',
                  extra: {
                    'title': widget.details.title,
                    'isTv': widget.isTv,
                    'details': widget.details,
                  },
                );
              },
              child: Text(
                context.l10n.share,
                style: TextStyle(color: AppColors.cinemaAccent),
              ),
            ),
          ],
        ),
        body: quotesAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.cinemaAccent),
          ),
          error: (error, _) =>
              Center(child: Text(context.l10n.errorLoadingQuotes(error.toString()))),
          data: (quotes) {
            // Filter out extremely long quotes (e.g. limit to ~300 chars for a good visual)
            final validQuotes = quotes
                .where((q) => q.text.length <= 300)
                .toList();

            if (validQuotes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.noItemsFound,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push(
                          '/explore_quotes',
                          extra: {
                            'title': widget.details.title,
                            'isTv': widget.isTv,
                            'details': widget.details,
                          },
                        );
                      },
                      icon: const Icon(Icons.search_rounded),
                      label: Text(context.l10n.searchWikiquotes),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cinemaAccent,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: validQuotes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final quote = validQuotes[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedQuote = quote;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cinemaSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          color: AppColors.cinemaAccent,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          quote.text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                        if (quote.character != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.quoteCharacter(quote.character!),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.cinemaAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    // Step 2: Editor
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedQuote = null;
            });
          },
        ),
        actions: [
          if (!_isCapturing) ...[
            IconButton(
              onPressed: _saveImage,
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              tooltip: context.l10n.tooltipSaveToGallery,
            ),
            IconButton(
              onPressed: _shareImage,
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              tooltip: context.l10n.tooltipShare,
            ),
          ],
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (details) {
          _initialQuoteScale = _quoteScale;
          _logicalQuotePosition = _quotePosition;
        },
        onScaleUpdate: (details) {
          setState(() {
            if (_editMode == EditMode.text) {
              _logicalQuotePosition += details.focalPointDelta;

              // Snapping logic
              bool newSnappedX = _logicalQuotePosition.dx.abs() < 15.0;
              bool newSnappedY = _logicalQuotePosition.dy.abs() < 15.0;

              if (newSnappedX && !_isSnappedX) HapticFeedback.lightImpact();
              if (newSnappedY && !_isSnappedY) HapticFeedback.lightImpact();

              _isSnappedX = newSnappedX;
              _isSnappedY = newSnappedY;

              _quotePosition = Offset(
                _isSnappedX ? 0 : _logicalQuotePosition.dx,
                _isSnappedY ? 0 : _logicalQuotePosition.dy,
              );

              _quoteScale = (_initialQuoteScale * details.scale).clamp(0.3, 3.0);
            } else if (_aspectRatio == ShareAspectRatio.portrait) {
              _bgAlignmentX -= details.focalPointDelta.dx / (MediaQuery.of(context).size.width / 2);
              _bgAlignmentX = _bgAlignmentX.clamp(-1.0, 1.0);
            }
          });
        },
        onScaleEnd: (details) {
          setState(() {
            _isSnappedX = false;
            _isSnappedY = false;
          });
        },
        onTap: () {
          setState(() {
            _showEditorMarkers = false;
          });
        },
        child: Stack(
          children: [
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              tween: Tween<double>(
                end: _aspectRatio == ShareAspectRatio.portrait
                    ? 9 / 16
                    : 16 / 9,
              ),
              builder: (context, ratio, child) {
                return AspectRatio(aspectRatio: ratio, child: child!);
              },
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  color: Colors.black,
                  child: combinedImagesAsync.when(
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cinemaAccent,
                      ),
                    ),
                    error: (error, stack) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
                    data: (images) {
                      if (_selectedBackdrop == null &&
                          images.backdrops.isNotEmpty) {
                        _selectedBackdrop = images.backdrops.first;
                      }
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image
                          if (_selectedBackdrop != null)
                            CachedNetworkImage(
                              imageUrl: _selectedBackdrop!,
                              fit: BoxFit.cover,
                              alignment: Alignment(_bgAlignmentX, 0),
                            ),

                          // Dark Gradient Overlay for text readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.black.withValues(alpha: 0.9),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),

                          // Quote Layer
                          Center(
                            child: Transform.translate(
                              offset: _quotePosition,
                              child: Transform.scale(
                                scale: _quoteScale,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: switch (_textAlign) {
                                        TextAlign.left || TextAlign.start => Alignment.centerLeft,
                                        TextAlign.right || TextAlign.end => Alignment.centerRight,
                                        _ => Alignment.center,
                                      },
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            _showEditorMarkers = true;
                                          });
                                        },
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                              decoration: BoxDecoration(
                                                border: (!_isCapturing && _editMode == EditMode.text && _showEditorMarkers)
                                                    ? Border.all(color: AppColors.cinemaAccent.withValues(alpha: 0.5), width: 1.5)
                                                    : null,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: switch (_textAlign) {
                                                  TextAlign.left || TextAlign.start => CrossAxisAlignment.start,
                                                  TextAlign.right || TextAlign.end => CrossAxisAlignment.end,
                                                  _ => CrossAxisAlignment.center,
                                                },
                                                children: [
                                                  Icon(
                                                    Icons.format_quote_rounded,
                                                    color: AppColors.cinemaAccent,
                                                    size: 48,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    _wrapText(_selectedQuote!.text, _maxCharsPerLine),
                                                    textAlign: _textAlign,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      fontStyle: FontStyle.italic,
                                                      height: 1.3,
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black54,
                                                          blurRadius: 12,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (_selectedQuote!.character != null) ...[
                                                    const SizedBox(height: 24),
                                                    Text(
                                                      context.l10n.quoteCharacter(_selectedQuote!.character!),
                                                      textAlign: _textAlign,
                                                      style: TextStyle(
                                                        color: AppColors.cinemaAccent,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 1.2,
                                                        shadows: const [
                                                          Shadow(
                                                            color: Colors.black54,
                                                            blurRadius: 8,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            if (!_isCapturing && _editMode == EditMode.text && _showEditorMarkers)
                                              Positioned(
                                                right: -30,
                                                top: 0,
                                                bottom: 0,
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onPanUpdate: (details) {
                                                    _dragAccumulator += details.delta.dx;
                                                    if (_dragAccumulator.abs() > 4) {
                                                      setState(() {
                                                        _maxCharsPerLine += (_dragAccumulator > 0 ? 1 : -1);
                                                        _maxCharsPerLine = _maxCharsPerLine.clamp(15, 80);
                                                      });
                                                      _dragAccumulator = 0;
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 60,
                                                    height: double.infinity,
                                                    color: Colors.transparent,
                                                    child: Center(
                                                      child: Container(
                                                        width: 6,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: AppColors.cinemaAccent,
                                                          borderRadius: BorderRadius.circular(3),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black45,
                                                              blurRadius: 4,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Logo / App branding on the final image
                          Positioned(
                            bottom: _aspectRatio == ShareAspectRatio.landscape
                                ? 12
                                : 24,
                            left: 0,
                            right: 0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                              padding: EdgeInsets.only(
                                bottom:
                                    _aspectRatio == ShareAspectRatio.landscape
                                    ? 0
                                    : 0,
                              ),
                              child: Column(
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          _aspectRatio ==
                                              ShareAspectRatio.landscape
                                          ? 10
                                          : 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing:
                                          _aspectRatio ==
                                              ShareAspectRatio.landscape
                                          ? 2
                                          : 3,
                                    ),
                                    child: Text(
                                      widget.details.title.toUpperCase(),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                    height:
                                        _aspectRatio ==
                                            ShareAspectRatio.landscape
                                        ? 4
                                        : 8,
                                  ),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize:
                                          _aspectRatio ==
                                              ShareAspectRatio.landscape
                                          ? 8
                                          : 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing:
                                          _aspectRatio ==
                                              ShareAspectRatio.landscape
                                          ? 1.5
                                          : 2,
                                    ),
                                  child: Text(
                                    context.l10n.discoverOnLumi,
                                  ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Guidelines
                          if (_isSnappedX && !_isCapturing)
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  width: 1,
                                  color: AppColors.cinemaAccent.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          if (_isSnappedY && !_isCapturing)
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  height: 1,
                                  color: AppColors.cinemaAccent.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Bottom Bar for Backdrop Selection
          if (!_isCapturing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black, Colors.black.withValues(alpha: 0.0)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_editMode == EditMode.text) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildAlignmentToggle(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        context.l10n.selectAQuote,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: combinedImagesAsync.when(
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            color: AppColors.cinemaAccent,
                          ),
                        ),
                        error: (error, stack) => const SizedBox(),
                        data: (images) {
                          final backdrops = images.backdrops;
                          if (backdrops.isEmpty) {
                            return Center(
                              child: Text(
                                context.l10n.noItemsFound,
                                style: const TextStyle(color: Colors.white54),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            scrollDirection: Axis.horizontal,
                            itemCount: backdrops.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final backdropUrl = backdrops[index];
                              final isSelected =
                                  _selectedBackdrop == backdropUrl;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedBackdrop = backdropUrl;
                                  });
                                },
                                child: Container(
                                  width: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.cinemaAccent
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl: backdropUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top Toggles
          if (!_isCapturing)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Aspect Ratio Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleButton(
                          icon: Icons.crop_portrait_rounded,
                          label: context.l10n.aspect9x16,
                          isSelected: _aspectRatio == ShareAspectRatio.portrait,
                          onTap: () => setState(() {
                            _aspectRatio = ShareAspectRatio.portrait;
                            _bgAlignmentX = 0.0;
                          }),
                        ),
                        _buildToggleButton(
                          icon: Icons.crop_landscape_rounded,
                          label: context.l10n.aspect16x9,
                          isSelected:
                              _aspectRatio == ShareAspectRatio.landscape,
                          onTap: () => setState(() {
                            _aspectRatio = ShareAspectRatio.landscape;
                            _bgAlignmentX = 0.0;
                            _editMode =
                                EditMode.text; // Force text mode for landscape
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Edit Mode Toggle
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _aspectRatio == ShareAspectRatio.portrait
                        ? 1.0
                        : 0.0,
                    child: IgnorePointer(
                      ignoring: _aspectRatio != ShareAspectRatio.portrait,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildToggleButton(
                              icon: Icons.text_fields_rounded,
                              label: context.l10n.overview,
                              isSelected: _editMode == EditMode.text,
                              onTap: () =>
                                  setState(() => _editMode = EditMode.text),
                            ),
                            _buildToggleButton(
                              icon: Icons.wallpaper_rounded,
                              label: context.l10n.background,
                              isSelected: _editMode == EditMode.background,
                              onTap: () => setState(
                                () => _editMode = EditMode.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Guide overlay
          if (!_isCapturing &&
              _quotePosition == Offset.zero &&
              _quoteScale == 1.0)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Column(
                  children: [
                    Icon(Icons.pinch_rounded, color: Colors.white54, size: 48),
                    SizedBox(height: 8),
                    Text(
                      context.l10n.tryAgain,
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

  Widget _buildAlignmentToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAlignmentButton(
            TextAlign.left,
            Icons.format_align_left_rounded,
          ),
          _buildAlignmentButton(
            TextAlign.center,
            Icons.format_align_center_rounded,
          ),
          _buildAlignmentButton(
            TextAlign.right,
            Icons.format_align_right_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentButton(TextAlign alignment, IconData icon) {
    final isSelected = _textAlign == alignment;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _textAlign = alignment);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cinemaAccent : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white70,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cinemaAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                key: ValueKey(isSelected),
                size: 16,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
