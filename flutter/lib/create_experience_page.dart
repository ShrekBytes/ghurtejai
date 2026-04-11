import 'package:flutter/material.dart';
import 'gj_colors.dart';
import 'models/app_data.dart';
import 'models/destination.dart';

// ─────────────────────────────────────────────────────────
//  LOCAL DATA MODELS  (draft state for the builder)
// ─────────────────────────────────────────────────────────
class _DraftEntry {
  String title;
  String notes;
  String type; // PLACE | FOOD | ACTIVITY | CUSTOM
  String timeStart;
  int costBdt;

  _DraftEntry({
    this.title = '',
    this.notes = '',
    this.type = 'CUSTOM',
    this.timeStart = '',
    this.costBdt = 0,
  });
}

class _DraftDay {
  final List<_DraftEntry> entries;
  _DraftDay() : entries = [];
}

// ─────────────────────────────────────────────────────────
//  CREATE EXPERIENCE PAGE
// ─────────────────────────────────────────────────────────
class CreateExperiencePage extends StatefulWidget {
  final String? preselectedSlug;
  const CreateExperiencePage({super.key, this.preselectedSlug});

  @override
  State<CreateExperiencePage> createState() => _CreateExperiencePageState();
}

class _CreateExperiencePageState extends State<CreateExperiencePage> {
  final _titleCtrl = TextEditingController();
  String? _selectedSlug;
  bool _isPublic = false;
  bool _autoCollage = true;
  int _selectedDay = 0;
  final List<_DraftDay> _days = [_DraftDay()];

