import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/config/app_config.dart';
import '../../../core/locale/app_strings.dart';
import '../../../core/models/paginated.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/ghurtejai_api.dart';
import '../../../shared/theme/gj_colors.dart';
import '../../../shared/theme/gj_tokens.dart';
import '../../../shared/widgets/guest_gate.dart';
import 'create_experience_drafts.dart';

/// §9.4 — Multi-step experience builder (create + edit).
class CreateExperienceScreen extends ConsumerStatefulWidget {
  const CreateExperienceScreen({super.key, this.editSlug, this.initialDestinationSlug});

  final String? editSlug;

  /// When creating (not editing), pre-select this destination by slug (e.g. from destination detail).
  final String? initialDestinationSlug;

  @override
  ConsumerState<CreateExperienceScreen> createState() =>
      _CreateExperienceScreenState();
}

class _CreateExperienceScreenState extends ConsumerState<CreateExperienceScreen> {
  final PageController _page = PageController();
  int _step = 0;

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _userCost = TextEditingController();
  bool _sharePublic = false;
  int? _destinationId;
  List<Map<String, dynamic>> _destinations = [];
  final _tagIds = <int>[];
  List<Map<String, dynamic>> _tags = [];
  String? _coverImageUrl;
  bool _loading = true;
  bool _saving = false;

  String? _status;
  String? _destinationStatus;

