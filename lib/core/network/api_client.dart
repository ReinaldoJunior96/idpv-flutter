import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl =
      'https://ahyrldewfotctzmjzkdy.supabase.co/functions/v1';
  static const String apiKey =
      'ipdv_cand_6a1a8ec901ea30f433269e42d0f487071b84dbeb40b9148d';
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