  @override
  void initState() {
    super.initState();
    _selectedSlug = widget.preselectedSlug;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  int get _estimatedCost {
    int total = 0;
    for (final day in _days) {
      for (final entry in day.entries) {
        if (entry.costBdt > 0) total += entry.costBdt;
      }
    }
    return total;
  }

  void _addDay() {
    setState(() {
      _days.add(_DraftDay());
      _selectedDay = _days.length - 1;
    });
  }

  void _showAddEntry() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GJ.pink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: GJ.dark, width: 2),
      ),
      builder: (_) => _AddEntrySheet(
        slug: _selectedSlug,
        onAdd: (entry) {
          setState(() => _days[_selectedDay].entries.add(entry));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removeEntry(int dayIdx, int entryIdx) {
    setState(() => _days[dayIdx].entries.removeAt(entryIdx));
  }

  void _submit({required bool share}) {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title', style: GJText.label),
          backgroundColor: GJ.pink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: GJ.dark, width: 2),
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          share
              ? '🚀 Experience submitted for review!'
              : '💾 Draft saved!',
          style: GJText.label,
        ),
        backgroundColor: GJ.yellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: GJ.dark, width: 2),
        ),
      ),
    );
    if (share) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = _days[_selectedDay];

    return Scaffold(
      backgroundColor: GJ.pink,
      body: Column(
        children: [
          GJPageHeader(pageTitle: 'Create Experience', showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Step 1: Basics ──
                  _sectionHeader('1 · Basics', GJ.yellow),
                  const SizedBox(height: 12),
                  // Title input
                  Container(
                    decoration: BoxDecoration(
                      color: GJ.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GJ.dark, width: 2),
                      boxShadow: const [
                        BoxShadow(offset: Offset(3, 3), color: GJ.dark),
                      ],
                    ),
                    child: TextField(
                      controller: _titleCtrl,
                      style: GJText.label.copyWith(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Experience title...',
                        hintStyle: GJText.body.copyWith(
                          color: GJ.dark.withValues(alpha: 0.35),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        filled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Destination selector
                  GestureDetector(
                    onTap: () => _showDestinationPicker(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: GJ.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GJ.dark, width: 2),
                        boxShadow: const [
                          BoxShadow(offset: Offset(3, 3), color: GJ.dark),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: GJ.dark, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedSlug != null
                                  ? (destinationBySlug(_selectedSlug!)?.name ??
                                      'Select destination')
                                  : 'Select destination',
                              style: _selectedSlug != null
                                  ? GJText.label.copyWith(fontSize: 14)
                                  : GJText.body.copyWith(
                                      color:
                                          GJ.dark.withValues(alpha: 0.35)),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: GJ.dark, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Visibility toggle
                  GJCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.visibility_outlined,
                            color: GJ.dark, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isPublic ? 'Public' : 'Private',
                                style: GJText.label.copyWith(fontSize: 13),
                              ),
                              Text(
                                _isPublic
                                    ? 'Will be submitted for moderation review'
                                    : 'Only visible to you',
                                style: GJText.tiny.copyWith(
                                  fontSize: 10,
                                  color: GJ.dark.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isPublic = !_isPublic),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            height: 26,
                            decoration: BoxDecoration(
                              color: _isPublic ? GJ.green : GJ.dark.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: GJ.dark, width: 2),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: _isPublic
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.all(1),
                                decoration: const BoxDecoration(
                                  color: GJ.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Step 2: Cover ──
                  _sectionHeader('2 · Cover Photo', GJ.blue),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _autoCollage = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            decoration: BoxDecoration(
                              color: _autoCollage ? GJ.blue : GJ.white,
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(10)),
                              border: Border.all(color: GJ.dark, width: 2),
                              boxShadow: _autoCollage
                                  ? const [
                                      BoxShadow(
                                          offset: Offset(2, 2),
                                          color: GJ.dark)
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '🎞 Auto Collage',
                                style: GJText.tiny.copyWith(fontSize: 11),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _autoCollage = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            decoration: BoxDecoration(
                              color: !_autoCollage ? GJ.blue : GJ.white,
                              borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(10)),
                              border: Border.all(color: GJ.dark, width: 2),
                              boxShadow: !_autoCollage
                                  ? const [
                                      BoxShadow(
                                          offset: Offset(2, 2),
                                          color: GJ.dark)
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '📷 Upload Photo',
                                style: GJText.tiny.copyWith(fontSize: 11),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Step 3: Day Builder ──
                  _sectionHeader('3 · Day-by-Day Itinerary', GJ.pink),
                  const SizedBox(height: 12),

                  // Day tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < _days.length; i++) ...[
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDay = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedDay == i
                                    ? GJ.pink
                                    : GJ.white,
                                borderRadius: BorderRadius.circular(30),
                                border:
                                    Border.all(color: GJ.dark, width: 2),
                                boxShadow: _selectedDay == i
                                    ? const [
                                        BoxShadow(
                                            offset: Offset(2, 2),
                                            color: GJ.dark)
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'Day ${i + 1}',
                                style: GJText.tiny.copyWith(
                                  fontSize: 11,
                                  color: GJ.dark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Add day button
                        GestureDetector(
                          onTap: _addDay,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: GJ.dark,
                              borderRadius: BorderRadius.circular(30),
                              border:
                                  Border.all(color: GJ.dark, width: 2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_rounded,
                                    color: GJ.yellow, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Add Day',
                                  style: GJText.tiny.copyWith(
                                      color: GJ.yellow, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Entries for selected day
                  if (currentDay.entries.isEmpty)
                    GJCard(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            const Text('🗺️',
                                style: TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(
                              'No entries for Day ${_selectedDay + 1} yet',
                              style: GJText.label.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "Add Entry" to start building',
                              style: GJText.tiny.copyWith(
                                color: GJ.dark.withValues(alpha: 0.5),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    for (int i = 0;
                        i < currentDay.entries.length;
                        i++) ...[
                      _EntryTile(
                        entry: currentDay.entries[i],
                        index: i,
                        onRemove: () => _removeEntry(_selectedDay, i),
                      ),
                      const SizedBox(height: 8),
                    ],

                  const SizedBox(height: 10),
                  // Add entry button
                  GJButton(
                    label: '✚  Add Entry to Day ${_selectedDay + 1}',
                    color: GJ.white,
                    onTap: _showAddEntry,
                  ),
                  const SizedBox(height: 20),

                  // ── Cost Summary ──
                  _sectionHeader('4 · Cost Summary', GJ.green),
                  const SizedBox(height: 12),
                  GJCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Per person estimate',
                                    style: GJText.tiny.copyWith(
                                      color:
                                          GJ.dark.withValues(alpha: 0.55),
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    _estimatedCost > 0
                                        ? '৳${_fmt(_estimatedCost)}'
                                        : 'N/A',
                                    style: GJText.title
                                        .copyWith(fontSize: 22),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: GJ.green,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: GJ.dark, width: 1.5),
                              ),
                              child: Text(
                                'Auto-calculated',
                                style: GJText.tiny.copyWith(fontSize: 9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: GJ.dark.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Your actual cost (optional)',
                                style: GJText.tiny.copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: GJ.offWhite,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: GJ.dark, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                child: Text('৳',
                                    style: GJText.label
                                        .copyWith(fontSize: 16)),
                              ),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  style: GJText.label
                                      .copyWith(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. 4500',
                                    hintStyle: GJText.body.copyWith(
                                      color: GJ.dark
                                          .withValues(alpha: 0.3),
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 12),
                                    filled: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Submit Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: GJGhostButton(
                          label: '💾 Save Draft',
                          onTap: () => _submit(share: false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GJButton(
                          label: '🚀 Share Experience',
                          color: GJ.yellow,
                          onTap: () => _submit(share: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDestinationPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: GJ.pink,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: GJ.dark, width: 2),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
            Text('Select Destination',
                style: GJText.title.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            ...kDestinations.map((d) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedSlug = d.slug);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedSlug == d.slug
                          ? GJ.yellow.withValues(alpha: 0.3)
                          : GJ.offWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedSlug == d.slug
                            ? GJ.dark
                            : GJ.dark.withValues(alpha: 0.2),
                        width: _selectedSlug == d.slug ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(d.emoji,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(d.name,
                                style:
                                    GJText.label.copyWith(fontSize: 13))),
                        Text(d.region,
                            style: GJText.tiny.copyWith(
                              color: GJ.dark.withValues(alpha: 0.5),
                              fontSize: 10,
                            )),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: color),
        const SizedBox(width: 10),
        Text(title, style: GJText.label.copyWith(fontSize: 14)),
      ],
    );
  }

  String _fmt(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : '$v';
}

// ─────────────────────────────────────────────────────────
//  ENTRY TILE (in the day builder)
// ─────────────────────────────────────────────────────────
class _EntryTile extends StatelessWidget {
  final _DraftEntry entry;
  final int index;
  final VoidCallback onRemove;

  const _EntryTile({
    required this.entry,
    required this.index,
    required this.onRemove,
  });

  static const _typeColors = {
    'PLACE': GJ.blue,
    'FOOD': GJ.pink,
    'ACTIVITY': GJ.green,
    'CUSTOM': GJ.yellow,
  };

  @override
  Widget build(BuildContext context) {
    final accent = _typeColors[entry.type] ?? GJ.yellow;
    return GJCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              border: Border.all(color: GJ.dark, width: 1.5),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GJText.tiny.copyWith(fontSize: 11),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title.isEmpty
                      ? 'Untitled Entry'
                      : entry.title,
                  style: GJText.label.copyWith(fontSize: 12),
                ),
                if (entry.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.notes,
                    style: GJText.tiny.copyWith(
                      color: GJ.dark.withValues(alpha: 0.5),
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (entry.costBdt > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: GJ.green,
                          borderRadius: BorderRadius.circular(4),
                          border:
                              Border.all(color: GJ.dark, width: 1),
                        ),
                        child: Text(
                          '৳${entry.costBdt}',
                          style: GJText.tiny.copyWith(fontSize: 9),
                        ),
                      ),
                    if (entry.timeStart.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: GJ.blue,
                          borderRadius: BorderRadius.circular(4),
                          border:
                              Border.all(color: GJ.dark, width: 1),
                        ),
                        child: Text(
                          entry.timeStart,
                          style: GJText.tiny.copyWith(fontSize: 9),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: GJ.pink.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: GJ.dark.withValues(alpha: 0.3), width: 1),
              ),
              child: Icon(Icons.close_rounded,
                  size: 13,
                  color: GJ.dark.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  ADD ENTRY BOTTOM SHEET
// ─────────────────────────────────────────────────────────
class _AddEntrySheet extends StatefulWidget {
  final String? slug;
  final ValueChanged<_DraftEntry> onAdd;

  const _AddEntrySheet({this.slug, required this.onAdd});

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  AttractionItem? _selectedAttraction;

  // Custom entry fields
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  String _customType = 'CUSTOM';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _costCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  List<AttractionItem> get _attractions =>
      kAttractionsBySlug[widget.slug] ?? [];

  void _addFromAttraction() {
    if (_selectedAttraction == null) return;
    final a = _selectedAttraction!;
    widget.onAdd(_DraftEntry(
      title: a.name,
      notes: a.notes,
      type: a.type,
      costBdt: _parseCost(a.priceRange),
    ));
  }

  void _addCustom() {
    if (_nameCtrl.text.trim().isEmpty) return;
    widget.onAdd(_DraftEntry(
      title: _nameCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      type: _customType,
      costBdt: int.tryParse(_costCtrl.text.trim()) ?? 0,
      timeStart: _timeCtrl.text.trim(),
    ));
  }

  int _parseCost(String range) {
    // crude: grab first number in the string
    final match = RegExp(r'\d+').firstMatch(range.replaceAll(',', ''));
    return int.tryParse(match?.group(0) ?? '0') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: GJ.offWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GJ.dark, width: 2),
              ),
              child: TabBar(
                controller: _tab,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: GJ.yellow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GJ.dark, width: 1.5),
                ),
                labelStyle: GJText.tiny.copyWith(fontSize: 11),
                unselectedLabelStyle:
                    GJText.tiny.copyWith(fontSize: 11),
                labelColor: GJ.dark,
                unselectedLabelColor: GJ.dark.withValues(alpha: 0.5),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '🔍 Search Attractions'),
                  Tab(text: '✏️ Custom Entry'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tab content
          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tab,
              children: [
                // Search attractions tab
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      Expanded(
                        child: _attractions.isEmpty
                            ? Center(
                                child: Text(
                                  widget.slug == null
                                      ? 'Select a destination first'
                                      : 'No attractions data yet',
                                  style: GJText.body
                                      .copyWith(fontSize: 12),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _attractions.length,
                                itemBuilder: (_, i) {
                                  final a = _attractions[i];
                                  final sel = _selectedAttraction == a;
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedAttraction = a),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 150),
                                      margin: const EdgeInsets.only(
                                          bottom: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: sel
                                            ? GJ.yellow
                                                .withValues(alpha: 0.3)
                                            : GJ.offWhite,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: sel
                                              ? GJ.dark
                                              : GJ.dark.withValues(
                                                  alpha: 0.2),
                                          width: sel ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(a.emoji,
                                              style: const TextStyle(
                                                  fontSize: 22)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(a.name,
                                                    style:
                                                        GJText.label.copyWith(
                                                            fontSize:
                                                                12)),
                                                Text(a.notes,
                                                    style:
                                                        GJText.tiny.copyWith(
                                                      color: GJ.dark
                                                          .withValues(
                                                              alpha:
                                                                  0.5),
                                                      fontSize: 9,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow
                                                        .ellipsis),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: a.color,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: GJ.dark,
                                                  width: 1),
                                            ),
                                            child: Text(
                                              a.type,
                                              style: GJText.tiny
                                                  .copyWith(fontSize: 8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 8),
                      GJButton(
                        label: _selectedAttraction == null
                            ? 'Select an attraction above'
                            : 'Add ${_selectedAttraction!.name} →',
                        color: _selectedAttraction != null
                            ? GJ.yellow
                            : GJ.white,
                        onTap: _addFromAttraction,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Custom entry tab
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _miniField(_nameCtrl, 'Entry name *', Icons.label_outline_rounded),
                      const SizedBox(height: 8),
                      _miniField(_notesCtrl, 'Notes', Icons.notes_rounded),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _miniField(_costCtrl, 'Cost (৳)',
                                Icons.payments_outlined,
                                inputType: TextInputType.number),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _miniField(_timeCtrl, 'Time (e.g. 9am)',
                                Icons.schedule_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Type selector
                      Row(
                        children: [
                          for (final t in ['PLACE', 'FOOD', 'ACTIVITY', 'CUSTOM'])
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _customType = t),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _customType == t ? GJ.yellow : GJ.offWhite,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: GJ.dark, width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(t,
                                      style: GJText.tiny.copyWith(fontSize: 8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GJButton(
                        label: 'Add Entry →',
                        color: GJ.yellow,
                        onTap: _addCustom,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? inputType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: GJ.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GJ.dark, width: 2),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(icon, size: 16, color: GJ.dark),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: inputType,
              style: GJText.body.copyWith(fontSize: 13, color: GJ.dark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GJText.body.copyWith(
                  color: GJ.dark.withValues(alpha: 0.35),
                  fontSize: 12,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
