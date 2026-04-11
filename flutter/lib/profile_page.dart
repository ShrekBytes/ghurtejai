import 'package:flutter/material.dart';
import 'gj_colors.dart';
import 'login_page.dart';
import 'notifications_page.dart';

// ─────────────────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────────────────
class _ProfileExpCard {
  final String name;
  final String username;
  final String imageUrl;
  final Color fallbackColor;
  final int days;
  final int attractions;
  final int price;
  final int upvotes;

  const _ProfileExpCard({
    required this.name,
    required this.username,
    required this.imageUrl,
    required this.fallbackColor,
    required this.days,
    required this.attractions,
    required this.price,
    required this.upvotes,
  });
}

const List<_ProfileExpCard> _kExperiences = [
  _ProfileExpCard(
    name: 'Sundarbans',
    username: '@rafi_explores',
    // Dense forest / mangrove — reliable Unsplash photo
    imageUrl:
        'https://images.unsplash.com/photo-1448375240586-882707db888b?w=600&q=80',
    fallbackColor: Color(0xFF2D6A4F),
    days: 3,
    attractions: 8,
    price: 4500,
    upvotes: 142,
  ),
  _ProfileExpCard(
    name: "Cox's Bazar",
    username: '@rafi_explores',
    imageUrl:
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&q=80',
    fallbackColor: Color(0xFF0077B6),
    days: 4,
    attractions: 6,
    price: 6200,
    upvotes: 289,
  ),
  _ProfileExpCard(
    name: 'Sajek Valley',
    username: '@rafi_explores',
    imageUrl:
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=600&q=80',
    fallbackColor: Color(0xFF386641),
    days: 2,
    attractions: 5,
    price: 3800,
    upvotes: 97,
  ),
  _ProfileExpCard(
    name: 'Sreemangal',
    username: '@rafi_explores',
    imageUrl:
        'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=600&q=80',
    fallbackColor: Color(0xFF1B4332),
    days: 2,
    attractions: 4,
    price: 2900,
    upvotes: 76,
  ),
];

const List<_ProfileExpCard> _kBookmarks = [
  _ProfileExpCard(
    name: 'Bhutan',
    username: '@travel_bd',
    imageUrl:
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
    fallbackColor: Color(0xFF7B2D00),
    days: 5,
    attractions: 12,
    price: 28000,
    upvotes: 431,
  ),
  _ProfileExpCard(
    name: 'Darjeeling',
    username: '@hillsaddict',
    imageUrl:
        'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=600&q=80',
    fallbackColor: Color(0xFF3D405B),
    days: 4,
    attractions: 9,
    price: 14000,
    upvotes: 318,
  ),
  _ProfileExpCard(
    name: 'Maldives',
    username: '@ocean_lover',
    imageUrl:
        'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=600&q=80',
    fallbackColor: Color(0xFF006994),
    days: 6,
    attractions: 7,
    price: 85000,
    upvotes: 762,
  ),
  _ProfileExpCard(
    name: 'Nepal',
    username: '@trek_nepal',
    imageUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600&q=80',
    fallbackColor: Color(0xFF6B2D0F),
    days: 8,
    attractions: 15,
    price: 22000,
    upvotes: 584,
  ),
];

