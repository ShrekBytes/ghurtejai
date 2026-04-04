import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_page.dart';

// import 'explore_page.dart';
// import 'experiences_page.dart';
// import 'create_page.dart';
// import 'profile_page.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFF0F1117);
  static const surface = Color(0xFF1A1D26);
  static const surfaceHigh = Color(0xFF242837);
  static const primary = Color(0xFFE8A045);
  static const primarySoft = Color(0x33E8A045);
  static const green = Color(0xFF3EBF7A);
  static const greenSoft = Color(0x223EBF7A);
  static const textPrimary = Color(0xFFF0EDE6);
  static const textSub = Color(0xFF9097A8);
  static const textMuted = Color(0xFF5A6070);
  static const border = Color(0xFF2A2F3E);
  static const aiGlow = Color(0xFF7C6FE0);
  static const aiSoft = Color(0x337C6FE0);
}

class AppText {
  static const display = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  static const title = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );
  static const body = TextStyle(
    fontSize: 13,
    color: AppColors.textSub,
    height: 1.4,
  );
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textMuted,
  );
  static const chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
class Destination {
  final String name, description;
  final List<String> tags;
  final int minCost, midCost, maxCost, attractionCount;
  // TODO: replace with your asset paths e.g. 'assets/images/coxsbazar_1.jpg'
  final List<String> imagePaths;
  const Destination({
    required this.name,
    required this.description,
    required this.tags,
    required this.minCost,
    required this.midCost,
    required this.maxCost,
    required this.attractionCount,
    required this.imagePaths,
  });
}

class Experience {
  final String title, author;
  final List<String> tags;
  final int days, attractions, cost, upvotes;
  // TODO: replace with your asset path e.g. 'assets/images/coxsbazar_thumb.jpg'
  final String thumbPath;
  const Experience({
    required this.title,
    required this.author,
    required this.tags,
    required this.days,
    required this.attractions,
    required this.cost,
    required this.upvotes,
    required this.thumbPath,
  });
}

// ─────────────────────────────────────────────
//  MOCK DATA
// ─────────────────────────────────────────────
final List<Destination> popularDestinations = [
  Destination(
    name: "Cox's Bazar",
    description:
        "World's longest natural sea beach with stunning sunsets and fresh seafood.",
    tags: ["Beach", "Mountain", "Water"],
    minCost: 2000,
    midCost: 5000,
    maxCost: 10000,
    attractionCount: 56,
    imagePaths: [
      'images/cox/cox_popular1.jpg',
      'images/cox/cox_popular2.jpg',
      'images/cox/cox_popular4.jpg',
      '',
    ],
  ),
  Destination(
    name: "Sylhet",
    description:
        "Rolling tea gardens, haor wetlands and spiritual shrines of the northeast.",
    tags: ["Nature", "Mountain", "Tea"],
    minCost: 1500,
    midCost: 4000,
    maxCost: 8000,
    attractionCount: 42,
    imagePaths: [
      'images/sylhet/syl_popular1.jpg',
      'images/sylhet/syl_popular2.jpg',
      'images/sylhet/syl_popular3.jpg',
      'images/sylhet/syl_popular4.jpg',
    ],
  ),
  Destination(
    name: "Bandarban",
    description:
        "Misty hill tracts with tribal culture, sky-touching peaks and hidden waterfalls.",
    tags: ["Adventure", "Mountain", "Tribal"],
    minCost: 3000,
    midCost: 6000,
    maxCost: 12000,
    attractionCount: 38,
    imagePaths: [
      'images/bandarban/band_pop1.jpg',
      'images/bandarban/band_pop3.jpg',
      'images/bandarban/band_pop2.jpg',
      'images/bandarban/band_pop4.jpg',
    ],
  ),
  Destination(
    name: "Sundarbans",
    description:
        "The world's largest mangrove delta — home to Royal Bengal Tiger and river dolphins.",
    tags: ["Nature", "Wildlife", "River"],
    minCost: 4000,
    midCost: 8000,
    maxCost: 15000,
    attractionCount: 29,
    imagePaths: [
      'images/sundarban/sund_pop1.jpg',
      'images/sundarban/sund_pop2.png',
      'images/sundarban/sund_pop4.webp',
      'images/sundarban/sund_pop3.jpg',
    ],
  ),
];

