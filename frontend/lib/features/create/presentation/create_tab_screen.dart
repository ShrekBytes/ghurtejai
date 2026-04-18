import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/locale/app_strings.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';
import 'create_experience_screen.dart';

/// Create tab opens the builder; guests see sign-in CTAs on this screen.
class CreateTabScreen extends ConsumerWidget {
  const CreateTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider).value;
    if (auth == null) {
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: GJTokens.maxContentWidth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appT(context, 'Create an experience', 'একটি অভিজ্ঞতা তৈরি করুন'),
                        style: GJText.title.copyWith(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        appT(
                          context,
                          'Sign in to build day-by-day itineraries and share them with travelers.',
                          'দিনভিত্তিক সফরসূচি তৈরি ও ভ্রমণকারীদের সাথে শেয়ার করতে সাইন ইন করুন।',
                        ),
                        style: GJText.body,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      GJButton(
                        label: appT(context, 'Sign In', 'সাইন ইন'),
                        color: GJ.yellow,
                        onTap: () => context.push('/login'),
                      ),
                      const SizedBox(height: 10),
                      GJGhostButton(
                        label: appT(context, 'Create Account', 'অ্যাকাউন্ট তৈরি'),
                        onTap: () => context.push('/register'),
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
    return const CreateExperienceScreen();
  }
}
