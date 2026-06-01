class Posto {
  final String id;
  final String cnpj;
  final String nomePosto;
  final String nomeFantasia;
  final String bandeira;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String municipio;
  final String uf;
  final String cep;
  final String cpfResponsavel;
  final String nomeResponsavel;
  final String emailResponsavel;
  final String cargoResponsavel;
  final List<String> combustiveis;
  final String status;
  final String? dataInauguracao;
  final int numeroBicos;
  final int numeroPistas;
  final String? observacoes;

  const Posto({
    required this.id,
    required this.cnpj,
    required this.nomePosto,
    required this.nomeFantasia,
    required this.bandeira,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.municipio,
    required this.uf,
    required this.cep,
    required this.cpfResponsavel,
    required this.nomeResponsavel,
    required this.emailResponsavel,
    required this.cargoResponsavel,
    required this.combustiveis,
    required this.status,
    this.dataInauguracao,
    required this.numeroBicos,
    required this.numeroPistas,
    this.observacoes,
  });

  factory Posto.fromJson(Map<String, dynamic> json) {
    return Posto(
      id: json['id'] as String,
      cnpj: json['cnpj'] as String,
      nomePosto: json['nome_posto'] as String,
      nomeFantasia: json['nome_fantasia'] as String,
      bandeira: json['bandeira'] as String,
      logradouro: json['logradouro'] as String,
      numero: json['numero'] as String,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String,
      municipio: json['municipio'] as String,
      uf: json['uf'] as String,
      cep: json['cep'] as String,
      cpfResponsavel: json['cpf_responsavel'] as String,
      nomeResponsavel: json['nome_responsavel'] as String,
      emailResponsavel: json['email_responsavel'] as String,
      cargoResponsavel: json['cargo_responsavel'] as String,
      combustiveis: (json['combustiveis'] as List<dynamic>).cast<String>(),
      status: json['status'] as String,
      dataInauguracao: json['data_inauguracao'] as String?,
      numeroBicos: json['numero_bicos'] as int,
      numeroPistas: json['numero_pistas'] as int,
      observacoes: json['observacoes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cnpj': cnpj,
        'nome_posto': nomePosto,
        'nome_fantasia': nomeFantasia,
        'bandeira': bandeira,
        'logradouro': logradouro,
        'numero': numero,
        'complemento': complemento,
        'bairro': bairro,
        'municipio': municipio,
        'uf': uf,
        'cep': cep,
        'cpf_responsavel': cpfResponsavel,
        'nome_responsavel': nomeResponsavel,
        'email_responsavel': emailResponsavel,
        'cargo_responsavel': cargoResponsavel,
        'combustiveis': combustiveis,
        'status': status,
        'data_inauguracao': dataInauguracao,
        'numero_bicos': numeroBicos,
        'numero_pistas': numeroPistas,
        'observacoes': observacoes,
      };
}
