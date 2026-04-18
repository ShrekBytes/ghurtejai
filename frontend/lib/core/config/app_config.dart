/// API base is built from [apiHost]. Defaults are set at startup via
/// [setResolvedHost] (see [resolveApiHost]).
/// Compile-time override: `flutter run --dart-define=GJ_API_HOST=192.168.1.5:8000`
class AppConfig {
  AppConfig._();

  static String _resolvedHost = '127.0.0.1:8000';

  /// Call from [main] after [resolveApiHost] before [runApp].
  static void setResolvedHost(String host) {
    _resolvedHost = host;
  }

  static String get apiHost {
    const override = String.fromEnvironment('GJ_API_HOST');
    if (override.isNotEmpty) return override;
    return _resolvedHost;
  }

  /// Trailing slash required so Dio resolves relative paths under `/api/` (not `/`).
  static String get apiBaseUrl => 'http://$apiHost/api/';
  static String get mediaOrigin => 'http://$apiHost';

  static String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final p = path.startsWith('/') ? path : '/$path';
    return '$mediaOrigin$p';
  }
}