final List<Experience> trendingExperiences = [
  Experience(
    title: "Cox's Bazar by sadib",
    author: "sadib",
    tags: ["Beach", "Mountain"],
    days: 2,
    attractions: 45,
    cost: 5000,
    upvotes: 27,
    thumbPath: 'images/cox/cox_trend.jpg',
  ),
  Experience(
    title: "Sylhet Sesh 6 Dine",
    author: "Rafi",
    tags: ["Nature", "Mountain"],
    days: 6,
    attractions: 23,
    cost: 12000,
    upvotes: 34,
    thumbPath: 'images/sylhet/syl_trend.jpg',
  ),
  Experience(
    title: "Bandarban Trek",
    author: "Nadia",
    tags: ["Adventure", "Mountain"],
    days: 3,
    attractions: 18,
    cost: 7500,
    upvotes: 51,
    thumbPath: 'images/bandarban/band_trend.jpg',
  ),
  Experience(
    title: "Sundarbans Safari",
    author: "Tanvir",
    tags: ["Wildlife", "River"],
    days: 4,
    attractions: 12,
    cost: 9000,
    upvotes: 42,
    thumbPath: 'images/sundarban/sund_trend.jpg',
  ),
];

final List<String> filterTags = [
  "All",
  "Beach",
  "Mountain",
  "Nature",
  "Adventure",
  "Food",
  "Cultural",
  "River",
];

// ─────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────
void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: MainScaffold()),
);

// ─────────────────────────────────────────────
//  MAIN SCAFFOLD + BOTTOM NAV
// ─────────────────────────────────────────────
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ExplorePage(),
    _PlaceholderPage(
      label: "Experiences",
    ), // TODO: replace with ExperiencesPage()
    _PlaceholderPage(label: "Create"), // TODO: replace with CreatePage()
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: _BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: "Explore",
    ),
    (
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: "Experiences",
    ),
    (
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle_rounded,
      label: "Create",
    ),
    (
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: "Profile",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? item.activeIcon : item.icon,
                        color: active ? AppColors.primary : AppColors.textSub,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: active ? AppColors.primary : AppColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      label,
      style: const TextStyle(color: Colors.white54, fontSize: 18),
    ),
  );
}

