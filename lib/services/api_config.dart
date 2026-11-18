/// Configuração de integração definida em tempo de compilação.
///
/// Exemplo:
/// `flutter run -d chrome --dart-define=SEMOB_API_URL=http://localhost:8000/api/v1`
/// `--dart-define=SEMOB_USE_MOCKS=false`
class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'SEMOB_API_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static const useMocks = bool.fromEnvironment(
    'SEMOB_USE_MOCKS',
    defaultValue: true,
  );

  static const sourceLabel =
      useMocks ? 'Base demonstrativa validada' : 'API SEMOB-SCS';
}
