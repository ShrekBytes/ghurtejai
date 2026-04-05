import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gj_colors.dart';
import 'login_page.dart';
import 'explore.dart';
import 'experiences_page.dart';
import 'create_experience_page.dart';
import 'profile_page.dart';

void main() {
  runApp(const GhurtejaiApp());
}

class GhurtejaiApp extends StatelessWidget {
  const GhurtejaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GhurteJai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Courier',
        scaffoldBackgroundColor: GJ.white,
        colorScheme: ColorScheme.light(
          primary: GJ.yellow,
          onPrimary: GJ.dark,
          surface: GJ.white,
          onSurface: GJ.dark,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  MAIN SCAFFOLD  (bottom nav shell for authenticated users)
// ─────────────────────────────────────────────────────────
class MainScaffold extends StatefulWidget {
  final int initialIndex;
  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  static const List<Widget> _pages = [
    ExplorePage(),
    ExperiencesPage(),
    CreateExperiencePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: GJ.white,
        body: IndexedStack(
          index: _index,
          children: _pages,
        ),
        bottomNavigationBar: _GJBottomNav(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  NEOBRUTALISM BOTTOM NAV BAR
// ─────────────────────────────────────────────────────────
class _GJBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GJBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
    (Icons.map_rounded, Icons.map_outlined, 'Experiences'),
    (Icons.add_circle_rounded, Icons.add_circle_outline_rounded, 'Create'),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottom + 6, top: 6),
      decoration: const BoxDecoration(
        color: GJ.white,
        border: Border(top: BorderSide(color: GJ.dark, width: 2.5)),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final active = i == currentIndex;
          // Create tab gets special yellow circle treatment
          if (i == 2) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: active ? GJ.yellow : GJ.dark,
                        shape: BoxShape.circle,
                        border: Border.all(color: GJ.dark, width: 2),
                        boxShadow: active
                            ? [const BoxShadow(offset: Offset(3, 3), color: GJ.dark)]
                            : null,
                      ),
                      child: Icon(
                        active ? item.$1 : item.$2,
                        color: active ? GJ.dark : GJ.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.$3,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 9,
                        fontWeight:
                            active ? FontWeight.w900 : FontWeight.w700,
                        color:
                            active ? GJ.dark : GJ.dark.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 36,
                    decoration: BoxDecoration(
                      color: active ? GJ.yellow : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: active
                          ? Border.all(color: GJ.dark, width: 2)
                          : null,
                    ),
                    child: Icon(
                      active ? item.$1 : item.$2,
                      color: active
                          ? GJ.dark
                          : GJ.dark.withValues(alpha: 0.4),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.$3,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 9,
                      fontWeight:
                          active ? FontWeight.w900 : FontWeight.w700,
                      color:
                          active ? GJ.dark : GJ.dark.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

