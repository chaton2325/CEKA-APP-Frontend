class AppConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ceka.mirhosty.com',
  );
  static const String logoUrl =
      'https://ebya2024.org/images/ceka%202026/logo.jpeg';
  static const String registrationCode = String.fromEnvironment(
    'REGISTRATION_CODE',
    defaultValue: 'CEKA2026',
  );
}
