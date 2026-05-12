import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/features/search/providers/search_provider.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({required this.isTv, super.key});

  final bool isTv;

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  late MediaFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    final baseFilter = widget.isTv
        ? ref.read(tvFilterProvider)
        : ref.read(movieFilterProvider);
    final globalSort = ref.read(genreSortProvider);
    
    _currentFilter = baseFilter.copyWith(
      sortField: globalSort.sortField,
      sortOrder: globalSort.sortOrder,
    );
  }

  void _applyFilters() {
    // Update global sort first
    ref.read(genreSortProvider.notifier).updateSort(_currentFilter.sortField, _currentFilter.sortOrder);
    
    if (widget.isTv) {
      resetMovieSection(ref, MovieSection.tvDiscover);
      ref.read(tvFilterProvider.notifier).updateFilter(_currentFilter);
    } else {
      resetMovieSection(ref, MovieSection.discover);
      ref.read(movieFilterProvider.notifier).updateFilter(_currentFilter);
    }
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _currentFilter = const MediaFilter();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cinemaBackground,
        title: const Text('Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text('Reset', style: TextStyle(color: AppColors.cinemaAccent)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Sort By'),
            _buildSortDropdowns(),
            const Divider(color: Colors.white24, height: 32),
            
            _buildSectionHeader('Availabilities'),
            _buildAvailabilities(),
            const Divider(color: Colors.white24, height: 32),

            _buildSectionHeader('User Score'),
            _buildUserScoreSlider(),
            _buildIncludeNotRatedToggle(),
            const Divider(color: Colors.white24, height: 32),

            _buildSectionHeader('Release Dates'),
            _buildReleaseTypeChips(),
            const SizedBox(height: 16),
            _buildDatePickers(),
            const Divider(color: Colors.white24, height: 32),

            _buildSectionHeader('Minimum User Votes'),
            _buildMinVotesSlider(),
            const Divider(color: Colors.white24, height: 32),

            _buildSectionHeader('Genres'),
            _buildGenreChips(),
            const Divider(color: Colors.white24, height: 32),

            _buildSectionHeader('People'),
            _buildPeopleFilter(),
            const Divider(color: Colors.white24, height: 32),

            _buildSectionHeader('Runtime (minutes)'),
            _buildRuntimeSlider(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinemaAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSortDropdowns() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SortField>(
                value: _currentFilter.sortField,
                isExpanded: true,
                dropdownColor: AppColors.cinemaSurface,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                items: SortField.values.map((field) {
                  return DropdownMenuItem(
                    value: field,
                    child: Text(field.label, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _currentFilter = _currentFilter.copyWith(sortField: value));
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SortOrder>(
                value: _currentFilter.sortOrder,
                isExpanded: true,
                dropdownColor: AppColors.cinemaSurface,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                items: SortOrder.values.map((order) {
                  return DropdownMenuItem(
                    value: order,
                    child: Text(order.label, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _currentFilter = _currentFilter.copyWith(sortOrder: value));
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilities() {
    final options = {
      'All': '',
      'Free': 'free',
      'Stream': 'flatrate',
      'Rent': 'rent',
      'Ads': 'ads',
      'Buy': 'buy',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((entry) {
        final isSelected = entry.value == '' 
            ? _currentFilter.availabilities.isEmpty 
            : _currentFilter.availabilities.contains(entry.value);
            
        return FilterChip(
          label: Text(entry.key),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (entry.value == '') {
                _currentFilter = _currentFilter.copyWith(availabilities: {});
              } else {
                final newSet = Set<String>.from(_currentFilter.availabilities);
                if (selected) {
                  newSet.add(entry.value);
                } else {
                  newSet.remove(entry.value);
                }
                _currentFilter = _currentFilter.copyWith(availabilities: newSet);
              }
            });
          },
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          selectedColor: AppColors.cinemaAccent.withValues(alpha: 0.4),
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 13),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? AppColors.cinemaAccent : Colors.white10)),
        );
      }).toList(),
    );
  }

  Widget _buildUserScoreSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${(_currentFilter.userScore.start * 10).toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('${(_currentFilter.userScore.end * 10).toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        RangeSlider(
          values: _currentFilter.userScore,
          min: 0,
          max: 10,
          divisions: 100,
          activeColor: Colors.cyan,
          inactiveColor: Colors.white10,
          onChanged: (values) {
            setState(() => _currentFilter = _currentFilter.copyWith(userScore: values));
          },
        ),
      ],
    );
  }

  Widget _buildIncludeNotRatedToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Include Not Rated', style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(width: 8),
        Switch(
          value: _currentFilter.includeNotRated,
          activeThumbColor: Colors.white,
          activeTrackColor: Colors.cyan,
          onChanged: (value) {
            setState(() => _currentFilter = _currentFilter.copyWith(includeNotRated: value));
          },
        ),
      ],
    );
  }

  Widget _buildReleaseTypeChips() {
    if (widget.isTv) return const SizedBox.shrink();

    final options = {
      'All': 0,
      'Theatrical Limited': 1,
      'Theatrical': 3,
      'Premier': 2,
      'Digital': 4,
      'Physical': 5,
      'TV': 6,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((entry) {
        final isSelected = entry.value == 0 
            ? _currentFilter.releaseTypes.isEmpty 
            : _currentFilter.releaseTypes.contains(entry.value);

        return FilterChip(
          label: Text(entry.key),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (entry.value == 0) {
                _currentFilter = _currentFilter.copyWith(releaseTypes: {});
              } else {
                final newSet = Set<int>.from(_currentFilter.releaseTypes);
                if (selected) {
                  newSet.add(entry.value);
                } else {
                  newSet.remove(entry.value);
                }
                _currentFilter = _currentFilter.copyWith(releaseTypes: newSet);
              }
            });
          },
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          selectedColor: AppColors.cinemaAccent.withValues(alpha: 0.4),
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 13),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? AppColors.cinemaAccent : Colors.white10)),
        );
      }).toList(),
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            label: 'From',
            date: _currentFilter.releaseDateFrom,
            onChanged: (date) => setState(() => _currentFilter = _currentFilter.copyWith(releaseDateFrom: date)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDatePicker(
            label: 'To',
            date: _currentFilter.releaseDateTo,
            onChanged: (date) => setState(() => _currentFilter = _currentFilter.copyWith(releaseDateTo: date)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({required String label, DateTime? date, required ValueChanged<DateTime?> onChanged}) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: AppColors.cinemaAccent,
                  onPrimary: Colors.black,
                  surface: AppColors.cinemaSurface,
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? DateFormat('MM/dd/yy').format(date) : '--/--/--',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildMinVotesSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('${_currentFilter.minUserVotes}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: _currentFilter.minUserVotes.toDouble(),
          min: 0,
          max: 500,
          divisions: 50,
          activeColor: Colors.grey,
          inactiveColor: Colors.white10,
          onChanged: (value) {
            setState(() => _currentFilter = _currentFilter.copyWith(minUserVotes: value.toInt()));
          },
        ),
      ],
    );
  }

  Widget _buildGenreChips() {
    final genresAsync = ref.watch(widget.isTv ? tvGenresProvider : movieGenresProvider);
    
    return genresAsync.when(
      data: (genres) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: genres.map((genre) {
          final isSelected = _currentFilter.genres.contains(genre.id);
          return FilterChip(
            label: Text(genre.name),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                final newSet = Set<int>.from(_currentFilter.genres);
                if (selected) {
                  newSet.add(genre.id);
                } else {
                  newSet.remove(genre.id);
                }
                _currentFilter = _currentFilter.copyWith(genres: newSet);
              });
            },
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            selectedColor: AppColors.cinemaAccent.withValues(alpha: 0.4),
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 13),
            checkmarkColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? AppColors.cinemaAccent : Colors.white10)),
          );
        }).toList(),
      ),
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.cinemaAccent)),
      error: (error, stack) => Row(
        children: [
          const Text(
            'Error loading genres',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => ref.invalidate(movieGenresProvider),
            child: Text('Retry', style: TextStyle(color: AppColors.cinemaAccent, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildRuntimeSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_currentFilter.runtime.start.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('${_currentFilter.runtime.end.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        RangeSlider(
          values: _currentFilter.runtime,
          min: 0,
          max: 390,
          divisions: 39,
          activeColor: Colors.cyan,
          inactiveColor: Colors.white10,
          onChanged: (values) {
            setState(() => _currentFilter = _currentFilter.copyWith(runtime: values));
          },
        ),
      ],
    );
  }

  Widget _buildPeopleFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchAnchor(
          builder: (context, controller) {
            return SearchBar(
              controller: controller,
              backgroundColor: WidgetStateProperty.all(
                Colors.white.withValues(alpha: 0.05),
              ),
              hintText: 'Search for a person...',
              hintStyle: WidgetStateProperty.all(
                const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(color: Colors.white, fontSize: 14),
              ),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              leading: const Icon(Icons.person_search_rounded, color: Colors.white70),
            );
          },
          suggestionsBuilder: (context, controller) async {
            final query = controller.text;
            if (query.length < 2) return [];

            final results = await ref.read(searchProvider.notifier).searchPersons(query);

            return results.map((person) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: person.posterPath != null
                      ? CachedNetworkImageProvider(person.posterPath!)
                      : null,
                  backgroundColor: AppColors.cinemaSurface,
                  child: person.posterPath == null
                      ? const Icon(Icons.person, color: Colors.white54)
                      : null,
                ),
                title: Text(
                  person.title,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  person.releaseDate ?? '',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                onTap: () {
                  setState(() {
                    final newIds = Set<int>.from(_currentFilter.personIds);
                    final newNames = Set<String>.from(_currentFilter.personNames);
                    newIds.add(person.id);
                    newNames.add(person.title);
                    _currentFilter = _currentFilter.copyWith(
                      personIds: newIds,
                      personNames: newNames,
                    );
                  });
                  controller.closeView(person.title);
                  controller.clear();
                },
              );
            });
          },
        ),
        if (_currentFilter.personNames.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _currentFilter.personIds.map((id) {
                  final index = _currentFilter.personIds.toList().indexOf(id);
                  final name = _currentFilter.personNames.elementAt(index);
                  return InputChip(
                    label: Text(name),
                    onDeleted: () {
                      setState(() {
                        final newIds = Set<int>.from(_currentFilter.personIds);
                        final newNames = Set<String>.from(_currentFilter.personNames);
                        newIds.remove(id);
                        newNames.remove(name);
                        _currentFilter = _currentFilter.copyWith(
                          personIds: newIds,
                          personNames: newNames,
                        );
                      });
                    },
                    backgroundColor: AppColors.cinemaAccent.withValues(
                      alpha: 0.1,
                    ),
                    deleteIconColor: Colors.white70,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.cinemaAccent),
                    ),
                  );
                }).toList(),
          ),
        ],
      ],
    );
  }
}
