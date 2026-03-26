import 'package:flutter/material.dart';
import 'gj_colors.dart';
import 'login_page.dart';

// ─────────────────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────────────────
class Destination {
  final String name;
  final String country;
  final Color cardColor;
  final String emoji;
  final String tag;

  const Destination({
    required this.name,
    required this.country,
    required this.cardColor,
    required this.emoji,
    required this.tag,
  });
}

const List<Destination> kExperiences = [
  Destination(name: 'Sundarbans',   country: 'Bangladesh', cardColor: Color(0xFF4CAF82), emoji: '🌿', tag: 'Nature'),
  Destination(name: "Cox's Bazar",  country: 'Bangladesh', cardColor: Color(0xFF2196C8), emoji: '🏖️', tag: 'Beach'),
  Destination(name: 'Sajek Valley', country: 'Bangladesh', cardColor: Color(0xFF8BC34A), emoji: '⛰️', tag: 'Hills'),
  Destination(name: 'Sreemangal',   country: 'Bangladesh', cardColor: Color(0xFF4DB6AC), emoji: '🍃', tag: 'Tea'),
];

const List<Destination> kBookmarks = [
  Destination(name: 'Bhutan',      country: 'Bhutan',   cardColor: Color(0xFFE57C3A), emoji: '🏯', tag: 'Culture'),
  Destination(name: 'Darjeeling',  country: 'India',    cardColor: Color(0xFF7986CB), emoji: '🚂', tag: 'Hills'),
  Destination(name: 'Maldives',    country: 'Maldives', cardColor: Color(0xFF26C6DA), emoji: '🤿', tag: 'Resort'),
  Destination(name: 'Nepal',       country: 'Nepal',    cardColor: Color(0xFFEF5350), emoji: '🏔️', tag: 'Trek'),
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
  String _language      = 'English';
  bool   _notifications = true;

  // ── i18n strings ─────────────────────────────────────────
  final Map<String, Map<String, String>> _str = {
    'English': {
      'profile':       'Profile',
      'edit':          'Edit Profile ✏️',
      'experiences':   'My Experiences',
      'bookmarks':     'Bookmarks',
      'seeAll':        'See All →',
      'language':      'Language',
      'notifications': 'Notifications',
      'logout':        'Log Out',
      'logoutSub':     'See you on the next adventure!',
      'trips':         'Trips',
      'reviews':       'Reviews',
      'saved':         'Saved',
    },
    'Bangla': {
      'profile':       'প্রোফাইল',
      'edit':          'সম্পাদনা করুন ✏️',
      'experiences':   'আমার অভিজ্ঞতা',
      'bookmarks':     'বুকমার্ক',
      'seeAll':        'সব দেখুন →',
      'language':      'ভাষা',
      'notifications': 'বিজ্ঞপ্তি',
      'logout':        'লগ আউট',
      'logoutSub':     'পরের অ্যাডভেঞ্চারে দেখা হবে!',
      'trips':         'ট্রিপ',
      'reviews':       'রিভিউ',
      'saved':         'সংরক্ষিত',
    },
  };

  String t(String key) => _str[_language]?[key] ?? key;

  // ── Logout dialog ─────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GJ.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GJ.dark, width: 3),
            boxShadow: const [
              BoxShadow(offset: Offset(6, 6), color: GJ.dark),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✈️', style: TextStyle(fontSize: 42)),
              const SizedBox(height: 12),
              Text(t('logout'),
                  style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: GJ.dark)),
              const SizedBox(height: 8),
              Text(t('logoutSub'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: GJ.dark)),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: GJ.grey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GJ.dark, width: 2),
                      ),
                      child: const Center(
                        child: Text('Cancel',
                            style: TextStyle(
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: GJ.dark)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: GJ.pink,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GJ.dark, width: 2),
                        boxShadow: const [
                          BoxShadow(offset: Offset(3, 3), color: GJ.dark),
                        ],
                      ),
                      child: Center(
                        child: Text(t('logout'),
                            style: const TextStyle(
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: GJ.white)),
                      ),
                    ),
                  ),
                ),
              ]),
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
      backgroundColor: GJ.blue,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildStatsStrip()),
            SliverToBoxAdapter(child: _sectionTitle(t('experiences'), GJ.pink)),
            SliverToBoxAdapter(child: _cardRow(kExperiences)),
            SliverToBoxAdapter(child: _sectionTitle(t('bookmarks'), GJ.yellow)),
            SliverToBoxAdapter(child: _cardRow(kBookmarks)),
            SliverToBoxAdapter(child: _buildSettings()),
            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: GJ.yellow,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        children: [
          // top bar
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: GJ.dark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GJ.dark, width: 2),
              ),
              child: const Center(
                child: Text('GJ',
                    style: TextStyle(
                        color: GJ.yellow,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        fontFamily: 'Courier')),
              ),
            ),
            const SizedBox(width: 10),
            Text(t('profile'),
                style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: GJ.dark)),
            const Spacer(),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: GJ.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GJ.dark, width: 2),
              ),
              child: const Icon(Icons.notifications_rounded,
                  color: GJ.dark, size: 18),
            ),
          ]),

          const SizedBox(height: 18),

          // Avatar row
          Row(children: [
            Stack(children: [
              Container(
                width: 78, height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: GJ.dark, width: 3),
                  boxShadow: const [
                    BoxShadow(offset: Offset(3, 3), color: GJ.dark),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: GJ.pink,
                    child: const Center(
                      child: Text('🧳',
                          style: TextStyle(fontSize: 36)),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 2, bottom: 2,
                child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: GJ.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: GJ.dark, width: 2),
                  ),
                ),
              ),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tahmid Alam Tamim',
                      style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: GJ.dark)),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: GJ.dark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('@mr_explorer142',
                        style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: GJ.yellow)),
                  ),
                  const SizedBox(height: 5),
                  Row(children: const [
                    Icon(Icons.location_on_rounded,
                        size: 13, color: GJ.dark),
                    SizedBox(width: 2),
                    Text('Uttara, Dhaka, Bangladesh',
                        style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: GJ.dark)),
                  ]),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 14),

          // Edit button
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: GJ.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GJ.dark, width: 2.5),
                  boxShadow: const [
                    BoxShadow(offset: Offset(3, 3), color: GJ.dark),
                  ],
                ),
                child: Text(t('edit'),
                    style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: GJ.dark)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats strip ──────────────────────────────────────────
  Widget _buildStatsStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: GJ.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GJ.dark, width: 2.5),
        boxShadow: const [BoxShadow(offset: Offset(4, 4), color: GJ.dark)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat('12', t('trips'), GJ.pink),
          Container(width: 2, height: 36,
              color: GJ.dark.withOpacity(0.12)),
          _stat('34', t('reviews'), GJ.yellow),
          Container(width: 2, height: 36,
              color: GJ.dark.withOpacity(0.12)),
          _stat('8', t('saved'), GJ.green),
        ],
      ),
    );
  }

  Widget _stat(String val, String label, Color color) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: GJ.dark, width: 1.5),
        ),
        child: Text(val,
            style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: GJ.dark)),
      ),
      const SizedBox(height: 5),
      Text(label,
          style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: GJ.dark)),
    ]);
  }

  // ── Section title ─────────────────────────────────────────
  Widget _sectionTitle(String title, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Row(children: [
        Container(
          width: 5, height: 22,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: GJ.dark, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: GJ.dark)),
      ]),
    );
  }

  // ── Horizontal card row ───────────────────────────────────
  Widget _cardRow(List<Destination> list) {
    return SizedBox(
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 8),
        itemCount: list.length + 1,
        itemBuilder: (ctx, i) {
          if (i == list.length) return _seeAllCard();
          return _destCard(list[i]);
        },
      ),
    );
  }

  Widget _destCard(Destination d) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      decoration: BoxDecoration(
        color: d.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GJ.dark, width: 2.5),
        boxShadow: const [BoxShadow(offset: Offset(4, 4), color: GJ.dark)],
      ),
      child: Stack(children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: const CustomPaint(painter: _CardDotPainter()),
          ),
        ),
        Positioned(
          top: 10, left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: GJ.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: GJ.dark, width: 1.5),
            ),
            child: Text(d.tag,
                style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: GJ.dark)),
          ),
        ),
        Positioned(
          right: 8, top: 6,
          child: Text(d.emoji, style: const TextStyle(fontSize: 30)),
        ),
        Positioned(
          bottom: 10, left: 10, right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.name,
                  style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: GJ.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Row(children: [
                const Icon(Icons.location_on_rounded,
                    size: 10, color: GJ.white),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(d.country,
                      style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: GJ.white),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _seeAllCard() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: GJ.yellow,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: GJ.dark, width: 2),
            ),
            content: const Text('Navigating to Explore 🗺️',
                style: TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w700,
                    color: GJ.dark)),
          ),
        );
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 16, bottom: 4),
        decoration: BoxDecoration(
          color: GJ.dark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GJ.dark, width: 2.5),
          boxShadow: const [BoxShadow(offset: Offset(4, 4), color: GJ.dark)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                color: GJ.yellow,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.explore_rounded, color: GJ.dark, size: 22),
              ),
            ),
            const SizedBox(height: 10),
            const Text('See All',
                style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: GJ.white)),
            const Text('→',
                style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: GJ.yellow)),
          ],
        ),
      ),
    );
  }

  // ── Settings block ────────────────────────────────────────
  Widget _buildSettings() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      decoration: BoxDecoration(
        color: GJ.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GJ.dark, width: 2.5),
        boxShadow: const [BoxShadow(offset: Offset(5, 5), color: GJ.dark)],
      ),
      child: Column(children: [
        // Language
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _settingsIcon(Icons.language_rounded, GJ.blue),
                const SizedBox(width: 12),
                Text(t('language'),
                    style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: GJ.dark)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _langChip('English'),
                const SizedBox(width: 10),
                _langChip('Bangla'),
              ]),
            ],
          ),
        ),
        _divider(),

        // Notifications
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Row(children: [
            _settingsIcon(Icons.notifications_active_rounded, GJ.yellow),
            const SizedBox(width: 12),
            Expanded(
              child: Text(t('notifications'),
                  style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: GJ.dark)),
            ),
            GestureDetector(
              onTap: () => setState(() => _notifications = !_notifications),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58, height: 30,
                decoration: BoxDecoration(
                  color: _notifications ? GJ.green : GJ.grey,
                  borderRadius: BorderRadius.circular(30),
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
                    width: 22, height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: const BoxDecoration(
                        color: GJ.dark, shape: BoxShape.circle),
                    child: Icon(
                      _notifications
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: _notifications ? GJ.green : GJ.grey,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
        _divider(),

        // Logout
        GestureDetector(
          onTap: _showLogoutDialog,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Row(children: [
              _settingsIcon(Icons.logout_rounded, GJ.pink, iconColor: GJ.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('logout'),
                        style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: GJ.pink)),
                    Text(t('logoutSub'),
                        style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: GJ.dark.withOpacity(0.45))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: GJ.pink, size: 22),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _settingsIcon(IconData icon, Color bg,
      {Color iconColor = GJ.dark}) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GJ.dark, width: 2),
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }

  Widget _langChip(String lang) {
    final sel = _language == lang;
    return GestureDetector(
      onTap: () => setState(() => _language = lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? GJ.dark : GJ.grey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: GJ.dark, width: 2),
          boxShadow: sel
              ? const [BoxShadow(offset: Offset(3, 3), color: GJ.dark)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang == 'English' ? '🇬🇧' : '🇧🇩',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(lang,
                style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: sel ? GJ.yellow : GJ.dark)),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: GJ.dark.withOpacity(0.08));
  }
}

// ── Card dot painter (lighter) ────────────────────────────
class _CardDotPainter extends CustomPainter {
  const _CardDotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.15);
    for (double x = 0; x < size.width; x += 14) {
      for (double y = 0; y < size.height; y += 14) {
        canvas.drawCircle(Offset(x, y), 1.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
