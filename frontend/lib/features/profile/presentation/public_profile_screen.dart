import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/app_strings.dart';
import '../../../core/network/ghurtejai_api.dart';
import '../../../core/utils/formatting.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';
import '../../../shared/widgets/feed_cards.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  const PublicProfileScreen({super.key, required this.username});

  final String username;

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _experiences = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final api = ref.read(ghurtejaiApiProvider);
    try {
      final p = await api.fetchPublicProfile(widget.username);
      final e = await api.fetchExperiences(
        authorUsername: widget.username,
        ordering: '-created_at',
        publishedOnly: true,
      );
      setState(() {
        _profile = p;
        _experiences = e.results;
        _loading = false;
      });
    } catch (err) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$err')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: GJ.dark)),
      );
    }
    final un = _profile?['username'] as String? ?? widget.username;

    return Scaffold(
      backgroundColor: GJTokens.tabCanvas,
      body: Column(
        children: [
          GJPageHeader(
            pageTitle: '@$un',
            pageSubtitle: appT(context, 'Public profile', 'পাবলিক প্রোফাইল'),
            showBack: true,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _profile?['bio'] as String? ?? '',
              style: GJText.body,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: GJ.dark,
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _experiences.length,
                itemBuilder: (context, i) {
                  final x = _experiences[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ApiExperienceCard(
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
