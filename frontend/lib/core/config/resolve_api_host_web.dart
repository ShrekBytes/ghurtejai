/// Web / WASM: no `dart:io`; same-machine dev server.
Future<String> resolveApiHost() async {
  const override = String.fromEnvironment('GJ_API_HOST');
  if (override.isNotEmpty) return override;
  return '127.0.0.1:8000';
}
