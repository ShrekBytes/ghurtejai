import 'package:flutter/material.dart';
import 'gj_colors.dart';
import 'models/experience_feed.dart';
import 'widgets/experience_collage.dart';

// ─────────────────────────────────────────────────────────
//  EXPERIENCE DETAIL PAGE
// ─────────────────────────────────────────────────────────
class ExperienceDetailPage extends StatefulWidget {
  final String experienceId;
  const ExperienceDetailPage({super.key, required this.experienceId});

  @override
  State<ExperienceDetailPage> createState() => _ExperienceDetailPageState();
}

class _ExperienceDetailPageState extends State<ExperienceDetailPage> {
  bool _bookmarked = false;
  bool _upvoted = false;
  final _commentCtrl = TextEditingController();
  final Map<String, int> _votes = {};

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = experienceDetailById(widget.experienceId);
    if (detail == null) {
      return Scaffold(
        backgroundColor: GJ.offWhite,
        body: Center(
          child: Text('Experience not found', style: GJText.label),
        ),
      );
    }
    final exp = detail.summary;
    final itinerary = detail.itinerary;
    final comments = detail.comments;

    return Scaffold(
      backgroundColor: GJ.offWhite,
      body: CustomScrollView(
        slivers: [
          // ── Header with collage ──
          SliverToBoxAdapter(
            child: GJPageHeader(pageTitle: exp.title, showBack: true),
          ),

          // ── Collage hero ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GJCard(
                padding: const EdgeInsets.all(6),
                child: ExperienceCollageHero(
                  paths: exp.coverImagePaths,
                  height: 220,
                ),
              ),
            ),
          ),

