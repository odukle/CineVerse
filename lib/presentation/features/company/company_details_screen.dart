import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/company_details.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/keyword/keyword_titles_screen.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetailsState {
  const CompanyDetailsState({
    this.company,
    this.results = const [],
    this.isCompanyLoading = false,
    this.isProductionsLoading = false,
    this.isLoadingMore = false,
    this.page = 1,
    this.hasMore = true,
    this.selectedType = KeywordMediaType.all,
    this.selectedSort = SortField.popularity,
    this.hasCompanyError = false,
    this.productionsError,
  });

  final CompanyDetails? company;
  final List<MediaTitle> results;
  final bool isCompanyLoading;
  final bool isProductionsLoading;
  final bool isLoadingMore;
  final int page;
  final bool hasMore;
  final KeywordMediaType selectedType;
  final SortField selectedSort;
  final bool hasCompanyError;
  final String? productionsError;

  CompanyDetailsState copyWith({
    CompanyDetails? company,
    List<MediaTitle>? results,
    bool? isCompanyLoading,
    bool? isProductionsLoading,
    bool? isLoadingMore,
    int? page,
    bool? hasMore,
    KeywordMediaType? selectedType,
    SortField? selectedSort,
    bool? hasCompanyError,
    String? productionsError,
  }) {
    return CompanyDetailsState(
      company: company ?? this.company,
      results: results ?? this.results,
      isCompanyLoading: isCompanyLoading ?? this.isCompanyLoading,
      isProductionsLoading: isProductionsLoading ?? this.isProductionsLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      selectedType: selectedType ?? this.selectedType,
      selectedSort: selectedSort ?? this.selectedSort,
      hasCompanyError: hasCompanyError ?? this.hasCompanyError,
      productionsError: productionsError,
    );
  }
}

class CompanyDetailsNotifier extends Notifier<CompanyDetailsState> {
  CompanyDetailsNotifier(this.companyId);
  final int companyId;

  @override
  CompanyDetailsState build() {
    Future.microtask(() {
      fetchCompanyInfo();
      loadInitialProductions();
    });
    return const CompanyDetailsState();
  }

  Future<void> fetchCompanyInfo() async {
    state = state.copyWith(isCompanyLoading: true, hasCompanyError: false);
    try {
      final repo = ref.read(mediaRepositoryProvider);
      final details = await repo.fetchCompanyDetails(companyId);
      state = state.copyWith(company: details, isCompanyLoading: false);
    } catch (e) {
      state = state.copyWith(
        isCompanyLoading: false,
        hasCompanyError: true,
      );
    }
  }

  Future<void> loadInitialProductions() async {
    state = state.copyWith(
      isProductionsLoading: true,
      productionsError: null,
      page: 1,
      results: const [],
      hasMore: true,
    );
    await _fetchProductions(1);
  }

  Future<void> _fetchProductions(int page) async {
    final repo = ref.read(mediaRepositoryProvider);
    final filter = MediaFilter(
      sortField: state.selectedSort,
      sortOrder: SortOrder.descending,
    );

    try {
      List<MediaTitle> fetchedResults = [];
      bool hasMoreResults = false;

      if (state.selectedType == KeywordMediaType.movies) {
        final movies = await repo.discoverMedia(
          isTv: false,
          filter: filter,
          page: page,
          withCompanies: companyId.toString(),
        );
        fetchedResults = movies;
        hasMoreResults = movies.length >= 20;
      } else if (state.selectedType == KeywordMediaType.tvShows) {
        final tv = await repo.discoverMedia(
          isTv: true,
          filter: filter,
          page: page,
          withCompanies: companyId.toString(),
        );
        fetchedResults = tv;
        hasMoreResults = tv.length >= 20;
      } else {
        // All
        final movies = await repo.discoverMedia(
          isTv: false,
          filter: filter,
          page: page,
          withCompanies: companyId.toString(),
        );
        final tv = await repo.discoverMedia(
          isTv: true,
          filter: filter,
          page: page,
          withCompanies: companyId.toString(),
        );

        final combined = [...movies, ...tv];
        _sortResults(combined, state.selectedSort);
        fetchedResults = combined;
        hasMoreResults = movies.length >= 20 || tv.length >= 20;
      }

      state = state.copyWith(
        results: page == 1
            ? fetchedResults
            : [...state.results, ...fetchedResults],
        page: page,
        isProductionsLoading: false,
        isLoadingMore: false,
        hasMore: hasMoreResults,
      );
    } catch (e) {
      state = state.copyWith(
        isProductionsLoading: false,
        isLoadingMore: false,
        productionsError: 'Failed to load productions',
      );
    }
  }

