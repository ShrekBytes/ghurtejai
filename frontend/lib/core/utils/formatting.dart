String formatMoneyBdt(dynamic v) {
  if (v == null) return 'N/A';
  if (v is num) return '৳${v.toString()}';
  return '৳$v';
}

/// User-facing status line (API still uses `DRAFT` — we call that "Private" in UI).
String experienceStatusShortLabel(String? raw) {
  switch (raw) {
    case 'DRAFT':
      return 'Private';
    case 'PENDING_REVIEW':
      return 'Pending review';
    case 'PUBLISHED':
      return 'Published';
    case 'REJECTED':
      return 'Rejected';
    default:
      return raw?.trim().isNotEmpty == true ? raw! : '';
  }
}
