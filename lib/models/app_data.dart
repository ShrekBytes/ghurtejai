import 'package:flutter/material.dart';
import 'destination.dart';

// ─────────────────────────────────────────────────────────
//  SHARED FILTER TAGS  (used by Explore + Experiences)
// ─────────────────────────────────────────────────────────
const List<String> kFilterTags = [
  'All', 'Beach', 'Mountain', 'Nature', 'Adventure', 'Food', 'Cultural', 'River',
];

const List<String> kRegions = [
  'All', 'Chittagong', 'Sylhet', 'Khulna', 'Barisal', 'Rajshahi', 'Dhaka',
];

const List<String> kTransportModes = [
  'All', 'Bus', 'Train', 'Boat', 'Air', 'CNG', 'Microbus',
];

// ─────────────────────────────────────────────────────────
//  DESTINATIONS
// ─────────────────────────────────────────────────────────
final List<DestinationSummary> kDestinations = [
  const DestinationSummary(
    name: "Cox's Bazar",
    slug: 'coxs-bazar',
    region: 'Chittagong',
    tags: ['Beach', 'Mountain'],
    emoji: '🌊',
    coverColor: Color(0xFFADD8F7),
    budgetMin: 2000, budgetMid: 5000, budgetMax: 10000,
    attractionCount: 12, foodCount: 8, activityCount: 6, experienceCount: 24,
    imagePaths: [
      'images/cox/cox_popular1.jpg', 'images/cox/cox_popular2.jpg',
      'images/cox/cox_popular4.jpg', 'images/cox/cox_trend.jpg',
    ],
    description: "World's longest natural sea beach with stunning sunsets and fresh seafood.",
  ),
  const DestinationSummary(
    name: 'Sylhet',
    slug: 'sylhet',
    region: 'Sylhet',
    tags: ['Nature', 'Mountain', 'Tea'],
    emoji: '🍃',
    coverColor: Color(0xFFC5F135),
    budgetMin: 1500, budgetMid: 4000, budgetMax: 8000,
    attractionCount: 10, foodCount: 6, activityCount: 5, experienceCount: 18,
    imagePaths: [
      'images/sylhet/syl_popular1.jpg', 'images/sylhet/syl_popular2.jpg',
      'images/sylhet/syl_popular3.jpg', 'images/sylhet/syl_popular4.jpg',
    ],
    description: 'Rolling tea gardens, haor wetlands and spiritual shrines of the northeast.',
  ),
  const DestinationSummary(
    name: 'Bandarban',
    slug: 'bandarban',
    region: 'Chittagong',
    tags: ['Adventure', 'Mountain', 'Tribal'],
    emoji: '⛰',
    coverColor: Color(0xFFC8F7E4),
    budgetMin: 3000, budgetMid: 6000, budgetMax: 12000,
    attractionCount: 9, foodCount: 4, activityCount: 8, experienceCount: 14,
    imagePaths: [
      'images/bandarban/band_pop1.jpg', 'images/bandarban/band_pop3.jpg',
      'images/bandarban/band_pop2.jpg', 'images/bandarban/band_pop4.jpg',
    ],
    description: 'Misty hill tracts with tribal culture, sky-touching peaks and hidden waterfalls.',
  ),
  const DestinationSummary(
    name: 'Sundarbans',
    slug: 'sundarbans',
    region: 'Khulna',
    tags: ['Nature', 'Wildlife', 'River'],
    emoji: '🌳',
    coverColor: Color(0xFFB8F0E8),
    budgetMin: 4000, budgetMid: 8000, budgetMax: 15000,
    attractionCount: 7, foodCount: 3, activityCount: 5, experienceCount: 10,
    imagePaths: [
      'images/sundarban/sund_pop1.jpg', 'images/sundarban/sund_pop2.png',
      'images/sundarban/sund_pop4.webp', 'images/sundarban/sund_pop3.jpg',
    ],
    description: "World's largest mangrove delta — home to Royal Bengal Tiger and river dolphins.",
  ),
  const DestinationSummary(
    name: 'Rangamati',
    slug: 'rangamati',
    region: 'Chittagong',
    tags: ['Nature', 'River', 'Cultural'],
    emoji: '⛵',
    coverColor: Color(0xFFFFD6E8),
    budgetMin: 2500, budgetMid: 5500, budgetMax: 10000,
    attractionCount: 8, foodCount: 4, activityCount: 6, experienceCount: 8,
    imagePaths: [],
    description: 'Kaptal Lake and the rolling hills of the Chittagong Hill Tracts.',
  ),
  const DestinationSummary(
    name: 'Sajek Valley',
    slug: 'sajek-valley',
    region: 'Chittagong',
    tags: ['Nature', 'Mountain', 'Adventure'],
    emoji: '☁',
    coverColor: Color(0xFFE8D5FF),
    budgetMin: 3500, budgetMid: 7000, budgetMax: 13000,
    attractionCount: 6, foodCount: 3, activityCount: 4, experienceCount: 11,
    imagePaths: [],
    description: 'Cloud-kissed valley in Rangamati district, a trekker\'s paradise.',
  ),
  const DestinationSummary(
    name: 'Kuakata',
    slug: 'kuakata',
    region: 'Barisal',
    tags: ['Beach', 'Nature'],
    emoji: '🌅',
    coverColor: Color(0xFFADD8F7),
    budgetMin: 2000, budgetMid: 4500, budgetMax: 9000,
    attractionCount: 5, foodCount: 5, activityCount: 3, experienceCount: 7,
    imagePaths: [],
    description: 'The "Daughter of the Sea" — see both sunrise and sunset from the same beach.',
  ),
  const DestinationSummary(
    name: 'Sreemangal',
    slug: 'sreemangal',
    region: 'Sylhet',
    tags: ['Nature', 'Food', 'Cultural'],
    emoji: '🍵',
    coverColor: Color(0xFFFFF3B0),
    budgetMin: 1500, budgetMid: 3500, budgetMax: 7000,
    attractionCount: 7, foodCount: 6, activityCount: 4, experienceCount: 9,
    imagePaths: [
      'images/sylhet/syl_popular4.jpg', 'images/sylhet/syl_popular1.jpg',
    ],
    description: 'Tea capital of Bangladesh with seven-layer tea and Lawachara rainforest.',
  ),
  const DestinationSummary(
    name: 'Paharpur',
    slug: 'paharpur',
    region: 'Rajshahi',
    tags: ['Cultural'],
    emoji: '🏛',
    coverColor: Color(0xFFFFE5B4),
    budgetMin: 1000, budgetMid: 2500, budgetMax: 5000,
    attractionCount: 4, foodCount: 2, activityCount: 2, experienceCount: 4,
    imagePaths: [],
    description: 'UNESCO World Heritage site — ruins of the ancient Buddhist Vihara of Paharpur.',
  ),
  const DestinationSummary(
    name: 'Dhaka',
    slug: 'dhaka',
    region: 'Dhaka',
    tags: ['Cultural', 'Food'],
    emoji: '🕌',
    coverColor: Color(0xFFFFD6E8),
    budgetMin: 500, budgetMid: 2000, budgetMax: 6000,
    attractionCount: 20, foodCount: 18, activityCount: 8, experienceCount: 30,
    imagePaths: [],
    description: 'The vibrant capital — Old Dhaka\'s rickshaws, biriyani, and centuries-old mosques.',
  ),
];

