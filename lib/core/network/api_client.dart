import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = String.fromEnvironment('API_URL');
  static const String apiKey = String.fromEnvironment('API_KEY');
  static const Duration timeout = Duration(seconds: 15);

  static const Map<String, String> jsonHeaders = {
    'x-api-key': apiKey,
    'Content-Type': 'application/json',
  };

  static const Map<String, String> baseHeaders = {
    'x-api-key': apiKey,
  };

  Future<http.Response> get(String path) {
    return http
        .get(Uri.parse('$baseUrl$path'), headers: jsonHeaders)
        .timeout(timeout);
  }

  Future<http.Response> post(String path,
      {required Map<String, dynamic> body}) {
    return http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: jsonHeaders,
          body: jsonEncode(body),
        )
        .timeout(timeout);
  }
}
