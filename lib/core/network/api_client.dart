import 'package:http/http.dart' as http;

class ApiClient {
  // Android emulator: use http://10.0.2.2:3000
  static const String baseUrl = 'http://localhost:3000';
  static const Duration _timeout = Duration(seconds: 10);

  Future<http.Response> get(String path) {
    return http.get(Uri.parse('$baseUrl$path')).timeout(_timeout);
  }
}
