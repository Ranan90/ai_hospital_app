import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return const String.fromEnvironment(
      'API_URL',
      defaultValue: 'http://localhost:3000',
    );
  }
}
