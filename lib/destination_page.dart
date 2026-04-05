import 'package:flutter/material.dart';
import 'gj_colors.dart';
import 'models/app_data.dart';
import 'models/destination.dart';
import 'widgets/gj_cards.dart';
import 'experience_detail_page.dart';
import 'create_experience_page.dart';
import 'models/experience_feed.dart';

// ─────────────────────────────────────────────────────────
//  DESTINATION DETAIL PAGE
// ─────────────────────────────────────────────────────────
class DestinationPage extends StatefulWidget {
  final String slug;
  const DestinationPage({super.key, required this.slug});

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _bookmarked = false;
  String _transportMode = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dest = destinationBySlug(widget.slug);
    if (dest == null) {
      return Scaffold(
        backgroundColor: GJ.offWhite,
        body: Center(child: Text('Destination not found', style: GJText.label)),
      );
    }

    final places = attractionsBySlug(widget.slug, type: 'PLACE');
    final foods = attractionsBySlug(widget.slug, type: 'FOOD');
    final activities = attractionsBySlug(widget.slug, type: 'ACTIVITY');
    final transport = transportBySlug(widget.slug, mode: _transportMode);

    final destExps = kExperienceFeedItems
        .where((e) =>
            e.destinationName.toLowerCase() == dest.name.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: GJ.offWhite,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero header ──
              SliverToBoxAdapter(child: _buildHero(dest)),

              // ── Quick stats ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: GJCard(
                    child: Row(
                      children: [
                        _statCell('${dest.attractionCount}', 'Places',
                            GJ.blue, true),
                        _statCell('${dest.foodCount}', 'Foods', GJ.pink, false),
                        _statCell('${dest.activityCount}', 'Activities',
                            GJ.green, false),
                        _statCell('${dest.experienceCount}', 'Trips',
                            GJ.yellow, false),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Budget banner ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: GJ.yellow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GJ.dark, width: 2),
                      boxShadow: const [
                        BoxShadow(offset: Offset(3, 3), color: GJ.dark),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Per person estimate',
                                style: GJText.tiny.copyWith(
                                  color: GJ.dark.withValues(alpha: 0.6),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '৳${_fmt(dest.budgetMin)} – ৳${_fmt(dest.budgetMax)}',
                                style:
                                    GJText.label.copyWith(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Wrap(
                          spacing: 4,
                          children: dest.tags
                              .take(2)
                              .map((t) => GJTagPill(tag: t, color: GJ.white))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Description ──
              if (dest.description.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Text(
                      dest.description,
                      style: GJText.body.copyWith(
                        color: GJ.dark.withValues(alpha: 0.65),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

              // ── Top Places ──
              if (places.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: GJSectionLabel(
                      title: 'Top Places', accent: GJ.blue),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _AttractionCard(item: places[i]),
                      childCount: places.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                  ),
                ),
              ],

              // ── Foods ──
              if (foods.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: GJSectionLabel(title: 'Top Foods', accent: GJ.pink),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: foods.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 160,
                          child: _AttractionCard(item: foods[i]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // ── Activities ──
              if (activities.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: GJSectionLabel(
                      title: 'Top Activities', accent: GJ.green),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _AttractionCard(item: activities[i]),
                      childCount: activities.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                  ),
                ),
              ],

              // ── Getting There ──
              SliverToBoxAdapter(
                child: GJSectionLabel(
                    title: 'Getting There 🚌', accent: GJ.yellow),
              ),
              // Transport mode filter
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: kTransportModes.length,
                    itemBuilder: (_, i) {
                      final mode = kTransportModes[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GJChip(
                          label: mode,
                          selected: _transportMode == mode,
                          onTap: () =>
                              setState(() => _transportMode = mode),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TransportCard(opt: transport[i]),
                    ),
                    childCount: transport.length,
                  ),
                ),
              ),
              if (transport.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: GJCard(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No transport options found for this mode.',
                        style: GJText.body.copyWith(fontSize: 12),
                      ),
                    ),
                  ),
                ),

              // ── Top Experiences from this Destination ──
              if (destExps.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: GJSectionLabel(
                      title: 'Experiences Here', accent: GJ.blue),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: destExps.length,
                      itemBuilder: (_, i) {
                        final exp = destExps[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 200,
                            child: GJExperienceCard(
                              exp: exp,
                              onTap: () => Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExperienceDetailPage(
                                    experienceId: exp.id,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // Bottom padding for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // ── Floating CTAs ──
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GJButton(
                    label: '✚  Create Experience',
                    color: GJ.yellow,
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateExperiencePage(
                          preselectedSlug: dest.slug,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _bookmarked = !_bookmarked),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _bookmarked ? GJ.pink : GJ.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GJ.dark, width: 2),
                        boxShadow: const [
                          BoxShadow(offset: Offset(3, 3), color: GJ.dark),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _bookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color: GJ.dark,
                          size: 20,
                        ),
                      ),
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

  Widget _buildHero(DestinationSummary dest) {
    return Column(
      children: [
        // Back button row (over colored hero)
        Container(
          color: dest.coverColor,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: GJ.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GJ.dark, width: 2),
                        boxShadow: const [
                          BoxShadow(offset: Offset(2, 2), color: GJ.dark),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: GJ.dark, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Big emoji panel
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: dest.coverColor,
            border: const Border(
                bottom: BorderSide(color: GJ.dark, width: 3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(dest.emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 8),
              Text(
                dest.name,
                style: GJText.display.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: GJ.dark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dest.region,
                  style: GJText.tiny.copyWith(
                      color: GJ.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCell(String val, String label, Color accent, bool first) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: first
              ? null
              : const Border(
                  left: BorderSide(color: GJ.dark, width: 1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: GJ.dark, width: 1.5),
              ),
              child: Text(val, style: GJText.label.copyWith(fontSize: 13)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GJText.tiny.copyWith(
                color: GJ.dark.withValues(alpha: 0.5),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : '$v';
}

// ─────────────────────────────────────────────────────────
//  ATTRACTION CARD
// ─────────────────────────────────────────────────────────
class _AttractionCard extends StatelessWidget {
  final AttractionItem item;
  const _AttractionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GJCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored emoji top
            Container(
              width: double.infinity,
              height: 60,
              color: item.color,
              child: Center(
                child: Text(item.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GJText.label.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.notes,
                      style: GJText.tiny.copyWith(
                        color: GJ.dark.withValues(alpha: 0.55),
                        fontSize: 9,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (item.priceRange.isNotEmpty)
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
                          item.priceRange,
                          style: GJText.tiny.copyWith(fontSize: 8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  TRANSPORT CARD
// ─────────────────────────────────────────────────────────
class _TransportCard extends StatelessWidget {
  final TransportOption opt;
  const _TransportCard({required this.opt});

  static const _modeIcons = {
    'Bus': Icons.directions_bus_rounded,
    'Train': Icons.train_rounded,
    'Boat': Icons.directions_boat_rounded,
    'Air': Icons.flight_rounded,
    'CNG': Icons.electric_rickshaw_rounded,
    'Microbus': Icons.airport_shuttle_rounded,
  };

  static const _modeColors = {
    'Bus': GJ.pink,
    'Train': GJ.blue,
    'Boat': GJ.blue,
    'Air': Color(0xFFE8D5FF),
    'CNG': GJ.green,
    'Microbus': GJ.yellow,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _modeIcons[opt.mode] ?? Icons.directions_rounded;
    final color = _modeColors[opt.mode] ?? GJ.yellow;
    return GJCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GJ.dark, width: 1.5),
            ),
            child: Icon(icon, color: GJ.dark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${opt.fromLocation} → ${opt.toLocation}',
                        style: GJText.label.copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      opt.mode,
                      style: GJText.tiny.copyWith(
                        color: GJ.dark.withValues(alpha: 0.5),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: GJ.yellow,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: GJ.dark, width: 1),
                      ),
                      child: Text(
                        opt.costRange,
                        style: GJText.tiny.copyWith(fontSize: 9),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '⏱ ${opt.duration}',
                      style: GJText.tiny.copyWith(
                        fontSize: 9,
                        color: GJ.dark.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                if (opt.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    opt.note,
                    style: GJText.tiny.copyWith(
                      fontSize: 9,
                      color: GJ.dark.withValues(alpha: 0.45),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
