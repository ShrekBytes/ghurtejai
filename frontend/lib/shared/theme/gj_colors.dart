import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/gj_standard_header.dart';
import 'gj_palette.dart';
import 'gj_tokens.dart';
import 'gj_typography.dart';

export 'gj_palette.dart';
export 'gj_typography.dart';

// ─────────────────────────────────────────────────────────
//  HEADER BAR  (used by Login & Signup)
// ─────────────────────────────────────────────────────────
class GJHeader extends StatelessWidget {
  final bool showBack;
  const GJHeader({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: GJ.yellow,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: GJ.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GJ.dark, width: 2),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: GJ.dark,
                  size: 18,
                ),
              ),
            )
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: GJ.dark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GJ.dark, width: 2),
              ),
              child: const Center(
                child: Text(
                  'GJ',
                  style: TextStyle(
                    color: GJ.yellow,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ),
          const SizedBox(width: 10),
          const Text(
            'GhurteJai',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: GJ.dark,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: GJ.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: GJ.dark, width: 2),
            ),
            child: Row(
              children: const [
                Icon(Icons.explore_rounded, size: 14, color: GJ.dark),
                SizedBox(width: 5),
                Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Courier',
                    color: GJ.dark,
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
//  MINIMAL NAV BAR  (used by Profile)
// ─────────────────────────────────────────────────────────
class GJNavBar extends StatelessWidget {
  final String title;
  final bool showBack;
  const GJNavBar({super.key, required this.title, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GJ.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: GJ.dark, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: GJ.dark,
                ),
              ),
            )
          else
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
          Text(title, style: GJText.label),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  TEXT FIELD  (used by Login & Signup)
// ─────────────────────────────────────────────────────────
class GJTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final Color focusColor;
  final String? errorText;

  const GJTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.focusColor = GJ.pink,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Courier',
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Courier',
          fontWeight: FontWeight.w700,
          color: GJ.dark,
          fontSize: 13,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(icon, color: GJ.dark, size: 20),
        suffixIcon: onToggleObscure != null
            ? GestureDetector(
                onTap: onToggleObscure,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: GJ.dark,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: GJ.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GJ.dark, width: 2.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GJ.dark, width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusColor, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 3),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  GJField  (used by Profile settings — minimal style)
// ─────────────────────────────────────────────────────────
class GJField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggle;
  final TextInputType? keyboardType;
  final Color accentColor;
  final String? errorText;

  const GJField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.onToggle,
    this.keyboardType,
    this.accentColor = GJ.dark,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GJText.label.copyWith(fontSize: 14),
      cursorColor: accentColor,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        labelStyle: GJText.body.copyWith(color: GJ.dark.withValues(alpha:0.5)),
        errorStyle: GJText.tiny.copyWith(color: Colors.red),
        prefixIcon: Icon(icon, size: 18, color: GJ.dark.withValues(alpha:0.45)),
        suffixIcon: onToggle != null
            ? GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: GJ.dark.withValues(alpha:0.45),
                ),
              )
            : null,
        filled: true,
        fillColor: GJ.offWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: GJ.dark, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: GJ.dark.withValues(alpha:0.2), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentColor, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  PRIMARY BUTTON
// ─────────────────────────────────────────────────────────
class GJButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  /// Tighter padding, border, and type for inline CTAs (e.g. destination detail).
  final bool compact;

  /// When set, used for label text (e.g. white on a red button).
  final Color? foregroundColor;

  const GJButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = true,
    this.compact = false,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final pad = compact
        ? const EdgeInsets.symmetric(vertical: 10, horizontal: 14)
        : const EdgeInsets.symmetric(vertical: 15, horizontal: 20);
    final radius = compact ? 8.0 : 10.0;
    final borderW = compact ? 1.5 : 2.0;
    final shadow = compact
        ? const [BoxShadow(offset: Offset(2, 2), color: GJ.dark)]
        : const [BoxShadow(offset: Offset(3, 3), color: GJ.dark)];
    final base = compact
        ? GJText.label.copyWith(fontSize: 13, fontWeight: FontWeight.w800)
        : GJText.label;
    final textStyle =
        foregroundColor != null ? base.copyWith(color: foregroundColor) : base;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: pad,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: GJ.dark, width: borderW),
          boxShadow: shadow,
        ),
        child: Center(child: Text(label, style: textStyle)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  GHOST BUTTON  (secondary, border-only)
// ─────────────────────────────────────────────────────────
class GJGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const GJGhostButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: GJ.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: GJ.dark.withValues(alpha:0.25), width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: GJText.label.copyWith(color: GJ.dark.withValues(alpha:0.6)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  DOT PATTERN PAINTER
// ─────────────────────────────────────────────────────────
class DotPatternPainter extends CustomPainter {
  final Color color;
  const DotPatternPainter({this.color = const Color(0x22FFFFFF)});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (double x = 0; x < size.width; x += 18) {
      for (double y = 0; y < size.height; y += 18) {
        canvas.drawCircle(Offset(x, y), 2, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────
//  MOUNTAIN PAINTER  (Login hero)
// ─────────────────────────────────────────────────────────
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sun
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.28),
      26,
      Paint()..color = GJ.yellow,
    );
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.28),
      26,
      Paint()
        ..color = GJ.dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Back mountain
    final back = Path()
      ..moveTo(w * 0.42, h)
      ..lineTo(w * 0.62, h * 0.42)
      ..lineTo(w * 0.82, h)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0x44FFFFFF));
    canvas.drawPath(
      back,
      Paint()
        ..color = GJ.dark.withValues(alpha:0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Front mountain
    final front = Path()
      ..moveTo(w * 0.52, h)
      ..lineTo(w * 0.72, h * 0.32)
      ..lineTo(w * 0.92, h)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0x66FFFFFF));
    canvas.drawPath(
      front,
      Paint()
        ..color = GJ.dark.withValues(alpha:0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Snow cap
    final snow = Path()
      ..moveTo(w * 0.72, h * 0.32)
      ..lineTo(w * 0.68, h * 0.46)
      ..lineTo(w * 0.76, h * 0.46)
      ..close();
    canvas.drawPath(snow, Paint()..color = GJ.white.withValues(alpha:0.9));

    // Clouds
    _cloud(canvas, Offset(w * 0.55, h * 0.15), 18, GJ.white.withValues(alpha:0.5));
    _cloud(canvas, Offset(w * 0.65, h * 0.24), 13, GJ.white.withValues(alpha:0.3));
  }

  void _cloud(Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()..color = color;
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c.translate(r * 1.1, r * 0.2), r * 0.75, p);
    canvas.drawCircle(c.translate(-r * 0.9, r * 0.2), r * 0.65, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────
//  MAP PAINTER  (Signup hero)
// ─────────────────────────────────────────────────────────
class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final line = Paint()
      ..color = GJ.dark.withValues(alpha:0.18)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final route = Path()
      ..moveTo(w * 0.45, h * 0.9)
      ..cubicTo(w * 0.55, h * 0.6, w * 0.65, h * 0.7, w * 0.75, h * 0.45)
      ..cubicTo(w * 0.82, h * 0.3, w * 0.88, h * 0.35, w * 0.92, h * 0.2);
    canvas.drawPath(route, line);

    _pin(canvas, Offset(w * 0.75, h * 0.38), GJ.pink, 14);
    _pin(canvas, Offset(w * 0.92, h * 0.14), GJ.pink, 11);
    _pin(canvas, Offset(w * 0.60, h * 0.32), GJ.yellow, 10);
  }

  void _pin(Canvas canvas, Offset pos, Color color, double r) {
    canvas.drawCircle(pos, r, Paint()..color = color);
    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = GJ.dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(pos, r * 0.4, Paint()..color = GJ.dark);
    final tail = Path()
      ..moveTo(pos.dx - r * 0.5, pos.dy + r * 0.7)
      ..lineTo(pos.dx, pos.dy + r * 1.8)
      ..lineTo(pos.dx + r * 0.5, pos.dy + r * 0.7)
      ..close();
    canvas.drawPath(tail, Paint()..color = color);
    canvas.drawPath(
      tail,
      Paint()
        ..color = GJ.dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────
//  GJ CARD  (white card with 2px border and 3px offset shadow)
// ─────────────────────────────────────────────────────────
class GJCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double borderRadius;
  final double borderWidth;
  final bool hasShadow;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GJCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius = 12,
    this.borderWidth = 2,
    this.hasShadow = true,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? GJ.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: GJTokens.outline.withValues(alpha: 0.14),
          width: borderWidth,
        ),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: GJTokens.outline.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }
    return container;
  }
}

