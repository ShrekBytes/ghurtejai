import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../../../shared/widgets/gj_standard_header.dart';
import 'ghurte_search_delegate.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  List<Map<String, dynamic>> _destinations = [];
  List<Map<String, dynamic>> _popularDestinations = [];
  List<Map<String, dynamic>> _popularExperiences = [];
  List<Map<String, dynamic>> _tags = [];
  String? _error;
  bool _loading = true;

  /// Normalized tag keys (lowercase, no #) for the bottom Destinations list; empty = show all.
  final Set<String> _selectedDestinationTagKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = ref.read(ghurtejaiApiProvider);
    try {
      final d = await api.fetchDestinations();
      final popExp = await api.fetchExperiences(ordering: '-score');
      final t = await api.fetchTags();
      final destList = d.results;
      final rankedDest = List<Map<String, dynamic>>.from(destList)
        ..sort((a, b) {
          final eb = (b['experience_count'] as num?)?.toInt() ?? 0;
          final ea = (a['experience_count'] as num?)?.toInt() ?? 0;
          if (eb != ea) return eb.compareTo(ea);
          final ab = (b['attraction_count'] as num?)?.toInt() ?? 0;
          final aa = (a['attraction_count'] as num?)?.toInt() ?? 0;
          return ab.compareTo(aa);
        });
      setState(() {
        _destinations = destList;
        _popularDestinations = rankedDest.take(12).toList();
        _popularExperiences = popExp.results.take(8).toList();
        _tags = t.take(12).toList();
        _loading = false;
      });
      ref.invalidate(unreadNotificationCountProvider);
    } catch (err) {
      setState(() {
        _error = '$err';
        _loading = false;
      });
    }
  }

  Future<void> _voteExperienceInList(
    List<Map<String, dynamic>> list,
    int index,
    int value,
  ) async {
    final auth = ref.read(authNotifierProvider).value;
    if (auth == null) {
      await showGuestSignInDialog(context);
      return;
    }
    if (index < 0 || index >= list.length) return;
    final prev = Map<String, dynamic>.from(list[index]);
    final id = (prev['id'] as num).toInt();
    final optimistic = patchExperienceVoteMap(prev, value);
    setState(() => list[index] = optimistic);
    try {
      await ref.read(ghurtejaiApiProvider).voteExperience(id, value);
    } catch (e) {
      if (!mounted) return;
      setState(() => list[index] = prev);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(formatApiError(e))),
      );
    }
  }

  void _openSearch() {
    showSearch<void>(
      context: context,
      delegate: GhurteSearchDelegate(
        ref.read(ghurtejaiApiProvider),
        searchHint: appT(context, 'Where do you want to go?', 'আপনি কোথায় যেতে চান?'),
      ),
    );
  }

  List<Map<String, dynamic>> get _browseDestinations {
    Iterable<Map<String, dynamic>> it = _destinations;
    if (_selectedDestinationTagKeys.isNotEmpty) {
      it = it.where((d) {
        final tags = d['tags'] as List<dynamic>?;
        if (tags == null) return false;
        return tags.any((x) {
          final s = '$x'.replaceAll('#', '').toLowerCase();
          return _selectedDestinationTagKeys.contains(s);
        });
      });
    }
    final list = it.toList();
    list.sort(
      (a, b) => '${a['name']}'.toLowerCase().compareTo('${b['name']}'.toLowerCase()),
    );
    return list;
  }

  void _toggleDestinationTagKey(String normalizedKey) {
    setState(() {
      if (_selectedDestinationTagKeys.contains(normalizedKey)) {
        _selectedDestinationTagKeys.remove(normalizedKey);
      } else {
        _selectedDestinationTagKeys.add(normalizedKey);
      }
    });
  }

  void _clearDestinationTagFilters() {
    setState(_selectedDestinationTagKeys.clear);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthUser?>>(authNotifierProvider, (prev, next) {
      if (!mounted || next.isLoading) return;
      final a = prev?.valueOrNull?.id;
      final b = next.valueOrNull?.id;
      if (a != b) {
        _load();
      }
    });

    final auth = ref.watch(authNotifierProvider).value;
    final unread = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: GJTokens.tabCanvas,
      body: RefreshIndicator(
        color: GJ.dark,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              backgroundColor: GJTokens.tabCanvas,
              foregroundColor: GJ.dark,
              toolbarHeight: 72,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GJStandardHeaderRow(
                  title: appT(context, 'Ghurtejai', 'ঘুরেতেজাই'),
                  subtitle: appT(context, 'Discover trips', 'সফর আবিষ্কার করুন'),
                  trailing: GJHeaderNotificationButton(
                    onPressed: () {
                      if (auth == null) {
                        showGuestSignInDialog(context);
                      } else {
                        context.push('/notifications');
                      }
                    },
                    unreadCount: unread,
                  ),
                ),
              ),
            ),
            if (_loading)
              SliverToBoxAdapter(child: _ExploreShimmer())
            else if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(_error!, style: GJText.body, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      GJButton(
                        label: appT(context, 'Retry', 'আবার চেষ্টা'),
                        color: GJ.yellow,
                        onTap: _load,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appT(context, 'Where to next?', 'পরবর্তী গন্তব্য কোথায়?'),
                        style: GJText.display.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 12),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _openSearch,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: GJ.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: GJ.dark, width: 2),
                              boxShadow: const [
                                BoxShadow(offset: Offset(2, 2), color: GJ.dark),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: GJ.dark.withValues(alpha: 0.45),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    appT(context, 'Where do you want to go?', 'আপনি কোথায় যেতে চান?'),
                                    style: GJText.body.copyWith(
                                      color: GJ.dark.withValues(alpha: 0.45),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: GJSectionLabel(
                  title: appT(context, 'Popular experiences', 'জনপ্রিয় অভিজ্ঞতা'),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 248,
                  child: _popularExperiences.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Center(
                            child: Text(
                              appT(
                                context,
                                'No experiences yet. Be the first!',
                                'এখনও কোনো অভিজ্ঞতা নেই। প্রথম হোন!',
                              ),
                              style: GJText.body,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          itemCount: _popularExperiences.length,
                          itemBuilder: (context, i) {
                            final x = _popularExperiences[i];
                            final est = formatMoneyBdt(x['estimated_cost']);
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: SizedBox(
                                width: 280,
                                child: ApiExperienceCard(
                                  compactRail: true,
                                  title: x['title'] as String? ?? '',
                                  destinationName: x['destination_name'] as String? ?? '',
                                  coverUrl: x['cover_image'] as String?,
                                  coverPending: x['cover_image_pending'] == true,
                                  dayCount: (x['day_count'] as num?)?.toInt() ?? 0,
                                  score: (x['score'] as num?)?.toInt() ?? 0,
                                  comments: (x['comment_count'] as num?)?.toInt() ?? 0,
                                  tags:
                                      (x['tags'] as List<dynamic>?)?.map((e) => '$e').toList() ??
                                          [],
                                  estimatedLabel: est,
                                  authorUsername: x['author_username'] as String?,
                                  description: x['description'] as String?,
                                  createdAtIso: x['created_at'] as String?,
                                  slug: x['slug'] as String?,
                                  experienceId: (x['id'] as num?)?.toInt(),
                                  userVote: (x['user_vote'] as num?)?.toInt() ?? 0,
                                  bookmarked: x['is_bookmarked'] == true,
                                  onTap: () => context.push('/experience/${x['slug']}'),
                                  showBookmark: auth != null,
                                  onBookmark: auth != null
                                      ? () async {
                                          await ref
                                              .read(ghurtejaiApiProvider)
                                              .toggleExperienceBookmark((x['id'] as num).toInt());
                                          await _load();
                                        }
                                      : () => showGuestSignInDialog(context),
                                  onCommentTap: () =>
                                      context.push('/experience/${x['slug']}?comments=1'),
                                  onVote: (v) => _voteExperienceInList(_popularExperiences, i, v),
                                  onClone: auth != null
                                      ? () async {
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
                                          if (ok == true && context.mounted) {
                                            await ref.read(ghurtejaiApiProvider).cloneExperienceResult(
                                                  x['slug'] as String,
                                                );
                                            if (context.mounted) {
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
                                      : () => showGuestSignInDialog(context),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: GJSectionLabel(
                  title: appT(context, 'Popular destinations', 'জনপ্রিয় গন্তব্য'),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 308,
                  child: _popularDestinations.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Center(
                            child: Text(
                              appT(context, 'No destinations yet.', 'এখনও কোনো গন্তব্য নেই।'),
                              style: GJText.body,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          itemCount: _popularDestinations.length,
                          itemBuilder: (context, i) {
                            final d = _popularDestinations[i];
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: SizedBox(
                                width: 268,
                                child: ApiDestinationCard(
                                  name: d['name'] as String? ?? '',
                                  subtitle:
                                      '${d['division_name'] ?? ''} · ${d['district_name'] ?? ''}',
                                  coverUrl: d['cover_image'] as String?,
                                  attractionCount: (d['attraction_count'] as num?)?.toInt() ?? 0,
                                  experienceCount: (d['experience_count'] as num?)?.toInt() ?? 0,
                                  largeTile: true,
                                  onTap: () => context.push('/destination/${d['slug']}'),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: GJSectionLabel(title: appT(context, 'Destinations', 'গন্তব্য')),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_tags.isNotEmpty) ...[
                        Text(
                          appT(context, 'Filter by tag', 'ট্যাগ দিয়ে ফিল্টার'),
                          style: GJText.tiny.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _tags.map((tg) {
                            final name = '${tg['name']}'.replaceAll('#', '');
                            final key = name.toLowerCase();
                            final sel = _selectedDestinationTagKeys.contains(key);
                            return GJChip(
                              label: '#$name',
                              selected: sel,
                              onTap: () => _toggleDestinationTagKey(key),
                            );
                          }).toList(),
                        ),
                      ],
                      if (_selectedDestinationTagKeys.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _clearDestinationTagFilters,
                            child: Text(
                              appT(context, 'Clear tags', 'ট্যাগ মুছুন'),
                              style: GJText.tiny,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_browseDestinations.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: Text(
                      _destinations.isEmpty
                          ? appT(context, 'No destinations yet.', 'এখনও কোনো গন্তব্য নেই।')
                          : appT(
                              context,
                              'No destinations match the selected tags.',
                              'নির্বাচিত ট্যাগের সাথে কোনো গন্তব্য মিলছে না।',
                            ),
                      style: GJText.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final d = _browseDestinations[i];
                        return Padding(
                          padding: EdgeInsets.only(bottom: i < _browseDestinations.length - 1 ? 12 : 0),
                          child: ApiDestinationCard(
                            name: d['name'] as String? ?? '',
                            subtitle:
                                '${d['division_name'] ?? ''} · ${d['district_name'] ?? ''}',
                            coverUrl: d['cover_image'] as String?,
                            attractionCount: (d['attraction_count'] as num?)?.toInt() ?? 0,
                            experienceCount: (d['experience_count'] as num?)?.toInt() ?? 0,
                            largeTile: false,
                            onTap: () => context.push('/destination/${d['slug']}'),
                          ),
                        );
                      },
                      childCount: _browseDestinations.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: GJButton(
                    label: appT(context, 'See all destinations', 'সব গন্তব্য দেখুন'),
                    color: GJ.white,
                    onTap: () => context.push('/destinations'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExploreShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: GJ.white.withValues(alpha: 0.4),
      highlightColor: GJ.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 24, width: 200, color: GJ.white),
            const SizedBox(height: 16),
            Container(height: 44, width: double.infinity, color: GJ.white),
            const SizedBox(height: 20),
            Container(height: 14, width: 160, color: GJ.white),
            const SizedBox(height: 10),
            SizedBox(
              height: 248,
              child: Row(
                children: List.generate(
                  3,
                  (_) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Container(
                      width: 200,
                      height: 248,
                      decoration: BoxDecoration(
                        color: GJ.white,
                        borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(height: 14, width: 180, color: GJ.white),
            const SizedBox(height: 10),
            SizedBox(
              height: 308,
              child: Row(
                children: List.generate(
                  3,
                  (_) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Container(
                      width: 180,
                      height: 308,
                      decoration: BoxDecoration(
                        color: GJ.white,
                        borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(height: 14, width: 120, color: GJ.white),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(
                5,
                (_) => Container(
                  width: 64,
                  height: 28,
                  decoration: BoxDecoration(
                    color: GJ.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 96,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: GJ.white,
                    borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
