enum ItemStatus { conforme, naoConforme, naoSeAplica }

extension ItemStatusLabel on ItemStatus {
  String get label {
    switch (this) {
      case ItemStatus.conforme:
        return 'Conforme';
      case ItemStatus.naoConforme:
        return 'Não Conforme';
      case ItemStatus.naoSeAplica:
        return 'N/A';
    }
  }
}

class ItemResult {
  final String itemId;
  final ItemStatus status;
  final String? observacao;
  final String? photoPath;

  const ItemResult({
    required this.itemId,
    required this.status,
    this.observacao,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'status': status.name,
        'observacao': observacao,
        'photoPath': photoPath,
      };

  factory ItemResult.fromJson(Map<String, dynamic> json) => ItemResult(
        itemId: json['itemId'] as String,
        status: ItemStatus.values.byName(json['status'] as String),
        observacao: json['observacao'] as String?,
        photoPath: json['photoPath'] as String?,
      );
}

class Vistoria {
  final String id;
  final String postoId;
  final String postoNomeFantasia;
  final DateTime dataHora;
  final List<ItemResult> resultados;

  const Vistoria({
    required this.id,
    required this.postoId,
    required this.postoNomeFantasia,
    required this.dataHora,
    required this.resultados,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'postoId': postoId,
        'postoNomeFantasia': postoNomeFantasia,
        'dataHora': dataHora.toIso8601String(),
        'resultados': resultados.map((r) => r.toJson()).toList(),
      };

  factory Vistoria.fromJson(Map<String, dynamic> json) => Vistoria(
        id: json['id'] as String,
        postoId: json['postoId'] as String,
        postoNomeFantasia: json['postoNomeFantasia'] as String,
        dataHora: DateTime.parse(json['dataHora'] as String),
        resultados: (json['resultados'] as List<dynamic>)
            .map((r) => ItemResult.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}