// ─────────────────────────────────────────────────────────
//  GJ CHIP  (filter / sort pill)
// ─────────────────────────────────────────────────────────
class GJChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  const GJChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor = GJ.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : GJ.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: GJ.dark, width: 2),
          boxShadow: selected
              ? const [BoxShadow(offset: Offset(2, 2), color: GJ.dark)]
              : null,
        ),
        child: Text(
          label,
          style: GJText.tiny.copyWith(fontSize: 11, color: GJ.dark),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  GJ TAG PILL  (hashtag pill: #Beach)
// ─────────────────────────────────────────────────────────
class GJTagPill extends StatelessWidget {
  final String tag;
  final Color color;

  const GJTagPill({
    super.key,
    required this.tag,
    this.color = GJ.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: GJ.dark, width: 1.5),
      ),
      child: Text(
        '#$tag',
        style: GJText.tiny.copyWith(fontSize: 10, color: GJ.dark),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  GJ SECTION LABEL
// ─────────────────────────────────────────────────────────
class GJSectionLabel extends StatelessWidget {
  final String title;
  final Color accent;
  final VoidCallback? onSeeAll;

  const GJSectionLabel({
    super.key,
    required this.title,
    this.accent = GJ.yellow,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accent, accent.withValues(alpha: 0.45)],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See all →',
                style: GJText.tiny.copyWith(
                  color: GJ.dark,
                  decoration: TextDecoration.underline,
                  decorationColor: GJ.dark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  GJ PAGE HEADER  (top bar used by all pages)
// ─────────────────────────────────────────────────────────
class GJPageHeader extends StatelessWidget {
  final String pageTitle;
  final String? pageSubtitle;
  final bool showBack;
  final bool showBell;
  final VoidCallback? onBell;
  final VoidCallback? onBack;
  final int? notificationUnreadCount;

  /// When set, used as the header trailing control instead of the bell.
  final Widget? trailing;

  const GJPageHeader({
    super.key,
    required this.pageTitle,
    this.pageSubtitle,
    this.showBack = false,
    this.showBell = false,
    this.onBell,
    this.onBack,
    this.notificationUnreadCount,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: GJStandardHeaderRow(
              title: pageTitle,
              subtitle: pageSubtitle,
              showBack: showBack,
              onBack: onBack,
              compactLogo: !showBack,
              trailing: trailing ??
                  (showBell
                      ? GJHeaderNotificationButton(
                          onPressed: onBell ?? () {},
                          unreadCount: notificationUnreadCount ?? 0,
                        )
                      : null),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  GJTokens.accent.withValues(alpha: 0.55),
                  GJTokens.accent.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  GJ SEARCH BAR
// ─────────────────────────────────────────────────────────
class GJSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const GJSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GJ.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GJ.dark, width: 2),
        boxShadow: const [BoxShadow(offset: Offset(3, 3), color: GJ.dark)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: GJ.dark, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: GJText.body.copyWith(fontSize: 14, color: GJ.dark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GJText.body.copyWith(
                  color: GJ.dark.withValues(alpha: 0.35),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                filled: false,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}
