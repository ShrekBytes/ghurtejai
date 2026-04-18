import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/app_strings.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/ghurtejai_api.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';

String _searchTextBlurb(String? s, int maxChars) {
  if (s == null) return '';
  final t = s.trim();
  if (t.isEmpty) return '';
  if (t.length <= maxChars) return t;
  return '${t.substring(0, maxChars)}…';
}

Widget _searchThumbnail(String? coverUrl, {IconData fallback = Icons.landscape_rounded}) {
  final u = coverUrl != null && coverUrl.isNotEmpty ? AppConfig.resolveMediaUrl(coverUrl) : '';
  if (u.isEmpty) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: GJTokens.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GJTokens.radiusSm),
      ),
      child: Icon(fallback, color: GJTokens.accent, size: 26),
    );
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(GJTokens.radiusSm),
    child: Image.network(
      u,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(fallback, color: GJTokens.accent),
    ),
  );
}

class GhurteSearchDelegate extends SearchDelegate<void> {
  GhurteSearchDelegate(this.api, {required this.searchHint});

  final GhurtejaiApi api;
  final String searchHint;

  @override
  String get searchFieldLabel => searchHint;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _Results(query: query, api: api);

  @override
  Widget buildSuggestions(BuildContext context) {
    return _Suggestions(api: api, query: query, delegate: this);
  }
}

class _Suggestions extends StatefulWidget {
  const _Suggestions({
    required this.api,
    required this.query,
    required this.delegate,
  });

  final GhurtejaiApi api;
  final String query;
  final GhurteSearchDelegate delegate;

  @override
  State<_Suggestions> createState() => _SuggestionsState();
}

class _SuggestionsState extends State<_Suggestions> {
  Map<String, dynamic>? _suggestData;
  bool _suggestLoading = true;
  String? _suggestError;

  Map<String, dynamic>? _liveData;
  bool _liveLoading = false;
  String? _liveError;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
    _scheduleLiveSearch(widget.query);
  }

  @override
  void didUpdateWidget(covariant _Suggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _scheduleLiveSearch(widget.query);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    try {
      final d = await widget.api.searchSuggestions();
      if (mounted) {
        setState(() {
          _suggestData = d;
          _suggestLoading = false;
          _suggestError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestLoading = false;
          _suggestError = formatApiError(e);
        });
      }
    }
  }

  void _scheduleLiveSearch(String q) {
    _debounce?.cancel();
    final trimmed = q.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _liveData = null;
        _liveLoading = false;
        _liveError = null;
      });
      return;
    }
    setState(() => _liveLoading = true);
    _debounce = Timer(const Duration(milliseconds: 320), () => _runLiveSearch(trimmed));
  }

  Future<void> _runLiveSearch(String trimmed) async {
    try {
      final d = await widget.api.search(trimmed, type: 'all');
      if (!mounted) return;
      setState(() {
        _liveData = d;
        _liveLoading = false;
        _liveError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _liveLoading = false;
        _liveError = formatApiError(e);
      });
    }
  }

  void _applyQueryAndShowResults(BuildContext context, String text) {
    widget.delegate.query = text;
    widget.delegate.showResults(context);
  }

  String _recentLabel(dynamic q) {
    if (q is Map) return '${q['query'] ?? ''}';
    return '$q';
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.query.trim();

    if (_suggestLoading && q.isEmpty) {
      return ColoredBox(
        color: GJTokens.tabCanvas,
        child: const Center(child: CircularProgressIndicator(color: GJ.dark)),
      );
    }

    final recent = (_suggestData?['recent'] as List<dynamic>?) ?? [];
    final popular = (_suggestData?['popular'] as List<dynamic>?) ?? [];

    return ColoredBox(
      color: GJTokens.tabCanvas,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
        if (_suggestError != null && q.isEmpty) ...[
          Text(_suggestError!, style: GJText.body),
          const SizedBox(height: 12),
          GJGhostButton(
            label: appT(context, 'Retry suggestions', 'পরামর্শ আবার লোড'),
            onTap: _loadSuggestions,
          ),
          const SizedBox(height: 16),
        ],
        if (q.isNotEmpty) ...[
          Text(appT(context, 'Results', 'ফলাফল'), style: GJText.label),
          const SizedBox(height: 8),
          if (_liveLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: GJTokens.onSurface)),
            )
          else if (_liveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_liveError!, style: GJText.body),
                  TextButton(
                    onPressed: () => _runLiveSearch(q),
                    child: Text(appT(context, 'Retry', 'আবার চেষ্টা'), style: GJText.tiny),
                  ),
                ],
              ),
            )
          else
            _SearchSectionList(
              type: 'all',
              data: _liveData,
              emptyMessage: appT(
                context,
                'No matches yet. Try another word.',
                'এখনও কিছু মিলেনি। অন্য শব্দ চেষ্টা করুন।',
              ),
            ),
          const SizedBox(height: 8),
          Text(
            appT(
              context,
              'Tip: use the filter chips after you press search on the keyboard.',
              'টিপ: কিবোর্ডে সার্চ চাপার পর ফিল্টার চিপ ব্যবহার করুন।',
            ),
            style: GJText.tiny.copyWith(color: GJTokens.onSurface.withValues(alpha: 0.55)),
          ),
          const Divider(height: 32),
        ],
        if (recent.isNotEmpty) ...[
          Text(appT(context, 'Recent', 'সাম্প্রতিক'), style: GJText.label),
          ...recent.map(
            (item) => ListTile(
              title: Text(_recentLabel(item), style: GJText.body),
              leading: const Icon(Icons.history_rounded, color: GJTokens.onSurface),
              onTap: () => _applyQueryAndShowResults(context, _recentLabel(item).trim()),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(appT(context, 'Popular', 'জনপ্রিয়'), style: GJText.label),
        if (popular.isEmpty && q.isEmpty && !_suggestLoading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              appT(
                context,
                'Search to build popular picks.',
                'জনপ্রিয় নির্বাচন তৈরিতে সার্চ করুন।',
              ),
              style: GJText.tiny,
            ),
          ),
        ...popular.map(
          (item) => ListTile(
            title: Text('$item', style: GJText.body),
            leading: const Icon(Icons.trending_up_rounded, color: GJTokens.onSurface),
            onTap: () => _applyQueryAndShowResults(context, '$item'.trim()),
          ),
        ),
      ],
      ),
    );
  }
}

