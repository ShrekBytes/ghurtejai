import 'package:flutter/material.dart';
import 'gj_colors.dart';
import 'models/experience_feed.dart';
import 'models/app_data.dart';
import 'widgets/gj_cards.dart';
import 'experience_detail_page.dart';
import 'notifications_page.dart';

// ─────────────────────────────────────────────────────────
//  EXPERIENCES PAGE
// ─────────────────────────────────────────────────────────
class ExperiencesPage extends StatefulWidget {
  const ExperiencesPage({super.key});

  @override
  State<ExperiencesPage> createState() => _ExperiencesPageState();
}

class _ExperiencesPageState extends State<ExperiencesPage> {
  ExperienceSort _sort = ExperienceSort.popular;
  String _tagFilter = 'All';
  String _destFilter = 'All';
  int? _maxDays;
  int? _maxBudget;
  final Set<String> _bookmarked = {};

  List<ExperienceFeedItem> get _visible => sortedFilteredExperiences(
        kExperienceFeedItems,
        sort: _sort,
        tagFilter: _tagFilter,
        destinationFilter: _destFilter,
        maxDays: _maxDays,
        maxBudget: _maxBudget,
      );

  void _openDetail(String id) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ExperienceDetailPage(experienceId: id)),
    );
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GJ.blue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: GJ.dark, width: 2),
      ),
      builder: (_) => _FiltersSheet(
        dest: _destFilter,
        maxDays: _maxDays,
        maxBudget: _maxBudget,
        onApply: (dest, days, budget) {
          setState(() {
            _destFilter = dest;
            _maxDays = days;
            _maxBudget = budget;
          });
          Navigator.pop(context);
        },
        onClear: () {
          setState(() {
            _destFilter = 'All';
            _maxDays = null;
            _maxBudget = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    return Scaffold(
      backgroundColor: GJ.blue,
      body: Column(
        children: [
          GJPageHeader(
            pageTitle: 'Experiences',
            showBell: true,
            onBell: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Sort chips ──
                SliverToBoxAdapter(child: _buildSortRow()),
                // ── Tag + Filter row ──
                SliverToBoxAdapter(child: _buildTagRow()),
                // ── Feed ──
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No experiences match your filters',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.w700,
                          color: GJ.dark,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final exp = items[i];
                          final bm = _bookmarked.contains(exp.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GJExperienceCard(
                              exp: exp,
                              bookmarked: bm,
                              onBookmark: () => setState(() {
                                if (bm) {
                                  _bookmarked.remove(exp.id);
                                } else {
                                  _bookmarked.add(exp.id);
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
          ),
        ],
      ),
    );
  }

  Widget _buildSortRow() {
    const labels = [
      (ExperienceSort.popular, 'Popular'),
      (ExperienceSort.newest, 'Newest'),
      (ExperienceSort.cost, 'Cost ↑'),
      (ExperienceSort.duration, 'Short'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 0, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final l in labels) ...[
              GJChip(
                label: l.$2,
                selected: _sort == l.$1,
                onTap: () => setState(() => _sort = l.$1),
                activeColor: GJ.yellow,
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Tags',
                  style: GJText.label.copyWith(fontSize: 12),
                ),
              ),
              GestureDetector(
                onTap: _openFilters,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: GJ.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GJ.dark, width: 2),
                    boxShadow: const [
                      BoxShadow(offset: Offset(2, 2), color: GJ.dark),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune_rounded,
                          size: 14, color: GJ.dark),
                      const SizedBox(width: 4),
                      Text(
                        'Filters',
                        style: GJText.tiny.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
            itemCount: kFilterTags.length,
            itemBuilder: (_, i) {
              final tag = kFilterTags[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GJChip(
                  label: tag,
                  selected: _tagFilter == tag,
                  onTap: () => setState(() => _tagFilter = tag),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  FILTERS BOTTOM SHEET
// ─────────────────────────────────────────────────────────
class _FiltersSheet extends StatefulWidget {
  final String dest;
  final int? maxDays;
  final int? maxBudget;
  final void Function(String, int?, int?) onApply;
  final VoidCallback onClear;

  const _FiltersSheet({
    required this.dest,
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
  double _days = 14;
  double _budget = 20000;

  @override
  void initState() {
    super.initState();
    _dest = widget.dest;
    _days = (widget.maxDays ?? 14).toDouble().clamp(1, 14);
    _budget = (widget.maxBudget ?? 20000).toDouble().clamp(1000, 20000);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: GJ.dark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Filter Experiences', style: GJText.title.copyWith(fontSize: 18)),
          const SizedBox(height: 16),

          // Destination filter
          Text('Destination', style: GJText.label.copyWith(fontSize: 12)),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kExperienceDestinations.length,
              itemBuilder: (_, i) {
                final d = kExperienceDestinations[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GJChip(
                    label: d,
                    selected: _dest == d,
                    onTap: () => setState(() => _dest = d),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Max days
          Text(
            _days >= 14 ? 'Max days: Any' : 'Max days: ${_days.round()}',
            style: GJText.label.copyWith(fontSize: 12),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: GJ.dark,
              inactiveTrackColor: GJ.dark.withValues(alpha: 0.15),
              thumbColor: GJ.yellow,
              overlayColor: GJ.yellow.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _days,
              min: 1,
              max: 14,
              divisions: 13,
              onChanged: (v) => setState(() => _days = v),
            ),
          ),

          // Max budget
          Text(
            _budget >= 20000
                ? 'Max budget: Any'
                : 'Max budget: ৳${_budget.round()}',
            style: GJText.label.copyWith(fontSize: 12),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: GJ.dark,
              inactiveTrackColor: GJ.dark.withValues(alpha: 0.15),
              thumbColor: GJ.yellow,
              overlayColor: GJ.yellow.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _budget,
              min: 1000,
              max: 20000,
              divisions: 19,
              onChanged: (v) => setState(() => _budget = v),
            ),
          ),
          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: GJGhostButton(label: 'Clear', onTap: widget.onClear),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GJButton(
                  label: 'Apply →',
                  color: GJ.yellow,
                  onTap: () => widget.onApply(
                    _dest,
                    _days >= 14 ? null : _days.round(),
                    _budget >= 20000 ? null : _budget.round(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