  void _sortResults(List<MediaTitle> list, SortField sortField) {
    list.sort((a, b) {
      int comparison = 0;
      switch (sortField) {
        case SortField.popularity:
          comparison = a.popularity.compareTo(b.popularity);
          break;
        case SortField.voteAverage:
          comparison = (a.voteAverage ?? 0).compareTo(b.voteAverage ?? 0);
          break;
        case SortField.voteCount:
          comparison = a.voteCount.compareTo(b.voteCount);
          break;
        case SortField.releaseDate:
          final dateA = DateTime.tryParse(a.releaseDate ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.releaseDate ?? '') ?? DateTime(0);
          comparison = dateA.compareTo(dateB);
          break;
        default:
          comparison = 0;
      }
      return -comparison;
    });
  }

  Future<void> loadMoreProductions() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    await _fetchProductions(state.page + 1);
  }

  void setMediaType(KeywordMediaType type) {
    if (type == state.selectedType) return;
    state = state.copyWith(selectedType: type);
    loadInitialProductions();
  }

  void setSortField(SortField sortField) {
    if (sortField == state.selectedSort) return;
    state = state.copyWith(selectedSort: sortField);
    loadInitialProductions();
  }
}

final companyDetailsNotifierProvider =
    NotifierProvider.family<CompanyDetailsNotifier, CompanyDetailsState, int>(
      CompanyDetailsNotifier.new,
    );

class CompanyDetailsScreen extends ConsumerStatefulWidget {
  const CompanyDetailsScreen({super.key, required this.companyId});

  final int companyId;

