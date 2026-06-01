enum ItemStatus { conforme, naoConforme, naoSeAplica }

enum SyncStatus { pending, syncing, synced, failed }

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

  // Valor esperado pela API
  String get apiValue {
    switch (this) {
      case ItemStatus.conforme:
        return 'conforme';
      case ItemStatus.naoConforme:
        return 'nao_conforme';
      case ItemStatus.naoSeAplica:
        return 'nao_se_aplica';
    }
  }
}

class ItemResult {
  final String itemId;
  final ItemStatus status;
  final String? observacao;
  final String? photoBase64; // bytes em base64 para persistência offline
  final String? fotoUrl;     // URL após upload bem-sucedido

  const ItemResult({
    required this.itemId,
    required this.status,
    this.observacao,
    this.photoBase64,
    this.fotoUrl,
  });

  ItemResult copyWith({String? fotoUrl}) => ItemResult(
        itemId: itemId,
        status: status,
        observacao: observacao,
        photoBase64: photoBase64,
        fotoUrl: fotoUrl ?? this.fotoUrl,
      );

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'status': status.name,
        'observacao': observacao,
        'photoBase64': photoBase64,
        'fotoUrl': fotoUrl,
      };

  factory ItemResult.fromJson(Map<String, dynamic> json) => ItemResult(
        itemId: json['itemId'] as String,
        status: ItemStatus.values.byName(json['status'] as String),
        observacao: json['observacao'] as String?,
        photoBase64: json['photoBase64'] as String?,
        fotoUrl: json['fotoUrl'] as String?,
      );
}

class Vistoria {
  final String id; // usado como client_id na API
  final String postoId;
  final String postoNome;
  final DateTime dataHora;
  final String startedAt;  // ISO8601 para a API
  final String finishedAt; // ISO8601 para a API
  final List<ItemResult> resultados;
  final SyncStatus syncStatus;

  const Vistoria({
    required this.id,
    required this.postoId,
    required this.postoNome,
    required this.dataHora,
    required this.startedAt,
    required this.finishedAt,
    required this.resultados,
    this.syncStatus = SyncStatus.pending,
  });

  Vistoria copyWith({
    List<ItemResult>? resultados,
    SyncStatus? syncStatus,
  }) =>
      Vistoria(
        id: id,
        postoId: postoId,
        postoNome: postoNome,
        dataHora: dataHora,
        startedAt: startedAt,
        finishedAt: finishedAt,
        resultados: resultados ?? this.resultados,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'postoId': postoId,
        'postoNome': postoNome,
        'dataHora': dataHora.toIso8601String(),
        'startedAt': startedAt,
        'finishedAt': finishedAt,
        'resultados': resultados.map((r) => r.toJson()).toList(),
        'syncStatus': syncStatus.name,
      };

  factory Vistoria.fromJson(Map<String, dynamic> json) => Vistoria(
        id: json['id'] as String,
        postoId: json['postoId'] as String,
        postoNome: json['postoNome'] as String,
        dataHora: DateTime.parse(json['dataHora'] as String),
        startedAt: json['startedAt'] as String,
        finishedAt: json['finishedAt'] as String,
        resultados: (json['resultados'] as List<dynamic>)
            .map((r) => ItemResult.fromJson(r as Map<String, dynamic>))
            .toList(),
        syncStatus: SyncStatus.values.byName(
          json['syncStatus'] as String? ?? 'pending',
        ),
      );
}
