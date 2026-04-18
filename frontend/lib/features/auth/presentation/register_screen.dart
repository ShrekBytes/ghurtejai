import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/locale/app_strings.dart';
import '../../../core/network/api_error.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/widgets/gj_auth_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _obscure = true;

  Future<void> _submit() async {
    if (_pw.text != _pw2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appT(context, 'Passwords do not match', 'পাসওয়ার্ড মিলছে না'))),
      );
      return;
    }
    await ref.read(authNotifierProvider.notifier).register(
          email: _email.text.trim(),
          username: _username.text.trim(),
          password: _pw.text,
          passwordConfirm: _pw2.text,
          firstName: _first.text.trim(),
          lastName: _last.text.trim(),
        );
    if (!mounted) return;
    final s = ref.read(authNotifierProvider);
    if (s.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(formatApiError(s.error))),
      );
      return;
    }
    if (s.hasValue && s.value != null) context.go('/explore');
  }

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _first.dispose();
    _last.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authNotifierProvider).isLoading;
    return GJAuthLayout(
      title: appT(context, 'Create account', 'অ্যাকাউন্ট তৈরি'),
      subtitle: appT(
        context,
        'Share itineraries and bookmark places across Bangladesh.',
        'সফরসূচি শেয়ার ও বাংলাদেশ জুড়ে স্থান বুকমার্ক করুন।',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GJTextField(
            controller: _email,
            label: appT(context, 'Email', 'ইমেইল'),
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          GJTextField(
            controller: _username,
            label: appT(context, 'Username', 'ইউজারনেম'),
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 10),
          GJTextField(
            controller: _first,
            label: appT(context, 'First name', 'নামের প্রথম অংশ'),
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 10),
          GJTextField(
            controller: _last,
            label: appT(context, 'Last name', 'নামের শেষ অংশ'),
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 10),
          GJTextField(
            controller: _pw,
            label: appT(context, 'Password', 'পাসওয়ার্ড'),
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
          ),
          const SizedBox(height: 10),
          GJTextField(
            controller: _pw2,
            label: appT(context, 'Confirm password', 'পাসওয়ার্ড নিশ্চিত করুন'),
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
          ),
          const SizedBox(height: 20),
          GJButton(
            label: loading ? '...' : appT(context, 'Create account', 'অ্যাকাউন্ট তৈরি'),
            color: GJ.yellow,
            onTap: loading ? () {} : _submit,
          ),
        ],
      ),
    );
  }
}