          // ── Title + meta ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exp.title,
                      style: GJText.title.copyWith(fontSize: 20)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: GJ.green,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: GJ.dark, width: 1.5),
                          boxShadow: const [
                            BoxShadow(offset: Offset(2, 2), color: GJ.dark),
                          ],
                        ),
                        child: Text(
                          exp.destinationName,
                          style: GJText.tiny.copyWith(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (exp.author != null)
                        Text(
                          'by @${exp.author}',
                          style: GJText.tiny.copyWith(
                            color: GJ.dark.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Stats strip ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: GJCard(
                child: Row(
                  children: [
                    _statCell('${exp.days}', 'days', GJ.yellow, true),
                    _statCell('${exp.entryCount}', 'entries', GJ.blue, false),
                    _statCell('${exp.attractions}', 'spots', GJ.pink, false),
                    _statCell(
                        '৳${_fmt(exp.costBdt)}', 'est. cost', GJ.green, false),
                  ],
                ),
              ),
            ),
          ),

          // ── Tags ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: exp.tags
                    .map((t) => GJTagPill(tag: t, color: GJ.blue))
                    .toList(),
              ),
            ),
          ),

          // ── Action buttons ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.thumb_up_alt_rounded,
                      label: _upvoted
                          ? 'Upvoted (${exp.upvotes + 1})'
                          : 'Upvote (${exp.upvotes})',
                      color: _upvoted ? GJ.yellow : GJ.white,
                      onTap: () => setState(() => _upvoted = !_upvoted),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: _bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      label: _bookmarked ? 'Saved' : 'Save',
                      color: _bookmarked ? GJ.pink : GJ.white,
                      onTap: () => setState(() => _bookmarked = !_bookmarked),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.content_copy_rounded,
                      label: 'Clone',
                      color: GJ.green,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Itinerary cloned!',
                                style: GJText.label),
                            backgroundColor: GJ.yellow,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: GJ.dark, width: 2),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Itinerary ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Container(width: 4, height: 20, color: GJ.yellow),
                  const SizedBox(width: 10),
                  Text('Itinerary',
                      style: GJText.label.copyWith(fontSize: 14)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _ItineraryEntry(
                    entry: itinerary[i],
                    isLast: i == itinerary.length - 1),
                childCount: itinerary.length,
              ),
            ),
          ),

          // ── Comments ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Container(width: 4, height: 20, color: GJ.pink),
                  const SizedBox(width: 10),
                  Text(
                      'Comments (${comments.length})',
                      style: GJText.label.copyWith(fontSize: 14)),
                ],
              ),
            ),
          ),
          // Comment input
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: GJ.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GJ.dark, width: 2),
                      ),
                      child: TextField(
                        controller: _commentCtrl,
                        style: GJText.body.copyWith(
                            fontSize: 13, color: GJ.dark),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: GJText.body.copyWith(
                            color: GJ.dark.withValues(alpha: 0.35),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _commentCtrl.clear()),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: GJ.yellow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GJ.dark, width: 2),
                        boxShadow: const [
                          BoxShadow(offset: Offset(2, 2), color: GJ.dark),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: GJ.dark, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Comment list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final c = comments[i];
                  final vote = _votes[c.id] ?? 0;
                  return _CommentTile(
                    comment: c,
                    userVote: vote,
                    onUpvote: () => setState(() {
                      _votes[c.id] = vote == 1 ? 0 : 1;
                    }),
                    onDownvote: () => setState(() {
                      _votes[c.id] = vote == -1 ? 0 : -1;
                    }),
                  );
                },
                childCount: comments.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell(
      String val, String label, Color accent, bool first) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: first
              ? null
              : const Border(left: BorderSide(color: GJ.dark, width: 1)),
        ),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: GJ.dark, width: 1.5),
              ),
              child: Text(val,
                  style: GJText.label.copyWith(fontSize: 12)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GJText.tiny.copyWith(
                color: GJ.dark.withValues(alpha: 0.5),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int p) {
    if (p >= 1000) {
      final k = p / 1000;
      return '${k == k.truncateToDouble() ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return '$p';
  }
}

// ─────────────────────────────────────────────────────────
//  ACTION BUTTON
// ─────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: GJ.dark, width: 2),
          boxShadow: const [BoxShadow(offset: Offset(2, 2), color: GJ.dark)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: GJ.dark),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: GJText.tiny.copyWith(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  ITINERARY ENTRY TILE
// ─────────────────────────────────────────────────────────
class _ItineraryEntry extends StatelessWidget {
  final ItineraryEntry entry;
  final bool isLast;

  const _ItineraryEntry({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: GJ.yellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: GJ.dark, width: 2),
                  boxShadow: const [
                    BoxShadow(offset: Offset(2, 2), color: GJ.dark),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${entry.order}',
                    style: GJText.tiny.copyWith(fontSize: 11),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: GJ.dark.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GJCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: GJText.label.copyWith(fontSize: 13),
                          ),
                        ),
                        if (entry.timeStart != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: GJ.blue,
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: GJ.dark, width: 1.5),
                            ),
                            child: Text(
                              entry.timeStart!,
                              style: GJText.tiny.copyWith(fontSize: 9),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      entry.body,
                      style: GJText.body.copyWith(
                          color: GJ.dark.withValues(alpha: 0.65),
                          fontSize: 12),
                    ),
                    if (entry.note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GJ.yellow.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: GJ.dark.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 11)),
                            Expanded(
                              child: Text(
                                entry.note,
                                style: GJText.tiny.copyWith(
                                  fontSize: 10,
                                  color: GJ.dark.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: GJ.green,
                            borderRadius: BorderRadius.circular(4),
                            border:
                                Border.all(color: GJ.dark, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                  offset: Offset(1, 1), color: GJ.dark),
                            ],
                          ),
                          child: Text(
                            entry.costLabel,
                            style: GJText.tiny.copyWith(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    // Entry images
                    if (entry.imagePaths.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: entry.imagePaths.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 70,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: GJ.dark, width: 1.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ExperienceAssetImage(
                                    path: entry.imagePaths[i]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  COMMENT TILE
// ─────────────────────────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final ExperienceComment comment;
  final int userVote;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const _CommentTile({
    required this.comment,
    required this.userVote,
    required this.onUpvote,
    required this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    final score = comment.score + userVote;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10,
        left: comment.parentId != null ? 24 : 0,
      ),
      child: GJCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: GJ.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: GJ.dark, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      comment.author[0].toUpperCase(),
                      style: GJText.tiny.copyWith(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@${comment.author}',
                        style: GJText.label.copyWith(fontSize: 12)),
                    Text(
                      '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                      style: GJText.tiny.copyWith(
                        fontSize: 9,
                        color: GJ.dark.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.body,
              style: GJText.body.copyWith(
                  color: GJ.dark.withValues(alpha: 0.75), fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _VoteButton(
                  icon: Icons.arrow_upward_rounded,
                  active: userVote == 1,
                  activeColor: GJ.green,
                  onTap: onUpvote,
                ),
                const SizedBox(width: 4),
                Text(
                  '$score',
                  style: GJText.tiny.copyWith(
                    color: score > 0
                        ? GJ.green
                        : score < 0
                            ? GJ.pink
                            : GJ.dark,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                _VoteButton(
                  icon: Icons.arrow_downward_rounded,
                  active: userVote == -1,
                  activeColor: GJ.pink,
                  onTap: onDownvote,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _VoteButton({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 22,
        decoration: BoxDecoration(
          color: active ? activeColor : GJ.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: GJ.dark, width: 1.5),
        ),
        child: Icon(icon, size: 12, color: GJ.dark),
      ),
    );
  }
}
