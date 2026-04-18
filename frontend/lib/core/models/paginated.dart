class Paginated<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  Paginated({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    final raw = json['results'] as List<dynamic>? ?? [];
    return Paginated(
      count: json['count'] as int? ?? raw.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: raw.map((e) => parseItem(e as Map<String, dynamic>)).toList(),
    );
  }
}
