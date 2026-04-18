import 'package:flutter/widgets.dart';

/// True when [MaterialApp.locale] is Bangla (`bn`).
bool appIsBn(BuildContext context) {
  return Localizations.localeOf(context).languageCode.startsWith('bn');
}

/// App-wide EN/BN copy. Use with [appLocaleProvider] in `main.dart`.
String appT(BuildContext context, String en, String bn) {
  return appIsBn(context) ? bn : en;
}
