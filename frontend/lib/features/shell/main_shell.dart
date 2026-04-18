import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/app_strings.dart';
import '../../shared/theme/gj_colors.dart';
import '../../shared/theme/gj_tokens.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: navigationShell,
        bottomNavigationBar: _GJBottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}

class _GJBottomNav extends StatelessWidget {
  const _GJBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.explore_rounded, Icons.explore_outlined),
    (Icons.map_rounded, Icons.map_outlined),
    (Icons.add_circle_rounded, Icons.add_circle_outline_rounded),
    (Icons.person_rounded, Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final labels = [
      appT(context, 'Explore', 'অন্বেষণ'),
      appT(context, 'Experiences', 'অভিজ্ঞতা'),
      appT(context, 'Create', 'তৈরি করুন'),
      appT(context, 'Profile', 'প্রোফাইল'),
    ];
    final bottom = MediaQuery.of(context).padding.bottom;
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    return Container(
      padding: EdgeInsets.only(bottom: bottom + 6, top: 6),
      decoration: BoxDecoration(
        color: GJTokens.surfaceElevated,
        border: const Border(top: BorderSide(color: GJTokens.outline, width: 2.5)),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final label = labels[i];
          final active = i == currentIndex;
          if (i == 2) {
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
                        border: active ? Border.all(color: GJ.dark, width: 2) : null,
                      ),
                      child: Icon(
                        active ? item.$1 : item.$2,
                        color: active ? GJ.dark : GJ.dark.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: labelStyle?.copyWith(
                        fontSize: 9,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? GJ.dark : GJ.dark.withValues(alpha: 0.4),
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
                      border: active ? Border.all(color: GJ.dark, width: 2) : null,
                    ),
                    child: Icon(
                      active ? item.$1 : item.$2,
                      color: active ? GJ.dark : GJ.dark.withValues(alpha: 0.4),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: labelStyle?.copyWith(
                      fontSize: 9,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: active ? GJ.dark : GJ.dark.withValues(alpha: 0.4),
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
