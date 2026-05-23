import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:go_router/go_router.dart';

class FullCastCrewScreen extends StatefulWidget {
  const FullCastCrewScreen({
    super.key,
    required this.title,
    required this.cast,
    required this.crew,
  });

  final String title;
  final List<MovieCredit> cast;
  final List<MovieCredit> crew;

  @override
  State<FullCastCrewScreen> createState() => _FullCastCrewScreenState();
}

class _FullCastCrewScreenState extends State<FullCastCrewScreen> {
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MovieCredit> _filterCredits(List<MovieCredit> credits) {
    if (_searchQuery.isEmpty) return credits;
    final query = _searchQuery.toLowerCase();
    return credits
        .where(
          (c) =>
              c.name.toLowerCase().contains(query) ||
              (c.characterName?.toLowerCase().contains(query) ?? false) ||
              c.role.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCast = _filterCredits(widget.cast);
    final filteredCrew = _filterCredits(widget.crew);

    return BackgroundGradient(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () {
                HapticFeedback.selectionClick();
                context.pop();
              },
            ),
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search name or role...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cast & Crew',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close_rounded : Icons.search_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchController.clear();
                    } else {
                      _isSearching = true;
                    }
                  });
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(74),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: AppColors.cinemaPanelGradient,
                    ),
                    border: Border.all(
                      color: AppColors.cinemaBorder.withValues(alpha: 0.28),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.cinemaGlow.withValues(alpha: 0.12),
                        blurRadius: 22,
                        spreadRadius: -12,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: TabBar(
                    onTap: (_) => HapticFeedback.selectionClick(),
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: BoxDecoration(
                      color: AppColors.cinemaAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.cinemaAccent.withValues(alpha: 0.4),
                      ),
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 0,
                    ),
                    splashBorderRadius: BorderRadius.circular(999),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                    tabs: const <Tab>[
                      Tab(
                        child: SizedBox(
                          height: 28,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Cast',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox(
                          height: 28,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Crew',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
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
          body: TabBarView(
            children: [
              _CreditGrid(
                credits: filteredCast,
                isCast: true,
                query: _searchQuery,
              ),
              _CreditGrid(
                credits: filteredCrew,
                isCast: false,
                query: _searchQuery,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditGrid extends StatelessWidget {
  const _CreditGrid({
    required this.credits,
    required this.isCast,
    required this.query,
  });

  final List<MovieCredit> credits;
  final bool isCast;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (credits.isEmpty) {
      return Center(
        child: Text(
          query.isEmpty
              ? 'No information available.'
              : 'No results for "$query"',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        mainAxisExtent: 220,
      ),
      itemCount: credits.length,
      itemBuilder: (context, index) {
        final credit = credits[index];
        return MediaPosterGridCard(
          movie: MediaTitle(
            id: credit.id,
            title: credit.name,
            posterPath: credit.imageUrl,
            releaseDate: isCast ? credit.characterName : credit.role,
            mediaType: GlobalMediaType.person,
          ),
          sectionTitle: isCast ? 'Cast' : 'Crew',
          width: 100,
        );
      },
    );
  }
}
