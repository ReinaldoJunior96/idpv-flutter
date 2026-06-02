# Vistoria Postos

App mobile para vistoria de postos de combustível. Funciona offline — vistorias são salvas localmente e sincronizadas automaticamente quando a conexão volta.

## Pré-requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) 3.44+
- Dart 3.12+

## Configuração

Crie um arquivo `.env.json` na raiz do projeto com as credenciais da API:

```json
{
  "API_URL": "https://<sua-url>.supabase.co/functions/v1",
  "API_KEY": "<sua-chave>"
}
```

## Como rodar

```bash
# Instalar dependências
flutter pub get
```

**Chrome (recomendado para desenvolvimento)**

```bash
flutter run -d chrome --dart-define-from-file=.env.json
```

**iOS**

Requer Xcode 26+ com runtime iOS 26.5 instalado. Se ainda não tiver o runtime:

```bash
xcodebuild -downloadPlatform iOS
```

Com o ambiente pronto, abra o projeto no Xcode e rode por lá:

```bash
open ios/Runner.xcworkspace
```

No Xcode: selecione o simulador no seletor de dispositivo e pressione **⌘ + R**. Para as variáveis de ambiente, adicione `API_URL` e `API_KEY` em `Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables`.

**Android**

Requer Android Studio com emulador configurado (API 21+). Abra o projeto pelo Android Studio, selecione o emulador e clique em **Run**. As variáveis podem ser configuradas em `Run > Edit Configurations > Environment variables`.

```bash
# Listar dispositivos disponíveis
flutter devices
```

## Testando a sincronização offline

Para simular o app fechando no meio de uma sincronização:

```bash
flutter run -d chrome --dart-define-from-file=.env.json --dart-define=SLOW_SYNC=true
```

Com essa flag, cada sincronização aguarda 8 segundos antes de concluir que o tempo suficiente para fechar o app e verificar a recuperação automática ao reabrir.

## Estrutura do projeto

```
lib/
├── core/
│   ├── network/        # ApiClient (base URL + autenticação)
│   ├── platform/       # Abstração de filesystem (native/web)
│   └── widgets/        # ConnectivityBanner
└── features/
    ├── postos/         # Lista e detalhe de postos
    ├── vistoria/       # Checklist + armazenamento offline
    │   ├── data/       # Modelos e storage (Hive)
    │   └── sync/       # SyncService + VistoriaApi
    └── sync/           # Tela de status de sincronização
```

## Variáveis de ambiente

| Flag | Descrição |
|------|-----------|
| `SLOW_SYNC=true` | Adiciona delay de 8s na sync (apenas para testes) |
