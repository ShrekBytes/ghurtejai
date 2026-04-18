/// In-memory day/entry models for the experience builder (§9.4).
class EntryDraft {
  EntryDraft({
    required this.name,
    this.time,
    this.cost,
    this.notes = '',
    this.attractionId,
    this.imageUrl,
  });

  String name;
  String? time;
  num? cost;
  String notes;
  int? attractionId;
  /// Optional image — server path/URL from upload endpoint (`image_url` in API body).
  String? imageUrl;
}

class DayDraft {
  DayDraft({required this.position, required this.entries, this.date});

  int position;
  DateTime? date;
  List<EntryDraft> entries;
}
