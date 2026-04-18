/// Local vote transition matching backend: same value removes, opposite flips, new adds.
Map<String, dynamic> patchExperienceVoteMap(Map<String, dynamic> raw, int pressed) {
  final x = Map<String, dynamic>.from(raw);
  var uv = (x['user_vote'] as num?)?.toInt() ?? 0;
  var sc = (x['score'] as num?)?.toInt() ?? 0;
  if (uv == pressed) {
    sc -= pressed;
    uv = 0;
  } else if (uv == 0) {
    sc += pressed;
    uv = pressed;
  } else {
    sc -= uv;
    sc += pressed;
    uv = pressed;
  }
  x['user_vote'] = uv;
  x['score'] = sc;
  return x;
}
