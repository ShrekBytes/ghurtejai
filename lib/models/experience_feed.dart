// Mock feed + detail models for Experiences list / detail screens.

enum ExperienceSort { popular, newest, cost, duration }

class ExperienceFeedItem {
  final String id;
  final String title;
  final String destinationName;
  final int entryCount;
  final int attractions;
  final int costBdt;
  final int days;
  final List<String> tags;
  final int upvotes;
  final int commentCount;
  final List<String> coverImagePaths;
  final DateTime createdAt;
  final String? author;

  const ExperienceFeedItem({
    required this.id,
    required this.title,
    required this.destinationName,
    required this.entryCount,
    required this.attractions,
    required this.costBdt,
    required this.days,
    required this.tags,
    required this.upvotes,
    required this.commentCount,
    required this.coverImagePaths,
    required this.createdAt,
    this.author,
  });
}

class ItineraryEntry {
  final int order;
  final String title;
  final String body;
  final String costLabel;
  final String note;
  final String? timeStart;
  final String? timeEnd;
  final List<String> imagePaths;

  const ItineraryEntry({
    required this.order,
    required this.title,
    required this.body,
    required this.costLabel,
    required this.note,
    this.timeStart,
    this.timeEnd,
    this.imagePaths = const [],
  });
}

class ExperienceComment {
  final String id;
  final String author;
  final String body;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;
  final String? parentId;

  const ExperienceComment({
    required this.id,
    required this.author,
    required this.body,
    this.upvotes = 0,
    this.downvotes = 0,
    required this.createdAt,
    this.parentId,
  });

  int get score => upvotes - downvotes;
}

class ExperienceDetail {
  final ExperienceFeedItem summary;
  final List<ItineraryEntry> itinerary;
  final List<ExperienceComment> comments;

  const ExperienceDetail({
    required this.summary,
    required this.itinerary,
    required this.comments,
  });
}

/// IDs aligned with Explore trending order: Cox, Sylhet, Bandarban, Sundarbans.
const List<String> kTrendingExperienceIds = [
  'exp_cox',
  'exp_sylhet',
  'exp_bandarban',
  'exp_sundarbans',
];