// ─────────────────────────────────────────────────────────
//  PROFILE PAGE
// ─────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _lang = 'English';
  bool _notifications = true;

  final Map<String, Map<String, String>> _s = {
    'English': {
      'profile': 'Profile',
      'edit': 'Edit',
      'experiences': 'My Experiences',
      'bookmarks': 'Bookmarks',
      'lang': 'Language',
      'notifs': 'Notifications',
      'logout': 'Log Out',
      'logoutSub': 'See you on the next adventure!',
      'shared': 'Shared',
      'upvotes': 'Upvotes',
      'comments': 'Reviews',
    },
    'Bangla': {
      'profile': 'প্রোফাইল',
      'edit': 'সম্পাদনা',
      'experiences': 'আমার অভিজ্ঞতা',
      'bookmarks': 'বুকমার্ক',
      'lang': 'ভাষা',
      'notifs': 'বিজ্ঞপ্তি',
      'logout': 'লগ আউট',
      'logoutSub': 'পরের অ্যাডভেঞ্চারে দেখা হবে!',
      'shared': 'শেয়ার',
      'upvotes': 'আপভোট',
      'comments': 'রিভিউ',
    },
  };

  String t(String k) => _s[_lang]?[k] ?? k;

  // ── Logout ────────────────────────────────────────────────
  void _logout() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GJ.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GJ.dark, width: 2),
            boxShadow: const [BoxShadow(offset: Offset(4, 4), color: GJ.dark)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t('logout'), style: GJText.title),
              const SizedBox(height: 8),
              Text(
                t('logoutSub'),
                textAlign: TextAlign.center,
                style: GJText.body.copyWith(
                  color: GJ.dark.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: GJ.dark.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('Cancel', style: GJText.label),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (_) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: GJ.pink,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GJ.dark, width: 2),
                          boxShadow: const [
                            BoxShadow(offset: Offset(3, 3), color: GJ.dark),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            t('logout'),
                            style: GJText.label.copyWith(color: GJ.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GJ.green,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── NAV BAR ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: GJ.dark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'GJ',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: GJ.yellow,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(t('profile'), style: GJText.label),
                        const Spacer(),
                        GestureDetector(
                        onTap: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsPage()),
                        ),
                          child: Icon(
                            _notifications
                                ? Icons.notifications_rounded
                                : Icons.notifications_off_outlined,
                            color: GJ.dark,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 3, color: GJ.blue),
                ],
              ),
            ),

            // ── PROFILE HEADER ────────────────────────────────
            SliverToBoxAdapter(child: _buildProfileHeader()),

            // ── STATS ─────────────────────────────────────────
            SliverToBoxAdapter(child: _buildStats()),

            // ── MY EXPERIENCES ────────────────────────────────
            SliverToBoxAdapter(child: _sectionLabel(t('experiences'), GJ.pink)),
            SliverToBoxAdapter(child: _cardRow(_kExperiences)),

            // ── BOOKMARKS ─────────────────────────────────────
            SliverToBoxAdapter(child: _sectionLabel(t('bookmarks'), GJ.yellow)),
            SliverToBoxAdapter(child: _cardRow(_kBookmarks)),

            // ── SETTINGS ──────────────────────────────────────
            SliverToBoxAdapter(child: _buildSettings()),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── Profile header ────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: GJ.dark, width: 2.5),
              boxShadow: const [
                BoxShadow(offset: Offset(3, 3), color: GJ.dark),
              ],
            ),
            child: ClipOval(
              child: Container(
                color: GJ.yellow,
                child: const Center(
                  child: Text(
                    'RA',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: GJ.dark,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rafi Ahmed', style: GJText.title),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: GJ.dark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '@rafi_explores',
                    style: GJText.tiny.copyWith(color: GJ.yellow),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 11,
                      color: GJ.dark.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Dhaka, Bangladesh',
                      style: GJText.tiny.copyWith(
                        color: GJ.dark.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit button
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  const Icon(Icons.edit_rounded, size: 12, color: GJ.dark),
                  const SizedBox(width: 5),
                  Text(t('edit'), style: GJText.tiny),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats strip ───────────────────────────────────────────
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: GJ.white,
          border: Border.all(color: GJ.dark, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(offset: Offset(3, 3), color: GJ.dark)],
        ),
        child: Row(
          children: [
            _statCell('12', t('shared'), GJ.pink, Icons.share_rounded, true),
            _statCell(
              '34',
              t('upvotes'),
              GJ.yellow,
              Icons.thumb_up_rounded,
              false,
            ),
            _statCell(
              '8',
              t('comments'),
              GJ.green,
              Icons.mode_comment_rounded,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCell(
    String val,
    String label,
    Color accent,
    IconData icon,
    bool first,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: first
              ? null
              : const Border(left: BorderSide(color: GJ.dark, width: 1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GJ.dark, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 13, color: GJ.dark),
                  const SizedBox(width: 4),
                  Text(val, style: GJText.title.copyWith(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GJText.tiny.copyWith(
                color: GJ.dark.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────
  Widget _sectionLabel(String title, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
      child: Row(
        children: [
          Container(width: 14, height: 3, color: accent),
          const SizedBox(width: 8),
          Text(title, style: GJText.label),
        ],
      ),
    );
  }

  // ── Horizontal card row ───────────────────────────────────
  Widget _cardRow(List<_ProfileExpCard> list) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 12),
        itemCount: list.length + 1,
        itemBuilder: (_, i) =>
            i == list.length ? _seeAllCard() : _destCard(list[i]),
      ),
    );
  }

  // ── Destination card ──────────────────────────────────────
  Widget _destCard(_ProfileExpCard d) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 12, bottom: 3),
      decoration: BoxDecoration(
        color: d.fallbackColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GJ.dark, width: 2),
        boxShadow: const [BoxShadow(offset: Offset(3, 3), color: GJ.dark)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.network(
                d.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: d.fallbackColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d.name,
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loadingBuilder: (_, child, p) {
                  if (p == null) return child;
                  return Container(
                    color: d.fallbackColor,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Gradient — strong bottom
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: GJ.white,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 4),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'by ${d.username}',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: GJ.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _cardPill(
                            '${d.days}d',
                            GJ.white.withValues(alpha: 0.15),
                          ),
                          const SizedBox(width: 6),
                          _cardPill(
                            '${d.attractions} spots',
                            GJ.white.withValues(alpha: 0.15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: GJ.yellow,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: GJ.dark, width: 1.5),
                              boxShadow: const [
                                BoxShadow(offset: Offset(2, 2), color: GJ.dark),
                              ],
                            ),
                            child: Text(
                              '৳ ${_fmt(d.price)}',
                              style: GJText.tiny.copyWith(fontSize: 11),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.thumb_up_rounded,
                                size: 11,
                                color: GJ.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${d.upvotes}',
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: GJ.white,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _cardPill(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: GJ.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: GJ.white,
        ),
      ),
    );
  }

  String _fmt(int p) {
    if (p >= 1000) {
      final k = p / 1000;
      return '${k == k.truncateToDouble() ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return '$p';
  }

  // ── See All card ──────────────────────────────────────────
  Widget _seeAllCard() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: GJ.yellow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: GJ.dark, width: 2),
          ),
          content: Text('Opening Explore 🗺️', style: GJText.label),
        ),
      ),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 20, bottom: 3),
        decoration: BoxDecoration(
          color: GJ.dark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GJ.dark, width: 2),
          boxShadow: const [BoxShadow(offset: Offset(3, 3), color: GJ.dark)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: GJ.yellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.explore_rounded,
                color: GJ.dark,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'See All',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: GJ.white,
              ),
            ),
            const Text(
              '→',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: GJ.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Settings block ────────────────────────────────────────
  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: GJ.white,
          border: Border.all(color: GJ.dark, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(offset: Offset(3, 3), color: GJ.dark)],
        ),
        child: Column(
          children: [
            // ── Language ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: GJ.blue,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GJ.dark, width: 2),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: GJ.dark,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(t('lang'), style: GJText.label),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _langChip('English'),
                      const SizedBox(width: 10),
                      _langChip('Bangla'),
                    ],
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: GJ.dark.withValues(alpha: 0.1),
            ),

            // ── Notifications ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: GJ.yellow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GJ.dark, width: 2),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: GJ.dark,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(t('notifs'), style: GJText.label)),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _notifications = !_notifications),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _notifications ? GJ.green : GJ.offWhite,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: GJ.dark, width: 2),
                        boxShadow: const [
                          BoxShadow(offset: Offset(2, 2), color: GJ.dark),
                        ],
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: _notifications
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: const BoxDecoration(
                            color: GJ.dark,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: GJ.dark.withValues(alpha: 0.1),
            ),

            // ── Log Out ─────────────────────────────────────
            GestureDetector(
              onTap: _logout,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: GJ.pink,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GJ.dark, width: 2),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: GJ.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('logout'),
                            style: GJText.label.copyWith(color: GJ.pink),
                          ),
                          Text(
                            t('logoutSub'),
                            style: GJText.tiny.copyWith(
                              color: GJ.dark.withValues(alpha: 0.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: GJ.pink),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langChip(String lang) {
    final sel = _lang == lang;
    return GestureDetector(
      onTap: () => setState(() => _lang = lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? GJ.dark : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: sel ? GJ.dark : GJ.dark.withValues(alpha: 0.2),
            width: sel ? 2 : 1.5,
          ),
          boxShadow: sel
              ? const [BoxShadow(offset: Offset(2, 2), color: GJ.dark)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lang == 'English' ? '🇬🇧' : '🇧🇩',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 6),
            Text(
              lang,
              style: GJText.tiny.copyWith(
                color: sel ? GJ.yellow : GJ.dark.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
