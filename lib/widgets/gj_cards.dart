import 'package:flutter/material.dart';

import '../gj_colors.dart';
import '../models/destination.dart';
import '../models/experience_feed.dart';
import 'experience_collage.dart';

// ─────────────────────────────────────────────────────────
//  GJ EXPERIENCE CARD  (used in Explore + Experiences pages)
// ─────────────────────────────────────────────────────────
class GJExperienceCard extends StatelessWidget {
  final ExperienceFeedItem exp;
  final bool bookmarked;
  final VoidCallback? onBookmark;
  final VoidCallback? onTap;

  const GJExperienceCard({
    super.key,
    required this.exp,
    this.bookmarked = false,
    this.onBookmark,
    this.onTap,
  });

  String _fmtCost(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : '$v';

  @override
  Widget build(BuildContext context) {
    return GJCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover collage ──
            Padding(
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ExperienceCollageSmall(
                  paths: exp.coverImagePaths,
                  height: 110,
                ),
              ),
            ),
            // ── Content ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.title,
                    style: GJText.label.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Destination pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: GJ.green,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: GJ.dark, width: 1.5),
                    ),
                    child: Text(
                      exp.destinationName,
                      style: GJText.tiny.copyWith(fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Stats row
                  Text(
                    '${exp.days}d · ${exp.attractions} spots · ৳${_fmtCost(exp.costBdt)}',
                    style: GJText.tiny.copyWith(
                      color: GJ.dark.withValues(alpha: 0.55),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Tags
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: exp.tags
                        .take(3)
                        .map((t) => GJTagPill(
                              tag: t,
                              color: GJ.blue,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  // Bottom: upvotes / comments / bookmark
                  Row(
                    children: [
                      const Icon(Icons.thumb_up_alt_outlined,
                          size: 14, color: GJ.dark),
                      const SizedBox(width: 4),
                      Text('${exp.upvotes}',
                          style: GJText.tiny.copyWith(fontSize: 11)),
                      const SizedBox(width: 12),
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 13, color: GJ.dark),
                      const SizedBox(width: 4),
                      Text('${exp.commentCount}',
                          style: GJText.tiny.copyWith(fontSize: 11)),
                      const Spacer(),
                      if (onBookmark != null)
                        GestureDetector(
                          onTap: onBookmark,
                          child: Icon(
                            bookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            size: 20,
                            color: bookmarked ? GJ.pink : GJ.dark,
                          ),
                        ),
                    ],
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

// ─────────────────────────────────────────────────────────
//  GJ DESTINATION CARD  (used in Explore + All Destinations)
// ─────────────────────────────────────────────────────────
class GJDestinationCard extends StatelessWidget {
  final DestinationSummary dest;
  final VoidCallback? onTap;

  const GJDestinationCard({
    super.key,
    required this.dest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GJCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Colored top panel with emoji ──
            Container(
              height: 86,
              width: double.infinity,
              decoration: BoxDecoration(
                color: dest.coverColor,
                border: const Border(
                    bottom: BorderSide(color: GJ.dark, width: 2)),
              ),
              child: Center(
                child: Text(dest.emoji,
                    style: const TextStyle(fontSize: 38)),
              ),
            ),
            // ── Info ──
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dest.name,
                    style: GJText.label.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dest.region,
                    style: GJText.tiny.copyWith(
                      fontSize: 9,
                      color: GJ.dark.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: GJ.yellow,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: GJ.dark, width: 1.5),
                          boxShadow: const [
                            BoxShadow(offset: Offset(1, 1), color: GJ.dark),
                          ],
                        ),
                        child: Text(
                          '৳${_fmtBudget(dest.budgetMin)}+',
                          style: GJText.tiny.copyWith(fontSize: 10),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${dest.attractionCount + dest.foodCount + dest.activityCount} spots',
                        style: GJText.tiny.copyWith(
                          fontSize: 9,
                          color: GJ.dark.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtBudget(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : '$v';
}

// ─────────────────────────────────────────────────────────
//  GJ DESTINATION CAROUSEL CARD  (wider version for Explore carousel)
// ─────────────────────────────────────────────────────────
class GJDestinationCarouselCard extends StatelessWidget {
  final DestinationSummary dest;
  final VoidCallback? onTap;

  const GJDestinationCarouselCard({
    super.key,
    required this.dest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: dest.coverColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GJ.dark, width: 2.5),
          boxShadow: const [BoxShadow(offset: Offset(4, 4), color: GJ.dark)],
        ),
        child: Stack(
          children: [
            // Big emoji center
            Center(
              child: Text(dest.emoji,
                  style: const TextStyle(fontSize: 64)),
            ),
            // Bottom bar with info
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: GJ.dark,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(13)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(dest.name,
                        style: GJText.label
                            .copyWith(color: GJ.white, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: GJ.yellow,
                            borderRadius: BorderRadius.circular(4),
                            border:
                                Border.all(color: GJ.white, width: 1),
                          ),
                          child: Text(
                            '৳${dest.budgetMin}+',
                            style: GJText.tiny.copyWith(fontSize: 9),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...dest.tags
                            .take(2)
                            .map((t) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: GJTagPill(tag: t, color: GJ.blue),
                                )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
