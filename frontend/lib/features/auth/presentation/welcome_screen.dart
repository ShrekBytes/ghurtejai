import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/app_strings.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GJTokens.maxContentWidth),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      appT(context, 'Ghurtejai', 'ঘুরেতেজাই'),
                      style: GJText.display.copyWith(
                        fontSize: 36,
                        color: GJTokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appT(
                        context,
                        'Tour planning and experiences for Bangladesh.',
                        'বাংলাদেশের জন্য ট্যুর পরিকল্পনা ও অভিজ্ঞতা শেয়ারিং।',
                      ),
                      style: GJText.body.copyWith(
                        fontSize: 14,
                        color: GJTokens.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    const Spacer(),
                    GJButton(
                      label: appT(context, 'Sign In', 'সাইন ইন'),
                      color: GJ.yellow,
                      onTap: () => context.push('/login'),
                    ),
                    const SizedBox(height: 12),
                    GJButton(
                      label: appT(context, 'Create Account', 'অ্যাকাউন্ট তৈরি'),
                      color: GJ.pink,
                      onTap: () => context.push('/register'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/explore'),
                      child: Text(
                        appT(context, 'Continue as guest', 'অতিথি হিসেবে চালিয়ে যান'),
                        style: GJText.label.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: GJTokens.onSurface.withValues(alpha: 0.55),
                          color: GJTokens.onSurface.withValues(alpha: 0.75),
                        ),
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
