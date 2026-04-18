import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/app_strings.dart';
import '../../../core/network/ghurtejai_api.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';
import '../../../shared/widgets/feed_cards.dart';

class AllDestinationsScreen extends ConsumerStatefulWidget {
  const AllDestinationsScreen({super.key});

  @override
  ConsumerState<AllDestinationsScreen> createState() => _AllDestinationsScreenState();
}

class _AllDestinationsScreenState extends ConsumerState<AllDestinationsScreen> {
  final List<Map<String, dynamic>> _items = [];
  String? _next;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch(null));
  }

  Future<void> _fetch(String? pageUrl) async {
    setState(() => _loading = true);
    try {
      final api = ref.read(ghurtejaiApiProvider);
      final r = await api.fetchDestinations(nextUrl: pageUrl);
      setState(() {
        if (pageUrl == null) {
          _items
            ..clear()
            ..addAll(r.results);
        } else {
          _items.addAll(r.results);
        }
        _next = r.next;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GJTokens.tabCanvas,
      body: Column(
        children: [
          GJPageHeader(
            pageTitle: appT(context, 'All destinations', 'সব গন্তব্য'),
            pageSubtitle: appT(context, 'Browse the map', 'মানচিত্র ব্রাউজ করুন'),
            showBack: true,
          ),
          Expanded(
            child: _loading && _items.isEmpty
                ? const Center(child: CircularProgressIndicator(color: GJ.dark))
                : RefreshIndicator(
                    color: GJ.dark,
                    onRefresh: () => _fetch(null),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length + (_next != null ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == _items.length) {
                          return TextButton(
                            onPressed: () => _fetch(_next),
                            child: Text(
                              appT(context, 'Load more', 'আরও লোড'),
                              style: GJText.label,
                            ),
                          );
                        }
                        final d = _items[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ApiDestinationCard(
                            name: d['name'] as String? ?? '',
                            subtitle:
                                '${d['division_name'] ?? ''} · ${d['district_name'] ?? ''}',
                            coverUrl: d['cover_image'] as String?,
                            attractionCount:
                                (d['attraction_count'] as num?)?.toInt() ?? 0,
                            experienceCount:
                                (d['experience_count'] as num?)?.toInt() ?? 0,
                            onTap: () => context.push('/destination/${d['slug']}'),
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
