import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/config/app_config.dart';
import '../theme/gj_colors.dart';
import '../theme/gj_tokens.dart';
import 'experience_collage.dart';
import 'gj_experience_vote.dart';

class ApiExperienceCard extends StatelessWidget {
  const ApiExperienceCard({
    super.key,
    required this.title,
    required this.destinationName,
    required this.coverUrl,
    required this.dayCount,
    required this.score,
    required this.comments,
    this.tags = const [],
    this.estimatedLabel,
    this.onTap,
    this.bookmarked = false,
    this.onBookmark,
    this.showBookmark = true,
    this.coverPending = false,
    this.authorUsername,
    this.description,
    this.createdAtIso,
    this.showAuthorRow = true,
    this.slug,
    this.experienceId,
    this.userVote = 0,
    this.onVote,
    this.onCommentTap,
    this.onClone,
    this.showActionRow = true,
    this.compactRail = false,
  });

  final String title;
  final String destinationName;
  final String? coverUrl;
  final bool coverPending;
  final int dayCount;
  final int score;
  final int comments;
  final List<String> tags;
  final String? estimatedLabel;
  final VoidCallback? onTap;
  final bool bookmarked;
  final VoidCallback? onBookmark;
  final bool showBookmark;
  final String? authorUsername;
  final String? description;
  final String? createdAtIso;
  final bool showAuthorRow;
  final String? slug;
  final int? experienceId;
  final int userVote;
  final Future<void> Function(int value)? onVote;
  final VoidCallback? onCommentTap;
  final VoidCallback? onClone;
  final bool showActionRow;

  /// Tighter card for horizontal carousels (avoids vertical overflow).
  final bool compactRail;

  List<String> get _paths {
    final u = coverUrl != null && coverUrl!.isNotEmpty
        ? AppConfig.resolveMediaUrl(coverUrl)
        : '';
    if (u.isEmpty) return [];
    return [u, u, u, u];
  }

  String _ago() {
    if (createdAtIso == null || createdAtIso!.isEmpty) return '';
    final t = DateTime.tryParse(createdAtIso!);
    if (t == null) return '';
    return timeago.format(t.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final au = authorUsername;
    final rail = compactRail;
    final collageH = rail ? 76.0 : 110.0;
    final showAuthor = !rail && showAuthorRow && au != null && au.isNotEmpty;
    return GJCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GJTokens.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(rail ? 4 : 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(GJTokens.radiusSm),
                child: coverPending && _paths.isEmpty
                    ? Shimmer.fromColors(
                        baseColor: GJ.offWhite,
                        highlightColor: GJ.white,
                        child: Container(
                          height: collageH,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: GJ.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    : ExperienceCollageSmall(paths: _paths, height: collageH),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(rail ? 10 : 12, rail ? 2 : 4, rail ? 10 : 12, rail ? 6 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showAuthor) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: GJ.yellow,
                          child: Text(
                            au.isNotEmpty ? au[0].toUpperCase() : '?',
                            style: GJText.tiny.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '@$au · ${_ago()}',
                            style: GJText.tiny.copyWith(
                              fontSize: 10,
                              color: GJ.dark.withValues(alpha: 0.65),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    title,
                    style: GJText.label.copyWith(
                      fontSize: rail ? 13 : 14,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: rail ? 2 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!rail &&
                      description != null &&
                      description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: GJText.body.copyWith(
                        fontSize: 12,
                        color: GJ.dark.withValues(alpha: 0.75),
                        height: 1.25,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: rail ? 4 : 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: GJ.green,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: GJ.dark, width: 1.5),
                        ),
                        child: Text(
                          destinationName,
                          style: GJText.tiny.copyWith(fontSize: 10),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: GJ.blue,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: GJ.dark, width: 1.5),
                        ),
                        child: Text(
                          '${dayCount}d',
                          style: GJText.tiny.copyWith(fontSize: 10),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: GJ.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: GJ.dark, width: 1.5),
                        ),
                        child: Text(
                          estimatedLabel ?? 'N/A',
                          style: GJText.tiny.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    SizedBox(height: rail ? 4 : 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags
                          .take(rail ? 2 : 4)
                          .map(
                            (t) => GJTagPill(
                              tag: t.replaceFirst('#', ''),
                              color: GJ.blue,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (showActionRow &&
                      (onCommentTap != null ||
                          onVote != null ||
                          onBookmark != null ||
                          onClone != null)) ...[
                    Divider(
                      height: 20,
                      thickness: 1,
                      color: GJTokens.outline.withValues(alpha: 0.1),
                    ),
                    Row(
                      children: [
                        if (onCommentTap != null)
                          IconButton(
                            onPressed: onCommentTap,
                            icon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 18,
                                  color: GJ.dark.withValues(alpha: 0.65),
                                ),
                                const SizedBox(width: 4),
                                Text('$comments', style: GJText.tiny),
                              ],
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (onVote != null) ...[
                          const SizedBox(width: 8),
                          GJExperienceVoteBlock(
                            score: score,
                            userVote: userVote,
                            axis: Axis.horizontal,
                            dense: true,
                            onVote: onVote,
                          ),
                        ],
                        if (showBookmark && onBookmark != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: onBookmark,
                            icon: Icon(
                              bookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                              size: 20,
                              color: bookmarked ? GJ.pink : GJ.dark,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                        if (onClone != null) ...[
                          const Spacer(),
                          IconButton(
                            onPressed: onClone,
                            icon: const Icon(Icons.copy_all_outlined, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ] else if (showBookmark && onBookmark != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onBookmark,
                        child: Icon(
                          bookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          size: 20,
                          color: bookmarked ? GJ.pink : GJ.dark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiDestinationCard extends StatelessWidget {
  const ApiDestinationCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.coverUrl,
    required this.attractionCount,
    required this.experienceCount,
    this.onTap,
    this.largeTile = false,
  });

  final String name;
  final String subtitle;
  final String? coverUrl;
  final int attractionCount;
  final int experienceCount;
  final VoidCallback? onTap;

  /// Taller image and type for prominent horizontal rails (e.g. Explore).
  final bool largeTile;

  @override
  Widget build(BuildContext context) {
    final url = coverUrl != null ? AppConfig.resolveMediaUrl(coverUrl) : '';
    final imgH = largeTile ? 128.0 : 86.0;
    final pad = largeTile ? 12.0 : 10.0;
    return GJCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GJTokens.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: imgH,
              width: double.infinity,
              child: url.isNotEmpty
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: GJ.blue,
                        child: const Center(
                          child: Icon(Icons.landscape_rounded, color: GJ.dark),
                        ),
                      ),
                    )
                  : Container(
                      color: GJ.yellow,
                      child: const Center(
                        child: Icon(Icons.place_rounded, color: GJ.dark, size: 40),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GJText.label.copyWith(
                      fontSize: largeTile ? 15 : 13,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: largeTile ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: largeTile ? 4 : 2),
                  Text(
                    subtitle,
                    style: GJText.tiny.copyWith(
                      fontSize: largeTile ? 11 : 9,
                      color: GJ.dark.withValues(alpha: 0.45),
                    ),
                    maxLines: largeTile ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: largeTile ? 8 : 6),
                  Text(
                    '$attractionCount attractions · $experienceCount experiences',
                    style: GJText.tiny.copyWith(fontSize: largeTile ? 11 : 10),
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
