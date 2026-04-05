import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'models/experience_feed.dart';
import 'widgets/experience_collage.dart';

const Color _kReportAccent = Color(0xFFFF4D8D);

class ExperienceDetailPage extends StatefulWidget {
  final String experienceId;

  const ExperienceDetailPage({super.key, required this.experienceId});

  @override
  State<ExperienceDetailPage> createState() => _ExperienceDetailPageState();
}

class _ExperienceDetailPageState extends State<ExperienceDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();

  late ExperienceDetail _detail;
  late List<ExperienceComment> _comments;
  bool _bookmarked = false;
  int _localUpvoteDelta = 0;
  final Map<String, int> _commentVoteDelta = {};
  final Map<String, bool> _replyOpen = {};

  @override
  void initState() {
    super.initState();
    final d = experienceDetailById(widget.experienceId);
    if (d != null) {
      _detail = d;
      _comments = List<ExperienceComment>.from(d.comments);
    } else {
      _detail = ExperienceDetail(
        summary: ExperienceFeedItem(
          id: widget.experienceId,
          title: 'Not found',
          destinationName: '',
          entryCount: 0,
          attractions: 0,
          costBdt: 0,
          days: 0,
          tags: const [],
          upvotes: 0,
          commentCount: 0,
          coverImagePaths: const [],
          createdAt: DateTime.now(),
        ),
        itinerary: const [],
        comments: const [],
      );
      _comments = [];
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToComments() {
    final ctx = _commentsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onClone() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Clone will prefill Create — coming soon',
          style: AppText.body.copyWith(color: AppColors.bg),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onReport(ExperienceComment c) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Report comment?', style: AppText.title),
        content: Text(
          'Flag this comment for review.',
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppText.body),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reported', style: AppText.body),
                  backgroundColor: AppColors.surfaceHigh,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: _kReportAccent,
            ),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _detail.summary;
    if (s.title == 'Not found') {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          foregroundColor: AppColors.textPrimary,
          title: const Text('Experience'),
        ),
        body: Center(
          child: Text('Experience not found', style: AppText.body),
        ),
      );
    }

    final upvotes = s.upvotes + _localUpvoteDelta;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              s.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.title.copyWith(fontSize: 15),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 6, top: 8, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${s.days}d',
                  style: AppText.label.copyWith(
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: _bookmarked ? AppColors.primary : AppColors.textSub,
                ),
                onPressed: () => setState(() => _bookmarked = !_bookmarked),
              ),
              IconButton(
                icon: const Icon(Icons.thumb_up_outlined),
                onPressed: () => setState(() => _localUpvoteDelta += 1),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                onPressed: _scrollToComments,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 72, 12, 16),
                  child: ExperienceCollageHero(
                    paths: s.coverImagePaths,
                    height: 200,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _onClone,
                      icon: const Icon(Icons.copy_all_rounded, size: 18),
                      label: const Text('Clone'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      s.destinationName,
                      style: AppText.body.copyWith(
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (s.author != null)
                    Text(
                      '@${s.author}',
                      style: AppText.body.copyWith(fontSize: 12),
                    ),
                  Text(
                    '·  $upvotes upvotes',
                    style: AppText.label.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _StatRow(summary: s),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Itinerary', style: AppText.title.copyWith(fontSize: 17)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final e = _detail.itinerary[i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: _ItineraryCard(entry: e),
                );
              },
              childCount: _detail.itinerary.length,
            ),
          ),
          SliverToBoxAdapter(
            key: _commentsKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Comments',
                style: AppText.title.copyWith(fontSize: 17),
              ),
            ),
          ),
          if (_comments.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No comments yet.',
                  style: AppText.body,
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final c = _comments[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _CommentTile(
                      comment: c,
                      voteDelta: _commentVoteDelta[c.id] ?? 0,
                      onUp: () => setState(() {
                        _commentVoteDelta[c.id] =
                            (_commentVoteDelta[c.id] ?? 0) + 1;
                      }),
                      onDown: () => setState(() {
                        _commentVoteDelta[c.id] =
                            (_commentVoteDelta[c.id] ?? 0) - 1;
                      }),
                      replyOpen: _replyOpen[c.id] ?? false,
                      onToggleReply: () => setState(() {
                        _replyOpen[c.id] = !(_replyOpen[c.id] ?? false);
                      }),
                      onSubmitReply: (text) {
                        setState(() {
                          _comments.add(
                            ExperienceComment(
                              id: 'local_${DateTime.now().millisecondsSinceEpoch}',
                              author: 'you',
                              body: text,
                              upvotes: 1,
                              downvotes: 0,
                              createdAt: DateTime.now(),
                              parentId: c.id,
                            ),
                          );
                          _replyOpen[c.id] = false;
                        });
                      },
                      onReport: () => _onReport(c),
                      nested: c.parentId != null,
                    ),
                  );
                },
                childCount: _comments.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final ExperienceFeedItem summary;

  const _StatRow({required this.summary});

  String _k(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : '$v';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _cell(
              Icons.place_outlined,
              '${summary.attractions}',
              'Attractions',
            ),
          ),
          _sep(),
          Expanded(
            child: _cell(
              Icons.article_outlined,
              '${summary.entryCount}',
              'Entries',
            ),
          ),
          _sep(),
          Expanded(
            child: _cell(
              Icons.payments_outlined,
              '৳${_k(summary.costBdt)}',
              'Cost',
            ),
          ),
          _sep(),
          Expanded(
            child: _cell(
              Icons.calendar_today_rounded,
              '${summary.days}',
              'Days',
            ),
          ),
        ],
      ),
    );
  }

  Widget _sep() => Container(
        width: 1,
        height: 36,
        color: AppColors.border,
      );

  Widget _cell(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textSub),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppText.title.copyWith(fontSize: 13),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: AppText.label.copyWith(fontSize: 8),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ItineraryCard extends StatelessWidget {
  final ItineraryEntry entry;

  const _ItineraryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${entry.order}',
                  style: AppText.title.copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: AppText.title.copyWith(fontSize: 15)),
                    if (entry.timeStart != null || entry.timeEnd != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          [
                            if (entry.timeStart != null) entry.timeStart,
                            if (entry.timeEnd != null) entry.timeEnd,
                          ].join(' → '),
                          style: AppText.label.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(entry.body, style: AppText.body),
          const SizedBox(height: 8),
          Text(
            'Cost: ${entry.costLabel}',
            style: AppText.title.copyWith(
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              entry.note,
              style: AppText.body.copyWith(fontSize: 12, height: 1.45),
            ),
          ),
          if (entry.imagePaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entry.imagePaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 200,
                      child: ExperienceAssetImage(path: entry.imagePaths[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentTile extends StatefulWidget {
  final ExperienceComment comment;
  final int voteDelta;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final bool replyOpen;
  final VoidCallback onToggleReply;
  final void Function(String text) onSubmitReply;
  final VoidCallback onReport;
  final bool nested;

  const _CommentTile({
    required this.comment,
    required this.voteDelta,
    required this.onUp,
    required this.onDown,
    required this.replyOpen,
    required this.onToggleReply,
    required this.onSubmitReply,
    required this.onReport,
    this.nested = false,
  });

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  final _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;
    final score = c.score + widget.voteDelta;
    final initial = c.author.isNotEmpty
        ? c.author[0].toUpperCase()
        : '?';

    return Container(
      margin: EdgeInsets.only(left: widget.nested ? 20 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  initial,
                  style: AppText.title.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.author,
                      style: AppText.title.copyWith(fontSize: 13),
                    ),
                    Text(
                      c.body,
                      style: AppText.body.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$score',
                style: AppText.label.copyWith(fontSize: 11),
              ),
              const SizedBox(width: 4),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                color: AppColors.textSub,
                onPressed: widget.onUp,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                color: AppColors.textSub,
                onPressed: widget.onDown,
              ),
              TextButton(
                onPressed: widget.onToggleReply,
                child: Text(
                  'Reply',
                  style: AppText.body.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onReport,
                child: Text(
                  'Report',
                  style: AppText.body.copyWith(
                    color: _kReportAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (widget.replyOpen) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _replyCtrl,
              maxLines: 2,
              style: AppText.body.copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Write a reply…',
                hintStyle: AppText.body.copyWith(fontSize: 12),
                filled: true,
                fillColor: AppColors.surfaceHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  final t = _replyCtrl.text.trim();
                  if (t.isEmpty) return;
                  widget.onSubmitReply(t);
                  _replyCtrl.clear();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.bg,
                ),
                child: const Text('Post'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
