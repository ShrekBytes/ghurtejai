import 'package:flutter/material.dart';
import 'gj_colors.dart';

// ─────────────────────────────────────────────────────────
//  NOTIFICATION MODEL
// ─────────────────────────────────────────────────────────
enum _NotifType {
  upvote,
  comment,
  reply,
  approved,
  rejected,
}

class _Notif {
  final _NotifType type;
  final String message;
  final String timestamp;
  bool read;

  _Notif({
    required this.type,
    required this.message,
    required this.timestamp,
    this.read = false,
  });
}

final List<_Notif> _mockNotifs = [
  _Notif(
    type: _NotifType.upvote,
    message: 'faysal_bd upvoted your experience "Cox\'s Bazar by sadib"',
    timestamp: '2 min ago',
    read: false,
  ),
  _Notif(
    type: _NotifType.comment,
    message: 'nabila_t commented on your experience: "Would add Himchari half-day if you have time."',
    timestamp: '15 min ago',
    read: false,
  ),
  _Notif(
    type: _NotifType.approved,
    message: 'Your attraction submission "Laboni Beach" was approved! 🎉',
    timestamp: '1 hour ago',
    read: true,
  ),
  _Notif(
    type: _NotifType.reply,
    message: 'hill_hopper replied to your comment on "2 Day Bandarban Adventure"',
    timestamp: '3 hours ago',
    read: true,
  ),
  _Notif(
    type: _NotifType.rejected,
    message: 'Your experience "Sylhet 6 Days" was rejected. Reason: "Incomplete itinerary — please add transport details."',
    timestamp: '1 day ago',
    read: true,
  ),
  _Notif(
    type: _NotifType.upvote,
    message: 'rafi_explores and 4 others upvoted your experience "Sundarbans Safari"',
    timestamp: '2 days ago',
    read: true,
  ),
  _Notif(
    type: _NotifType.approved,
    message: 'Your experience "Tea Garden Weekend" is now live for everyone to see!',
    timestamp: '3 days ago',
    read: true,
  ),
];

// ─────────────────────────────────────────────────────────
//  NOTIFICATIONS PAGE
// ─────────────────────────────────────────────────────────
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<_Notif> _notifs;

  @override
  void initState() {
    super.initState();
    _notifs = List.from(_mockNotifs);
  }

  int get _unreadCount => _notifs.where((n) => !n.read).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        n.read = true;
      }
    });
  }

  Color _typeColor(_NotifType t) {
    switch (t) {
      case _NotifType.upvote:
        return GJ.yellow;
      case _NotifType.comment:
      case _NotifType.reply:
        return GJ.blue;
      case _NotifType.approved:
        return GJ.green;
      case _NotifType.rejected:
        return GJ.pink;
    }
  }

  IconData _typeIcon(_NotifType t) {
    switch (t) {
      case _NotifType.upvote:
        return Icons.thumb_up_alt_rounded;
      case _NotifType.comment:
        return Icons.chat_bubble_rounded;
      case _NotifType.reply:
        return Icons.reply_rounded;
      case _NotifType.approved:
        return Icons.check_circle_rounded;
      case _NotifType.rejected:
        return Icons.cancel_rounded;
    }
  }

  String _typeLabel(_NotifType t) {
    switch (t) {
      case _NotifType.upvote:
        return 'Upvote';
      case _NotifType.comment:
        return 'Comment';
      case _NotifType.reply:
        return 'Reply';
      case _NotifType.approved:
        return 'Approved';
      case _NotifType.rejected:
        return 'Rejected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GJ.purple,
      body: Column(
        children: [
          GJPageHeader(pageTitle: 'Notifications', showBack: true),
          // ── Header strip ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                if (_unreadCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: GJ.pink,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: GJ.dark, width: 2),
                      boxShadow: const [
                        BoxShadow(offset: Offset(2, 2), color: GJ.dark),
                      ],
                    ),
                    child: Text(
                      '$_unreadCount unread',
                      style: GJText.tiny.copyWith(
                        color: GJ.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _markAllRead,
                    child: Text(
                      'Mark all read',
                      style: GJText.tiny.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: GJ.dark,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ] else
                  Text(
                    'All caught up! ✓',
                    style: GJText.label.copyWith(
                      color: GJ.dark.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          // ── List ──
          Expanded(
            child: _notifs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔔',
                            style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No notifications yet',
                          style: GJText.label.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Share an experience to get started!',
                          style: GJText.tiny.copyWith(
                            color: GJ.dark.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    itemCount: _notifs.length,
                    itemBuilder: (_, i) {
                      final n = _notifs[i];
                      return _NotifTile(
                        notif: n,
                        typeColor: _typeColor(n.type),
                        typeIcon: _typeIcon(n.type),
                        typeLabel: _typeLabel(n.type),
                        onTap: () => setState(() => n.read = true),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  NOTIFICATION TILE
// ─────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final Color typeColor;
  final IconData typeIcon;
  final String typeLabel;
  final VoidCallback onTap;

  const _NotifTile({
    required this.notif,
    required this.typeColor,
    required this.typeIcon,
    required this.typeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: notif.read ? GJ.white : GJ.yellow.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.read
                ? GJ.dark.withValues(alpha: 0.2)
                : GJ.dark,
            width: notif.read ? 1 : 2,
          ),
          boxShadow: notif.read
              ? null
              : const [BoxShadow(offset: Offset(3, 3), color: GJ.dark)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left color accent bar
              Container(
                width: 4,
                color: typeColor,
              ),
              // Icon
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GJ.dark, width: 1.5),
                  ),
                  child: Icon(typeIcon, color: GJ.dark, size: 18),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor,
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: GJ.dark, width: 1),
                            ),
                            child: Text(
                              typeLabel,
                              style:
                                  GJText.tiny.copyWith(fontSize: 9),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (!notif.read)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: GJ.pink,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notif.message,
                        style: GJText.body.copyWith(
                          color: GJ.dark.withValues(alpha: 0.8),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.timestamp,
                        style: GJText.tiny.copyWith(
                          color: GJ.dark.withValues(alpha: 0.4),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
