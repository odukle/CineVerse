import 'package:cineverse/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ToastUtils {
  static void showToast(BuildContext context, String message, {String? emoji, SnackBarAction? action, Duration duration = const Duration(seconds: 2)}) {
    final effectiveEmoji = emoji ?? _detectEmoji(message);
    
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger == null) return;
    
    scaffoldMessenger.hideCurrentSnackBar();
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        action: action,
        content: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: ((value - 0.8) / 0.2).clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (effectiveEmoji != null) ...[
                Text(effectiveEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.detailsCard.withValues(alpha: 0.95),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.cinemaAccent.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        elevation: 8,
      ),
    );
  }

  static String? _detectEmoji(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('added to favorites') || 
        lower.contains('added to favourites') || 
        lower.contains('marked as favorite')) {
      return '❤️';
    }
    if (lower.contains('removed from favorites') || 
        lower.contains('removed from favourites')) {
      return '💔';
    }
    if (lower.contains('added to watchlist')) {
      return '🔖';
    }
    if (lower.contains('removed from watchlist')) {
      return '➖';
    }
    if (lower.contains('marked as watched') || lower.contains('watched info')) {
      return '🎬';
    }
    if (lower.contains('removed from watched')) {
      return '🔄';
    }
    if (lower.contains('added to')) {
      return '✅';
    }
    if (lower.contains('saved') || lower.contains('updated')) {
      return '💾';
    }
    if (lower.contains('deleted') || lower.contains('removed')) {
      return '🗑️';
    }
    if (lower.contains('error') || lower.contains('failed')) {
      return '❌';
    }
    if (lower.contains('copied')) {
      return '📋';
    }
    return '✨';
  }
}
