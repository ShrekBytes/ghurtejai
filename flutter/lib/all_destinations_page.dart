import 'package:flutter/material.dart';
import 'gj_colors.dart';
import 'models/app_data.dart';
import 'models/destination.dart';
import 'widgets/gj_cards.dart';
import 'destination_page.dart';

// ─────────────────────────────────────────────────────────
//  ALL DESTINATIONS PAGE
// ─────────────────────────────────────────────────────────
class AllDestinationsPage extends StatefulWidget {
  const AllDestinationsPage({super.key});

  @override
  State<AllDestinationsPage> createState() => _AllDestinationsPageState();
}

class _AllDestinationsPageState extends State<AllDestinationsPage> {
  final _searchCtrl = TextEditingController();
  String _region = 'All';
  String _tag = 'All';
  int? _maxBudget;

  List<DestinationSummary> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return kDestinations.where((d) {
      if (_region != 'All' && d.region != _region) return false;
      if (_tag != 'All' &&
          !d.tags.any((t) => t.toLowerCase() == _tag.toLowerCase())) {
        return false;
      }
      if (_maxBudget != null && d.budgetMin > _maxBudget!) { return false; }
      if (q.isNotEmpty &&
          !d.name.toLowerCase().contains(q) &&
          !d.region.toLowerCase().contains(q)) { return false; }
      return true;
    }).toList();
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: GJ.orange,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: GJ.dark, width: 2),
      ),
      builder: (_) => _DestFilterSheet(
        maxBudget: _maxBudget,
        onApply: (budget) {
          setState(() => _maxBudget = budget);
          Navigator.pop(context);
        },
        onClear: () {
          setState(() => _maxBudget = null);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return Scaffold(
      backgroundColor: GJ.orange,
      body: Column(
        children: [
          GJPageHeader(pageTitle: 'All Destinations', showBack: true),
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: GJSearchBar(
              controller: _searchCtrl,
              hintText: 'Search destinations...',
              onChanged: (_) => setState(() {}),
            ),
          ),
          // ── Region filter chips ──
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: kRegions.length,
              itemBuilder: (_, i) {
                final r = kRegions[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GJChip(
                    label: r,
                    selected: _region == r,
                    onTap: () => setState(() => _region = r),
                    activeColor: GJ.pink,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // ── Tag filter + Filter button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: kFilterTags.length,
                      itemBuilder: (_, i) {
                        final t = kFilterTags[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GJChip(
                            label: t,
                            selected: _tag == t,
                            onTap: () => setState(() => _tag = t),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _openFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _maxBudget != null ? GJ.yellow : GJ.white,
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
                          _maxBudget != null
                              ? '৳${_fmt(_maxBudget!)}'
                              : 'Budget',
                          style: GJText.tiny.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Count label ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Text(
                  '${results.length} destination${results.length == 1 ? '' : 's'} found',
                  style: GJText.tiny.copyWith(
                    color: GJ.dark.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // ── Grid ──
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🗺️',
                            style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No destinations match',
                          style: GJText.label.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final d = results[i];
                      return GJDestinationCard(
                        dest: d,
                        onTap: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DestinationPage(slug: d.slug),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _fmt(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : '$v';
}

// ─────────────────────────────────────────────────────────
//  BUDGET FILTER SHEET
// ─────────────────────────────────────────────────────────
class _DestFilterSheet extends StatefulWidget {
  final int? maxBudget;
  final void Function(int?) onApply;
  final VoidCallback onClear;

  const _DestFilterSheet({
    required this.maxBudget,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_DestFilterSheet> createState() => _DestFilterSheetState();
}

class _DestFilterSheetState extends State<_DestFilterSheet> {
  double _budget = 20000;

  @override
  void initState() {
    super.initState();
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
          Text('Budget Filter', style: GJText.title.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          Text(
            _budget >= 20000
                ? 'Min budget: Any'
                : 'Min budget: ৳${_budget.round()}',
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
