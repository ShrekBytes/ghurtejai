import 'package:flutter/material.dart';

// ── Colors ──────────────────────────────────────────────────────
const kYellow = Color(0xFFF5C518);
const kPink   = Color(0xFFFF4D8D);
const kMint   = Color(0xFF00D4AA);
const kBlue   = Color(0xFFB8E4F9);
const kBlack  = Color(0xFF1A1A1A);
const kWhite  = Color(0xFFFFFFFF);

// ── Sample Reviews ───────────────────────────────────────────────
final List<Map<String, dynamic>> reviewList = [
  {'name': 'Alex K.',  'initials': 'AK', 'avatarColor': kYellow,           'rating': 5, 'text': 'Absolutely magical. The guide was wonderful and the sunrise was the best I have ever seen!'},
  {'name': 'Sara R.',  'initials': 'SR', 'avatarColor': Color(0xFFFFD6E8), 'rating': 5, 'text': 'Worth every penny. Felt totally safe and the breakfast on board was delicious.'},
  {'name': 'James T.', 'initials': 'JT', 'avatarColor': kMint,             'rating': 4, 'text': 'Great experience overall. The boat was comfortable and the crew was very friendly.'},
];

// ── Experience View Page ─────────────────────────────────────────
class ExperienceViewPage extends StatefulWidget {
  const ExperienceViewPage({super.key});

  @override
  State<ExperienceViewPage> createState() => _ExperienceViewPageState();
}

class _ExperienceViewPageState extends State<ExperienceViewPage> {
  // Tracks if user bookmarked this experience
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Column(
        children: [
          buildStatusBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeroSection(context),
                  buildInfoSection(),
                  buildStatsSection(),
                  buildAboutSection(),
                  buildReviewsSection(),
                  buildBookButton(),
                  SizedBox(height: 16),
                ],
              ),
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

  // ── Hero Section ─────────────────────────────────────────────
  Widget buildHeroSection(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: kBlue,
        border: Border(bottom: BorderSide(color: kBlack, width: 2)),
      ),
      child: Stack(
        children: [
          // Big emoji centered
          Center(child: Text('🌿', style: TextStyle(fontSize: 80))),

          // Back button top left
          Positioned(
            top: 12, left: 12,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: kYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBlack, width: 2),
                ),
                child: Icon(Icons.arrow_back, color: kBlack, size: 18),
              ),
            ),
          ),

          // Bookmark button
          Positioned(
            top: 12, right: 56,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isBookmarked = !isBookmarked;
                });
              },
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isBookmarked ? kPink : kWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBlack, width: 2),
                ),
                child: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isBookmarked ? kWhite : kBlack,
                  size: 18,
                ),
              ),
            ),
          ),

          // Trending badge top right
          Positioned(
            top: 16, right: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kPink,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: kBlack, width: 2),
              ),
              child: Text('🔥 Trending', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kWhite)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Title & Location ─────────────────────────────────────────
  Widget buildInfoSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag pills
          Row(
            children: [
              buildTag('🛶 River', kYellow),
              SizedBox(width: 8),
              buildTag('🌿 Nature', kBlue),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Boat Tour through\nSundarbans',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: kBlack, height: 1.2),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text('Khulna, Bangladesh', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Text('·', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text('4h experience', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats Row ────────────────────────────────────────────────
  Widget buildStatsSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          buildStatBox('4.9', 'Rating', kYellow),
          SizedBox(width: 8),
          buildStatBox('320', 'Reviews', kMint),
          SizedBox(width: 8),
          buildStatBox('\$49', 'Per person', kBlue),
        ],
      ),
    );
  }

  // ── About Section ────────────────────────────────────────────
  Widget buildAboutSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this experience', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kBlack)),
          SizedBox(height: 8),
          Text(
            'Explore the world\'s largest mangrove forest right here in Bangladesh. '
            'Glide through narrow waterways on a traditional wooden boat while your guide shares stories of the Sundarbans. '
            'Includes local lunch and a visit to a forest watchtower.',
            style: TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── Reviews Section ──────────────────────────────────────────
  Widget buildReviewsSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kBlack)),
          SizedBox(height: 10),
          // Loop through reviews using a simple for loop
          for (int i = 0; i < reviewList.length; i++)
            buildReviewCard(reviewList[i]),
        ],
      ),
    );
  }

  // ── Book Button ──────────────────────────────────────────────
  Widget buildBookButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () {
          // TODO: go to booking page
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: kPink,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: kBlack, width: 2.5),
            boxShadow: [BoxShadow(color: kBlack, offset: Offset(4, 4), blurRadius: 0)],
          ),
          child: Center(
            child: Text(
              'Book This Experience →',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: kWhite),
            ),
          ),
        ),
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
          buildTabItem(Icons.map_rounded, 'Map', false),
          buildTabItem(Icons.person_rounded, 'Profile', false),
        ],
      ),
    );
  }

  // ── Helper: Tag Pill ─────────────────────────────────────────
  Widget buildTag(String text, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: kBlack, width: 1.5),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kBlack)),
    );
  }

  // ── Helper: Stat Box ─────────────────────────────────────────
  Widget buildStatBox(String value, String label, Color bgColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBlack, width: 2),
          boxShadow: [BoxShadow(color: kBlack, offset: Offset(2, 2), blurRadius: 0)],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kBlack)),
            SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
          ],
        ),
      ),
    );
  }

  // ── Helper: Review Card ──────────────────────────────────────
  Widget buildReviewCard(Map<String, dynamic> review) {
    // Build star string like "⭐⭐⭐⭐⭐"
    String stars = '';
    for (int i = 0; i < review['rating']; i++) {
      stars += '⭐';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBlack, width: 2),
        boxShadow: [BoxShadow(color: kBlack, offset: Offset(2, 2), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with initials
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: review['avatarColor'],
                  shape: BoxShape.circle,
                  border: Border.all(color: kBlack, width: 2),
                ),
                child: Center(
                  child: Text(review['initials'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kBlack)),
                ),
              ),
              SizedBox(width: 8),
              Text(review['name'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kBlack)),
              Spacer(),
              Text(stars, style: TextStyle(fontSize: 11)),
            ],
          ),
          SizedBox(height: 8),
          Text(review['text'], style: TextStyle(fontSize: 12, color: Color(0xFF444444), height: 1.5)),
        ],
      ),
    );
  }

  // ── Helper: Tab Item ─────────────────────────────────────────
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
    home: ExperienceViewPage(),
  ));
}
