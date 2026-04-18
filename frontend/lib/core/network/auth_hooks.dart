/// Set from the root widget to clear auth state when refresh fails (avoids import cycles).
class AuthHooks {
  AuthHooks._();

  static Future<void> Function()? onSessionInvalid;
}
