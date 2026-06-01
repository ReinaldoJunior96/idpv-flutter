import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../data/checklist_items.dart';
import '../data/vistoria_model.dart';

class VistoriaApi {
  final _client = ApiClient();

  /// Faz upload de uma foto e retorna a URL gerada pelo servidor.
  Future<String?> uploadFoto(
    String clientId,
    String itemName,
    Uint8List bytes,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiClient.baseUrl}/fotos'),
    );
    request.headers['x-api-key'] = ApiClient.apiKey;
    request.fields['client_id'] = clientId;
    request.fields['item'] = itemName;
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: '${clientId}_$itemName.jpg',
    ));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['url'] ?? body['foto_url'] ?? body['path']) as String?;
    }
    throw Exception('Falha ao enviar foto (${response.statusCode}): ${response.body}');
  }

  /// Envia a vistoria completa com as URLs das fotos já resolvidas.
  Future<void> postVistoria(Vistoria vistoria) async {
    final itens = vistoria.resultados.map((r) {
      final item = kChecklist.firstWhere((i) => i.id == r.itemId);
      return {
        'item': item.nome,
        'status': r.status.apiValue,
        'observacao': r.observacao,
        'foto_url': r.fotoUrl,
      };
    }).toList();

    final body = {
      'client_id': vistoria.id,
      'posto_id': vistoria.postoId,
      'observacao_geral': null,
      'started_at': vistoria.startedAt,
      'finished_at': vistoria.finishedAt,
      'itens': itens,
    };

    final response = await _client.post('/vistorias', body: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Falha ao sincronizar vistoria (${response.statusCode}): ${response.body}');
    }
  }
}
