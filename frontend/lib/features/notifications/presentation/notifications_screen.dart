import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/locale/app_strings.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/ghurtejai_api.dart';
import '../../../core/providers/unread_notifications.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final authState = ref.read(authNotifierProvider);
    if (authState.isLoading) {
      return;
    }
    final auth = authState.value;
    if (auth == null) {
      if (mounted) context.pushReplacement('/login');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(ghurtejaiApiProvider);
      final r = await api.fetchNotifications();
      setState(() {
        _items = r.results;
        _loading = false;
      });
      ref.invalidate(unreadNotificationCountProvider);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = formatApiError(e);
      });
    }
  }

  void _openItem(Map<String, dynamic> n) {
    final type = '${n['type'] ?? ''}';
    final expSlug = n['experience_slug'] as String?;
    final destSlug = n['destination_slug'] as String?;
    final attDestSlug = n['attraction_destination_slug'] as String?;

    if (expSlug != null && expSlug.isNotEmpty) {
      final commentTypes = {
        'COMMENT_ON_EXPERIENCE',
        'REPLY_TO_COMMENT',
        'UPVOTE_EXPERIENCE',
      };
      if (commentTypes.contains(type)) {
        context.push('/experience/$expSlug?comments=1');
      } else {
        context.push('/experience/$expSlug');
      }
      return;
    }
    if (destSlug != null && destSlug.isNotEmpty) {
      context.push('/destination/$destSlug');
      return;
    }
    if (attDestSlug != null && attDestSlug.isNotEmpty) {
      context.push('/destination/$attDestSlug');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    ref.listen<AsyncValue<AuthUser?>>(authNotifierProvider, (prev, next) {
      if (!mounted) return;
      if (next.isLoading) return;
      final nextUser = next.valueOrNull;
      if (nextUser != null && (prev?.valueOrNull?.id != nextUser.id)) {
        _load();
      }
      if (next.hasValue && nextUser == null) {
        context.pushReplacement('/login');
      }
    });

    Widget body;
    if (_loading) {
      body = Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: GJTokens.surfaceElevated,
          highlightColor: GJTokens.surface,
          child: Column(
            children: List.generate(
              6,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: GJTokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                    border: Border.all(color: GJTokens.outline.withValues(alpha: 0.1)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (_error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: GJText.body, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              GJButton(
                label: 'Retry',
                color: GJ.yellow,
                onTap: _load,
              ),
            ],
          ),
        ),
      );
    } else if (_items.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            appT(context, "You're all caught up!", 'সব আপডেট দেখে ফেলেছেন!'),
            style: GJText.body,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final n = _items[i];
          final read = n['is_read'] == true;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: read ? GJTokens.surfaceElevated : GJTokens.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(GJTokens.radiusMd),
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                side: BorderSide(color: GJTokens.outline.withValues(alpha: 0.1)),
              ),
              child: InkWell(
                onTap: () async {
                  await ref.read(ghurtejaiApiProvider).markNotificationRead(
                        (n['id'] as num).toInt(),
                      );
                  if (context.mounted) {
                    _openItem(n);
                    await _load();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n['message'] as String? ?? n['type'] as String? ?? '',
                        style: GJText.body,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${n['type']}',
                        style: GJText.tiny.copyWith(
                          color: GJTokens.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: GJTokens.tabCanvas,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GJPageHeader(
              pageTitle: appT(context, 'Notifications', 'নোটিফিকেশন'),
              pageSubtitle: appT(context, 'Loading…', 'লোড হচ্ছে…'),
              showBack: true,
            ),
            const Expanded(child: Center(child: CircularProgressIndicator(color: GJ.dark))),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: GJTokens.tabCanvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GJPageHeader(
            pageTitle: appT(context, 'Notifications', 'নোটিফিকেশন'),
            pageSubtitle: appT(context, 'Activity', 'কার্যকলাপ'),
            showBack: true,
            trailing: TextButton(
              onPressed: _loading
                  ? null
                  : () async {
                      await ref.read(ghurtejaiApiProvider).markAllNotificationsRead();
                      await _load();
                    },
              child: Text(
                appT(context, 'Mark all read', 'সব পঠিত চিহ্নিত করুন'),
                style: GJText.tiny,
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