  @override
  ConsumerState<CompanyDetailsScreen> createState() =>
      _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends ConsumerState<CompanyDetailsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref
          .read(companyDetailsNotifierProvider(widget.companyId).notifier)
          .loadMoreProductions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyDetailsNotifierProvider(widget.companyId));

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      appBar: AppBar(
        title: Text(
          state.company?.name ?? context.l10n.productionCompany,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.cinemaGradientTop,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: state.isCompanyLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.cinemaAccent),
              )
            : state.hasCompanyError
            ? _buildErrorScreen(context.l10n.failedToLoadCompanyInfo, isCompany: true)
            : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCompanyHeader(state.company!),
                          const SizedBox(height: 24),
                          _buildProductionsSectionHeader(state),
                        ],
                      ),
                    ),
                  ),
                  _buildProductionsContent(state),
                ],
              ),
      ),
    );
  }

  Widget _buildCompanyHeader(CompanyDetails company) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.detailsCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company logo box
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cinemaGlow.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: company.logoPath != null
                ? CachedNetworkImage(
                    imageUrl: company.logoPath!,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.business_rounded,
                      color: Colors.black45,
                      size: 32,
                    ),
                  )
                : const Icon(
                    Icons.business_rounded,
                    color: Colors.black45,
                    size: 32,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (company.headquarters != null &&
                    company.headquarters!.isNotEmpty) ...[
                  _buildHeaderDetailRow(
                    Icons.location_on_rounded,
                    company.headquarters!,
                  ),
                  const SizedBox(height: 4),
                ],
                if (company.parentCompany != null &&
                    company.parentCompany!.isNotEmpty) ...[
                  _buildHeaderDetailRow(
                    Icons.corporate_fare_rounded,
                    'Parent: ${company.parentCompany!}',
                  ),
                  const SizedBox(height: 4),
                ],
                if (company.originCountry != null &&
                    company.originCountry!.isNotEmpty) ...[
                  _buildHeaderDetailRow(
                    Icons.flag_rounded,
                    'Country: ${company.originCountry!}',
                  ),
                  const SizedBox(height: 4),
                ],
                if (company.homepage != null &&
                    company.homepage!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      final url = Uri.parse(company.homepage!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.cinemaAccent.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.link_rounded,
                            color: AppColors.cinemaAccent,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.l10n.officialSite,
                            style: TextStyle(
                              color: AppColors.cinemaAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProductionsSectionHeader(CompanyDetailsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.productions,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<SortField>(
              icon: const Icon(Icons.sort_rounded, color: Colors.white70),
              onSelected: (sortField) {
                HapticFeedback.selectionClick();
                ref
                    .read(
                      companyDetailsNotifierProvider(widget.companyId).notifier,
                    )
                    .setSortField(sortField);
              },
              itemBuilder: (context) =>
                  [
                        SortField.popularity,
                        SortField.voteAverage,
                        SortField.releaseDate,
                        SortField.voteCount,
                      ]
                      .map(
                        (f) => PopupMenuItem(
                          value: f,
                          child: Row(
                            children: [
                              if (state.selectedSort == f)
                                Icon(
                                  Icons.check_rounded,
                                  color: AppColors.cinemaAccent,
                                  size: 18,
                                )
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 8),
                              Text(
                                f.label,
                                style: TextStyle(
                                  color: state.selectedSort == f
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: state.selectedSort == f
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Choice chips for filtering media types
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: KeywordMediaType.values.length,
            itemBuilder: (context, index) {
              final type = KeywordMediaType.values[index];
              final isSelected = state.selectedType == type;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type.label(context)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      ref
                          .read(
                            companyDetailsNotifierProvider(
                              widget.companyId,
                            ).notifier,
                          )
                          .setMediaType(type);
                    }
                  },
                  backgroundColor: AppColors.cinemaSurface.withValues(
                    alpha: 0.5,
                  ),
                  selectedColor: AppColors.cinemaAccent,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.black
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductionsContent(CompanyDetailsState state) {
    if (state.isProductionsLoading && state.results.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.productionsError != null && state.results.isEmpty) {
      return SliverFillRemaining(
        child: _buildErrorScreen(state.productionsError!, isCompany: false),
      );
    }

    final results = state.results;

    if (results.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            context.l10n.noProductionsFound,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    const double crossAxisSpacing = 12;
    const double mainAxisSpacing = 16;
    const int crossAxisCount = 3;
    final double cardWidth =
        (MediaQuery.sizeOf(context).width - (16 * 2) - (crossAxisSpacing * 2)) /
        crossAxisCount;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: 0.55,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final media = results[index];
              return MediaPosterGridCard(
                movie: media,
                sectionTitle: 'company_${widget.companyId}',
                width: cardWidth,
                isTvTitle: media.mediaType == GlobalMediaType.tv,
              );
            }, childCount: results.length),
          ),
          if (state.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.cinemaAccent,
                  ),
                ),
              ),
            )
          else if (state.hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      ref
                          .read(
                            companyDetailsNotifierProvider(
                              widget.companyId,
                            ).notifier,
                          )
                          .loadMoreProductions();
                    },
                    child: Text(
                      context.l10n.loadMore,
                      style: TextStyle(color: AppColors.cinemaAccent),
                    ),
                  ),
                ),
              ),
            )
          else if (results.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    context.l10n.noMoreProductionsFound,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String message, {required bool isCompany}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white30,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (isCompany) {
                  ref
                      .read(
                        companyDetailsNotifierProvider(
                          widget.companyId,
                        ).notifier,
                      )
                      .fetchCompanyInfo();
                } else {
                  ref
                      .read(
                        companyDetailsNotifierProvider(
                          widget.companyId,
                        ).notifier,
                      )
                      .loadInitialProductions();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinemaAccent,
              ),
              child: Text(context.l10n.retry, style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
