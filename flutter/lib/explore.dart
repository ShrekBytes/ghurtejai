import 'package:flutter/material.dart';
import 'gj_colors.dart';

import 'models/app_data.dart';
import 'models/experience_feed.dart';
import 'models/destination.dart';
import 'widgets/gj_cards.dart';
import 'notifications_page.dart';
import 'destination_page.dart';
import 'all_destinations_page.dart';
import 'experiences_page.dart';
import 'experience_detail_page.dart';

// ─────────────────────────────────────────────────────────
//  EXPLORE PAGE
// ─────────────────────────────────────────────────────────
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _tagFilter = 'All';
  bool _aiMode = false;

  List<DestinationSummary> get _filteredDestinations {
    if (_searchCtrl.text.trim().isEmpty) return kDestinations;
    final q = _searchCtrl.text.trim().toLowerCase();
    return kDestinations
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.region.toLowerCase().contains(q) ||
            d.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  List<ExperienceFeedItem> get _trendingExperiences {
    final items = List<ExperienceFeedItem>.from(kExperienceFeedItems);
    items.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    return items.take(6).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openDestination(DestinationSummary d) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => DestinationPage(slug: d.slug)),
    );
  }

  void _openExperienceDetail(String id) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ExperienceDetailPage(experienceId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GJ.orange,
      body: Column(
        children: [
          // ── Page Header ──
          GJPageHeader(
            pageTitle: 'Explore',
            showBell: true,
            onBell: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            ),
          ),
          // ── Scrollable content ──
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Search bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Where to next? 🗺️',
                          style: GJText.display.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Discover Bangladesh with fellow travellers',
                          style: GJText.body.copyWith(
                            color: GJ.dark.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GJSearchBar(
                          controller: _searchCtrl,
                          focusNode: _searchFocus,
                          hintText: _aiMode
                              ? 'Ask AI anything — "best beach in 3 days..."'
                              : 'Search destinations, experiences...',
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        // AI mode toggle
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _aiMode = !_aiMode),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _aiMode ? GJ.green : GJ.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: GJ.dark, width: 2),
                                  boxShadow: _aiMode
                                      ? const [BoxShadow(
                                          offset: Offset(2, 2),
                                          color: GJ.dark)]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _aiMode ? '✦' : '✦',
                                      style: GJText.tiny.copyWith(
                                        fontSize: 11,
                                        color: GJ.dark,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _aiMode ? 'AI Mode ON' : 'AI Mode',
                                      style: GJText.tiny.copyWith(
                                          fontSize: 10, color: GJ.dark),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Tag filter chips ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: kFilterTags.length,
                        itemBuilder: (_, i) {
                          final tag = kFilterTags[i];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GJChip(
                              label: tag,
                              selected: _tagFilter == tag,
                              onTap: () =>
                                  setState(() => _tagFilter = tag),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ── Popular Destinations carousel ──
                SliverToBoxAdapter(
                  child: GJSectionLabel(
                    title: 'Popular Destinations',
                    accent: GJ.pink,
                    onSeeAll: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AllDestinationsPage()),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _PopularCarousel(
                    destinations: kDestinations.take(5).toList(),
                    onTap: _openDestination,
                  ),
                ),

                // ── Trending Experiences ──
                SliverToBoxAdapter(
                  child: GJSectionLabel(
                    title: 'Trending Experiences',
                    accent: GJ.blue,
                    onSeeAll: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExperiencesPage()),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 310,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _trendingExperiences.length,
                      itemBuilder: (_, i) {
                        final exp = _trendingExperiences[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: SizedBox(
                            width: 210,
                            child: GJExperienceCard(
                              exp: exp,
                              onTap: () => _openExperienceDetail(exp.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── All Destinations grid ──
                SliverToBoxAdapter(
                  child: GJSectionLabel(
                    title: 'All Destinations',
                    accent: GJ.green,
                    onSeeAll: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AllDestinationsPage()),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final dest = _filteredDestinations[i];
                        return GJDestinationCard(
                          dest: dest,
                          onTap: () => _openDestination(dest),
                        );
                      },
                      childCount: _filteredDestinations.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.82,
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
}

// ─────────────────────────────────────────────────────────
//  POPULAR CAROUSEL
// ─────────────────────────────────────────────────────────
class _PopularCarousel extends StatefulWidget {
  final List<DestinationSummary> destinations;
  final ValueChanged<DestinationSummary> onTap;

  const _PopularCarousel({
    required this.destinations,
    required this.onTap,
  });

  @override
  State<_PopularCarousel> createState() => _PopularCarouselState();
}

class _PopularCarouselState extends State<_PopularCarousel> {
  int _page = 0;
  final _ctrl = PageController(viewportFraction: 0.65);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.destinations.length,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (_, i) {
              final dest = widget.destinations[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GJDestinationCarouselCard(
                  dest: dest,
                  onTap: () => widget.onTap(dest),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.destinations.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? GJ.dark : GJ.dark.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
                border: active
                    ? Border.all(color: GJ.dark, width: 1)
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}
