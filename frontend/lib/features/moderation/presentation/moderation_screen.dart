import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/locale/app_strings.dart';
import '../../../core/models/user.dart';
import '../../../core/network/ghurtejai_api.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';

class ModerationScreen extends ConsumerStatefulWidget {
  const ModerationScreen({super.key});

  @override
  ConsumerState<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends ConsumerState<ModerationScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _queue;
  Map<String, dynamic>? _stats;
  bool _loading = true;
  final _reason = TextEditingController();
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final authState = ref.read(authNotifierProvider);
    if (authState.isLoading) {
      return;
    }
    final auth = authState.value;
    if (auth == null || !auth.isModeratorOrAdmin) {
      if (mounted) context.pop();
      return;
    }
    setState(() => _loading = true);
    try {
      final api = ref.read(ghurtejaiApiProvider);
      final q = await api.moderationQueue(type: 'all');
      final s = await api.moderationStats();
      setState(() {
        _queue = q;
        _stats = s;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _reject(
    Future<void> Function(String?) call, {
    required bool needReason,
  }) async {
    _reason.clear();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appT(ctx, 'Reject', 'প্রত্যাখ্যান'), style: GJText.title),
        content: TextField(
          controller: _reason,
          decoration: InputDecoration(
            labelText: appT(ctx, 'Reason (required)', 'কারণ (প্রয়োজন)'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appT(ctx, 'Cancel', 'বাতিল')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _reason.text.trim()),
            child: Text(appT(ctx, 'Reject', 'প্রত্যাখ্যান')),
          ),
        ],
      ),
    );
    if (reason == null || (needReason && reason.isEmpty)) return;
    await call(reason.isEmpty ? null : reason);
    await _load();
  }

  @override
  void dispose() {
    _reason.dispose();
    _tabs.dispose();
    super.dispose();
  }

  int _badge(String key) {
    final s = _stats;
    if (s == null) return 0;
    return (s[key] as num?)?.toInt() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthUser?>>(authNotifierProvider, (prev, next) {
      if (!mounted) return;
      if (next.isLoading) return;
      _load();
    });

    if (_loading && _queue == null) {
      return Scaffold(
        backgroundColor: GJTokens.tabCanvas,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GJPageHeader(
              pageTitle: appT(context, 'Moderation', 'মডারেশন'),
              pageSubtitle: appT(context, 'Loading queue…', 'সারি লোড হচ্ছে…'),
              showBack: true,
            ),
            const Expanded(child: Center(child: CircularProgressIndicator(color: GJ.dark))),
          ],
        ),
      );
    }
    final dest = (_queue?['destinations'] as List<dynamic>?) ?? [];
    final att = (_queue?['attractions'] as List<dynamic>?) ?? [];
    final tr = (_queue?['transports'] as List<dynamic>?) ?? [];
    final exp = (_queue?['experiences'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: GJTokens.tabCanvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GJPageHeader(
            pageTitle: appT(context, 'Moderation', 'মডারেশন'),
            pageSubtitle: appT(context, 'Review queue', 'পর্যালোচনার সারি'),
            showBack: true,
          ),
          Material(
            color: GJTokens.surfaceElevated,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              labelColor: GJTokens.onSurface,
              unselectedLabelColor: GJTokens.onSurface.withValues(alpha: 0.45),
              indicatorColor: GJTokens.accent,
              indicatorWeight: 3,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              tabs: [
                Tab(
                  text: appT(
                    context,
                    'Destinations (${_badge('pending_destinations')})',
                    'গন্তব্য (${_badge('pending_destinations')})',
                  ),
                ),
                Tab(
                  text: appT(
                    context,
                    'Attractions (${_badge('pending_attractions')})',
                    'দর্শনীয় স্থান (${_badge('pending_attractions')})',
                  ),
                ),
                Tab(
                  text: appT(
                    context,
                    'Transport (${_badge('pending_transports')})',
                    'পরিবহন (${_badge('pending_transports')})',
                  ),
                ),
                Tab(
                  text: appT(
                    context,
                    'Experiences (${_badge('pending_experiences')})',
                    'অভিজ্ঞতা (${_badge('pending_experiences')})',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
          _list(
            dest,
            title: (m) => '${m['name']}',
            approve: (id) => ref.read(ghurtejaiApiProvider).moderateDestination(id, 'approve'),
            reject: (id, r) => ref.read(ghurtejaiApiProvider).moderateDestination(
                  id,
                  'reject',
                  rejectionReason: r ?? '',
                ),
          ),
          _list(
            att,
            title: (m) => '${m['name']}',
            approve: (id) => ref.read(ghurtejaiApiProvider).moderateAttraction(id, 'approve'),
            reject: (id, r) => ref.read(ghurtejaiApiProvider).moderateAttraction(
                  id,
                  'reject',
                  rejectionReason: r ?? '',
                ),
          ),
          _list(
            tr,
            title: (m) => '${m['from_location']} → ${m['to_location']}',
            approve: (id) => ref.read(ghurtejaiApiProvider).moderateTransport(id, 'approve'),
            reject: (id, r) => ref.read(ghurtejaiApiProvider).moderateTransport(
                  id,
                  'reject',
                  rejectionReason: r ?? '',
                ),
          ),
          _list(
            exp,
            title: (m) => '${m['title']}',
            approve: (id) => ref.read(ghurtejaiApiProvider).moderateExperience(id, 'approve'),
            reject: (id, r) => ref.read(ghurtejaiApiProvider).moderateExperience(
                  id,
                  'reject',
                  rejectionReason: r ?? '',
                ),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(
    List<dynamic> items, {
    required String Function(Map<String, dynamic>) title,
    required Future<void> Function(int id) approve,
    required Future<void> Function(int id, String? r) reject,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          appT(context, "Nothing pending — you're up to date!", 'অপেক্ষমাণ কিছু নেই — সব ঠিক আছে!'),
          style: GJText.body,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final raw = items[i] as Map<String, dynamic>;
        final id = (raw['id'] as num).toInt();
        return Dismissible(
          key: ValueKey('mod_${raw['id']}_$i'),
          background: Container(
            color: Colors.green.shade100,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: Text(appT(context, 'Approve', 'অনুমোদন')),
          ),
          secondaryBackground: Container(
            color: Colors.red.shade100,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Text(appT(context, 'Reject', 'প্রত্যাখ্যান')),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              await approve(id);
              await _load();
            } else {
              await _reject(
                (r) => reject(id, r),
                needReason: true,
              );
              await _load();
            }
            return false;
          },
          child: Card(
            child: ListTile(
              title: Text(title(raw), style: GJText.label),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_rounded),
                    onPressed: () async {
                      await approve(id);
                      await _load();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => _reject(
                      (r) => reject(id, r),
                      needReason: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
