import 'dart:convert';
import 'package:vistoria_postos/core/network/api_client.dart';
import 'posto_model.dart';

class PostosApi {
  final _client = ApiClient();

  Future<List<Posto>> fetchPostos() async {
    final response = await _client.get('/postos');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;
      return data
          .map((e) => Posto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erro ao buscar postos: ${response.statusCode}');
  }
}
