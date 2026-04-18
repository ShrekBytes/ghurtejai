import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/app_strings.dart';
import '../theme/gj_colors.dart';

Future<void> showGuestSignInDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: GJ.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: GJ.dark, width: 2),
      ),
      title: Text(
        appT(ctx, 'Sign in required', 'সাইন ইন প্রয়োজন'),
        style: GJText.title.copyWith(fontSize: 18),
      ),
      content: Text(
        appT(
          ctx,
          'Create an account or sign in to use this feature.',
          'এই ফিচার ব্যবহারে অ্যাকাউন্ট তৈরি করুন বা সাইন ইন করুন।',
        ),
        style: GJText.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(appT(ctx, 'Cancel', 'বাতিল'), style: GJText.label),
        ),
        GJButton(
          label: appT(ctx, 'Sign In', 'সাইন ইন'),
          color: GJ.yellow,
          fullWidth: false,
          onTap: () {
            Navigator.pop(ctx);
            context.push('/login');
          },
        ),
      ],
    ),
  );
}

/// Create tab previously opened a dialog; callers may still reference this name
/// after hot reload. Navigates to login (no dialog).
Future<void> showCreateTabGuestDialog(BuildContext context) {
  return context.push<void>('/login');
}