final List<ExperienceFeedItem> kExperienceFeedItems = [
  ExperienceFeedItem(
    id: 'exp_cox',
    title: "Cox's Bazar by sadib",
    destinationName: "Cox's Bazar",
    entryCount: 6,
    attractions: 45,
    costBdt: 5000,
    days: 2,
    tags: ['Beach', 'Mountain'],
    upvotes: 27,
    commentCount: 8,
    coverImagePaths: [
      'images/cox/cox_popular1.jpg',
      'images/cox/cox_popular2.jpg',
      'images/cox/cox_popular3.jpg',
      'images/cox/cox_trend.jpg',
    ],
    createdAt: DateTime(2025, 11, 2),
    author: 'sadib',
  ),
  ExperienceFeedItem(
    id: 'exp_sylhet',
    title: 'Sylhet Sesh 6 Dine',
    destinationName: 'Sylhet',
    entryCount: 12,
    attractions: 23,
    costBdt: 12000,
    days: 6,
    tags: ['Nature', 'Mountain'],
    upvotes: 34,
    commentCount: 15,
    coverImagePaths: [
      'images/sylhet/syl_popular1.jpg',
      'images/sylhet/syl_popular2.jpg',
      'images/sylhet/syl_popular3.jpg',
      'images/sylhet/syl_trend.jpg',
    ],
    createdAt: DateTime(2025, 10, 18),
    author: 'Rafi',
  ),
  ExperienceFeedItem(
    id: 'exp_bandarban',
    title: '2 Day Bandarban Adventure',
    destinationName: 'Bandarban',
    entryCount: 8,
    attractions: 5,
    costBdt: 4800,
    days: 2,
    tags: ['Adventure', 'Mountain', 'Food'],
    upvotes: 63,
    commentCount: 12,
    coverImagePaths: [
      'images/bandarban/band_pop1.jpg',
      'images/bandarban/band_pop2.jpg',
      'images/bandarban/band_pop3.jpg',
      'images/bandarban/band_trend.jpg',
    ],
    createdAt: DateTime(2026, 1, 5),
    author: 'Nadia',
  ),
  ExperienceFeedItem(
    id: 'exp_sundarbans',
    title: 'Sundarbans Safari',
    destinationName: 'Sundarbans',
    entryCount: 7,
    attractions: 12,
    costBdt: 9000,
    days: 4,
    tags: ['Wildlife', 'River', 'Nature'],
    upvotes: 42,
    commentCount: 9,
    coverImagePaths: [
      'images/sundarban/sund_pop1.jpg',
      'images/sundarban/sund_pop2.png',
      'images/sundarban/sund_pop3.jpg',
      'images/sundarban/sund_trend.jpg',
    ],
    createdAt: DateTime(2025, 12, 20),
    author: 'Tanvir',
  ),
  ExperienceFeedItem(
    id: 'exp_sreemangal',
    title: 'Tea Garden Weekend',
    destinationName: 'Sreemangal',
    entryCount: 5,
    attractions: 8,
    costBdt: 3500,
    days: 2,
    tags: ['Nature', 'Food', 'Cultural'],
    upvotes: 19,
    commentCount: 4,
    coverImagePaths: [
      'images/sylhet/syl_popular4.jpg',
      'images/sylhet/syl_popular1.jpg',
      'images/sylhet/syl_popular2.jpg',
      'images/sylhet/syl_trend.jpg',
    ],
    createdAt: DateTime(2025, 9, 1),
    author: 'Mitu',
  ),
  ExperienceFeedItem(
    id: 'exp_kuakata',
    title: 'Kuakata Sun & Sea',
    destinationName: 'Kuakata',
    entryCount: 4,
    attractions: 6,
    costBdt: 6200,
    days: 3,
    tags: ['Beach', 'Nature'],
    upvotes: 31,
    commentCount: 6,
    coverImagePaths: [
      'images/cox/cox_popular4.jpg',
      'images/cox/cox_popular1.jpg',
      'images/cox/cox_popular2.jpg',
      'images/cox/cox_popular3.jpg',
    ],
    createdAt: DateTime(2025, 8, 14),
    author: 'Orin',
  ),
];

