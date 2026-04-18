import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/config/app_config.dart';
import '../../../core/locale/app_locale_provider.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/ghurtejai_api.dart';
import '../../../core/locale/app_strings.dart';
import '../../../core/providers/unread_notifications.dart';
import '../../../core/utils/formatting.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';
import '../../../shared/widgets/feed_cards.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _mine = [];
  List<Map<String, dynamic>> _destBm = [];
  List<Map<String, dynamic>> _expBm = [];
  bool _loading = true;
  bool _uploadingAvatar = false;

  /// `all` | `published` | `private` — API `scope` (`private` = non‑public visibility).
  String _mineScope = 'all';

  /// DRF `ordering` param (whitelist on backend).
  String _mineOrdering = '-created_at';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final authState = ref.read(authNotifierProvider);
    if (authState.isLoading) {
      return;
    }
    final auth = authState.value;
    if (auth == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _mine = [];
          _destBm = [];
          _expBm = [];
        });
      }
      return;
    }
    if (mounted) setState(() => _loading = true);
    final api = ref.read(ghurtejaiApiProvider);
    try {
      final m = await api.fetchMyExperiences(scope: _mineScope, ordering: _mineOrdering);
      final db = await api.fetchDestinationBookmarks();
      final eb = await api.fetchExperienceBookmarks();
      setState(() {
        _mine = m.results;
        _destBm = db.results;
        _expBm = eb.results;
        _loading = false;
      });
      ref.invalidate(unreadNotificationCountProvider);
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _reloadMineOnly() async {
    final auth = ref.read(authNotifierProvider).value;
    if (auth == null) return;
    try {
      final m = await ref.read(ghurtejaiApiProvider).fetchMyExperiences(
            scope: _mineScope,
            ordering: _mineOrdering,
          );
      if (mounted) setState(() => _mine = m.results);
    } catch (_) {}
  }

  String _avatarDisplayUrl(AuthUser auth) {
    final u = auth.avatarUrl;
    if (u == null || u.isEmpty) return '';
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    return AppConfig.resolveMediaUrl(u);
  }

  Future<void> _onAvatarTap(AuthUser auth) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: GJTokens.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GJTokens.radiusLg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_rounded),
              title: Text(appT(ctx, 'View avatar', 'ছবি দেখুন'), style: GJText.label),
              onTap: () {
                Navigator.pop(ctx);
                _viewAvatar(auth);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(appT(ctx, 'Change avatar', 'ছবি বদলান'), style: GJText.label),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadAvatar();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewAvatar(AuthUser auth) {
    final url = _avatarDisplayUrl(auth);
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appT(context, 'No profile photo yet.', 'এখনও কোনো প্রোফাইল ছবি নেই।'))),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: GJTokens.surfaceElevated,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final auth = ref.read(authNotifierProvider).value;
    if (auth == null) return;
    final picker = ImagePicker();
    final f = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200, imageQuality: 88);
    if (f == null || !mounted) return;
    setState(() => _uploadingAvatar = true);
    try {
      await ref.read(ghurtejaiApiProvider).patchMyProfile(avatarFilePath: f.path);
      await ref.read(authNotifierProvider.notifier).refreshProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appT(context, 'Profile photo updated.', 'প্রোফাইল ছবি আপডেট হয়েছে।'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatApiError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Widget _buildAvatar(AuthUser auth) {
    final url = _avatarDisplayUrl(auth);
    final letter = auth.username.isNotEmpty ? auth.username[0].toUpperCase() : '?';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _uploadingAvatar ? null : () => _onAvatarTap(auth),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: GJ.yellow,
              child: url.isEmpty
                  ? Text(letter, style: GJText.title)
                  : ClipOval(
                      child: Image.network(
                        url,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Text(letter, style: GJText.title),
                      ),
                    ),
            ),
            if (_uploadingAvatar)
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(strokeWidth: 2, color: GJ.dark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMineFilters(BuildContext context) {
    void setScope(String s) {
      if (_mineScope == s) return;
      setState(() => _mineScope = s);
      _reloadMineOnly();
    }

    Widget chip(String value, String en, String bn) {
      final sel = _mineScope == value;
      return GJChip(
        label: appT(context, en, bn),
        selected: sel,
        onTap: () => setScope(value),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(appT(context, 'Show', 'দেখান'), style: GJText.tiny.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                chip('all', 'All', 'সব'),
                const SizedBox(width: 8),
                chip('published', 'Published', 'প্রকাশিত'),
                const SizedBox(width: 8),
                chip('private', 'Private', 'ব্যক্তিগত'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(appT(context, 'Sort', 'সাজান'), style: GJText.tiny.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _mineOrdering,
            decoration: InputDecoration(
              filled: true,
              fillColor: GJ.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: [
              _sortItem('-created_at', 'Newest first', 'নতুন প্রথমে'),
              _sortItem('created_at', 'Oldest first', 'পুরনো প্রথমে'),
              _sortItem('-comment_count', 'Most comments', 'সবচেয়ে বেশি মন্তব্য'),
              _sortItem('-score', 'Most upvotes', 'সবচেয়ে বেশি ভোট'),
              _sortItem('score', 'Least upvotes', 'কম ভোট'),
              _sortItem('estimated_cost', 'Cost: low → high', 'খরচ: কম থেকে বেশি'),
              _sortItem('-estimated_cost', 'Cost: high → low', 'খরচ: বেশি থেকে কম'),
              _sortItem('title', 'Title A–Z', 'শিরোনাম ক–খ'),
              _sortItem('-title', 'Title Z–A', 'শিরোনাম খ–ক'),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _mineOrdering = v);
              _reloadMineOnly();
            },
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _sortItem(String value, String en, String bn) {
    return DropdownMenuItem(
      value: value,
      child: Text(appT(context, en, bn), style: GJText.tiny),
    );
  }

  Widget _buildMineTab(BuildContext context) {
    return RefreshIndicator(
      color: GJ.dark,
      onRefresh: _load,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMineFilters(context),
          Expanded(
            child: _mine.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Text(
                              appT(
                                context,
                                'No experiences match these filters.',
                                'এই ফিল্টারে কোনো অভিজ্ঞতা নেই।',
                              ),
                              style: GJText.body,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            GJButton(
                              label: appT(context, 'Create experience', 'অভিজ্ঞতা তৈরি করুন'),
                              color: GJ.yellow,
                              onTap: () => context.go('/create'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: _mine.length,
                    itemBuilder: (context, i) {
                      final x = _mine[i];
                      final st = experienceStatusShortLabel(x['status'] as String?);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: GJ.blue,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: GJ.dark, width: 1.5),
                              ),
                              child: Text(st, style: GJText.tiny),
                            ),
                            const SizedBox(height: 6),
                            ApiExperienceCard(
                              title: x['title'] as String? ?? '',
                              destinationName: x['destination_name'] as String? ?? '',
                              coverUrl: x['cover_image'] as String?,
                              coverPending: x['cover_image_pending'] == true,
                              dayCount: (x['day_count'] as num?)?.toInt() ?? 0,
                              score: (x['score'] as num?)?.toInt() ?? 0,
                              comments: (x['comment_count'] as num?)?.toInt() ?? 0,
                              estimatedLabel: formatMoneyBdt(x['estimated_cost']),
                              authorUsername: x['author_username'] as String?,
                              description: x['description'] as String?,
                              createdAtIso: x['created_at'] as String?,
                              onTap: () => context.push('/experience/${x['slug']}'),
                              showBookmark: false,
                              showActionRow: false,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    ref.listen<AsyncValue<AuthUser?>>(authNotifierProvider, (prev, next) {
      if (!mounted) return;
      final prevUser = prev?.valueOrNull;
      final nextUser = next.valueOrNull;
      if (prevUser?.id != nextUser?.id) {
        _load();
      }
      if (next.hasValue && nextUser == null && !next.isLoading) {
        setState(() {
          _mine = [];
          _destBm = [];
          _expBm = [];
          _loading = false;
        });
      }
    });

    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: GJTokens.surface,
        body: const Center(child: CircularProgressIndicator(color: GJ.dark)),
      );
    }

    final auth = authState.value;
    final mod = auth?.isModeratorOrAdmin == true;
    final unread = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

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
                        appT(context, 'Join Ghurtejai', 'Ghurtejai-তে যোগ দিন'),
                        style: GJText.display.copyWith(fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        appT(
                          context,
                          'Sign in to save experiences and bookmarks.',
                          'অভিজ্ঞতা ও বুকমার্ক সংরক্ষণে সাইন ইন করুন।',
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

    return Scaffold(
      backgroundColor: GJTokens.tabCanvas,
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: GJTokens.tabCanvas,
            foregroundColor: GJ.dark,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('@${auth.username}', style: GJText.label),
              background: Container(color: GJTokens.accent.withValues(alpha: 0.12)),
            ),
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: GJ.pink,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: GJ.dark, width: 1.5),
                        ),
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: GJText.tiny.copyWith(fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (v) async {
                  if (v == 'mod' && mod) context.push('/moderation');
                  if (v == 'lang_en') {
                    ref.read(appLocaleProvider.notifier).state = const Locale('en');
                  }
                  if (v == 'lang_bn') {
                    ref.read(appLocaleProvider.notifier).state = const Locale('bn');
                  }
                  if (v == 'out') {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) context.go('/explore');
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'lang_en',
                    child: Text(appT(context, 'English', 'English')),
                  ),
                  PopupMenuItem(
                    value: 'lang_bn',
                    child: const Text('বাংলা'),
                  ),
                  if (mod)
                    PopupMenuItem(
                      value: 'mod',
                      child: Text(appT(context, 'Moderation', 'মডারেশন')),
                    ),
                  PopupMenuItem(
                    value: 'out',
                    child: Text(appT(context, 'Log out', 'লগ আউট')),
                  ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _buildAvatar(auth),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [auth.firstName, auth.lastName]
                              .where((e) => (e ?? '').isNotEmpty)
                              .join(' ')
                              .trim()
                              .isEmpty
                              ? auth.username
                              : '${auth.firstName ?? ''} ${auth.lastName ?? ''}'.trim(),
                          style: GJText.title.copyWith(fontSize: 18),
                        ),
                        Text(
                          auth.email,
                          style: GJText.tiny.copyWith(color: GJ.dark.withValues(alpha: 0.6)),
                        ),
                        Text(
                          '${_mine.length} ${appT(context, 'experiences', 'অভিজ্ঞতা')} · ${_destBm.length + _expBm.length} ${appT(context, 'bookmarks', 'বুকমার্ক')}',
                          style: GJText.tiny,
                        ),
                        Text(
                          appT(context, 'Tap photo to view or change', 'ছবিতে ট্যাপ করে দেখুন বা বদলান'),
                          style: GJText.tiny.copyWith(color: GJ.dark.withValues(alpha: 0.45)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tab,
                labelColor: GJ.dark,
                unselectedLabelColor: GJ.dark.withValues(alpha: 0.5),
                indicatorColor: GJ.dark,
                tabs: [
                  Tab(text: appT(context, 'My Experiences', 'আমার অভিজ্ঞতা')),
                  Tab(text: appT(context, 'Bookmarks', 'বুকমার্ক')),
                ],
              ),
            ),
          ),
        ],
        body: _loading
            ? Center(
                child: Shimmer.fromColors(
                  baseColor: GJ.offWhite,
                  highlightColor: GJ.white,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GJ.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            : TabBarView(
                controller: _tab,
                children: [
                  _buildMineTab(context),
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: GJ.dark,
                          tabs: [
                            Tab(text: appT(context, 'Destinations', 'গন্তব্য')),
                            Tab(text: appT(context, 'Experiences', 'অভিজ্ঞতা')),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              RefreshIndicator(
                                color: GJ.dark,
                                onRefresh: _load,
                                child: _destBm.isEmpty
                                    ? ListView(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        padding: const EdgeInsets.all(32),
                                        children: [
                                          Text(
                                            appT(context, 'Nothing saved yet.', 'এখনও কিছু সংরক্ষিত নেই।'),
                                            style: GJText.body,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(12),
                                        itemCount: _destBm.length,
                                        itemBuilder: (context, i) {
                                          final b = _destBm[i];
                                          final name = b['destination_name'] as String? ?? '';
                                          final slug = b['destination_slug'] as String? ?? '';
                                          return ListTile(
                                            title: Text(name, style: GJText.label),
                                            trailing: const Icon(Icons.chevron_right),
                                            onTap: () => context.push('/destination/$slug'),
                                          );
                                        },
                                      ),
                              ),
                              RefreshIndicator(
                                color: GJ.dark,
                                onRefresh: _load,
                                child: _expBm.isEmpty
                                    ? ListView(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        padding: const EdgeInsets.all(32),
                                        children: [
                                          Text(
                                            appT(context, 'Nothing saved yet.', 'এখনও কিছু সংরক্ষিত নেই।'),
                                            style: GJText.body,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(12),
                                        itemCount: _expBm.length,
                                        itemBuilder: (context, i) {
                                          final b = _expBm[i];
                                          final slug = b['experience_slug'] as String? ?? '';
                                          final title = b['experience_title'] as String? ?? '';
                                          return ListTile(
                                            title: Text(title, style: GJText.label),
                                            trailing: const Icon(Icons.chevron_right),
                                            onTap: () => context.push('/experience/$slug'),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: GJTokens.surface, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}
