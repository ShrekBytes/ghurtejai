import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../network/auth_hooks.dart';
import '../network/dio_provider.dart';
import '../network/ghurtejai_api.dart';
import '../network/token_storage.dart';

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>(AuthNotifier.new);

class AuthNotifier extends Notifier<AsyncValue<AuthUser?>> {
  @override
  AsyncValue<AuthUser?> build() => const AsyncValue.data(null);

  GhurtejaiApi get _api => ref.read(ghurtejaiApiProvider);

  TokenStorage get _storage => ref.read(tokenStorageProvider);

  Future<void> bootstrap() async {
    state = const AsyncValue.loading();
    final access = await _storage.readAccess();
    if (access == null || access.isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }
    state = await AsyncValue.guard(() async {
      return _api.fetchProfile();
    });
    if (state.hasError) {
      await _storage.clear();
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String emailOrUsername, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final r = await _api.login(
        emailOrUsername: emailOrUsername,
        password: password,
      );
      await _storage.saveTokens(access: r.access, refresh: r.refresh);
      return _api.fetchProfile();
    });
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final r = await _api.register(
        email: email,
        username: username,
        password: password,
        passwordConfirm: passwordConfirm,
        firstName: firstName,
        lastName: lastName,
      );
      await _storage.saveTokens(access: r.access, refresh: r.refresh);
      return _api.fetchProfile();
    });
  }

  Future<void> refreshProfile() async {
    if (!state.hasValue || state.valueOrNull == null) return;
    try {
      final u = await _api.fetchProfile();
      state = AsyncValue.data(u);
    } catch (_) {
      // Keep existing session if refresh fails.
    }
  }

  Future<void> logout() async {
    final refresh = await _storage.readRefresh();
    if (refresh != null) {
      try {
        await _api.logout(refresh);
      } catch (_) {}
    }
    await clearSession();
  }

  Future<void> clearSession() async {
    await _storage.clear();
    state = const AsyncValue.data(null);
  }
}

void registerAuthHooks(WidgetRef ref) {
  AuthHooks.onSessionInvalid = () async {
    await ref.read(authNotifierProvider.notifier).clearSession();
  };
}