List<ExperienceDetail> _buildDetails() {
  return [
    ExperienceDetail(
      summary: kExperienceFeedItems[0],
      itinerary: [
        ItineraryEntry(
          order: 1,
          title: 'Dhaka to Cox’s Bazar (Shyamoli / Ena)',
          body: 'Overnight bus from Kalabagan; reached Teknaf road early morning.',
          costLabel: '৳800–950',
          note:
              'Booked window seat online. Carry light jacket — AC gets cold.',
          timeStart: '10pm',
          timeEnd: '6am',
          imagePaths: ['images/cox/cox_popular1.jpg'],
        ),
        ItineraryEntry(
          order: 2,
          title: 'Laboni Beach sunrise',
          body: 'Walked the main beach strip; light crowd before 7am.',
          costLabel: '৳0',
          note: 'Best photos facing east; local tea stalls open around 6:30.',
          timeStart: '5:30am',
          timeEnd: '8am',
          imagePaths: ['images/cox/cox_trend.jpg', 'images/cox/cox_popular2.jpg'],
        ),
        ItineraryEntry(
          order: 3,
          title: 'Seafood lunch at Marine Drive',
          body: 'Shared prawn bhuna and rupchanda fry at a roadside kitchen.',
          costLabel: '৳450–600',
          note: 'Ask for live weight pricing to avoid surprises.',
          timeStart: '1pm',
          timeEnd: '2:30pm',
          imagePaths: ['images/cox/cox_popular3.jpg'],
        ),
      ],
      comments: [
        ExperienceComment(
          id: 'c1',
          author: 'faysal_bd',
          body: 'Solid route — bus tip saved me a headache.',
          upvotes: 12,
          downvotes: 0,
          createdAt: DateTime(2025, 11, 4),
        ),
        ExperienceComment(
          id: 'c2',
          author: 'nabila_t',
          body: 'Would add Himchari half-day if you have time.',
          upvotes: 5,
          downvotes: 1,
          createdAt: DateTime(2025, 11, 5),
        ),
      ],
    ),
    ExperienceDetail(
      summary: kExperienceFeedItems[1],
      itinerary: [
        ItineraryEntry(
          order: 1,
          title: 'Dhaka to Sylhet (train)',
          body: 'Upashona Express — scenic last leg into hills.',
          costLabel: '৳350–650',
          note: 'Sleeper tickets sell fast on weekends.',
          timeStart: '9pm',
          timeEnd: '7am',
          imagePaths: ['images/sylhet/syl_popular1.jpg'],
        ),
        ItineraryEntry(
          order: 2,
          title: 'Jaflong day trip',
          body: 'River views and stone collecting boats (go early).',
          costLabel: '৳1200 (shared car)',
          note: 'Negotiate return time with driver upfront.',
          timeStart: '6am',
          timeEnd: '3pm',
          imagePaths: ['images/sylhet/syl_trend.jpg'],
        ),
      ],
      comments: [
        ExperienceComment(
          id: 'c3',
          author: 'rafi_explores',
          body: 'Tea gardens on day 3 were the highlight.',
          upvotes: 8,
          downvotes: 0,
          createdAt: DateTime(2025, 10, 20),
        ),
      ],
    ),
    ExperienceDetail(
      summary: kExperienceFeedItems[2],
      itinerary: [
        ItineraryEntry(
          order: 1,
          title: 'Zenith Express to Cox’s Bazar (example route)',
          body: 'From Dhaka Kalabagan stand — overnight to coast.',
          costLabel: '৳800',
          note:
              'We took Zenith at 5pm from Kalabagan, slept on the bus until midnight stop.',
          timeStart: '5pm',
          timeEnd: '12am',
          imagePaths: ['images/bandarban/band_pop1.jpg'],
        ),
        ItineraryEntry(
          order: 2,
          title: 'Chingri snacks & drinks',
          body: 'Quick stop at highway tea stall.',
          costLabel: '৳100–200',
          note: 'After food, short rest before hill transfer next morning.',
          timeStart: '1am',
          timeEnd: '2am',
          imagePaths: ['images/bandarban/band_pop2.jpg'],
        ),
        ItineraryEntry(
          order: 3,
          title: 'Nilgiri viewpoint',
          body: 'Jeep from town; mist rolled in by afternoon.',
          costLabel: '৳1500',
          note: 'Carry ID for army checkposts.',
          timeStart: '10am',
          timeEnd: '4pm',
          imagePaths: ['images/bandarban/band_trend.jpg', 'images/bandarban/band_pop3.jpg'],
        ),
      ],
      comments: [
        ExperienceComment(
          id: 'c4',
          author: 'hill_hopper',
          body: 'Costs are accurate for dry season.',
          upvotes: 21,
          downvotes: 2,
          createdAt: DateTime(2026, 1, 6),
        ),
        ExperienceComment(
          id: 'c5',
          author: 'anonymous_user',
          body: 'Nilgiri queue was long on Friday.',
          upvotes: 3,
          downvotes: 0,
          createdAt: DateTime(2026, 1, 7),
          parentId: 'c4',
        ),
      ],
    ),
    ExperienceDetail(
      summary: kExperienceFeedItems[3],
      itinerary: [
        ItineraryEntry(
          order: 1,
          title: 'Khulna launch to forest',
          body: 'Joined group tour boat; life jackets provided.',
          costLabel: '৳2500 (package slice)',
          note: 'Silence rules after dark for wildlife.',
          timeStart: '8am',
          timeEnd: '6pm',
          imagePaths: ['images/sundarban/sund_trend.jpg'],
        ),
        ItineraryEntry(
          order: 2,
          title: 'Watchtower walk',
          body: 'Short trek; spotted deer and monitor lizards.',
          costLabel: '৳0',
          note: 'Leeches in monsoon — carry salt.',
          timeStart: '5pm',
          timeEnd: '7pm',
          imagePaths: ['images/sundarban/sund_pop1.jpg', 'images/sundarban/sund_pop3.jpg'],
        ),
      ],
      comments: [
        ExperienceComment(
          id: 'c6',
          author: 'safari_fan',
          body: 'Tiger sighting is rare — go for the delta vibe.',
          upvotes: 15,
          downvotes: 1,
          createdAt: DateTime(2025, 12, 22),
        ),
      ],
    ),
    ExperienceDetail(
      summary: kExperienceFeedItems[4],
      itinerary: [
        ItineraryEntry(
          order: 1,
          title: 'Lawachara trail',
          body: 'Easy loop; guide optional but helpful for gibbons.',
          costLabel: '৳200 entry',
          note: 'Start before 8am for calls.',
          timeStart: '7am',
          timeEnd: '10am',
          imagePaths: ['images/sylhet/syl_popular3.jpg'],
        ),
        ItineraryEntry(
          order: 2,
          title: 'Seven Layer Tea',
          body: 'Nilkantha stall near town.',
          costLabel: '৳80',
          note: 'Sweet — one cup is enough!',
          timeStart: '4pm',
          timeEnd: '5pm',
          imagePaths: ['images/sylhet/syl_popular4.jpg'],
        ),
      ],
      comments: [],
    ),
    ExperienceDetail(
      summary: kExperienceFeedItems[5],
      itinerary: [
        ItineraryEntry(
          order: 1,
          title: 'Dhaka to Kuakata bus',
          body: 'Direct coaches from Gabtoli; long but smooth highway.',
          costLabel: '৳900',
          note: 'Take night bus to catch sunrise next day.',
          timeStart: '9pm',
          timeEnd: '6am',
          imagePaths: ['images/cox/cox_popular4.jpg'],
        ),
        ItineraryEntry(
          order: 2,
          title: 'Sunrise on both sea edges',
          body: 'Walked the beach arc; unique dual horizon feel.',
          costLabel: '৳0',
          note: 'Tripod helps for low light.',
          timeStart: '5:15am',
          timeEnd: '7am',
          imagePaths: ['images/cox/cox_popular1.jpg'],
        ),
      ],
      comments: [
        ExperienceComment(
          id: 'c7',
          author: 'coast_lover',
          body: 'Underrated compared to Cox’s.',
          upvotes: 9,
          downvotes: 0,
          createdAt: DateTime(2025, 8, 16),
        ),
      ],
    ),
  ];
}