  final _days = <DayDraft>[
    DayDraft(
      position: 1,
      entries: [EntryDraft(name: 'Activity')],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final api = ref.read(ghurtejaiApiProvider);
    try {
      final t = await api.fetchTags();
      if (!mounted) return;
      setState(() {
        _tags = t;
        _loading = false;
      });
      if (widget.editSlug != null) {
        await _loadForEdit(api);
      } else {
        final d = await api.fetchDestinations();
        if (!mounted) return;
        final slug = widget.initialDestinationSlug?.trim();
        final match = slug != null && slug.isNotEmpty
            ? d.results.firstWhereOrNull((e) => e['slug'] == slug)
            : null;
        setState(() {
          _destinations = d.results;
          if (match != null) {
            _destinationId = (match['id'] as num).toInt();
          } else if (_destinations.isNotEmpty) {
            _destinationId = (_destinations.first['id'] as num).toInt();
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadForEdit(GhurtejaiApi api) async {
    setState(() => _loading = true);
    try {
      final d = await api.fetchExperienceDetail(widget.editSlug!);
      final days = (d['days'] as List<dynamic>?) ?? [];
      _status = d['status'] as String?;
      _destinationStatus = d['destination_status'] as String?;
      _title.text = d['title'] as String? ?? '';
      _description.text = d['description'] as String? ?? '';
      final uc = d['user_cost'];
      if (uc != null) _userCost.text = '$uc';
      _sharePublic = d['visibility'] == 'PUBLIC';
      _destinationId = (d['destination'] as num?)?.toInt();
      final tagStrs = d['tags'] as List<dynamic>?;
      if (tagStrs != null && _tags.isNotEmpty) {
        final names = tagStrs.map((e) => '$e'.replaceAll('#', '').toLowerCase()).toSet();
        _tagIds.clear();
        for (final tg in _tags) {
          final n = '${tg['name']}'.toLowerCase();
          if (names.contains(n)) {
            _tagIds.add((tg['id'] as num).toInt());
          }
        }
      }
      final cover = d['cover_image'] as String?;
      if (cover != null && cover.isNotEmpty) _coverImageUrl = cover;

      final loadedDays = <DayDraft>[];
      for (final raw in days) {
        final m = raw as Map<String, dynamic>;
        final entRaw = (m['entries'] as List<dynamic>?) ?? [];
        final entries = entRaw.map((e) {
          final em = e as Map<String, dynamic>;
          String? timeStr = em['time'] as String?;
          if (timeStr != null && timeStr.length >= 5) {
            timeStr = timeStr.substring(0, 5);
          }
          return EntryDraft(
            name: em['name'] as String? ?? 'Entry',
            time: timeStr,
            cost: em['cost'] as num?,
            notes: em['notes'] as String? ?? '',
            attractionId: (em['attraction'] as num?)?.toInt(),
            imageUrl: em['image'] as String?,
          );
        }).toList();
        if (entries.isEmpty) entries.add(EntryDraft(name: 'Entry'));
        DateTime? dt;
        final ds = m['date'] as String?;
        if (ds != null && ds.isNotEmpty) {
          dt = DateTime.tryParse(ds);
        }
        loadedDays.add(
          DayDraft(
            position: (m['position'] as num?)?.toInt() ?? loadedDays.length + 1,
            date: dt,
            entries: entries,
          ),
        );
      }
      if (loadedDays.isNotEmpty) {
        setState(() {
          _days
            ..clear()
            ..addAll(loadedDays);
        });
      }

      final dest = await api.fetchDestinations();
      if (!mounted) return;
      setState(() {
        _destinations = dest.results;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatApiError(e))),
        );
      }
    }
  }

  Future<void> _pickCover() async {
    final auth = ref.read(authNotifierProvider).value;
    if (auth == null) {
      await showGuestSignInDialog(context);
      return;
    }
    final x = ImagePicker();
    final f = await x.pickImage(source: ImageSource.gallery);
    if (f == null) return;
    try {
      final res = await ref.read(ghurtejaiApiProvider).uploadImage(f.path);
      final url = res['url'] as String?;
      if (url != null) setState(() => _coverImageUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatApiError(e))),
        );
      }
    }
  }

  Map<String, dynamic> _body({bool draft = false, bool share = false}) {
    final days = <Map<String, dynamic>>[];
    var di = 0;
    for (final day in _days) {
      di++;
      final entries = <Map<String, dynamic>>[];
      var pos = 1;
      for (final e in day.entries) {
        final row = <String, dynamic>{
          'name': e.name.trim().isEmpty ? 'Entry' : e.name.trim(),
          'position': pos++,
          if (e.notes.isNotEmpty) 'notes': e.notes,
          if (e.cost != null) 'cost': e.cost,
          if (e.attractionId != null) 'attraction': e.attractionId,
          if (e.imageUrl != null && e.imageUrl!.trim().isNotEmpty)
            'image_url': e.imageUrl,
        };
        if (e.time != null && e.time!.isNotEmpty) {
          row['time'] = e.time!.length == 5 ? '${e.time}:00' : e.time;
        }
        entries.add(row);
      }
      final dm = <String, dynamic>{
        'position': di,
        'entries': entries,
      };
      if (day.date != null) {
        dm['date'] = day.date!.toIso8601String().split('T').first;
      }
      days.add(dm);
    }
    final uc = _userCost.text.trim();
    String visibility;
    if (draft) {
      visibility = 'PRIVATE';
    } else if (share) {
      visibility = 'PUBLIC';
    } else {
      visibility = _sharePublic ? 'PUBLIC' : 'PRIVATE';
    }
    return {
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'destination': _destinationId,
      'visibility': visibility,
      'user_cost': uc.isEmpty ? null : num.tryParse(uc),
      'days': days,
      'tag_ids': _tagIds,
      if (_coverImageUrl != null) 'cover_image_url': _coverImageUrl,
    };
  }

  num? _estimatedSum() {
    num t = 0;
    var any = false;
    for (final d in _days) {
      for (final e in d.entries) {
        final c = e.cost;
        if (c != null && c > 0) {
          t += c;
          any = true;
        }
      }
    }
    return any ? t : null;
  }

  Future<void> _resetFormFromReview() async {
    if (_saving) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          widget.editSlug != null
              ? appT(ctx, 'Discard changes?', 'পরিবর্তন বাতিল করবেন?')
              : appT(ctx, 'Reset this experience?', 'এই অভিজ্ঞতা রিসেট করবেন?'),
          style: GJText.title,
        ),
        content: Text(
          widget.editSlug != null
              ? appT(
                  ctx,
                  'Unsaved edits will be dropped and this experience will be loaded again from the server.',
                  'সংরক্ষণহীন সম্পাদনা বাদ যাবে এবং অভিজ্ঞতাটি সার্ভার থেকে আবার লোড হবে।',
                )
              : appT(
                  ctx,
                  'Title, description, destination choice, days, tags, cover image, and spend will be reset. You will return to step 1.',
                  'শিরোনাম, বর্ণনা, গন্তব্য, দিন, ট্যাগ, কভার ও ব্যয় রিসেট হবে। আপনি ১ নম্বর ধাপে ফিরে যাবেন।',
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
            child: Text(
              widget.editSlug != null
                  ? appT(ctx, 'Reload', 'আবার লোড')
                  : appT(ctx, 'Reset', 'রিসেট'),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    if (widget.editSlug != null) {
      await _loadForEdit(ref.read(ghurtejaiApiProvider));
      if (!mounted) return;
      setState(() => _step = 0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_page.hasClients) _page.jumpToPage(0);
      });
      return;
    }

    setState(() {
      _title.clear();
      _description.clear();
      _userCost.clear();
      _sharePublic = false;
      _coverImageUrl = null;
      _tagIds.clear();
      _status = null;
      _destinationStatus = null;
      _days
        ..clear()
        ..add(
          DayDraft(
            position: 1,
            entries: [EntryDraft(name: appT(context, 'Activity', 'কার্যক্রম'))],
          ),
        );
      final slug = widget.initialDestinationSlug?.trim();
      final match = slug != null && slug.isNotEmpty && _destinations.isNotEmpty
          ? _destinations.firstWhereOrNull((e) => e['slug'] == slug)
          : null;
      if (match != null) {
        _destinationId = (match['id'] as num).toInt();
      } else if (_destinations.isNotEmpty) {
        _destinationId = (_destinations.first['id'] as num).toInt();
      } else {
        _destinationId = null;
      }
      _step = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_page.hasClients) _page.jumpToPage(0);
    });
  }

  Future<void> _saveDraft() async {
    final auth = ref.read(authNotifierProvider).value;
    if (auth == null) {
      await showGuestSignInDialog(context);
      return;
    }
    if (_destinationId == null || _title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appT(context, 'Title and destination are required', 'শিরোনাম ও গন্তব্য প্রয়োজন'),
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final api = ref.read(ghurtejaiApiProvider);
      if (widget.editSlug != null) {
        await api.updateExperience(widget.editSlug!, _body(draft: true));
      } else {
        await api.createExperience(_body(draft: true));
      }
      if (mounted) context.go('/profile');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatApiError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submitPublicExperience() async {
    final auth = ref.read(authNotifierProvider).value;
    if (auth == null) {
      await showGuestSignInDialog(context);
      return;
    }
    if (_destinationId == null || _title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appT(context, 'Title and destination are required', 'শিরোনাম ও গন্তব্য প্রয়োজন'),
          ),
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appT(ctx, 'Share publicly?', 'পাবলিক শেয়ার করবেন?'), style: GJText.title),
        content: Text(
          appT(
            ctx,
            'Your experience will be reviewed before going public.',
            'পাবলিক হওয়ার আগে আপনার অভিজ্ঞতা পর্যালোচিত হবে।',
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
            child: Text(appT(ctx, 'Submit', 'জমা দিন')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      final api = ref.read(ghurtejaiApiProvider);
      if (widget.editSlug != null) {
        await api.updateExperience(widget.editSlug!, _body(share: true));
      } else {
        await api.createExperience(_body(share: true));
      }
      if (mounted) context.go('/profile');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatApiError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _page.dispose();
    _title.dispose();
    _description.dispose();
    _userCost.dispose();
    super.dispose();
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

    final pendingBanner = _status == 'PENDING_REVIEW';
    final destWarn =
        _destinationStatus != null && _destinationStatus != 'APPROVED';

    return Scaffold(
      backgroundColor: GJTokens.tabCanvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GJPageHeader(
            pageTitle: _step == 0
                ? appT(context, 'Basics', 'মৌলিক')
                : _step == 1
                    ? appT(context, 'Days', 'দিনসমূহ')
                    : appT(context, 'Review', 'পর্যালোচনা'),
            pageSubtitle: appT(
              context,
              'Create experience · Step ${_step + 1} of 3',
              'অভিজ্ঞতা তৈরি · ধাপ ${_step + 1} / ৩',
            ),
            showBack: context.canPop(),
            onBack: () => context.pop(),
            trailing: auth != null
                ? TextButton(
                    onPressed: _saving ? null : _saveDraft,
                    child: Text(appT(context, 'Save', 'সংরক্ষণ'), style: GJText.tiny),
                  )
                : null,
          ),
          if (pendingBanner)
            Material(
              color: GJ.orange.withValues(alpha: 0.35),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  appT(
                    context,
                    'Saving changes will return this to private. Resubmit for review to go public.',
                    'সংরক্ষণে এটি আবার ব্যক্তিগত হবে। পাবলিকের জন্য আবার জমা দিন।',
                  ),
                  style: GJText.tiny,
                ),
              ),
            ),
          if (destWarn)
            Material(
              color: GJ.pink.withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  appT(
                    context,
                    'Destination under review — you can keep editing; it may not appear in selectors until approved.',
                    'গন্তব্য পর্যালোচনায় — সম্পাদনা চালিয়ে যেতে পারেন; অনুমোদন না হওয়া পর্যন্ত তালিকায় নাও দেখাতে পারে।',
                  ),
                  style: GJText.tiny,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: List.generate(3, (i) {
                final on = i <= _step;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    height: 6,
                    decoration: BoxDecoration(
                      color: on ? GJ.dark : GJ.dark.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: GJ.dark, width: 1),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _basicsStep(auth),
                _daysStep(auth),
                _reviewStep(auth),
              ],
            ),
          ),
          if (_step < 2)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: GJGhostButton(
                        label: appT(context, 'Back', 'পিছনে'),
                        onTap: () {
                          _page.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                          setState(() => _step--);
                        },
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    child: GJButton(
                      label: appT(context, 'Next', 'পরবর্তী'),
                      color: GJ.yellow,
                      onTap: () {
                        _page.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                        setState(() => _step++);
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GJGhostButton(
                      label: appT(context, 'Back', 'পিছনে'),
                      onTap: () {
                        _page.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                        setState(() => _step--);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: GJButton(
                      label: appT(context, 'Reset', 'রিসেট'),
                      color: const Color(0xFFDC2626),
                      foregroundColor: GJ.white,
                      onTap: () {
                        if (!_saving) _resetFormFromReview();
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openDestinationSearch() async {
    final api = ref.read(ghurtejaiApiProvider);
    final searchCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GJ.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: GJ.dark, width: 2),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.85,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: searchCtrl,
                          decoration: InputDecoration(
                            labelText: appT(context, 'Search destinations', 'গন্তব্য খুঁজুন'),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setModal(() {}),
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<Paginated<Map<String, dynamic>>>(
                          key: ValueKey(searchCtrl.text),
                          future: api.fetchDestinations(
                            nameContains: searchCtrl.text.trim(),
                          ),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(color: GJ.dark),
                              );
                            }
                            final list = snap.data!.results;
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: list.length + 1,
                              itemBuilder: (context, i) {
                                if (i == list.length) {
                                  return ListTile(
                                    leading: const Icon(Icons.add_location_alt_rounded),
                                    title: Text(
                                      appT(context, 'Create new destination…', 'নতুন গন্তব্য জমা…'),
                                      style: GJText.label,
                                    ),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _openSubmitDestinationForm();
                                    },
                                  );
                                }
                                final m = list[i];
                                return ListTile(
                                  title: Text('${m['name']}', style: GJText.body),
                                  subtitle: Text(
                                    '${m['district_name'] ?? ''}',
                                    style: GJText.tiny,
                                  ),
                                  onTap: () {
                                    setState(
                                      () => _destinationId = (m['id'] as num).toInt(),
                                    );
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openSubmitDestinationForm() async {
    final name = TextEditingController();
    final desc = TextEditingController();
    int? districtId;
    String? coverImageUrl;
    final districts = await ref.read(ghurtejaiApiProvider).fetchDistricts();
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          return AlertDialog(
            title: Text(
              appT(ctx, 'Submit destination', 'গন্তব্য জমা দিন'),
              style: GJText.title,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: appT(ctx, 'Name *', 'নাম *'),
                    ),
                  ),
                  TextField(
                    controller: desc,
                    decoration: InputDecoration(
                      labelText: appT(ctx, 'Description', 'বর্ণনা'),
                    ),
                    maxLines: 3,
                  ),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: appT(ctx, 'District', 'জেলা'),
                    ),
                    items: districts
                        .map(
                          (d) => DropdownMenuItem(
                            value: (d['id'] as num).toInt(),
                            child: Text('${d['name']}', style: GJText.tiny),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => districtId = v,
                  ),
                  const SizedBox(height: 12),
                  GJGhostButton(
                    label: coverImageUrl == null
                        ? appT(ctx, 'Cover image (optional)', 'কভার ছবি (ঐচ্ছিক)')
                        : appT(ctx, 'Change cover image', 'কভার ছবি পরিবর্তন'),
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
                        if (u != null) setDialog(() => coverImageUrl = u);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(formatApiError(e))),
                          );
                        }
                      }
                    },
                  ),
                  if (coverImageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        coverImageUrl!,
                        style: GJText.tiny,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(appT(ctx, 'Cancel', 'বাতিল')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(appT(ctx, 'Submit', 'জমা দিন')),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || districtId == null || name.text.trim().isEmpty) return;
    try {
      await ref.read(ghurtejaiApiProvider).createDestination({
        'name': name.text.trim(),
        'description': desc.text.trim(),
        'district': districtId,
        if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
          'cover_image_url': coverImageUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appT(
                context,
                "Destination submitted for review. You'll be notified when it's approved.",
                'গন্তব্য পর্যালোচনায় জমা হয়েছে। অনুমোদন হলে জানানো হবে।',
              ),
            ),
          ),
        );
      }
      final d = await ref.read(ghurtejaiApiProvider).fetchDestinations();
      if (mounted) {
        setState(() => _destinations = d.results);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatApiError(e))),
        );
      }
    }
  }

  void _moveEntry(DayDraft day, int i, int delta) {
    final j = i + delta;
    if (j < 0 || j >= day.entries.length) return;
    setState(() {
      final e = day.entries.removeAt(i);
      day.entries.insert(j, e);
    });
  }

  Future<void> _openEntryEditor(DayDraft day, int entryIndex) async {
    if (_destinationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appT(context, 'Choose a destination first', 'প্রথমে একটি গন্তব্য বেছে নিন'),
          ),
        ),
      );
      return;
    }
    final api = ref.read(ghurtejaiApiProvider);
    final entry = day.entries[entryIndex];
    final nameCtrl = TextEditingController(text: entry.name);
    final notesCtrl = TextEditingController(text: entry.notes);
    final costCtrl = TextEditingController(
      text: entry.cost != null ? '${entry.cost}' : '',
    );
    final timeCtrl = TextEditingController(text: entry.time ?? '');
    final searchCtrl = TextEditingController();
    var page = 0;
    var attractionSearch = '';
    var sheetImageUrl = entry.imageUrl;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: GJTokens.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(GJTokens.radiusLg)),
        side: BorderSide(color: GJTokens.outline.withValues(alpha: 0.12)),
      ),
      builder: (ctx) {
        final inset = MediaQuery.viewInsetsOf(ctx).bottom;
        final screenH = MediaQuery.sizeOf(ctx).height;
        final listH = (screenH * 0.36).clamp(220.0, 440.0);
        final formMaxH = (screenH * 0.48).clamp(280.0, 560.0);
        return Padding(
          padding: EdgeInsets.only(bottom: inset),
          child: StatefulBuilder(
            builder: (context, setSheet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 4, 0),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(appT(context, 'Entry', 'খণ্ড'), style: GJText.title),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text(appT(context, 'Attraction', 'দর্শনীয় স্থান')),
                          selected: page == 0,
                          onSelected: (_) => setSheet(() => page = 0),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(appT(context, 'Custom', 'কাস্টম')),
                          selected: page == 1,
                          onSelected: (_) => setSheet(() => page = 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (page == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: searchCtrl,
                            decoration: InputDecoration(
                              labelText: appT(context, 'Search attractions', 'আকর্ষণ খুঁজুন'),
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (v) => setSheet(() => attractionSearch = v),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: listH,
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              key: ValueKey('${attractionSearch}_$_destinationId'),
                              future: api.fetchAttractions(
                                destinationId: _destinationId!,
                                search: attractionSearch.isEmpty ? null : attractionSearch,
                              ),
                              builder: (context, snap) {
                                if (!snap.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(color: GJ.dark),
                                  );
                                }
                                final list = snap.data!;
                                if (list.isEmpty) {
                                  return ListView(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    children: [
                                      Text(
                                        appT(context, "Can't find it?", 'পাচ্ছেন না?'),
                                        style: GJText.label,
                                      ),
                                      TextButton(
                                        onPressed: () => setSheet(() => page = 1),
                                        child: Text(
                                          appT(context, 'Use as custom entry', 'কাস্টম খণ্ড হিসেবে নিন'),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await _submitAttractionInline(
                                            searchCtrl.text,
                                            (created) {
                                              setSheet(() {
                                                entry.attractionId =
                                                    (created['id'] as num).toInt();
                                                nameCtrl.text =
                                                    '${created['name'] ?? searchCtrl.text}';
                                                page = 1;
                                              });
                                            },
                                          );
                                        },
                                        child: Text(
                                          appT(context, 'Submit this attraction', 'এই আকর্ষণ জমা দিন'),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return ListView.separated(
                                  itemCount: list.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    color: GJTokens.outline.withValues(alpha: 0.08),
                                  ),
                                  itemBuilder: (context, i) {
                                    final a = list[i];
                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                      title: Text('${a['name']}', style: GJText.body),
                                      subtitle: Text('${a['type']}', style: GJText.tiny),
                                      onTap: () {
                                        setSheet(() {
                                          entry.attractionId = (a['id'] as num).toInt();
                                          nameCtrl.text = '${a['name']}';
                                          page = 1;
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: formMaxH),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: nameCtrl,
                              decoration: InputDecoration(
                                labelText: appT(context, 'Name *', 'নাম *'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: timeCtrl,
                              decoration: InputDecoration(
                                labelText: appT(context, 'Time (HH:MM)', 'সময় (ঘণ্টা:মিনিট)'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: costCtrl,
                              decoration: InputDecoration(
                                labelText: appT(context, 'Cost (BDT)', 'খরচ (টাকা)'),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: notesCtrl,
                              decoration: InputDecoration(
                                labelText: appT(context, 'Notes', 'নোট'),
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            GJGhostButton(
                              label: sheetImageUrl == null
                                  ? appT(context, 'Entry image (optional)', 'খণ্ডের ছবি (ঐচ্ছিক)')
                                  : appT(context, 'Change entry image', 'খণ্ডের ছবি পরিবর্তন'),
                              onTap: () async {
                                final auth = ref.read(authNotifierProvider).value;
                                if (auth == null) {
                                  await showGuestSignInDialog(context);
                                  return;
                                }
                                final f =
                                    await ImagePicker().pickImage(source: ImageSource.gallery);
                                if (f == null) return;
                                try {
                                  final res =
                                      await ref.read(ghurtejaiApiProvider).uploadImage(f.path);
                                  final u = res['url'] as String?;
                                  if (u != null) setSheet(() => sheetImageUrl = u);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(formatApiError(e))),
                                    );
                                  }
                                }
                              },
                            ),
                            if (sheetImageUrl != null && sheetImageUrl!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(GJTokens.radiusSm),
                                  child: Image.network(
                                    AppConfig.resolveMediaUrl(sheetImageUrl),
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    child: GJButton(
                      label: appT(context, 'Save entry', 'খণ্ড সংরক্ষণ'),
                      color: GJ.yellow,
                      onTap: () {
                        entry.name = nameCtrl.text.trim().isEmpty
                            ? appT(context, 'Entry', 'খণ্ড')
                            : nameCtrl.text.trim();
                        entry.time = timeCtrl.text.trim().isEmpty ? null : timeCtrl.text.trim();
                        entry.cost = num.tryParse(costCtrl.text.trim());
                        entry.notes = notesCtrl.text;
                        entry.imageUrl = sheetImageUrl;
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _submitAttractionInline(
    String query,
    void Function(Map<String, dynamic>) onCreatedSelf,
  ) async {
    final name = TextEditingController(text: query);
    String type = 'PLACE';
    final notes = TextEditingController();
    final address = TextEditingController();
    final price = TextEditingController();
    var localSelf = false;
    String? attractionImageUrl;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx2) => StatefulBuilder(
        builder: (context, setD) {
          return AlertDialog(
            title: Text(
              appT(ctx2, 'Submit attraction', 'আকর্ষণ জমা দিন'),
              style: GJText.title,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: appT(ctx2, 'Name', 'নাম'),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: [
                      DropdownMenuItem(
                        value: 'PLACE',
                        child: Text(appT(ctx2, 'Place', 'স্থান')),
                      ),
                      DropdownMenuItem(
                        value: 'FOOD',
                        child: Text(appT(ctx2, 'Food', 'খাবার')),
                      ),
                      DropdownMenuItem(
                        value: 'ACTIVITY',
                        child: Text(appT(ctx2, 'Activity', 'কার্যক্রম')),
                      ),
                    ],
                    onChanged: (v) => setD(() => type = v ?? 'PLACE'),
                  ),
                  TextField(
                    controller: address,
                    decoration: InputDecoration(
                      labelText: appT(ctx2, 'Address', 'ঠিকানা'),
                    ),
                  ),
                  TextField(
                    controller: price,
                    decoration: InputDecoration(
                      labelText: appT(ctx2, 'Price range', 'মূল্যের ধরন'),
                    ),
                  ),
                  TextField(
                    controller: notes,
                    decoration: InputDecoration(
                      labelText: appT(ctx2, 'Notes', 'নোট'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GJGhostButton(
                    label: attractionImageUrl == null
                        ? appT(ctx2, 'Photo (optional)', 'ছবি (ঐচ্ছিক)')
                        : appT(ctx2, 'Change photo', 'ছবি পরিবর্তন'),
                    onTap: () async {
                      final auth = ref.read(authNotifierProvider).value;
                      if (auth == null) {
                        await showGuestSignInDialog(context);
                        return;
                      }
                      final f =
                          await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (f == null) return;
                      try {
                        final res =
                            await ref.read(ghurtejaiApiProvider).uploadImage(f.path);
                        final u = res['url'] as String?;
                        if (u != null) setD(() => attractionImageUrl = u);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(formatApiError(e))),
                          );
                        }
                      }
                    },
                  ),
                  if (attractionImageUrl != null && attractionImageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          AppConfig.resolveMediaUrl(attractionImageUrl),
                          height: 88,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  SwitchListTile(
                    title: Text(appT(ctx2, 'Save for myself only', 'শুধু আমার জন্য সংরক্ষণ')),
                    value: localSelf,
                    onChanged: (v) => setD(() => localSelf = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx2, false),
                child: Text(appT(ctx2, 'Cancel', 'বাতিল')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx2, true),
                child: Text(appT(ctx2, 'Submit', 'জমা দিন')),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || _destinationId == null) return;
    try {
      final res = await ref.read(ghurtejaiApiProvider).createAttraction({
        'destination': _destinationId,
        'type': type,
        'name': name.text.trim(),
        'notes': notes.text.trim(),
        'address': address.text.trim(),
        'price_range': price.text.trim(),
        'is_public_submission': !localSelf,
        if (attractionImageUrl != null && attractionImageUrl!.isNotEmpty)
          'image_url': attractionImageUrl,
      });
      if (localSelf) {
        onCreatedSelf(res);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appT(context, 'Attraction saved for your use.', 'আকর্ষণ আপনার ব্যবহারে সংরক্ষিত।'),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appT(context, 'Attraction submitted for review.', 'আকর্ষণ পর্যালোচনায় জমা হয়েছে।'),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatApiError(e))),
        );
      }
    }
  }
  Widget _basicsStep(AuthUser? auth) {
    final destLabel = _destinations.firstWhereOrNull(
      (e) => (e['id'] as num).toInt() == _destinationId,
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(appT(context, 'Destination', 'গন্তব্য'), style: GJText.label),
          subtitle: Text(
            destLabel != null
                ? '${destLabel['name']}'
                : appT(context, 'Tap to search', 'খুঁজতে ট্যাপ করুন'),
            style: GJText.body,
          ),
          trailing: const Icon(Icons.search_rounded),
          onTap: auth == null ? null : () => _openDestinationSearch(),
        ),
        if (auth == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              appT(context, 'Sign in to create', 'তৈরিতে সাইন ইন করুন'),
              style: GJText.tiny,
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _title,
          decoration: InputDecoration(
            labelText: appT(context, 'Title *', 'শিরোনাম *'),
          ),
          style: GJText.body,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          decoration: InputDecoration(
            labelText: appT(context, 'Description', 'বর্ণনা'),
          ),
          maxLines: 3,
          style: GJText.body,
        ),
        const SizedBox(height: 12),
        Text(appT(context, 'Visibility', 'দৃশ্যমানতা'), style: GJText.label),
        RadioListTile<bool>(
          title: Text(appT(context, 'Private (only you)', 'ব্যক্তিগত (শুধু আপনি)')),
          value: false,
          groupValue: _sharePublic,
          onChanged: auth == null
              ? null
              : (v) {
                  if (v != null) setState(() => _sharePublic = v);
                },
        ),
        RadioListTile<bool>(
          title: Text(
            appT(
              context,
              'Public (submit for review when you share)',
              'পাবলিক (শেয়ারে পর্যালোচনার জন্য জমা)',
            ),
          ),
          value: true,
          groupValue: _sharePublic,
          onChanged: auth == null
              ? null
              : (v) {
                  if (v != null) setState(() => _sharePublic = v);
                },
        ),
        const SizedBox(height: 8),
        Text(appT(context, 'Tags', 'ট্যাগ'), style: GJText.label),
        Wrap(
          spacing: 6,
          children: _tags.map((tg) {
            final id = (tg['id'] as num).toInt();
            final sel = _tagIds.contains(id);
            return FilterChip(
              label: Text('${tg['name']}', style: GJText.tiny),
              selected: sel,
              onSelected: auth == null
                  ? null
                  : (_) {
                      setState(() {
                        if (sel) {
                          _tagIds.remove(id);
                        } else {
                          _tagIds.add(id);
                        }
                      });
                    },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        GJGhostButton(
          label: _coverImageUrl == null
              ? appT(context, 'Pick cover image (optional)', 'কভার ছবি বেছে নিন (ঐচ্ছিক)')
              : appT(context, 'Cover selected — tap to change', 'কভার নির্বাচিত — পরিবর্তনে ট্যাপ'),
          onTap: _pickCover,
        ),
      ],
    );
  }

  Widget _daysStep(AuthUser? auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _days.length,
            onReorder: auth == null
                ? (_, __) {}
                : (oldI, newI) {
                    setState(() {
                      if (newI > oldI) newI -= 1;
                      final item = _days.removeAt(oldI);
                      _days.insert(newI, item);
                      for (var j = 0; j < _days.length; j++) {
                        _days[j].position = j + 1;
                      }
                    });
                  },
            itemBuilder: (context, i) {
              final day = _days[i];
              return Card(
                key: ValueKey('day_${day.position}_$i'),
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.none,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReorderableDragStartListener(
                            index: i,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8, top: 4),
                              child: Icon(Icons.drag_handle_rounded),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appT(context, 'Day ${day.position}', 'দিন ${day.position}'),
                                  style: GJText.title,
                                ),
                                if (day.date != null)
                                  Text(
                                    day.date!.toLocal().toString().split(' ').first,
                                    style: GJText.tiny.copyWith(
                                      color: GJ.dark.withValues(alpha: 0.65),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today_outlined, size: 20),
                            onPressed: auth == null
                                ? null
                                : () async {
                                    final d = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                      initialDate: day.date ?? DateTime.now(),
                                    );
                                    if (d != null) {
                                      setState(() => day.date = d);
                                    }
                                  },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: _days.length <= 1
                                ? null
                                : () => setState(() {
                                      _days.removeAt(i);
                                      for (var j = 0; j < _days.length; j++) {
                                        _days[j].position = j + 1;
                                      }
                                    }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...day.entries.asMap().entries.map((me) {
                  final ei = me.key;
                  final entry = me.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: auth == null ? null : () => _openEntryEditor(day, ei),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 28,
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                                    onPressed:
                                        ei == 0 ? null : () => _moveEntry(day, ei, -1),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 28,
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                    onPressed: ei >= day.entries.length - 1
                                        ? null
                                        : () => _moveEntry(day, ei, 1),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.name,
                                      style: GJText.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      [
                                        if (entry.time != null && entry.time!.isNotEmpty)
                                          entry.time,
                                        if (entry.cost != null) '৳${entry.cost}',
                                        if (entry.imageUrl != null &&
                                            entry.imageUrl!.isNotEmpty)
                                          appT(context, 'Photo', 'ছবি'),
                                      ].join(' · '),
                                      style: GJText.tiny,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  if (day.entries.length <= 1) return;
                                  setState(() => day.entries.removeAt(ei));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                      TextButton(
                        onPressed: auth == null
                            ? null
                            : () => setState(() {
                                  day.entries.add(
                                    EntryDraft(name: appT(context, 'Entry', 'খণ্ড')),
                                  );
                                }),
                        child: Text(
                          appT(context, '+ Add entry', '+ খণ্ড যোগ'),
                          style: GJText.tiny,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GJGhostButton(
            label: appT(context, '+ Add Day', '+ দিন যোগ'),
            onTap: () {
              if (auth == null) {
                showGuestSignInDialog(context);
                return;
              }
              setState(() {
                _days.add(
                  DayDraft(
                    position: _days.length + 1,
                    entries: [
                      EntryDraft(name: appT(context, 'New entry', 'নতুন খণ্ড')),
                    ],
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _reviewStep(AuthUser? auth) {
    final est = _estimatedSum();
    final estLabel = est != null ? '৳$est' : appT(context, 'N/A', 'প্রযোজ্য নয়');
    final entryTotal = _days.fold<int>(0, (a, d) => a + d.entries.length);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          appT(context, 'Review & publish', 'পর্যালোচনা ও প্রকাশ'),
          style: GJText.title.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          appT(
            context,
            'Check the summary below, then save or share.',
            'নিচের সারাংশ দেখে সংরক্ষণ বা শেয়ার করুন।',
          ),
          style: GJText.tiny.copyWith(color: GJTokens.onSurface.withValues(alpha: 0.55)),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SummaryStatCard(
                icon: Icons.calendar_view_day_rounded,
                label: appT(context, 'Days', 'দিন'),
                value: '${_days.length}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryStatCard(
                icon: Icons.list_alt_rounded,
                label: appT(context, 'Activities', 'কার্যক্রম'),
                value: '$entryTotal',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryStatCard(
                icon: Icons.payments_outlined,
                label: appT(context, 'Est. total', 'আনুমানিক মোট'),
                value: estLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          appT(context, 'Actual spend (optional)', 'প্রকৃত ব্যয় (ঐচ্ছিক)'),
          style: GJText.label.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _userCost,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: appT(context, '৳ e.g. 12000', '৳ উদা. ১২০০০'),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: GJTokens.surfaceElevated,
          ),
          style: GJText.body,
        ),
        const SizedBox(height: 28),
        if (auth == null)
          GJButton(
            label: appT(context, 'Sign in to save', 'সংরক্ষণে সাইন ইন'),
            color: GJ.yellow,
            onTap: () => showGuestSignInDialog(context),
          )
        else ...[
          GJButton(
            label: appT(context, 'Save as private', 'ব্যক্তিগত সংরক্ষণ'),
            color: GJ.white,
            onTap: () {
              if (!_saving) _saveDraft();
            },
          ),
          const SizedBox(height: 12),
          GJButton(
            label: appT(context, 'Share experience', 'অভিজ্ঞতা শেয়ার'),
            color: GJ.pink,
            onTap: () {
              if (!_saving) _submitPublicExperience();
            },
          ),
        ],
      ],
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: GJTokens.surfaceElevated,
        borderRadius: BorderRadius.circular(GJTokens.radiusMd),
        border: Border.all(color: GJTokens.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: GJTokens.accent, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GJText.label.copyWith(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GJText.tiny.copyWith(color: GJTokens.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
