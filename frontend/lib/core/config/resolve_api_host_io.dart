import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// VM / native: pick a sensible default per OS. Override with
/// `--dart-define=GJ_API_HOST=host:port` (e.g. LAN IP for phone without adb reverse).
Future<String> resolveApiHost() async {
  const override = String.fromEnvironment('GJ_API_HOST');
  if (override.isNotEmpty) return override;

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    return '127.0.0.1:8000';
  }
  if (Platform.isIOS) {
    return '127.0.0.1:8000';
  }
  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    if (info.isPhysicalDevice) {
      // With `adb reverse tcp:8000 tcp:8000`, localhost reaches the host.
      return '127.0.0.1:8000';
    }
    return '10.0.2.2:8000';
  }
  return '127.0.0.1:8000';
}
