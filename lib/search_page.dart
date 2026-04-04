import 'package:flutter/material.dart';

// ── Colors ──────────────────────────────────────────────────────
const kYellow = Color(0xFFF5C518);
const kPink   = Color(0xFFFF4D8D);
const kMint   = Color(0xFF00D4AA);
const kBlue   = Color(0xFFB8E4F9);
const kBlack  = Color(0xFF1A1A1A);
const kWhite  = Color(0xFFFFFFFF);

// ── Sample Data ─────────────────────────────────────────────────
// Each destination is a simple Map with name, location, emoji, rating, tag, color
final List<Map<String, dynamic>> allDestinations = [
  {'name': 'Paris, France',   'location': 'Western Europe',  'emoji': '🗼', 'rating': 4.9, 'tag': 'City',     'color': kBlue},
  {'name': 'Bali, Indonesia', 'location': 'Southeast Asia',  'emoji': '🌺', 'rating': 4.8, 'tag': 'Beach',    'color': Color(0xFFFFD6E8)},
  {'name': 'Swiss Alps',      'location': 'Central Europe',  'emoji': '🏔', 'rating': 4.7, 'tag': 'Mountain', 'color': Color(0xFFC8F7E4)},
  {'name': 'Kyoto, Japan',    'location': 'East Asia',       'emoji': '🏯', 'rating': 4.9, 'tag': 'Culture',  'color': Color(0xFFFFF3B0)},
  {'name': 'Serengeti',       'location': 'East Africa',     'emoji': '🦁', 'rating': 4.8, 'tag': 'Nature',   'color': Color(0xFFE8D5FF)},
  {'name': 'Santorini',       'location': 'Greece',          'emoji': '🏛', 'rating': 4.8, 'tag': 'Beach',    'color': Color(0xFFFFE5B4)},
];

// Filter chip labels
final List<String> filterList = ['All', '🏖 Beach', '🏔 Mountain', '🏙 City', '🌿 Nature', '🏛 Culture'];

// ── Search Page ─────────────────────────────────────────────────
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Tracks what user typed in search box
  String searchText = '';

  // Tracks which filter chip is selected
  String selectedFilter = 'All';

  // This function filters the list based on search text and selected filter
  List<Map<String, dynamic>> getFilteredList() {
    List<Map<String, dynamic>> result = [];

    for (int i = 0; i < allDestinations.length; i++) {
      Map<String, dynamic> dest = allDestinations[i];

      // Check if name or location matches search text
      bool matchesSearch = searchText.isEmpty ||
          dest['name'].toLowerCase().contains(searchText.toLowerCase()) ||
          dest['location'].toLowerCase().contains(searchText.toLowerCase());

      // Check if tag matches selected filter
      bool matchesFilter = selectedFilter == 'All' ||
          dest['tag'].toLowerCase() ==
              selectedFilter
                  .replaceAll('🏖 ', '')
                  .replaceAll('🏔 ', '')
                  .replaceAll('🏙 ', '')
                  .replaceAll('🌿 ', '')
                  .replaceAll('🏛 ', '')
                  .toLowerCase();

      // Only add to result if both conditions pass
      if (matchesSearch && matchesFilter) {
        result.add(dest);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Get filtered list every time page rebuilds
    List<Map<String, dynamic>> filteredList = getFilteredList();

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Column(
        children: [
          buildStatusBar(context),
          buildNavBar(context),
          buildSearchHeader(),
          buildFilterChips(),
          // "Popular Results" label
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'POPULAR RESULTS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1.2),
              ),
            ),
          ),
          // Results list
          Expanded(
            child: filteredList.isEmpty
                ? Center(child: Text('No results found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> dest = filteredList[index];
                      return buildResultCard(dest);
                    },
                  ),
          ),
          buildTabBar(context),
        ],
      ),
    );
  }

  // ── Status Bar ───────────────────────────────────────────────
  Widget buildStatusBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kYellow),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 20, right: 20, bottom: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('9:41', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kBlack)),
          Text('●●●', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kBlack)),
        ],
      ),
    );
  }

  // ── Nav Bar ──────────────────────────────────────────────────
  Widget buildNavBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: kYellow,
        border: Border(bottom: BorderSide(color: kBlack, width: 2)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: kBlack, shape: BoxShape.circle),
              child: Icon(Icons.arrow_back, color: kYellow, size: 16),
            ),
          ),
          SizedBox(width: 10),
          Text('Search', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kBlack)),
        ],
      ),
    );
  }

  // ── Search Header ────────────────────────────────────────────
  Widget buildSearchHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kMint,
        border: Border(bottom: BorderSide(color: kBlack, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find your next\nadventure ✈',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: kBlack, height: 1.2),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: kBlack, width: 2),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Row(
              children: [
                Icon(Icons.search, color: kBlack, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      // Update searchText when user types
                      setState(() {
                        searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search destinations, places...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chips ─────────────────────────────────────────────
  Widget buildFilterChips() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: kWhite,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: filterList.length,
        itemBuilder: (context, index) {
          String filter = filterList[index];
          bool isActive = selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? kYellow : kWhite,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: kBlack, width: 2),
              ),
              child: Text(filter, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kBlack)),
            ),
          );
        },
      ),
    );
  }

  // ── Result Card ──────────────────────────────────────────────
  Widget buildResultCard(Map<String, dynamic> dest) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBlack, width: 2),
        boxShadow: [BoxShadow(color: kBlack, offset: Offset(3, 3), blurRadius: 0)],
      ),
      child: Row(
        children: [
          // Emoji image box
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: dest['color'],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
            child: Center(child: Text(dest['emoji'], style: TextStyle(fontSize: 32))),
          ),
          // Info section
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dest['name'], style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: kBlack)),
                  SizedBox(height: 2),
                  Text('📍 ${dest['location']}', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      buildPill('⭐ ${dest['rating']}', kYellow, kBlack),
                      Spacer(),
                      buildPill(dest['tag'], kPink, kWhite),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pill Badge ───────────────────────────────────────────────
  Widget buildPill(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: kBlack, width: 1.5),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textColor)),
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────
  Widget buildTabBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 4, top: 8),
      decoration: BoxDecoration(
        color: kYellow,
        border: Border(top: BorderSide(color: kBlack, width: 2)),
      ),
      child: Row(
        children: [
          buildTabItem(Icons.home_rounded, 'Home', false),
          buildTabItem(Icons.search_rounded, 'Search', true),
          buildTabItem(Icons.map_rounded, 'Map', false),
          buildTabItem(Icons.person_rounded, 'Profile', false),
        ],
      ),
    );
  }

  // ── Tab Item ─────────────────────────────────────────────────
  Widget buildTabItem(IconData icon, String label, bool isActive) {
    return Expanded(
      child: Opacity(
        opacity: isActive ? 1.0 : 0.45,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kBlack, size: 22),
            SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: kBlack)),
          ],
        ),
      ),
    );
  }
}

// ── Entry Point ──────────────────────────────────────────────────
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SearchPage(),
  ));
}
