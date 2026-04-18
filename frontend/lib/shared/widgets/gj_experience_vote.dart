import 'package:flutter/material.dart';

import '../theme/gj_tokens.dart';

/// Reddit-style up / net score / down. POST `{"value": 1|-1}`; same value again removes.
class GJExperienceVoteBlock extends StatelessWidget {
  const GJExperienceVoteBlock({
    super.key,
    required this.score,
    required this.userVote,
    this.axis = Axis.vertical,
    this.dense = false,
    this.onVote,
  });

  /// Net upvotes minus downvotes (may be negative).
  final int score;

  /// Current user's vote: -1, 0, or 1.
  final int userVote;
  final Axis axis;
  final bool dense;

  /// Called with `1` (up) or `-1` (down). Backend removes the vote if it matches the current one.
  final Future<void> Function(int value)? onVote;

  Future<void> _run(int value) async {
    final fn = onVote;
    if (fn == null) return;
    await fn(value);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final canInteract = onVote != null;

    Color upColor() {
      if (!canInteract) return GJTokens.onSurface.withValues(alpha: 0.28);
      if (userVote == 1) return GJTokens.accent;
      return GJTokens.onSurface.withValues(alpha: 0.55);
    }

    Color downColor() {
      if (!canInteract) return GJTokens.onSurface.withValues(alpha: 0.28);
      if (userVote == -1) return GJTokens.danger;
      return GJTokens.onSurface.withValues(alpha: 0.55);
    }

    Widget arrowUp() {
      return Icon(Icons.arrow_upward_rounded, size: dense ? 20 : 22, color: upColor());
    }

    Widget arrowDown() {
      return Icon(Icons.arrow_downward_rounded, size: dense ? 20 : 22, color: downColor());
    }

    final scoreColor = score > 0
        ? GJTokens.accent
        : score < 0
            ? GJTokens.danger
            : GJTokens.onSurface;

    final scoreStyle = (dense ? tt.labelMedium : tt.titleSmall)?.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.1,
      color: scoreColor,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: axis == Axis.vertical ? (dense ? 4 : 6) : 6,
        vertical: axis == Axis.vertical ? (dense ? 2 : 4) : 4,
      ),
      decoration: BoxDecoration(
        color: GJTokens.surfaceElevated,
        borderRadius: BorderRadius.circular(GJTokens.radiusMd),
        border: Border.all(color: GJTokens.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: GJTokens.outline.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: axis == Axis.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _VoteInk(
                  onTap: canInteract ? () => _run(1) : null,
                  child: arrowUp(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('$score', style: scoreStyle),
                ),
                _VoteInk(
                  onTap: canInteract ? () => _run(-1) : null,
                  child: arrowDown(),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _VoteInk(
                  onTap: canInteract ? () => _run(1) : null,
                  child: arrowUp(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('$score', style: scoreStyle),
                ),
                _VoteInk(
                  onTap: canInteract ? () => _run(-1) : null,
                  child: arrowDown(),
                ),
              ],
            ),
    );
  }
}

class _VoteInk extends StatelessWidget {
  const _VoteInk({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: child,
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: child,
        ),
      ),
    );
  }
}
