import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/locale/app_strings.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/ghurtejai_api.dart';
import '../../../core/utils/experience_vote_local.dart';
import '../../../core/providers/unread_notifications.dart';
import '../../../core/utils/formatting.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';
import '../../../shared/widgets/feed_cards.dart';
import '../../../shared/widgets/guest_gate.dart';

class ExperiencesScreen extends ConsumerStatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  ConsumerState<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends ConsumerState<ExperiencesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late final List<PagingController<String?, Map<String, dynamic>>> _paging;

  static const _orderings = ['-created_at', '-score', 'estimated_cost'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _paging = List.generate(3, (i) {
      final c = PagingController<String?, Map<String, dynamic>>(firstPageKey: null);
      c.addPageRequestListener((pageKey) => _fetchPage(i, pageKey, c));
      return c;
    });
  }

  Future<void> _fetchPage(
    int tab,
    String? pageKey,
    PagingController<String?, Map<String, dynamic>> c,
  ) async {
    try {
      final res = await ref.read(ghurtejaiApiProvider).fetchExperiences(
            ordering: _orderings[tab],
            nextUrl: pageKey,
          );
      final isLast = res.next == null;
      if (isLast) {
        c.appendLastPage(res.results);
      } else {
        c.appendPage(res.results, res.next);
      }
    } catch (e) {
      c.error = e;
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    for (final p in _paging) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _voteInTab(int tab, int experienceId, int value) async {
    final auth = ref.read(authNotifierProvider).value;
    if (auth == null) {
      await showGuestSignInDialog(context);
      return;
    }
    final c = _paging[tab];
    final list = c.itemList;
    if (list == null) return;
    final idx = list.indexWhere((e) => (e['id'] as num).toInt() == experienceId);
    if (idx < 0) return;
    final prev = Map<String, dynamic>.from(list[idx]);
    final next = patchExperienceVoteMap(prev, value);
    final copy = List<Map<String, dynamic>>.from(list);
    copy[idx] = next;
    c.itemList = copy;
    try {
      await ref.read(ghurtejaiApiProvider).voteExperience(experienceId, value);
    } catch (e) {
      copy[idx] = prev;
      c.itemList = copy;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatApiError(e))),
        );
      }
    }
  }

  Future<void> _confirmClone(String slug) async {
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
      await ref.read(ghurtejaiApiProvider).cloneExperienceResult(slug);
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

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthUser?>>(authNotifierProvider, (prev, next) {
      if (!mounted || next.isLoading) return;
      final a = prev?.valueOrNull?.id;
      final b = next.valueOrNull?.id;
      if (a != b) {
        for (final p in _paging) {
          p.refresh();
        }
      }
    });

    final auth = ref.watch(authNotifierProvider).value;
    final unread = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;
    return Scaffold(
      backgroundColor: GJTokens.tabCanvas,
      body: Column(
        children: [
          GJPageHeader(
            pageTitle: appT(context, 'Experiences', 'অভিজ্ঞতা'),
            pageSubtitle: appT(context, 'Curated feeds', 'নির্বাচিত ফিড'),
            showBell: true,
            notificationUnreadCount: unread,
            onBell: () {
              if (auth == null) {
                showGuestSignInDialog(context);
              } else {
                context.push('/notifications');
              }
            },
          ),
          Material(
            color: GJTokens.surfaceElevated,
            child: TabBar(
              controller: _tab,
              labelColor: GJTokens.onSurface,
              unselectedLabelColor: GJTokens.onSurface.withValues(alpha: 0.45),
              indicatorColor: GJTokens.accent,
              indicatorWeight: 3,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              tabs: [
                Tab(text: appT(context, 'For you', 'আপনার জন্য')),
                Tab(text: appT(context, 'Popular', 'জনপ্রিয়')),
                Tab(text: appT(context, 'Budget', 'বাজেট')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: List.generate(3, (tab) {
                return RefreshIndicator(
                  color: GJ.dark,
                  onRefresh: () async {
                    _paging[tab].refresh();
                    await Future<void>.delayed(const Duration(milliseconds: 50));
                  },
                  child: PagedListView<String?, Map<String, dynamic>>.separated(
                    pagingController: _paging[tab],
                    padding: const EdgeInsets.all(12),
                    separatorBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: GJTokens.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
                      itemBuilder: (context, x, index) {
                        final loggedIn = auth != null;
                        final slug = x['slug'] as String? ?? '';
                        final id = (x['id'] as num).toInt();
                        return ApiExperienceCard(
                          title: x['title'] as String? ?? '',
                          destinationName: x['destination_name'] as String? ?? '',
                          coverUrl: x['cover_image'] as String?,
                          coverPending: x['cover_image_pending'] == true,
                          dayCount: (x['day_count'] as num?)?.toInt() ?? 0,
                          score: (x['score'] as num?)?.toInt() ?? 0,
                          comments: (x['comment_count'] as num?)?.toInt() ?? 0,
                          tags: (x['tags'] as List<dynamic>?)?.map((e) => '$e').toList() ?? [],
                          estimatedLabel: formatMoneyBdt(x['estimated_cost']),
                          authorUsername: x['author_username'] as String?,
                          description: x['description'] as String?,
                          createdAtIso: x['created_at'] as String?,
                          slug: slug,
                          experienceId: id,
                          userVote: (x['user_vote'] as num?)?.toInt() ?? 0,
                          bookmarked: x['is_bookmarked'] == true,
                          onTap: () => context.push('/experience/$slug'),
                          showBookmark: loggedIn,
                          onBookmark: loggedIn
                              ? () async {
                                  await ref.read(ghurtejaiApiProvider).toggleExperienceBookmark(id);
                                  _paging[tab].refresh();
                                }
                              : () => showGuestSignInDialog(context),
                          onCommentTap: () => context.push('/experience/$slug?comments=1'),
                          onVote: (v) => _voteInTab(tab, id, v),
                          onClone: loggedIn
                              ? () => _confirmClone(slug)
                              : () => showGuestSignInDialog(context),
                        );
                      },
                      firstPageProgressIndicatorBuilder: (_) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: _ExperienceFeedShimmer(),
                      ),
                      newPageProgressIndicatorBuilder: (_) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(color: GJ.dark)),
                      ),
                      noItemsFoundIndicatorBuilder: (_) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            appT(context, 'No experiences here yet.', 'এখনও এখানে কোনো অভিজ্ঞতা নেই।'),
                            style: GJText.body,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceFeedShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: GJ.white.withValues(alpha: 0.5),
      highlightColor: GJ.white,
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: GJ.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GJ.dark, width: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
