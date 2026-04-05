import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────
//  DESTINATION SUMMARY  (for lists, grids, and cards)
// ─────────────────────────────────────────────────────────
class DestinationSummary {
  final String name;
  final String slug;
  final String region;
  final List<String> tags;
  final String emoji;
  final Color coverColor;
  final int budgetMin;
  final int budgetMid;
  final int budgetMax;
  final int attractionCount;
  final int foodCount;
  final int activityCount;
  final int experienceCount;
  final List<String> imagePaths;
  final String description;

  const DestinationSummary({
    required this.name,
    required this.slug,
    required this.region,
    required this.tags,
    required this.emoji,
    required this.coverColor,
    required this.budgetMin,
    required this.budgetMid,
    required this.budgetMax,
    required this.attractionCount,
    required this.foodCount,
    required this.activityCount,
    required this.experienceCount,
    this.imagePaths = const [],
    this.description = '',
  });
}

// ─────────────────────────────────────────────────────────
//  ATTRACTION ITEM  (place, food, or activity)
// ─────────────────────────────────────────────────────────
class AttractionItem {
  final String name;
  final String type; // PLACE | FOOD | ACTIVITY
  final String notes;
  final String address;
  final String priceRange;
  final String emoji;
  final Color color;

  const AttractionItem({
    required this.name,
    required this.type,
    required this.notes,
    required this.address,
    this.priceRange = '',
    required this.emoji,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────
//  TRANSPORT OPTION
// ─────────────────────────────────────────────────────────
class TransportOption {
  final String fromLocation;
  final String toLocation;
  final String mode; // Bus | Train | Launch | Boat | Air | CNG | Microbus
  final String duration;
  final String costRange;
  final String note;

  const TransportOption({
    required this.fromLocation,
    required this.toLocation,
    required this.mode,
    required this.duration,
    required this.costRange,
    this.note = '',
  });
}