// ─────────────────────────────────────────────
//  EXPLORE PAGE
// ─────────────────────────────────────────────
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  bool _aiMode = false;
  bool _searchFocused = false;
  String _selectedFilter = "All";
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _searchFocused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ── Subtle top glow ──
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
              _buildHeader(),
              _buildSearchBar(),
              if (_searchFocused)
                _buildSearchSuggestions()
              else ...[
                _buildSectionLabel("Popular Destinations", onSeeAll: () {}),
                _buildPopularDestinations(),
                _buildSectionLabel("Trending Experiences", onSeeAll: () {}),
                _buildTrendingExperiences(),
                _buildAllDestinationsHeader(),
                _buildFilterChips(),
                _buildAllDestinations(),
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "GHURTEJAI",
                style: AppText.label.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 4),
              Text("Explore", style: AppText.display),
            ],
          ),
          GestureDetector(
            onTap: () {
              //notification
            },
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
  );

  // ── Search Bar ──
  Widget _buildSearchBar() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _searchFocused
                ? (_aiMode ? AppColors.aiGlow : AppColors.primary).withValues(
                    alpha: 0.6,
                  )
                : AppColors.border,
            width: 1.5,
          ),
          boxShadow: _searchFocused
              ? [
                  BoxShadow(
                    color: (_aiMode ? AppColors.aiGlow : AppColors.primary)
                        .withValues(alpha: 0.12),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              _aiMode ? Icons.auto_awesome_rounded : Icons.search_rounded,
              color: _aiMode ? AppColors.aiGlow : AppColors.textSub,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                onSubmitted: (val) {
                  // TODO: trigger search / AI query with val
                },
                decoration: InputDecoration(
                  hintText: _aiMode
                      ? "e.g. beach under ৳3k, 2 days..."
                      : "Search destinations or experiences",
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontStyle: _aiMode ? FontStyle.italic : FontStyle.normal,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            // AI mode toggle
            GestureDetector(
              onTap: () => setState(() => _aiMode = !_aiMode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _aiMode ? AppColors.aiSoft : AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _aiMode
                        ? AppColors.aiGlow.withOpacity(0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 12,
                      color: _aiMode ? AppColors.aiGlow : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "AI",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _aiMode ? AppColors.aiGlow : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // ── Search Suggestions Overlay ──
  Widget _buildSearchSuggestions() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: !_aiMode
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _suggestionSection("Recent Searches", Icons.history_rounded, [
                  "Cox's Bazar",
                  "Bumba experience",
                  "Sylhet tea garden",
                ]),
                const SizedBox(height: 16),
                _suggestionSection(
                  "Popular Searches",
                  Icons.trending_up_rounded,
                  [
                    "Beach destinations",
                    "Mountain trek",
                    "Under ৳5k experiences",
                  ],
                ),
              ],
            )
          : _aiSuggestions(),
    ),
  );

  Widget _suggestionSection(String title, IconData icon, List<String> items) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(title.toUpperCase(), style: AppText.label),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (s) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                s,
                style: AppText.body.copyWith(color: AppColors.textPrimary),
              ),
              trailing: const Icon(
                Icons.north_west_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
              onTap: () {
                _searchCtrl.text = s;
                _focusNode.unfocus();
                // TODO: trigger search with s
              },
            ),
          ),
        ],
      );

  Widget _aiSuggestions() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 13,
            color: AppColors.aiGlow,
          ),
          const SizedBox(width: 6),
          Text(
            "Try asking",
            style: AppText.label.copyWith(color: AppColors.aiGlow),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ...[
        "Show me all beach destinations under ৳2k",
        "Mountain experiences with 2 days less than ৳3k",
        "Family-friendly places in Sylhet",
        "Top rated experiences this month",
      ].map(
        (q) => GestureDetector(
          onTap: () {
            _searchCtrl.text = q;
            _focusNode.unfocus();
            // TODO: trigger AI query with q
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.aiSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.aiGlow.withOpacity(0.2)),
            ),
            child: Text(
              q,
              style: AppText.body.copyWith(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    ],
  );

  // ── Section Label ──
  Widget _buildSectionLabel(String title, {VoidCallback? onSeeAll}) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppText.title.copyWith(fontSize: 17)),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  "See all",
                  style: AppText.body.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      );

  // ── Popular Destinations Carousel ──
  Widget _buildPopularDestinations() =>
      const SliverToBoxAdapter(child: _PopularDestCarousel());

  // ── Trending Experiences ──
  Widget _buildTrendingExperiences() => SliverToBoxAdapter(
    child: SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 8),
        itemCount: trendingExperiences.length,
        itemBuilder: (ctx, i) => _TrendingExpCard(
          exp: trendingExperiences[i],
          onTap: () {
            // TODO: navigate to experience detail
          },
        ),
      ),
    ),
  );

  // ── All Destinations Header ──
  Widget _buildAllDestinationsHeader() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("All Destinations", style: AppText.title.copyWith(fontSize: 17)),
          GestureDetector(
            onTap: () {
              // TODO: navigate to all destinations
            },
            child: Text(
              "See all",
              style: AppText.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    ),
  );

  // ── Filter Chips ──
  Widget _buildFilterChips() => SliverToBoxAdapter(
    child: SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 8),
        itemCount: filterTags.length,
        itemBuilder: (ctx, i) {
          final tag = filterTags[i];
          final sel = _selectedFilter == tag;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = tag);
              // TODO: filter destinations list by tag
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  );

  // ── All Destinations Grid ──
  Widget _buildAllDestinations() => SliverPadding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => _DestGridCard(
          dest: popularDestinations[i % popularDestinations.length],
          onTap: () {
            // TODO: navigate to destination detail
          },
        ),
        childCount: 8,
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  POPULAR DESTINATIONS — PageView carousel
// ─────────────────────────────────────────────
class _PopularDestCarousel extends StatefulWidget {
  const _PopularDestCarousel();
  @override
  State<_PopularDestCarousel> createState() => _PopularDestCarouselState();
}

