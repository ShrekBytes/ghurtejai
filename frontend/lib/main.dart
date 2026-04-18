import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_notifier.dart';
import 'core/config/app_config.dart';
import 'core/config/resolve_api_host.dart';
import 'core/locale/app_locale_provider.dart';
import 'core/router/app_router.dart';
import 'shared/theme/gj_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final host = await resolveApiHost();
  AppConfig.setResolvedHost(host);
  runApp(const ProviderScope(child: GhurtejaiApp()));
}

class GhurtejaiApp extends ConsumerStatefulWidget {
  const GhurtejaiApp({super.key});

  @override
  ConsumerState<GhurtejaiApp> createState() => _GhurtejaiAppState();
}

class _GhurtejaiAppState extends ConsumerState<GhurtejaiApp> {
  var _boot = false;

  @override
  Widget build(BuildContext context) {
    if (!_boot) {
      _boot = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        registerAuthHooks(ref);
        ref.read(authNotifierProvider.notifier).bootstrap();
      });
    }

    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      title: 'Ghurtejai',
      debugShowCheckedModeBanner: false,
      theme: buildGJTheme(),
      routerConfig: router,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('bn'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
