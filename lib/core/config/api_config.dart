class ApiConfig {
  // Android emulator can reach the host machine through 10.0.2.2.
  // Override with --dart-define=API_BASE_URL=... for a physical device or desktop.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );
}