class _PopularDestCarouselState extends State<_PopularDestCarousel> {
  final _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pc,
            itemCount: popularDestinations.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _DestPageCard(
              dest: popularDestinations[i],
              onTap: () {
                // TODO: navigate to destination detail for popularDestinations[i]
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(popularDestinations.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DestPageCard extends StatelessWidget {
  final Destination dest;
  final VoidCallback onTap;
  const _DestPageCard({required this.dest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            // ── 4-image filmstrip ──
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 5, child: _AssetImg(path: dest.imagePaths[0])),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(child: _AssetImg(path: dest.imagePaths[1])),
                        const SizedBox(height: 2),
                        Expanded(child: _AssetImg(path: dest.imagePaths[2])),
                        const SizedBox(height: 2),
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _AssetImg(path: dest.imagePaths[3]),
                              Container(
                                color: Colors.black.withOpacity(0.55),
                                child: const Center(
                                  child: Text(
                                    "+12",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dest.name,
                          style: AppText.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ...dest.tags
                          .take(2)
                          .map(
                            (t) => Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t,
                                style: AppText.label.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dest.description,
                    style: AppText.body.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _cTier("৳${_k(dest.minCost)}"),
                      _divider(),
                      _cTier("৳${_k(dest.midCost)}"),
                      _divider(),
                      _cTier("৳${_k(dest.maxCost)}"),
                      _divider(),
                      const Icon(
                        Icons.place_outlined,
                        size: 12,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "${dest.attractionCount} attractions",
                        style: AppText.label.copyWith(
                          color: AppColors.green,
                          fontSize: 10,
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

  Widget _cTier(String t) => Text(
    t,
    style: AppText.label.copyWith(color: AppColors.textSub, fontSize: 11),
  );
  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Text(
      "|",
      style: AppText.label.copyWith(color: AppColors.border, fontSize: 13),
    ),
  );
  String _k(int v) => v >= 1000 ? "${(v / 1000).toStringAsFixed(0)}k" : "$v";
}

// ─────────────────────────────────────────────
//  TRENDING EXPERIENCE CARD
// ─────────────────────────────────────────────
class _TrendingExpCard extends StatelessWidget {
  final Experience exp;
  final VoidCallback onTap;
  const _TrendingExpCard({required this.exp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 195,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _AssetImg(path: exp.thumbPath),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0xF0060810)],
                  stops: [0.0, 0.60],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Wrap(
                    spacing: 4,
                    children: exp.tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              t,
                              style: AppText.label.copyWith(
                                color: Colors.white70,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exp.title,
                    style: AppText.title.copyWith(fontSize: 13, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _stat(Icons.calendar_today_rounded, "${exp.days} day"),
                      const SizedBox(width: 10),
                      _stat(
                        Icons.place_outlined,
                        "${exp.attractions} attractions",
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "৳${_k(exp.cost)}",
                        style: AppText.title.copyWith(
                          color: AppColors.primary,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              size: 11,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "${exp.upvotes}",
                              style: AppText.label.copyWith(
                                color: AppColors.green,
                                fontSize: 10,
                              ),
                            ),
                          ],
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

  Widget _stat(IconData icon, String val) => Row(
    children: [
      Icon(icon, size: 11, color: Colors.white54),
      const SizedBox(width: 3),
      Text(
        val,
        style: AppText.label.copyWith(color: Colors.white54, fontSize: 10),
      ),
    ],
  );
  String _k(int v) => v >= 1000 ? "${(v / 1000).toStringAsFixed(0)}k" : "$v";
}

// ─────────────────────────────────────────────
//  ALL DESTINATIONS GRID CARD
// ─────────────────────────────────────────────
class _DestGridCard extends StatelessWidget {
  final Destination dest;
  final VoidCallback onTap;
  const _DestGridCard({required this.dest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              child: Row(
                children: [
                  Expanded(flex: 2, child: _AssetImg(path: dest.imagePaths[0])),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _AssetImg(path: dest.imagePaths[1])),
                        const SizedBox(height: 2),
                        Expanded(child: _AssetImg(path: dest.imagePaths[2])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dest.name,
                    style: AppText.title.copyWith(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dest.description,
                    style: AppText.body.copyWith(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 10,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${dest.attractionCount} attractions",
                        style: AppText.label.copyWith(
                          color: AppColors.green,
                          fontSize: 9,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "৳${_k(dest.minCost)}+",
                        style: AppText.label.copyWith(
                          color: AppColors.primary,
                          fontSize: 9,
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

  String _k(int v) => v >= 1000 ? "${(v / 1000).toStringAsFixed(0)}k" : "$v";
}

// ─────────────────────────────────────────────
//  HELPER — Asset image with placeholder
//  TODO: once you add asset paths, this will render your images
// ─────────────────────────────────────────────
class _AssetImg extends StatelessWidget {
  final String path;
  const _AssetImg({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      // Placeholder shown until you fill in asset paths
      return Container(
        color: AppColors.surfaceHigh,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            color: AppColors.textMuted,
            size: 18,
          ),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surfaceHigh,
        child: const Icon(
          Icons.broken_image_outlined,
          color: AppColors.textMuted,
          size: 18,
        ),
      ),
    );
  }
}
