import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/gj_tokens.dart';

/// Consistent top row: brand or back, title, optional trailing (e.g. notifications).
class GJStandardHeaderRow extends StatelessWidget {
  const GJStandardHeaderRow({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.trailing,
    this.compactLogo = false,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  /// When false (home / tab roots), shows trail icon in a round badge instead of back.
  final bool compactLogo;

  static BoxDecoration _iconShell(BuildContext context) {
    return BoxDecoration(
      color: GJTokens.surfaceElevated,
      borderRadius: BorderRadius.circular(GJTokens.radiusMd),
      border: Border.all(color: GJTokens.outline.withValues(alpha: 0.14)),
      boxShadow: [
        BoxShadow(
          color: GJTokens.outline.withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBack)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack ?? () => context.pop(),
              borderRadius: BorderRadius.circular(GJTokens.radiusMd),
              child: Ink(
                decoration: _iconShell(context),
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(Icons.arrow_back_rounded, color: GJTokens.onSurface, size: 22),
                ),
              ),
            ),
          )
        else
          Container(
            width: 42,
            height: 42,
            decoration: _iconShell(context).copyWith(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GJTokens.accent.withValues(alpha: 0.9),
                  GJTokens.accent.withValues(alpha: 0.65),
                ],
              ),
              border: Border.all(color: GJTokens.outline.withValues(alpha: 0.2)),
            ),
            child: Icon(
              compactLogo ? Icons.route_rounded : Icons.explore_rounded,
              color: GJTokens.onAccent,
              size: 22,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(
                    color: GJTokens.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Notification icon with badge; use as [GJStandardHeaderRow.trailing].
class GJHeaderNotificationButton extends StatelessWidget {
  const GJHeaderNotificationButton({
    super.key,
    required this.onPressed,
    this.unreadCount = 0,
  });

  final VoidCallback onPressed;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(GJTokens.radiusMd),
            child: Ink(
              decoration: BoxDecoration(
                color: GJTokens.surfaceElevated,
                borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                border: Border.all(color: GJTokens.outline.withValues(alpha: 0.14)),
                boxShadow: [
                  BoxShadow(
                    color: GJTokens.outline.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(Icons.notifications_outlined, color: GJTokens.onSurface, size: 22),
              ),
            ),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D8D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GJTokens.outline, width: 1.2),
              ),
              constraints: const BoxConstraints(minWidth: 18),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: GJTokens.onAccent,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
