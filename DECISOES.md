# Decisões técnicas

## Armazenamento local

**Escolha: Hive**

Hive armazena documentos como pares chave-valor. No app, cada vistoria é salva com seu UUID como chave e o objeto completo serializado em JSON como valor.

```dart
await box.put(vistoria.id, jsonEncode(vistoria.toJson()));
```

**Por que não SQLite (sqflite/Drift)?**

SQLite seria a alternativa, mas ele é mais robusto para dados relacionais e permite queries complexas como `SELECT * FROM itens WHERE ....'`. O app não precisa disso, as vistorias são sempre lidas e escritas como objetos completos, nunca por campos individuais. Usar SQL aqui seria adicionar schema, migrations e queries para um padrão de acesso que é simplesmente "salva tudo, lê tudo, filtra em Dart".

**Decisão adicional:** não usamos os type adapters gerados pelo Hive (via `build_runner`). O modelo é Dart puro com `toJson`/`fromJson`. Isso mantém o código independente do Hive, se precisar trocar a solução de storage no futuro, só a camada de persistência muda.

---

## Fila de sincronização

Não existe uma fila separada. **A própria vistoria é a fila**, através do campo `syncStatus`.

1. Promotor finaliza a vistoria sem internet e salva no Hive com `syncStatus: pending`.
2. O `SyncService` roda no startup e quando a conexão volta, filtra as vistorias pendentes.

```dart
final pending = all.where((v) =>
  v.syncStatus == SyncStatus.pending ||
  v.syncStatus == SyncStatus.syncing // recuperação de crash
);
```

3. Para cada uma, tenta sincronizar na ordem:

```
pending - syncing - synced
                  - failed (em caso de erro)
```

4. Se o app fechar enquanto uma vistoria está em `syncing`, no próximo startup o `SyncService` reseta esse estado para `pending` antes de tentar qualquer coisa.

```dart
// onInit do SyncService
final travadas = all.where((v) => v.syncStatus == SyncStatus.syncing);
for (final v in travadas) {
  await _storage.updateStatus(v.id, SyncStatus.pending);
}
```

Isso garante que nenhuma vistoria fica presa para sempre por causa de um crash.

A idempotência é garantida pelo `client_id`, o UUID gerado no device e enviado para a API. Se a rede cair depois do POST chegar ao servidor mas antes da resposta voltar, o app tentará reenviar a mesma vistoria com o mesmo `client_id`, e o servidor ignorará a duplicata.

Adiciona fila por FIFO(First In, First Out)

```dart
// adiciona fila por FIFO(First In, First Out)
    ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
```

Se dependesse do Hive para ordenar, estaria assumindo um comportamento que ele não garante. Assim a lógica de ordenação fica explícita no código e funciona independente de qual storage você usar no futuro.

**Sincronização de fotos em duas fases**

A sync de uma vistoria com fotos acontece em duas etapas separadas, nessa ordem:

```
1. POST /fotos  - recebe URL
2. POST /vistorias - envia URL no payload
```

A ordem importa. Se fosse o contrário, enviar a vistoria primeiro e as fotos depois, o servidor receberia `foto_url: null` e não teria como associar a foto depois.

O ponto é que a URL retornada pelo `POST /fotos` é salva no Hive antes de tentar o `POST /vistorias`:

```dart
await _storage.updateResultados(vistoria.id, resultadosComUrls); // salva URL
await _api.postVistoria(vistoriaComUrls);                        // só então envia
```

Se a rede cair entre os dois passos, na próxima tentativa a condição `item.fotoUrl == null`. 

(Não sei como ta estruturado o backend da API);

Se o servidor ser idempotente para POST /fotos com o mesmo `client_id + item`.

Tentativa 1: POST /fotos - servidor salva -  rede cai - sem resposta
Tentativa 2: POST /fotos (mesmo client_id + item) - servidor retorna URL

App salva URL no Hive - POST /vistorias e com foto_url preenchida.

Se o servidor noa tratar as chamadas iguais cada tentativa criaria uma foto duplicada no storage do servidor, e ficaria com múltiplos arquivos para a mesma vistoria.

---

## O que faria diferente com mais tempo

**Testes automatizados nas camadas críticas**

O `SyncService` e o `VistoriaStorage` são o coração do offline-first e hoje não têm cobertura de testes. Com mais tempo, escreveria testes unitários para os cenários de crash (`syncing` e `pending` no restart), falha de rede e idempotência do `client_id`.

OBS: Testei apenas no codigo a falha de rede desativando a rede e colocando `SLOW_SYNC=true` qunado fosse subir o app.

**Retry com backoff exponencial**

Hoje uma vistoria que falha vai direto para `failed` e espera ação do usuário. O correto seria tentar algumas vezes com intervalo crescente (1s, 2s, 4s...) antes de desistir.


**Melhoraria o front da aplicacao**

