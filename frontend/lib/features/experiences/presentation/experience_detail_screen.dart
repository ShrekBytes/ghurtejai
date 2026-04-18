import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/config/app_config.dart';
import '../../../core/locale/app_strings.dart';
import '../../../core/network/ghurtejai_api.dart';
import '../../../core/utils/formatting.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';
import '../../../shared/widgets/experience_collage.dart';
import '../../../shared/widgets/gj_experience_vote.dart';
import '../../../shared/widgets/gj_standard_header.dart';
import '../../../shared/widgets/guest_gate.dart';

class ExperienceDetailScreen extends ConsumerStatefulWidget {
  const ExperienceDetailScreen({
    super.key,
    required this.slug,
    this.initialScrollToComments = false,
  });

  final String slug;
  final bool initialScrollToComments;

  @override
  ConsumerState<ExperienceDetailScreen> createState() =>
      _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends ConsumerState<ExperienceDetailScreen> {
  Map<String, dynamic>? _detail;
  List<Map<String, dynamic>> _comments = [];
  final _commentCtrl = TextEditingController();
  final _scroll = ScrollController();
  final _commentsKey = GlobalKey();
  bool _loading = true;
  var _didScrollToComments = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final api = ref.read(ghurtejaiApiProvider);
    try {
      final d = await api.fetchExperienceDetail(widget.slug);
      final id = (d['id'] as num).toInt();
      final c = await api.fetchComments(id);
      if (!mounted) return;
      setState(() {
        _detail = d;
        _comments = c;
        _loading = false;
      });
      if (widget.initialScrollToComments && !_didScrollToComments) {
        _didScrollToComments = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = _commentsKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _sendComment({int? parentId}) async {
    final auth = ref.read(authNotifierProvider).value;
    if (auth == null) {
      await showGuestSignInDialog(context);
      return;
    }
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _detail == null) return;
    final api = ref.read(ghurtejaiApiProvider);
    await api.postComment(
      (_detail!['id'] as num).toInt(),
      text: text,
      parentId: parentId,
    );
    _commentCtrl.clear();
    await _load();
  }

  Future<void> _confirmClone() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          appT(ctx, 'Clone experience?', 'অভিজ্ঞতা ক্লোন করবেন?'),
          style: GJText.title,
        ),
        content: Text(
          appT(
            ctx,
            'A full copy will be saved as a private experience.',
            'সম্পূর্ণ কপি ব্যক্তিগত অভিজ্ঞতা হিসেবে সংরক্ষিত হবে।',
          ),
          style: GJText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(appT(ctx, 'Cancel', 'বাতিল')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(appT(ctx, 'Clone', 'ক্লোন')),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(ghurtejaiApiProvider).cloneExperienceResult(widget.slug);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appT(
                context,
                'Cloned as a private experience',
                'ব্যক্তিগত অভিজ্ঞতা হিসেবে ক্লোন হয়েছে',
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteExperience() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          appT(ctx, 'Delete experience?', 'অভিজ্ঞতা মুছবেন?'),
          style: GJText.title,
        ),
        content: Text(
          appT(
            ctx,
            'This will remove your trip for you and readers.',
            'এটি আপনার ও পাঠকদের জন্য সফরটি সরিয়ে দেবে।',
          ),
          style: GJText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(appT(ctx, 'Cancel', 'বাতিল')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(appT(ctx, 'Delete', 'মুছুন')),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(ghurtejaiApiProvider).deleteExperience(widget.slug);
      if (mounted) context.go('/profile');
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider).value;
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: GJ.dark)),
      );
    }
    if (_detail == null) {
      return Scaffold(
        backgroundColor: GJTokens.tabCanvas,
        body: Center(
          child: Text(appT(context, 'Not found', 'পাওয়া যায়নি'), style: GJText.label),
        ),
      );
    }
    final d = _detail!;
    final cover = d['cover_image'] as String?;
    final url = cover != null && cover.isNotEmpty
        ? AppConfig.resolveMediaUrl(cover)
        : '';
    final pending = d['cover_image_pending'] == true;
    final paths = url.isEmpty ? <String>[] : [url, url, url, url];
    final author = d['author_username'] as String? ?? '';
    final authorId = (d['author'] as num?)?.toInt();
    final isOwner = auth != null && authorId != null && auth.id == authorId;
    final destSlug = d['destination_slug'] as String?;

