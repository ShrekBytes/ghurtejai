import 'package:dio/dio.dart';

import 'auth_hooks.dart';
import 'token_storage.dart';

/// Attaches Bearer token; on 401 refreshes JWT and retries once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.storage,
    required this.dio,
  });

  final TokenStorage storage;
  final Dio dio;

  late final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: dio.options.baseUrl,
      connectTimeout: dio.options.connectTimeout,
      receiveTimeout: dio.options.receiveTimeout,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final access = await storage.readAccess();
    if (access != null && access.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    final opts = err.requestOptions;
    if (opts.extra['gj_auth_retry'] == true) {
      await _failSession();
      return handler.next(err);
    }
    final refresh = await storage.readRefresh();
    if (refresh == null || refresh.isEmpty) {
      await _failSession();
      return handler.next(err);
    }
    try {
      final res = await _refreshDio.post<Map<String, dynamic>>(
        'auth/refresh/',
        data: {'refresh': refresh},
      );
      final data = res.data ?? {};
      final newAccess = data['access'] as String?;
      final newRefresh = data['refresh'] as String?;
      if (newAccess == null) {
        await _failSession();
        return handler.next(err);
      }
      await storage.saveAccess(newAccess);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await storage.saveRefresh(newRefresh);
      }
      opts.headers['Authorization'] = 'Bearer $newAccess';
      opts.extra['gj_auth_retry'] = true;
      final clone = await dio.fetch(opts);
      return handler.resolve(clone);
    } catch (_) {
      await _failSession();
      return handler.next(err);
    }
  }

  Future<void> _failSession() async {
    await storage.clear();
    await AuthHooks.onSessionInvalid?.call();
  }
}
