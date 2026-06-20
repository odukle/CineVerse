import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/core/utils/toast_utils.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/shared_named_list.dart';
import 'package:cineverse/presentation/features/watchlist/providers/library_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/shared_named_list_provider.dart';
import 'package:cineverse/presentation/features/watchlist/watchlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SharedListImportScreen extends ConsumerStatefulWidget {
  const SharedListImportScreen({super.key, required this.shareId});

  final String shareId;

  @override
  ConsumerState<SharedListImportScreen> createState() =>
      _SharedListImportScreenState();
}

class _SharedListImportScreenState
    extends ConsumerState<SharedListImportScreen> {
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final sharedListAsync = ref.watch(sharedNamedListProvider(widget.shareId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.importSharedList)),
      body: sharedListAsync.when(
        data: (sharedList) {
          if (sharedList == null) {
            return _InfoState(
              icon: Icons.link_off_rounded,
              title: context.l10n.noSharedTitlesAvailable,
              subtitle: context.l10n.invalidSharedListLink,
            );
          }

          if (sharedList.items.isEmpty) {
            return _InfoState(
              icon: Icons.playlist_remove_rounded,
              title: context.l10n.noSharedTitlesAvailable,
              subtitle: context.l10n.noTitlesAvailableToImport,
            );
          }

          return Column(
            children: <Widget>[
              _SharedListHeader(sharedList: sharedList),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: sharedList.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = sharedList.items[index];
                    return _SharedListItemTile(item: item);
                  },
                ),
              ),
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: FilledButton.icon(
                  onPressed: _isImporting
                      ? null
                      : () => _importList(sharedList),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.cinemaAccent,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  icon: _isImporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(
                    _isImporting
                        ? context.l10n.importing
                        : context.l10n.importSharedList,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _InfoState(
          icon: Icons.error_outline_rounded,
          title: context.l10n.couldNotLoadSharedList,
          subtitle: context.l10n.couldNotLoadContent('$error'),
        ),
      ),
    );
  }

  Future<void> _importList(SharedNamedList sharedList) async {
    setState(() => _isImporting = true);
    try {
      final importedName = await ref
          .read(namedListsProvider.notifier)
          .importSharedList(sharedList);
      if (!mounted) {
        return;
      }
      ToastUtils.showToast(context, context.l10n.importedInto(importedName));
      context.goNamed(
        AppRoute.watchlist.name,
        queryParameters: {'openSection': LibrarySection.lists.slug},
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ToastUtils.showToast(context, context.l10n.couldNotImportList);
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }
}

class _SharedListHeader extends StatelessWidget {
  const _SharedListHeader({required this.sharedList});

  final SharedNamedList sharedList;

  @override
  Widget build(BuildContext context) {
    final createdAt = sharedList.createdAt;
    final createdLabel = createdAt == null
        ? null
        : DateFormat.yMMMd().format(createdAt);
    final metadata = <String>[
      if ((sharedList.ownerDisplayName ?? '').isNotEmpty)
        'Shared by ${sharedList.ownerDisplayName}',
      ...?createdLabel == null ? null : <String>[createdLabel],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.detailsCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cinemaAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${sharedList.items.length} ${sharedList.items.length == 1 ? "title" : "titles"}',
                style: TextStyle(
                  color: AppColors.cinemaAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              sharedList.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (metadata.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                metadata.join(' • '),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SharedListItemTile extends StatelessWidget {
  const _SharedListItemTile({required this.item});

  final SharedNamedListItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 52,
            height: 72,
            child: item.posterPath == null || item.posterPath!.isEmpty
                ? Container(
                    color: Colors.white.withValues(alpha: 0.06),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.movie_creation_outlined,
                      color: Colors.white38,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl:
                        'https://image.tmdb.org/t/p/w185${item.posterPath}',
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          _subtitle(context),
          style: const TextStyle(color: Colors.white60),
        ),
      ),
    );
  }

  String _subtitle(BuildContext context) {
    final parts = <String>[
      item.mediaType == GlobalMediaType.tv
          ? context.l10n.tvShow
          : context.l10n.movie,
      if ((item.releaseDate ?? '').isNotEmpty) item.releaseDate!,
      if (item.voteAverage != null && item.voteAverage! > 0)
        item.voteAverage!.toStringAsFixed(1),
    ];
    return parts.join(' • ');
  }
}

class _InfoState extends StatelessWidget {
  const _InfoState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 52, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
