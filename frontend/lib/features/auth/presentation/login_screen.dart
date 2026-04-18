import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/locale/app_strings.dart';
import '../../../core/network/api_error.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';
import '../../../shared/widgets/gj_auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _submitted = false;

  String? _identifierError(BuildContext context) {
    if (!_submitted) return null;
    final v = _identifier.text.trim();
    if (v.isEmpty) {
      return appT(context, 'Email or username is required', 'ইমেইল বা ইউজারনেম প্রয়োজন');
    }
    if (v.contains('@')) {
      final ok = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w]{2,}$').hasMatch(v);
      if (!ok) {
        return appT(context, 'Enter a valid email address', 'সঠিক ইমেইল লিখুন');
      }
    }
    return null;
  }

  String? _passwordError(BuildContext context) {
    if (!_submitted) return null;
    if (_password.text.isEmpty) {
      return appT(context, 'Password is required', 'পাসওয়ার্ড প্রয়োজন');
    }
    if (_password.text.length < 8) {
      return appT(context, 'At least 8 characters', 'কমপক্ষে ৮ অক্ষর');
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_identifierError(context) != null || _passwordError(context) != null) return;
    await ref.read(authNotifierProvider.notifier).login(
          _identifier.text.trim(),
          _password.text,
        );
    if (!mounted) return;
    final s = ref.read(authNotifierProvider);
    if (s.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(formatApiError(s.error))),
      );
      return;
    }
    if (s.hasValue && s.value != null) {
      context.go('/explore');
    }
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authNotifierProvider).isLoading;
    return GJAuthLayout(
      title: appT(context, 'Sign in', 'সাইন ইন'),
      subtitle: appT(
        context,
        'Welcome back — pick up where your last trip left off.',
        'স্বাগতম — আপনার গত সফর থেকে চালিয়ে যান।',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GJTextField(
            controller: _identifier,
            label: appT(context, 'Email or username', 'ইমেইল বা ইউজারনেম'),
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.text,
            errorText: _identifierError(context),
          ),
          const SizedBox(height: 14),
          GJTextField(
            controller: _password,
            label: appT(context, 'Password', 'পাসওয়ার্ড'),
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
            errorText: _passwordError(context),
          ),
          const SizedBox(height: 24),
          GJButton(
            label: loading ? '...' : appT(context, 'Sign In', 'সাইন ইন'),
            color: GJ.yellow,
            onTap: loading ? () {} : _submit,
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => context.push('/register'),
            child: Text(appT(context, 'Create account', 'অ্যাকাউন্ট তৈরি'), style: GJText.label),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.go('/explore'),
            icon: Icon(Icons.travel_explore_rounded, color: GJTokens.accent, size: 20),
            label: Text(
              appT(context, 'Explore as guest', 'অতিথি হিসেবে এক্সপ্লোর'),
              style: GJText.label.copyWith(color: GJTokens.onSurface),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: GJTokens.onSurface,
              side: BorderSide(color: GJTokens.outline.withValues(alpha: 0.28), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GJTokens.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