    return Scaffold(
      backgroundColor: GJTokens.tabCanvas,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: GJStandardHeaderRow(
                  showBack: true,
                  title: appT(context, 'Experience', 'অভিজ্ঞতা'),
                  subtitle: appT(context, 'Itinerary & tips', 'সূচি ও টিপস'),
                  trailing: isOwner
                      ? PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert_rounded, color: GJTokens.onSurface),
                          onSelected: (v) async {
                            if (v == 'edit') {
                              context.push('/experience/${widget.slug}/edit');
                            } else if (v == 'del') {
                              await _deleteExperience();
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(appT(ctx, 'Edit', 'সম্পাদনা')),
                            ),
                            PopupMenuItem(
                              value: 'del',
                              child: Text(appT(ctx, 'Delete', 'মুছুন')),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GJCard(
                padding: const EdgeInsets.all(6),
                child: pending && paths.isEmpty
                    ? Shimmer.fromColors(
                        baseColor: GJTokens.surface,
                        highlightColor: GJ.white,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: GJ.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    : ExperienceCollageHero(paths: paths, height: 200),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: GJ.yellow,
                        child: Text(
                          author.isNotEmpty ? author[0].toUpperCase() : '?',
                          style: GJText.title,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['title'] as String? ?? '', style: GJText.title),
                            GestureDetector(
                              onTap: () => context.push('/u/$author'),
                              child: Text(
                                '@$author',
                                style: GJText.label.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (destSlug != null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => context.push('/destination/$destSlug'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: GJ.green,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: GJ.dark, width: 1.5),
                        ),
                        child: Text(
                          d['destination_name'] as String? ?? '',
                          style: GJText.tiny,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    appT(
                      context,
                      'Est. cost: ${formatMoneyBdt(d['estimated_cost'])} · '
                          'Days: ${(d['days'] as List?)?.length ?? 0}',
                      'আনুমানিক ব্যয়: ${formatMoneyBdt(d['estimated_cost'])} · '
                          'দিন: ${(d['days'] as List?)?.length ?? 0}',
                    ),
                    style: GJText.body,
                  ),
                  if ((d['user_cost'] as num?) != null)
                    Text(
                      appT(
                        context,
                        'Your spend: ${formatMoneyBdt(d['user_cost'])}',
                        'আপনার ব্যয়: ${formatMoneyBdt(d['user_cost'])}',
                      ),
                      style: GJText.tiny,
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      GJExperienceVoteBlock(
                        score: (d['score'] as num?)?.toInt() ?? 0,
                        userVote: (d['user_vote'] as num?)?.toInt() ?? 0,
                        axis: Axis.horizontal,
                        onVote: auth != null
                            ? (v) async {
                                await ref.read(ghurtejaiApiProvider).voteExperience(
                                  (d['id'] as num).toInt(),
                                  v,
                                );
                                await _load();
                              }
                            : (v) async {
                                await showGuestSignInDialog(context);
                              },
                      ),
                      if (auth != null) ...[
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: GJTokens.surfaceElevated,
                            foregroundColor: GJTokens.onSurface,
                          ),
                          onPressed: () async {
                            await ref.read(ghurtejaiApiProvider).toggleExperienceBookmark(
                                  (d['id'] as num).toInt(),
                                );
                            await _load();
                          },
                          icon: Icon(
                            (d['is_bookmarked'] == true)
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            color: (d['is_bookmarked'] == true) ? GJ.pink : GJTokens.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: _confirmClone,
                          child: Text(appT(context, 'Clone', 'ক্লোন'), style: GJText.label),
                        ),
                      ] else
                        TextButton(
                          onPressed: () => showGuestSignInDialog(context),
                          child: Text(
                            appT(context, 'Sign in to save or clone', 'সংরক্ষণ বা ক্লোনে সাইন ইন'),
                            style: GJText.label,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ..._daySlivers(context, d),
          SliverToBoxAdapter(
            key: _commentsKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_rounded, size: 22, color: GJTokens.accent),
                  const SizedBox(width: 8),
                  Text(
                    appT(context, 'Comments', 'মন্তব্য'),
                    style: GJText.title.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final c = _comments[i];
                return _CommentThread(
                  comment: c,
                  onVote: auth == null
                      ? null
                      : (id, val) async {
                          await ref.read(ghurtejaiApiProvider).voteComment(id, val);
                          await _load();
                        },
                  onReply: auth == null
                      ? null
                      : (parentId) async {
                          final t = await showDialog<String>(
                            context: context,
                            builder: (ctx) {
                              final ctrl = TextEditingController();
                              return AlertDialog(
                                title: Text(appT(ctx, 'Reply', 'উত্তর'), style: GJText.title),
                                content: TextField(
                                  controller: ctrl,
                                  decoration: InputDecoration(
                                    labelText: appT(ctx, 'Reply', 'উত্তর'),
                                  ),
                                  maxLines: 3,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(appT(ctx, 'Cancel', 'বাতিল')),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                                    child: Text(appT(ctx, 'Send', 'পাঠান')),
                                  ),
                                ],
                              );
                            },
                          );
                          if (t != null && t.isNotEmpty && _detail != null) {
                            await ref.read(ghurtejaiApiProvider).postComment(
                                  (_detail!['id'] as num).toInt(),
                                  text: t,
                                  parentId: parentId,
                                );
                            await _load();
                          }
                        },
                  onReport: auth == null
                      ? null
                      : (id) async {
                          final r = await showDialog<String>(
                            context: context,
                            builder: (ctx) {
                              final ctrl = TextEditingController();
                              return AlertDialog(
                                title: Text(appT(ctx, 'Report', 'রিপোর্ট'), style: GJText.title),
                                content: TextField(
                                  controller: ctrl,
                                  decoration: InputDecoration(
                                    labelText: appT(ctx, 'Reason', 'কারণ'),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(appT(ctx, 'Cancel', 'বাতিল')),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                                    child: Text(appT(ctx, 'Submit', 'জমা দিন')),
                                  ),
                                ],
                              );
                            },
                          );
                          if (r != null && r.isNotEmpty) {
                            await ref.read(ghurtejaiApiProvider).reportComment(id, r);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  appT(context, 'Report submitted', 'রিপোর্ট জমা হয়েছে'),
                                ),
                              ),
                            );
                          }
                        },
                  guest: auth == null,
                );
              },
              childCount: _comments.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GJTextField(
                    controller: _commentCtrl,
                    label: appT(context, 'Add a comment', 'মন্তব্য যোগ করুন'),
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GJButton(
                      label: appT(context, 'Post', 'পোস্ট'),
                      color: GJ.green,
                      fullWidth: false,
                      onTap: () => _sendComment(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _daySlivers(BuildContext context, Map<String, dynamic> d) {
    final days = (d['days'] as List<dynamic>?) ?? [];
    return [
      for (final day in days)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GJCard(
              backgroundColor: GJTokens.surfaceElevated,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: GJTokens.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(GJTokens.radiusSm),
                      border: Border.all(color: GJTokens.outline.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_view_day_rounded, size: 20, color: GJTokens.accent),
                        const SizedBox(width: 10),
                        Text(
                          appT(context, 'Day ${day['position']}', 'দিন ${day['position']}'),
                          style: GJText.title.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...((day['entries'] as List<dynamic>?) ?? []).map((e) {
                    final m = e as Map<String, dynamic>;
                    final badge = m['attraction'] != null
                        ? appT(context, ' · linked', ' · সংযুক্ত')
                        : '';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${m['time'] ?? ''}',
                            style: GJText.tiny,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${m['name']}$badge',
                                  style: GJText.label,
                                ),
                                if ((m['notes'] as String?)?.isNotEmpty == true)
                                  Text(m['notes'] as String, style: GJText.body),
                                Text(
                                  appT(
                                    context,
                                    'Cost: ${formatMoneyBdt(m['cost'])}',
                                    'ব্যয়: ${formatMoneyBdt(m['cost'])}',
                                  ),
                                  style: GJText.tiny,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  ],
                ),
              ),
            ),
          ),
    ];
  }
}

class _CommentThread extends StatelessWidget {
  const _CommentThread({
    required this.comment,
    this.onVote,
    this.onReply,
    this.onReport,
    this.guest = false,
    this.depth = 0,
  });

  final Map<String, dynamic> comment;
  final void Function(int commentId, int value)? onVote;
  final void Function(int parentId)? onReply;
  final void Function(int commentId)? onReport;
  final bool guest;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final id = (comment['id'] as num).toInt();
    final replies = (comment['replies'] as List<dynamic>?) ?? [];
    final score = comment['score'] as int? ?? 0;
    final uv = comment['user_vote'] as int? ?? 0;

    final scoreStyle = GJText.tiny.copyWith(
      fontWeight: FontWeight.w800,
      color: score > 0
          ? GJTokens.accent
          : score < 0
              ? GJTokens.danger
              : GJTokens.onSurface.withValues(alpha: 0.55),
    );

    return Padding(
      padding: EdgeInsets.only(left: depth * 14.0, right: 12, bottom: 10),
      child: GJCard(
        padding: const EdgeInsets.fromLTRB(8, 10, 10, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onVote != null) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(
                        uv == 1 ? Icons.arrow_upward_rounded : Icons.arrow_upward_outlined,
                        size: 20,
                        color: uv == 1 ? GJTokens.accent : GJTokens.onSurface.withValues(alpha: 0.45),
                      ),
                      onPressed: () => onVote!(id, 1),
                    ),
                    Text('$score', textAlign: TextAlign.center, style: scoreStyle),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(
                        uv == -1 ? Icons.arrow_downward_rounded : Icons.arrow_downward_outlined,
                        size: 20,
                        color:
                            uv == -1 ? GJTokens.danger : GJTokens.onSurface.withValues(alpha: 0.45),
                      ),
                      onPressed: () => onVote!(id, -1),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('$score', textAlign: TextAlign.center, style: scoreStyle),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '@${comment['author_username']}',
                          style: GJText.label.copyWith(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (onReport != null)
                        IconButton(
                          icon: Icon(Icons.flag_outlined, size: 18, color: GJTokens.onSurface.withValues(alpha: 0.45)),
                          onPressed: () => onReport!(id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comment['text'] as String? ?? '',
                    style: GJText.body,
                  ),
                  if (onReply != null && depth == 0) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => onReply!(id),
                        child: Text(
                          appT(context, 'Reply', 'উত্তর'),
                          style: GJText.tiny.copyWith(color: GJTokens.accent),
                        ),
                      ),
                    ),
                  ],
                  ...replies.map(
                    (r) => _CommentThread(
                      comment: Map<String, dynamic>.from(r as Map),
                      onVote: onVote,
                      onReply: onReply,
                      onReport: onReport,
                      guest: guest,
                      depth: depth + 1,
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
