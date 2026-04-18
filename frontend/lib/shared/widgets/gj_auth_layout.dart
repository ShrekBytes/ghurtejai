import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/gj_tokens.dart';

/// Shared chrome for sign-in flows: soft gradient, centered card, consistent header.
class GJAuthLayout extends StatelessWidget {
  const GJAuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: GJTokens.authGradient,
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: GJTokens.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showBack)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: GJTokens.surfaceElevated,
                            side: const BorderSide(color: GJTokens.outline, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                            ),
                          ),
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded, color: GJTokens.onSurface),
                        ),
                      ),
                    SizedBox(height: showBack ? 12 : 0),
                    Text(
                      title,
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        style: tt.bodyMedium?.copyWith(
                          color: GJTokens.onSurface.withValues(alpha: 0.68),
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Material(
                      color: GJTokens.surfaceElevated,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GJTokens.radiusLg),
                        side: const BorderSide(color: GJTokens.outline, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
