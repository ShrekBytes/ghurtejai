import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage();

  static const _kAccess = 'gj_access_token';
  static const _kRefresh = 'gj_refresh_token';

  final FlutterSecureStorage _s = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _s.write(key: _kAccess, value: access);
    await _s.write(key: _kRefresh, value: refresh);
  }

  Future<void> saveAccess(String access) async {
    await _s.write(key: _kAccess, value: access);
  }

  Future<void> saveRefresh(String refresh) async {
    await _s.write(key: _kRefresh, value: refresh);
  }

  Future<String?> readAccess() => _s.read(key: _kAccess);

  Future<String?> readRefresh() => _s.read(key: _kRefresh);

  Future<void> clear() async {
    await _s.delete(key: _kAccess);
    await _s.delete(key: _kRefresh);
  }
}