class _Results extends StatefulWidget {
  const _Results({required this.query, required this.api});

  final String query;
  final GhurtejaiApi api;

  @override
  State<_Results> createState() => _ResultsState();
}

class _ResultsState extends State<_Results> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  String _type = 'all';

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void didUpdateWidget(covariant _Results oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _run();
  }

  Future<void> _run() async {
    final q = widget.query.trim();
    if (q.isEmpty) {
      setState(() {
        _data = null;
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await widget.api.search(q, type: _type);
      if (mounted) {
        setState(() {
          _data = d;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = formatApiError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query.trim().isEmpty) {
      return Center(
        child: Text(appT(context, 'Type to search', 'সার্চ করতে টাইপ করুন'), style: GJText.body),
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: GJ.dark));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: GJText.body, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              GJButton(
                label: appT(context, 'Retry', 'আবার চেষ্টা'),
                color: GJ.yellow,
                onTap: _run,
              ),
            ],
          ),
        ),
      );
    }
    final dest = (_data?['destinations'] as List<dynamic>?) ?? [];
    final exp = (_data?['experiences'] as List<dynamic>?) ?? [];
    final att = (_data?['attractions'] as List<dynamic>?) ?? [];
    final empty = switch (_type) {
      'all' => dest.isEmpty && exp.isEmpty && att.isEmpty,
      'destinations' => dest.isEmpty,
      'experiences' => exp.isEmpty,
      'attractions' => att.isEmpty,
      _ => dest.isEmpty && exp.isEmpty && att.isEmpty,
    };

    return ColoredBox(
      color: GJTokens.tabCanvas,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: appT(context, 'All', 'সব'),
                    selected: _type == 'all',
                    onTap: () => setState(() {
                      _type = 'all';
                      _run();
                    }),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: appT(context, 'Destinations', 'গন্তব্য'),
                    selected: _type == 'destinations',
                    onTap: () => setState(() {
                      _type = 'destinations';
                      _run();
                    }),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: appT(context, 'Experiences', 'অভিজ্ঞতা'),
                    selected: _type == 'experiences',
                    onTap: () => setState(() {
                      _type = 'experiences';
                      _run();
                    }),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: appT(context, 'Attractions', 'দর্শনীয় স্থান'),
                    selected: _type == 'attractions',
                    onTap: () => setState(() {
                      _type = 'attractions';
                      _run();
                    }),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: empty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        appT(
                          context,
                          'No matches for this filter. Try "All" or another search.',
                          'এই ফিল্টারে কিছু মিলেনি। "সব" বা অন্য সার্চ চেষ্টা করুন।',
                        ),
                        style: GJText.body,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      if (_type == 'all' || _type == 'destinations') ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Text(
                            appT(context, 'Destinations', 'গন্তব্য'),
                            style: GJText.label.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        ...dest.map((raw) {
                          final m = raw as Map<String, dynamic>;
                          final blurb = _searchTextBlurb(m['description'] as String?, 160);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: GJTokens.surfaceElevated,
                              borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push('/destination/${m['slug']}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _searchThumbnail(m['cover_image'] as String?),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${m['name']}',
                                              style: GJText.label.copyWith(fontWeight: FontWeight.w800),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${m['division_name'] ?? ''} · ${m['district_name'] ?? ''}',
                                              style: GJText.tiny.copyWith(
                                                color: GJTokens.onSurface.withValues(alpha: 0.55),
                                              ),
                                            ),
                                            if (blurb.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                blurb,
                                                style: GJText.body.copyWith(fontSize: 13, height: 1.35),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                      if (_type == 'all' || _type == 'experiences') ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Text(
                            appT(context, 'Experiences', 'অভিজ্ঞতা'),
                            style: GJText.label.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        ...exp.map((raw) {
                          final m = raw as Map<String, dynamic>;
                          final blurb = _searchTextBlurb(m['description'] as String?, 140);
                          final days = (m['day_count'] as num?)?.toInt() ?? 0;
                          final sc = (m['score'] as num?)?.toInt() ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: GJTokens.surfaceElevated,
                              borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push('/experience/${m['slug']}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _searchThumbnail(m['cover_image'] as String?),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${m['title']}',
                                              style: GJText.label.copyWith(fontWeight: FontWeight.w800),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${m['destination_name'] ?? ''} · $days ${appT(context, 'days', 'দিন')} · ${appT(context, 'score', 'স্কোর')} $sc',
                                              style: GJText.tiny.copyWith(
                                                color: GJTokens.onSurface.withValues(alpha: 0.55),
                                              ),
                                            ),
                                            if (blurb.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                blurb,
                                                style: GJText.body.copyWith(fontSize: 13, height: 1.35),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                      if (_type == 'all' || _type == 'attractions') ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Text(
                            'Attractions',
                            style: GJText.label.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        ...att.map((raw) {
                          final m = raw as Map<String, dynamic>;
                          final ds = m['destination_slug'] as String? ?? '';
                          final blurb = _searchTextBlurb(m['notes'] as String?, 160);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: GJTokens.surfaceElevated,
                              borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  if (ds.isNotEmpty) context.push('/destination/$ds');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _searchThumbnail(null, fallback: Icons.place_rounded),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${m['name']}',
                                              style: GJText.label.copyWith(fontWeight: FontWeight.w800),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${m['destination_name'] ?? ''} · ${m['type'] ?? ''}',
                                              style: GJText.tiny.copyWith(
                                                color: GJTokens.onSurface.withValues(alpha: 0.55),
                                              ),
                                            ),
                                            if (blurb.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                blurb,
                                                style: GJText.body.copyWith(fontSize: 13, height: 1.35),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Inline search hits for the suggestions overlay (type is always "all" there).
class _SearchSectionList extends StatelessWidget {
  const _SearchSectionList({
    required this.type,
    required this.data,
    required this.emptyMessage,
  });

  final String type;
  final Map<String, dynamic>? data;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final dest = (data?['destinations'] as List<dynamic>?) ?? [];
    final exp = (data?['experiences'] as List<dynamic>?) ?? [];
    final att = (data?['attractions'] as List<dynamic>?) ?? [];
    final empty = dest.isEmpty && exp.isEmpty && att.isEmpty;
    if (empty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(emptyMessage, style: GJText.body),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (type == 'all' || type == 'destinations') ...[
          if (dest.isNotEmpty) Text(appT(context, 'Destinations', 'গন্তব্য'), style: GJText.tiny),
          ...dest.take(5).map((raw) {
            final m = raw as Map<String, dynamic>;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${m['name']}', style: GJText.body),
              onTap: () {
                Navigator.pop(context);
                context.push('/destination/${m['slug']}');
              },
            );
          }),
        ],
        if (type == 'all' || type == 'experiences') ...[
          if (exp.isNotEmpty) Text(appT(context, 'Experiences', 'অভিজ্ঞতা'), style: GJText.tiny),
          ...exp.take(5).map((raw) {
            final m = raw as Map<String, dynamic>;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${m['title']}', style: GJText.body),
              onTap: () {
                Navigator.pop(context);
                context.push('/experience/${m['slug']}');
              },
            );
          }),
        ],
        if (type == 'all' || type == 'attractions') ...[
          if (att.isNotEmpty) Text(appT(context, 'Attractions', 'দর্শনীয় স্থান'), style: GJText.tiny),
          ...att.take(5).map((raw) {
            final m = raw as Map<String, dynamic>;
            final ds = m['destination_slug'] as String? ?? '';
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${m['name']}', style: GJText.body),
              subtitle: Text('${m['destination_name']}', style: GJText.tiny),
              onTap: () {
                Navigator.pop(context);
                if (ds.isNotEmpty) context.push('/destination/$ds');
              },
            );
          }),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? GJTokens.accent.withValues(alpha: 0.22) : GJTokens.surfaceElevated,
          borderRadius: BorderRadius.circular(GJTokens.radiusSm),
          border: Border.all(color: GJTokens.outline.withValues(alpha: selected ? 0.22 : 0.12)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: GJTokens.outline.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(label, style: GJText.tiny),
      ),
    );
  }
}
