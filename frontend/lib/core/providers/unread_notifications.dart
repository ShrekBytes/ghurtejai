import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_notifier.dart';
import '../network/ghurtejai_api.dart';

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final auth = ref.watch(authNotifierProvider).value;
  if (auth == null) return 0;
  try {
    return ref.read(ghurtejaiApiProvider).unreadNotificationCount();
  } catch (_) {
    return 0;
  }
});