DestinationSummary? destinationBySlug(String slug) {
  for (final d in kDestinations) {
    if (d.slug == slug) return d;
  }
  return null;
}

// ─────────────────────────────────────────────────────────
//  ATTRACTIONS BY DESTINATION SLUG
// ─────────────────────────────────────────────────────────
final Map<String, List<AttractionItem>> kAttractionsBySlug = {
  'coxs-bazar': const [
    AttractionItem(
      name: 'Laboni Beach', type: 'PLACE',
      notes: 'Main beach strip — best at sunrise. Lifeguard patrolled.',
      address: 'Marine Drive, Cox\'s Bazar',
      emoji: '🏖', color: Color(0xFFADD8F7),
    ),
    AttractionItem(
      name: 'Inani Beach', type: 'PLACE',
      notes: 'Rocky coral reef beach, cleaner water, less crowded.',
      address: '27 km south of Cox\'s Bazar town',
      emoji: '🪸', color: Color(0xFFF2F0E8),
    ),
    AttractionItem(
      name: 'Himchari National Park', type: 'ACTIVITY',
      notes: 'Waterfall + hill deer + ocean view from the top.',
      address: '12 km south of Cox\'s Bazar',
      priceRange: '৳50 entry',
      emoji: '🌿', color: Color(0xFFC8F7E4),
    ),
    AttractionItem(
      name: 'Seafood at Marine Drive', type: 'FOOD',
      notes: 'Fresh rupchanda, prawn bhuna, lobster. Ask for live weight pricing.',
      address: 'Marine Drive Road',
      priceRange: '৳300–৳700/person',
      emoji: '🦐', color: Color(0xFFFFD6E8),
    ),
    AttractionItem(
      name: 'Shutki Palli', type: 'FOOD',
      notes: 'Largest dry fish market in Bangladesh. Free to browse.',
      address: 'Fisherman\'s Wharf, Cox\'s Bazar',
      emoji: '🐟', color: Color(0xFFFFE5B4),
    ),
  ],
  'sylhet': const [
    AttractionItem(
      name: 'Jaflong', type: 'PLACE',
      notes: 'Crystal-clear river, stone-collecting boats from across the border.',
      address: 'Jaflong, Gowainghat, Sylhet',
      emoji: '💎', color: Color(0xFFADD8F7),
    ),
    AttractionItem(
      name: 'Ratargul Swamp Forest', type: 'PLACE',
      notes: 'Only freshwater swamp forest in Bangladesh — boat ride essential.',
      address: 'Gowainghat, Sylhet',
      emoji: '🌲', color: Color(0xFFC8F7E4),
    ),
    AttractionItem(
      name: 'Lawachara National Park', type: 'ACTIVITY',
      notes: 'Guided primate walk for hoolock gibbons. Start before 8am.',
      address: 'Sreemangal, Moulvibazar',
      priceRange: '৳200 entry',
      emoji: '🦧', color: Color(0xFFC5F135),
    ),
    AttractionItem(
      name: 'Seven-Layer Tea (Nilkantha)', type: 'FOOD',
      notes: 'The world-famous multi-layered tea. One cup is enough!',
      address: 'Nilkantha Tea Cabin, Sreemangal',
      priceRange: '৳70–৳100',
      emoji: '🍵', color: Color(0xFFFFF3B0),
    ),
  ],
  'bandarban': const [
    AttractionItem(
      name: 'Nilgiri', type: 'PLACE',
      notes: 'Highest point accessible by jeep. Army permit required.',
      address: 'Nilgiri, 49 km from Bandarban town',
      priceRange: '৳1500 jeep hire',
      emoji: '🏔', color: Color(0xFFC8F7E4),
    ),
    AttractionItem(
      name: 'Boga Lake', type: 'PLACE',
      notes: 'Remote volcanic crater lake — 2-day trek only.',
      address: 'Keokradong range, Bandarban',
      emoji: '🏞', color: Color(0xFFADD8F7),
    ),
    AttractionItem(
      name: 'Chimbuk Hill', type: 'PLACE',
      notes: 'Second highest peak, closer and easier than Nilgiri.',
      address: '26 km from Bandarban town',
      emoji: '⛰', color: Color(0xFFC5F135),
    ),
    AttractionItem(
      name: 'Tribal Village Walk', type: 'ACTIVITY',
      notes: 'Visit Marma, Chakma, Murung villages. Arrange with local guide.',
      address: 'Various locations around Bandarban',
      emoji: '🏘', color: Color(0xFFE8D5FF),
    ),
    AttractionItem(
      name: 'Sujing Restaurant', type: 'FOOD',
      notes: 'Authentic Marma kitchen food — local bamboo dishes.',
      address: 'Bandarban town',
      priceRange: '৳150–৳300',
      emoji: '🍛', color: Color(0xFFFFD6E8),
    ),
  ],
  'sundarbans': const [
    AttractionItem(
      name: 'Karamjal Eco-Tourism Centre', type: 'PLACE',
      notes: 'Crocodile, deer, and python nursery — great for kids.',
      address: 'Karamjal, Mongla',
      priceRange: '৳100 entry',
      emoji: '🐊', color: Color(0xFFC8F7E4),
    ),
    AttractionItem(
      name: 'Kotka Beach & Forest', type: 'PLACE',
      notes: 'Deep forest area, tiger territory — guided groups only.',
      address: 'Kotka, Sundarbans East',
      emoji: '🐯', color: Color(0xFFFFE5B4),
    ),
    AttractionItem(
      name: 'Khulna–Sundarbans Launch Tour', type: 'ACTIVITY',
      notes: 'Overnight group tour package from Mongla port.',
      address: 'Mongla port, Khulna',
      priceRange: '৳2500–৳5000 (package)',
      emoji: '⛴', color: Color(0xFFADD8F7),
    ),
    AttractionItem(
      name: 'Forest Watchtower Hike', type: 'ACTIVITY',
      notes: 'Spot deer, monitor lizards, rare birds. Leeches in monsoon.',
      address: 'Kotka or Karamjal',
      emoji: '🌿', color: Color(0xFFB8F0E8),
    ),
  ],
};

