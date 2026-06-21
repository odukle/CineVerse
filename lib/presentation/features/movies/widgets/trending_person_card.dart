import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class TrendingPersonCard extends StatefulWidget {
  const TrendingPersonCard({
    required this.person,
    required this.accent,
    required this.width,
    super.key,
  });

  final MediaTitle person;
  final Color accent;
  final double width;

  @override
  State<TrendingPersonCard> createState() => _TrendingPersonCardState();
}

class _TrendingPersonCardState extends State<TrendingPersonCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String heroTag = 'person_${widget.person.id}_explore';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        context.pushNamed(
          AppRoute.personDetails.name,
          pathParameters: <String, String>{
            'personId': widget.person.id.toString(),
          },
          queryParameters: <String, String>{'heroTag': heroTag},
        );
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular avatar with border/glow
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow background
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.accent.withValues(alpha: 0.15),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Border container
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.accent.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Hero(
                        tag: heroTag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(43),
                          child: widget.person.posterPath != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.person.posterPath!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Name text
              Text(
                widget.person.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              // Department text
              if (widget.person.subtitle != null)
                Text(
                  widget.person.subtitle!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.05),
      child: Icon(
        Icons.person_rounded,
        size: 40,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }
}
