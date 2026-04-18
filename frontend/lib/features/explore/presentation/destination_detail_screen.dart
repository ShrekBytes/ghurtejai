import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/config/app_config.dart';
import '../../../core/locale/app_strings.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/ghurtejai_api.dart';
import '../../../core/utils/formatting.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';
import '../../../shared/widgets/feed_cards.dart';
import '../../../shared/widgets/guest_gate.dart';

class DestinationDetailScreen extends ConsumerStatefulWidget {
  const DestinationDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends ConsumerState<DestinationDetailScreen> {
  Map<String, dynamic>? _d;
  List<Map<String, dynamic>> _related = [];
  bool _loading = true;
  bool _bm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final api = ref.read(ghurtejaiApiProvider);
      final d = await api.fetchDestinationDetail(widget.slug);
      final rel = await api.fetchExperiences(
        destinationSlug: widget.slug,
        ordering: '-created_at',
      );
      if (!mounted) return;
      setState(() {
        _d = d;
        _related = rel.results.take(12).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupAttractions(List<dynamic> raw) {
    final out = <String, List<Map<String, dynamic>>>{
      'PLACE': [],
      'FOOD': [],
      'ACTIVITY': [],
    };
    for (final a in raw) {
      final m = Map<String, dynamic>.from(a as Map);
      final t = '${m['type'] ?? 'PLACE'}';
      out[t]?.add(m);
    }
    return out;
  }

  Future<void> _toggleBookmark(int destId) async {
    final auth = ref.read(authNotifierProvider).value;
    if (auth == null) {
      await showGuestSignInDialog(context);
      return;
    }
    await ref.read(ghurtejaiApiProvider).toggleDestinationBookmark(destId);
    setState(() => _bm = !_bm);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider).value;
    if (_loading) {
      return Scaffold(
        backgroundColor: GJTokens.tabCanvas,
        body: const Center(child: CircularProgressIndicator(color: GJ.dark)),
      );
    }
    if (_d == null) {
      return Scaffold(
        backgroundColor: GJTokens.tabCanvas,
        body: Center(
          child: Text(appT(context, 'Not found', 'পাওয়া যায়নি'), style: GJText.label),
        ),
      );
    }
    final d = _d!;
    final cover = d['cover_image'] as String?;
    final url = cover != null ? AppConfig.resolveMediaUrl(cover) : '';
    final attractions = (d['attractions'] as List<dynamic>?) ?? [];
    final transports = (d['transports'] as List<dynamic>?) ?? [];
    final tags = (d['tags'] as List<dynamic>?)?.map((e) => '$e').toList() ?? [];
    final district = d['district'] as Map<String, dynamic>?;
    final divName = district?['division'] is Map
        ? '${(district!['division'] as Map)['name'] ?? ''}'
        : '';
    final distName = district?['name'] as String? ?? '';
    final lat = d['latitude'];
    final lng = d['longitude'];
    final destId = (d['id'] as num).toInt();
    final grouped = _groupAttractions(attractions);
    final attractionSections = <({String title, String empty, String key})>[
      (
        title: appT(context, 'Places', 'স্থান'),
        empty: appT(context, 'No places listed yet.', 'এখনও কোনো স্থান তালিকাভুক্ত নেই।'),
        key: 'PLACE',
      ),
      (
        title: appT(context, 'Food', 'খাবার'),
        empty: appT(context, 'No food listed yet.', 'এখনও কোনো খাবার তালিকাভুক্ত নেই।'),
        key: 'FOOD',
      ),
      (
        title: appT(context, 'Activities', 'কার্যক্রম'),
        empty: appT(context, 'No activities listed yet.', 'এখনও কোনো কার্যক্রম তালিকাভুক্ত নেই।'),
        key: 'ACTIVITY',
      ),
    ];

    return Scaffold(
      backgroundColor: GJTokens.tabCanvas,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                if (url.isNotEmpty)
                  ShaderMask(
                    shaderCallback: (r) => LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ).createShader(r),
                    blendMode: BlendMode.darken,
                    child: Image.network(
                      url,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 220,
                    color: GJ.yellow,
                    child: const Center(
                      child: Icon(Icons.place_rounded, size: 64, color: GJ.dark),
                    ),
                  ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: GJTokens.surfaceElevated.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(GJTokens.radiusMd),
                            border: Border.all(
                              color: GJTokens.outline.withValues(alpha: 0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GJTokens.outline.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const SizedBox(
                            width: 42,
                            height: 42,
                            child: Icon(Icons.arrow_back_rounded, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (auth != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: SafeArea(
                      child: IconButton(
                        onPressed: () => _toggleBookmark(destId),
                        icon: Icon(
                          _bm ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          color: GJ.white,
                          shadows: const [Shadow(color: GJ.dark, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d['name'] as String? ?? '', style: GJText.title.copyWith(fontSize: 22)),
                  const SizedBox(height: 6),
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: tags
                          .map(
                            (t) => GJTagPill(
                              tag: t.replaceFirst('#', ''),
                              color: GJ.blue,
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    [divName, distName].where((s) => s.isNotEmpty).join(' · '),
                    style: GJText.body,
                  ),
                  if (lat != null && lng != null)
                    Text(
                      appT(context, 'Coordinates: $lat, $lng', 'স্থানাঙ্ক: $lat, $lng'),
                      style: GJText.tiny,
                    ),
                  const SizedBox(height: 8),
                  Text(d['description'] as String? ?? '', style: GJText.body),
                  const SizedBox(height: 12),
                  GJButton(
                    label: appT(context, 'Create experience', 'অভিজ্ঞতা তৈরি'),
                    color: GJ.pink,
                    compact: true,
                    onTap: () async {
                      final a = ref.read(authNotifierProvider).value;
                      if (a == null) {
                        await showGuestSignInDialog(context);
                        return;
                      }
                      if (!context.mounted) return;
                      context.push(
                        Uri(
                          path: '/create/experience',
                          queryParameters: {'destination': widget.slug},
                        ).toString(),
                      );
                    },
                  ),
                  if (auth != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GJGhostButton(
                            label: appT(context, 'Add Attraction', 'আকর্ষণ যোগ'),
                            onTap: () => _showAttractionForm(destId),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GJGhostButton(
                            label: appT(context, 'Add Transport', 'পরিবহন যোগ'),
                            onTap: () => _showTransportForm(destId),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          for (final sec in attractionSections)
            ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(sec.title, style: GJText.title.copyWith(fontSize: 16)),
                ),
              ),
              if ((grouped[sec.key] ?? []).isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      sec.empty,
                      style: GJText.tiny,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final a = grouped[sec.key]![i];
                      return ListTile(
                        leading: a['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  AppConfig.resolveMediaUrl('${a['image']}'),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.place),
                                ),
                              )
                            : const Icon(Icons.place_rounded),
                        title: Text('${a['name']}', style: GJText.label),
                        subtitle: Text(
                          [
                            if ((a['address'] as String?)?.isNotEmpty == true) a['address'],
                            if ((a['price_range'] as String?)?.isNotEmpty == true)
                              a['price_range'],
                          ].join(' · '),
                          style: GJText.tiny,
                        ),
                      );
                    },
                    childCount: grouped[sec.key]!.length,
                  ),
                ),
            ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                appT(context, 'Transport', 'পরিবহন'),
                style: GJText.title.copyWith(fontSize: 16),
              ),
            ),
          ),
          if (transports.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  appT(context, 'No transport info yet.', 'এখনও পরিবহনের তথ্য নেই।'),
                  style: GJText.tiny,
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final t = transports[i] as Map<String, dynamic>;
                  final img = t['image'];
                  return ListTile(
                    leading: img != null && '$img'.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              AppConfig.resolveMediaUrl('$img'),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.directions_bus_rounded),
                            ),
                          )
                        : const Icon(Icons.directions_bus_rounded),
                    title: Text(
                      '${t['from_location']} → ${t['to_location']}',
                      style: GJText.label,
                    ),
                    subtitle: Text(
                      '${t['type']} · ${t['operator']} · ৳${t['cost'] ?? '—'} · '
                      '${t['departure_time'] ?? ''} · ${t['start_point'] ?? ''}',
                      style: GJText.tiny,
                    ),
                  );
                },
                childCount: transports.length,
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Text(
                    appT(context, 'Related experiences', 'সম্পর্কিত অভিজ্ঞতা'),
                    style: GJText.title.copyWith(fontSize: 16),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/experiences'),
                    child: Text(
                      appT(context, 'See all →', 'সব দেখুন →'),
                      style: GJText.tiny,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_related.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  appT(context, 'No experiences yet.', 'এখনও কোনো অভিজ্ঞতা নেই।'),
                  style: GJText.tiny,
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: SizedBox(
                height: 236,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _related.length,
                  itemBuilder: (context, i) {
                    final x = _related[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 276,
                        child: ApiExperienceCard(
                          title: x['title'] as String? ?? '',
                          destinationName: x['destination_name'] as String? ?? '',
                          coverUrl: x['cover_image'] as String?,
                          coverPending: x['cover_image_pending'] == true,
                          dayCount: (x['day_count'] as num?)?.toInt() ?? 0,
                          score: (x['score'] as num?)?.toInt() ?? 0,
                          comments: (x['comment_count'] as num?)?.toInt() ?? 0,
                          tags: const [],
                          estimatedLabel: formatMoneyBdt(x['estimated_cost']),
                          authorUsername: x['author_username'] as String?,
                          createdAtIso: x['created_at'] as String?,
                          onTap: () => context.push('/experience/${x['slug']}'),
                          showBookmark: false,
                          showActionRow: false,
                          compactRail: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Future<void> _showAttractionForm(int destinationId) async {
    final name = TextEditingController();
    String type = 'PLACE';
    final address = TextEditingController();
    final price = TextEditingController();
    final notes = TextEditingController();
    String? imageUrl;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.48,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => StatefulBuilder(
          builder: (sheetContext, setS) {
            return Material(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(GJTokens.radiusLg)),
              color: GJTokens.surfaceElevated,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: GJTokens.outline.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 4, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            appT(sheetContext, 'Add attraction', 'আকর্ষণ যোগ করুন'),
                            style: GJText.title,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      children: [
                        TextField(
                          controller: name,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'Name *', 'নাম *'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: type,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'Type', 'ধরন'),
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'PLACE',
                              child: Text(appT(sheetContext, 'Place', 'স্থান')),
                            ),
                            DropdownMenuItem(
                              value: 'FOOD',
                              child: Text(appT(sheetContext, 'Food', 'খাবার')),
                            ),
                            DropdownMenuItem(
                              value: 'ACTIVITY',
                              child: Text(appT(sheetContext, 'Activity', 'কার্যক্রম')),
                            ),
                          ],
                          onChanged: (v) => setS(() => type = v ?? 'PLACE'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: address,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'Address', 'ঠিকানা'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: price,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'Price range', 'মূল্যের ধরন'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: notes,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'Notes', 'নোট'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GJGhostButton(
                          label: imageUrl == null
                              ? appT(sheetContext, 'Photo (optional)', 'ছবি (ঐচ্ছিক)')
                              : appT(sheetContext, 'Change photo', 'ছবি পরিবর্তন'),
                          onTap: () async {
                            final auth = ref.read(authNotifierProvider).value;
                            if (auth == null) {
                              await showGuestSignInDialog(context);
                              return;
                            }
                            final f = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (f == null) return;
                            try {
                              final res = await ref.read(ghurtejaiApiProvider).uploadImage(f.path);
                              final u = res['url'] as String?;
                              if (u != null) setS(() => imageUrl = u);
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text(formatApiError(e))),
                                );
                              }
                            }
                          },
                        ),
                        if (imageUrl != null && imageUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(GJTokens.radiusSm),
                              child: Image.network(
                                AppConfig.resolveMediaUrl(imageUrl),
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.paddingOf(ctx).bottom),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(appT(ctx, 'Cancel', 'বাতিল')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: GJTokens.accent,
                              foregroundColor: GJTokens.onAccent,
                            ),
                            onPressed: () {
                              if (name.text.trim().isEmpty) return;
                              Navigator.pop(ctx, true);
                            },
                            child: Text(appT(ctx, 'Submit', 'জমা দিন')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    try {
      await ref.read(ghurtejaiApiProvider).createAttraction({
        'destination': destinationId,
        'type': type,
        'name': name.text.trim(),
        'address': address.text.trim(),
        'price_range': price.text.trim(),
        'notes': notes.text.trim(),
        'is_public_submission': true,
        if (imageUrl != null && imageUrl!.isNotEmpty) 'image_url': imageUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appT(context, 'Submitted for review', 'পর্যালোচনার জন্য জমা হয়েছে'),
            ),
          ),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatApiError(e))),
        );
      }
    }
  }

  Future<void> _showTransportForm(int destinationId) async {
    final from = TextEditingController();
    final to = TextEditingController();
    final op = TextEditingController();
    final cost = TextEditingController();
    final start = TextEditingController();
    String ttype = 'BUS';
    String? imageUrl;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.48,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => StatefulBuilder(
          builder: (sheetContext, setS) {
            return Material(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(GJTokens.radiusLg)),
              color: GJTokens.surfaceElevated,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: GJTokens.outline.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 4, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            appT(sheetContext, 'Add transport', 'পরিবহন যোগ করুন'),
                            style: GJText.title,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      children: [
                        TextField(
                          controller: from,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'From *', 'থেকে *'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: to,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'To *', 'পর্যন্ত *'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: ttype,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'Type', 'ধরন'),
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'BUS',
                              child: Text(appT(sheetContext, 'Bus', 'বাস')),
                            ),
                            DropdownMenuItem(
                              value: 'AC_BUS',
                              child: Text(appT(sheetContext, 'AC Bus', 'এসি বাস')),
                            ),
                            DropdownMenuItem(
                              value: 'TRAIN',
                              child: Text(appT(sheetContext, 'Train', 'ট্রেন')),
                            ),
                            DropdownMenuItem(
                              value: 'FLIGHT',
                              child: Text(appT(sheetContext, 'Flight', 'ফ্লাইট')),
                            ),
                            DropdownMenuItem(
                              value: 'OTHER',
                              child: Text(appT(sheetContext, 'Other', 'অন্যান্য')),
                            ),
                          ],
                          onChanged: (v) => setS(() => ttype = v ?? 'BUS'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: op,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'Operator', 'অপারেটর'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: cost,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'Cost', 'খরচ'),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: start,
                          decoration: InputDecoration(
                            labelText: appT(sheetContext, 'Start point', 'শুরুর পয়েন্ট'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GJGhostButton(
                          label: imageUrl == null
                              ? appT(sheetContext, 'Photo (optional)', 'ছবি (ঐচ্ছিক)')
                              : appT(sheetContext, 'Change photo', 'ছবি পরিবর্তন'),
                          onTap: () async {
                            final auth = ref.read(authNotifierProvider).value;
                            if (auth == null) {
                              await showGuestSignInDialog(context);
                              return;
                            }
                            final f = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (f == null) return;
                            try {
                              final res = await ref.read(ghurtejaiApiProvider).uploadImage(f.path);
                              final u = res['url'] as String?;
                              if (u != null) setS(() => imageUrl = u);
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text(formatApiError(e))),
                                );
                              }
                            }
                          },
                        ),
                        if (imageUrl != null && imageUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(GJTokens.radiusSm),
                              child: Image.network(
                                AppConfig.resolveMediaUrl(imageUrl),
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.paddingOf(ctx).bottom),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(appT(ctx, 'Cancel', 'বাতিল')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: GJTokens.accent,
                              foregroundColor: GJTokens.onAccent,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(appT(ctx, 'Submit', 'জমা দিন')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(ghurtejaiApiProvider).createTransport({
        'destination': destinationId,
        'from_location': from.text.trim(),
        'to_location': to.text.trim(),
        'type': ttype,
        'operator': op.text.trim(),
        'cost': cost.text.trim().isEmpty ? null : num.tryParse(cost.text.trim()),
        'start_point': start.text.trim(),
        if (imageUrl != null && imageUrl!.isNotEmpty) 'image_url': imageUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appT(context, 'Submitted for review', 'পর্যালোচনার জন্য জমা হয়েছে'),
            ),
          ),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatApiError(e))),
        );
      }
    }
  }
}