List<AttractionItem> attractionsBySlug(String slug, {String? type}) {
  final list = kAttractionsBySlug[slug] ?? [];
  if (type == null || type == 'All') return list;
  return list.where((a) => a.type == type).toList();
}

// ─────────────────────────────────────────────────────────
//  TRANSPORT BY DESTINATION SLUG
// ─────────────────────────────────────────────────────────
final Map<String, List<TransportOption>> kTransportBySlug = {
  'coxs-bazar': const [
    TransportOption(
      fromLocation: 'Dhaka', toLocation: "Cox's Bazar",
      mode: 'Bus', duration: '10–12 hrs', costRange: '৳800–৳1500',
      note: 'Night buses from Kalabagan / Arambagh — S.Alam, Shyamoli.',
    ),
    TransportOption(
      fromLocation: 'Dhaka', toLocation: "Cox's Bazar",
      mode: 'Air', duration: '~1 hr', costRange: '৳3500–৳8000',
      note: 'Biman, US-Bangla, Novoair. Book 2 weeks ahead.',
    ),
    TransportOption(
      fromLocation: 'Chittagong', toLocation: "Cox's Bazar",
      mode: 'Bus', duration: '2.5–3 hrs', costRange: '৳200–৳350',
      note: 'Frequent departures from Chittagong Dampara stand.',
    ),
  ],
  'sylhet': const [
    TransportOption(
      fromLocation: 'Dhaka', toLocation: 'Sylhet',
      mode: 'Train', duration: '6–7 hrs', costRange: '৳350–৳750',
      note: 'Upashona / Parabat Express. Book Shovon or Sleeper.',
    ),
    TransportOption(
      fromLocation: 'Dhaka', toLocation: 'Sylhet',
      mode: 'Bus', duration: '5–6 hrs', costRange: '৳500–৳900',
      note: 'Ena, Shyamoli — depart from Sayedabad bus stand.',
    ),
  ],
  'bandarban': const [
    TransportOption(
      fromLocation: 'Dhaka', toLocation: 'Bandarban',
      mode: 'Bus', duration: '9–11 hrs', costRange: '৳750–৳1200',
      note: 'S. Alam, Shyamoli — overnight bus preferred.',
    ),
    TransportOption(
      fromLocation: 'Chittagong', toLocation: 'Bandarban',
      mode: 'Bus', duration: '1.5–2 hrs', costRange: '৳150–৳250',
      note: 'From Chittagong Bahaddarbad stand.',
    ),
  ],
  'sundarbans': const [
    TransportOption(
      fromLocation: 'Dhaka', toLocation: 'Khulna',
      mode: 'Train', duration: '5–6 hrs', costRange: '৳300–৳600',
      note: 'Sundarban Express / Chitra Express — frequent departures.',
    ),
    TransportOption(
      fromLocation: 'Khulna', toLocation: 'Sundarbans (Mongla)',
      mode: 'Boat', duration: '2–3 hrs', costRange: '৳2500+ (group)',
      note: 'Join a tour group from Mongla port for forest access.',
    ),
  ],
};

List<TransportOption> transportBySlug(String slug, {String? mode}) {
  final list = kTransportBySlug[slug] ?? [];
  if (mode == null || mode == 'All') return list;
  return list.where((t) => t.mode == mode).toList();
}