final Map<String, ExperienceDetail> kExperienceDetails = {
  for (final d in _buildDetails()) d.summary.id: d,
};

ExperienceDetail? experienceDetailById(String id) => kExperienceDetails[id];

ExperienceFeedItem? experienceFeedItemById(String id) {
  for (final e in kExperienceFeedItems) {
    if (e.id == id) return e;
  }
  return null;
}

List<String> get kExperienceDestinations {
  final set = <String>{};
  for (final e in kExperienceFeedItems) {
    set.add(e.destinationName);
  }
  final list = set.toList()..sort();
  return ['All', ...list];
}

/// Tag filter: null or 'All' = no tag filter.
List<ExperienceFeedItem> sortedFilteredExperiences(
  List<ExperienceFeedItem> all, {
  required ExperienceSort sort,
  String? tagFilter,
  String? destinationFilter,
  int? maxDays,
  int? maxBudget,
}) {
  var out = List<ExperienceFeedItem>.from(all);

  if (tagFilter != null &&
      tagFilter.isNotEmpty &&
      tagFilter != 'All') {
    out = out
        .where((e) => e.tags.any(
              (t) => t.toLowerCase() == tagFilter.toLowerCase(),
            ))
        .toList();
  }

  if (destinationFilter != null &&
      destinationFilter.isNotEmpty &&
      destinationFilter != 'All') {
    out = out
        .where((e) => e.destinationName == destinationFilter)
        .toList();
  }

  if (maxDays != null) {
    out = out.where((e) => e.days <= maxDays).toList();
  }

  if (maxBudget != null) {
    out = out.where((e) => e.costBdt <= maxBudget).toList();
  }

  switch (sort) {
    case ExperienceSort.popular:
      out.sort((a, b) {
        final u = b.upvotes.compareTo(a.upvotes);
        if (u != 0) return u;
        return b.commentCount.compareTo(a.commentCount);
      });
      break;
    case ExperienceSort.newest:
      out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case ExperienceSort.cost:
      out.sort((a, b) => a.costBdt.compareTo(b.costBdt));
      break;
    case ExperienceSort.duration:
      out.sort((a, b) => a.days.compareTo(b.days));
      break;
  }

  return out;
}
