import 'package:flutter/material.dart';

// ── Colors ──────────────────────────────────────────────────────
const kYellow = Color(0xFFF5C518);
const kPink   = Color(0xFFFF4D8D);
const kMint   = Color(0xFF00D4AA);
const kBlue   = Color(0xFFB8E4F9);
const kBlack  = Color(0xFF1A1A1A);
const kWhite  = Color(0xFFFFFFFF);

// ── Sample Data ─────────────────────────────────────────────────
// Bangladesh districts — emoji and flag use only place/nature icons, no animals or faces
final List<Map<String, dynamic>> allDestinations = [
  {'name': 'Cox\'s Bazar',  'country': 'Chittagong Division', 'flag': '🏖', 'emoji': '🌊', 'rating': 4.9, 'region': 'Chittagong', 'color': kBlue,             'isFavorite': false},
  {'name': 'Bandarban',     'country': 'Chittagong Division', 'flag': '⛰',  'emoji': '🏔', 'rating': 4.8, 'region': 'Chittagong', 'color': Color(0xFFC8F7E4), 'isFavorite': false},
  {'name': 'Sylhet',        'country': 'Sylhet Division',     'flag': '🍃', 'emoji': '🌿', 'rating': 4.9, 'region': 'Sylhet',     'color': Color(0xFFFFF3B0), 'isFavorite': true},
  {'name': 'Sundarbans',    'country': 'Khulna Division',     'flag': '🌳', 'emoji': '🛶', 'rating': 4.9, 'region': 'Khulna',     'color': Color(0xFFB8F0E8), 'isFavorite': false},
  {'name': 'Rangamati',     'country': 'Chittagong Division', 'flag': '🏞', 'emoji': '⛵', 'rating': 4.7, 'region': 'Chittagong', 'color': Color(0xFFFFD6E8), 'isFavorite': false},
  {'name': 'Sajek Valley',  'country': 'Chittagong Division', 'flag': '☁',  'emoji': '🏕', 'rating': 4.8, 'region': 'Chittagong', 'color': Color(0xFFE8D5FF), 'isFavorite': false},
  {'name': 'Kuakata',       'country': 'Barisal Division',    'flag': '🌅', 'emoji': '🌊', 'rating': 4.7, 'region': 'Barisal',    'color': kBlue,             'isFavorite': false},
  {'name': 'Srimangal',     'country': 'Sylhet Division',     'flag': '🍵', 'emoji': '🌱', 'rating': 4.8, 'region': 'Sylhet',     'color': Color(0xFFC8F7E4), 'isFavorite': false},
  {'name': 'Paharpur',      'country': 'Rajshahi Division',   'flag': '🏛', 'emoji': '🏛', 'rating': 4.6, 'region': 'Rajshahi',   'color': Color(0xFFFFE5B4), 'isFavorite': false},
  {'name': 'Dhaka',         'country': 'Dhaka Division',      'flag': '🏙', 'emoji': '🕌', 'rating': 4.7, 'region': 'Dhaka',      'color': Color(0xFFFFD6E8), 'isFavorite': false},
];

// Division filter options
final List<String> regionList = ['All', 'Chittagong', 'Sylhet', 'Khulna', 'Barisal', 'Rajshahi', 'Dhaka'];

// ── All Destinations Page ────────────────────────────────────────
class AllDestinationsPage extends StatefulWidget {
  const AllDestinationsPage({super.key});

  @override
  State<AllDestinationsPage> createState() => _AllDestinationsPageState();
}

class _AllDestinationsPageState extends State<AllDestinationsPage> {
  // Tracks which region filter is selected
  String selectedRegion = 'All';

  // Returns filtered list based on selected region
  List<Map<String, dynamic>> getFilteredList() {
    List<Map<String, dynamic>> result = [];

    for (int i = 0; i < allDestinations.length; i++) {
      Map<String, dynamic> dest = allDestinations[i];

      // If "All" is selected, add everything
      // Otherwise only add if region matches
      if (selectedRegion == 'All' || dest['region'] == selectedRegion) {
        result.add(dest);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredList = getFilteredList();

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Column(
        children: [
          buildStatusBar(context),
          buildNavBar(context),
          buildHeader(filteredList.length),
          buildFilterChips(),
          // Grid of destination cards
          Expanded(
            child: filteredList.isEmpty
                ? Center(child: Text('No destinations found', style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    padding: EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,       // 2 cards per row
                      crossAxisSpacing: 12,    // horizontal gap
                      mainAxisSpacing: 12,     // vertical gap
                      childAspectRatio: 0.85,  // card height ratio
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> dest = filteredList[index];
                      return buildDestCard(dest, index);
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
        color: kPink,
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
          Text('All Destinations', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kWhite)),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget buildHeader(int count) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: kPink,
        border: Border(bottom: BorderSide(color: kBlack, width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Bangladesh 🇧🇩',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: kWhite),
                ),
                SizedBox(height: 4),
                Text('Find your perfect destination', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          // Count badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: kBlack,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text('$count+ spots', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kYellow)),
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
        itemCount: regionList.length,
        itemBuilder: (context, index) {
          String region = regionList[index];
          bool isActive = selectedRegion == region;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedRegion = region;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? kMint : kWhite,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: kBlack, width: 2),
              ),
              child: Text(region, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kBlack)),
            ),
          );
        },
      ),
    );
  }

  // ── Destination Card ─────────────────────────────────────────
  Widget buildDestCard(Map<String, dynamic> dest, int index) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBlack, width: 2),
        boxShadow: [BoxShadow(color: kBlack, offset: Offset(3, 3), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top emoji image area
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: dest['color'],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(bottom: BorderSide(color: kBlack, width: 2)),
            ),
            child: Center(child: Text(dest['emoji'], style: TextStyle(fontSize: 40))),
          ),
          // Bottom info area
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dest['name'],
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: kBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text('${dest['country']} ${dest['flag']}', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Spacer(),
                  Row(
                    children: [
                      // Simple star rating using Text
                      Text(
                        '⭐ ${dest['rating']}',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kBlack),
                      ),
                      Spacer(),
                      // Favorite button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // Toggle favorite true/false
                            dest['isFavorite'] = !dest['isFavorite'];
                          });
                        },
                        child: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: dest['isFavorite'] ? kPink : kWhite,
                            shape: BoxShape.circle,
                            border: Border.all(color: kBlack, width: 1.5),
                          ),
                          child: Icon(
                            dest['isFavorite'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 12,
                            color: dest['isFavorite'] ? kWhite : kBlack,
                          ),
                        ),
                      ),
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
          buildTabItem(Icons.search_rounded, 'Search', false),
          buildTabItem(Icons.map_rounded, 'Map', true),
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
    home: AllDestinationsPage(),
  ));
}
