import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'experience_detail_page.dart';
import 'models/experience_feed.dart';
import 'widgets/experience_collage.dart';

class ExperiencesPage extends StatefulWidget {
  const ExperiencesPage({super.key});

  @override
  State<ExperiencesPage> createState() => _ExperiencesPageState();
}

class _ExperiencesPageState extends State<ExperiencesPage> {
  ExperienceSort _sort = ExperienceSort.popular;
  String _tagFilter = 'All';
  String _destinationFilter = 'All';
  int? _maxDays;
  int? _maxBudget;
  final Set<String> _bookmarkedIds = {};

  List<ExperienceFeedItem> get _visible {
    return sortedFilteredExperiences(
      kExperienceFeedItems,
      sort: _sort,
      tagFilter: _tagFilter,
      destinationFilter: _destinationFilter,
      maxDays: _maxDays,
      maxBudget: _maxBudget,
    );
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _FiltersSheet(
          destination: _destinationFilter,
          maxDays: _maxDays,
          maxBudget: _maxBudget,
          onApply: (dest, days, budget) {
            setState(() {
              _destinationFilter = dest;
              _maxDays = days;
              _maxBudget = budget;
            });
            if (context.mounted) Navigator.pop(ctx);
          },
          onClear: () {
            setState(() {
              _destinationFilter = 'All';
              _maxDays = null;
              _maxBudget = null;
            });
            if (context.mounted) Navigator.pop(ctx);
          },
        );
      },
    );
  }

  void _openDetail(String id) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ExperienceDetailPage(experienceId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GHURTEJAI',
                          style: AppText.label.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Experiences', style: AppText.display),
                        const SizedBox(height: 6),
                        Text(
                          'Browse trips shared by travellers',
                          style: AppText.body.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textSub,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildSortRow()),
          SliverToBoxAdapter(child: _buildTagAndFilterRow()),
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No experiences match your filters',
                  style: AppText.body,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final exp = items[i];
                    final bm = _bookmarkedIds.contains(exp.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ExperienceFeedCard(
                        exp: exp,
                        bookmarked: bm,
                        onBookmark: () => setState(() {
                          if (bm) {
                            _bookmarkedIds.remove(exp.id);
                          } else {
                            _bookmarkedIds.add(exp.id);
                          }
                        }),
                        onTap: () => _openDetail(exp.id),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortRow() {
    const labels = [
      (ExperienceSort.popular, 'Popular'),
      (ExperienceSort.newest, 'New'),
      (ExperienceSort.cost, 'Cost'),
      (ExperienceSort.duration, 'Duration'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 0, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              _SortChip(
                label: labels[i].$2,
                selected: _sort == labels[i].$1,
                onTap: () => setState(() => _sort = labels[i].$1),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagAndFilterRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Tags',
                  style: AppText.title.copyWith(fontSize: 14),
                ),
              ),
              TextButton.icon(
                onPressed: _openFilters,
                icon: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Filters',
                  style: AppText.body.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
            itemCount: filterTags.length,
            itemBuilder: (ctx, i) {
              final tag = filterTags[i];
              final sel = _tagFilter == tag;
              return GestureDetector(
                onTap: () => setState(() => _tagFilter = tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: AppText.chip.copyWith(
                      color: sel ? AppColors.bg : AppColors.textSub,
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

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppText.chip.copyWith(
            color: selected ? AppColors.primary : AppColors.textSub,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ExperienceFeedCard extends StatelessWidget {
  final ExperienceFeedItem exp;
  final bool bookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  const _ExperienceFeedCard({
    required this.exp,
    required this.bookmarked,
    required this.onBookmark,
    required this.onTap,
  });

  String _fmtCost(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : '$v';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: ExperienceCollageSmall(
                paths: exp.coverImagePaths,
                height: 118,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.title,
                    style: AppText.title.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exp.destinationName,
                    style: AppText.body.copyWith(
                      color: AppColors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${exp.entryCount} entries · ${exp.attractions} attractions · ৳${_fmtCost(exp.costBdt)} · ${exp.days}d',
                    style: AppText.label.copyWith(
                      color: AppColors.textSub,
                      fontSize: 10,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: exp.tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#$t',
                              style: AppText.label.copyWith(
                                color: AppColors.primary,
                                fontSize: 9,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.thumb_up_alt_outlined,
                        size: 16,
                        color: AppColors.textSub,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exp.upvotes}',
                        style: AppText.body.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 15,
                        color: AppColors.textSub,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exp.commentCount}',
                        style: AppText.body.copyWith(fontSize: 12),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onBookmark,
                        child: Icon(
                          bookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          size: 22,
                          color: bookmarked
                              ? AppColors.primary
                              : AppColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final String destination;
  final int? maxDays;
  final int? maxBudget;
  final void Function(String destination, int? maxDays, int? maxBudget)
      onApply;
  final VoidCallback onClear;

  const _FiltersSheet({
    required this.destination,
    required this.maxDays,
    required this.maxBudget,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String _dest;
  double _daysSlider = 7;
  double _budgetSlider = 15000;

  @override
  void initState() {
    super.initState();
    _dest = widget.destination;
    _daysSlider = (widget.maxDays ?? 14).toDouble().clamp(1, 14);
    _budgetSlider = (widget.maxBudget ?? 20000).toDouble().clamp(1000, 20000);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Destination', style: AppText.title.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kExperienceDestinations.length,
              itemBuilder: (ctx, i) {
                final d = kExperienceDestinations[i];
                final sel = _dest == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _dest = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          d,
                          style: AppText.chip.copyWith(
                            color: sel ? AppColors.bg : AppColors.textSub,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _daysSlider >= 14
                ? 'Max days: Any'
                : 'Max days: ${_daysSlider.round()}',
            style: AppText.title.copyWith(fontSize: 14),
          ),
          Slider(
            value: _daysSlider,
            min: 1,
            max: 14,
            divisions: 13,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (v) => setState(() => _daysSlider = v),
          ),
          Text(
            _budgetSlider >= 20000
                ? 'Max budget (BDT): Any'
                : 'Max budget (BDT): ${_budgetSlider.round()}',
            style: AppText.title.copyWith(fontSize: 14),
          ),
          Slider(
            value: _budgetSlider,
            min: 1000,
            max: 20000,
            divisions: 19,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (v) => setState(() => _budgetSlider = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSub,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => widget.onApply(
                    _dest,
                    _daysSlider >= 14 ? null : _daysSlider.round(),
                    _budgetSlider >= 20000 ? null : _budgetSlider.round(),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.bg,
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
