class Posto {
  final String id;
  final String nome;
  final String endereco;
  final String cidade;
  final String estado;
  final String bandeira;
  final bool jaAuditado;
  final int totalVistoriasSincronizadas;
  final String? ultimaVistoriaId;
  final String? ultimoClientId;
  final String? ultimaSincronizacao;

  const Posto({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.cidade,
    required this.estado,
    required this.bandeira,
    required this.jaAuditado,
    required this.totalVistoriasSincronizadas,
    this.ultimaVistoriaId,
    this.ultimoClientId,
    this.ultimaSincronizacao,
  });

  factory Posto.fromJson(Map<String, dynamic> json) => Posto(
        id: json['id'] as String,
        nome: json['nome'] as String,
        endereco: json['endereco'] as String,
        cidade: json['cidade'] as String,
        estado: json['estado'] as String,
        bandeira: json['bandeira'] as String,
        jaAuditado: json['ja_auditado'] as bool,
        totalVistoriasSincronizadas:
            json['total_vistorias_sincronizadas'] as int,
        ultimaVistoriaId: json['ultima_vistoria_id'] as String?,
        ultimoClientId: json['ultimo_client_id'] as String?,
        ultimaSincronizacao: json['ultima_sincronizacao'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'endereco': endereco,
        'cidade': cidade,
        'estado': estado,
        'bandeira': bandeira,
        'ja_auditado': jaAuditado,
        'total_vistorias_sincronizadas': totalVistoriasSincronizadas,
        'ultima_vistoria_id': ultimaVistoriaId,
        'ultimo_client_id': ultimoClientId,
        'ultima_sincronizacao': ultimaSincronizacao,
      };
}
