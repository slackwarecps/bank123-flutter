# CLAUDE.md

Este arquivo fornece orientação ao Claude Code (claude.ai/code) ao trabalhar com código neste repositório.

## Contexto do projeto

Bank123 é um protótipo de frontend mobile em Flutter construído para um TCC (Trabalho de Conclusão de Curso) sobre segurança em aplicações mobile. É um app de banco digital mock cujo propósito real é demonstrar práticas de codificação segura (autenticação Firebase, armazenamento seguro, SSL pinning, anti-tampering) em vez de funcionalidades reais de banco.

Comunique-se com o usuário em português e o chame de "Fabão" (conforme `GEMINI.md`). Ele desenvolve em um MacBook usando um emulador Android (`Pixel_3a_API_33`).

IMPORTANTE: Nunca commit no git sem ser expressamente orientado.

O backend é um repositório separado: `bff-bank123`, um serviço Spring Boot apoiado por PostgreSQL. Não faz parte deste repositório.

A Pasta do Mockoon fica em /bff-mockoon

## Comandos

```bash
# Instalar dependências
flutter pub get

# Regenerar configuração do Firebase (selecione o projeto draft1-app-fabao)
flutterfire configure

# Análise estática (usa flutter_lints — executar antes de fazer commit)
flutter analyze

# Executar contra o BFF real (API_BASE_URL é obrigatório na CLI)
flutter run --dart-define=API_BASE_URL=https://bank123-main-297cd30.d2.zuplo.dev

# Executar completamente offline contra serviços mock em memória (sem chamadas de backend/Firebase)
flutter run --dart-define=USE_MOCK=true

# Compilar APK
flutter build apk --dart-define=API_BASE_URL=https://bank123-main-297cd30.d2.zuplo.dev

# Regenerar ícones de launcher após alterar assets/icon/
flutter pub run flutter_launcher_icons
```

Não há suite de testes neste repo (`flutter_test` é uma dependência dev, mas nenhum diretório `test/` existe ainda). VS Code tem alvos de launch pré-configurados em `.vscode/launch.json`: `bank123` (backend real), `bank123-local` (serviços mock), além de variantes de profile/release.

A configuração é injetada exclusivamente via `--dart-define` no tempo de build/run (`API_BASE_URL`, `USE_MOCK`) — nunca via `.env`/`assets`, pois assets do Flutter são enviados como texto claro no pacote. Não reintroduza um caminho de configuração baseado em `.env`.

## Arquitetura

**Gerenciamento de estado:** GetX (pacote `get`) em toda parte — campos reativos `.obs` em subclasses `GetxController`, `Obx(() => ...)` em widgets, `Get.put()`/`Get.find()` para DI, `GetPage`/`GetMaterialApp` para roteamento (todas as rotas declaradas em `lib/main.dart`).

**Layout de diretórios** (`lib/`):
- `bindings/` — classes `Bindings` do GetX que conectam injeção de dependência por rota/estágio de ciclo de vida do app.
- `controllers/` — um `GetxController` por tela/fluxo, mantém estado de UI e chama para `services/`.
- `services/` — camada de wrapper de API/Firebase (veja padrão de DI abaixo).
- `telas/` — telas principais (login, home, perfil, extrato, transferência, configuração, jailbreak/páginas de erro). `telas/diversos/` contém telas de POC/scratch.
- `models/` — modelos de dados/DTOs.
- `firebase_options.dart` — gerado por `flutterfire configure`; não edite manualmente.

**Camada de serviço / padrão de DI mock:** Implementações reais vs. mock são selecionadas uma vez na inicialização com base no dart-define `USE_MOCK`, em `lib/bindings/initial_binding.dart`:
- `IAuthService` → `FirebaseAuthService` (real) ou `MockAuthService` (mock)
- `IBffService` → `HttpBffService` (real, em `bff_service.dart`) ou `MockBffService` (mock)

Controllers dependem das interfaces (`IAuthService`, `IBffService`) via `Get.find()`, nunca das implementações concretas diretamente — isso é o que faz `USE_MOCK=true` funcionar. Ao adicionar uma nova chamada de backend, adicione primeiro à interface, depois implemente em ambos os serviços real e mock.

**Comunicação com BFF (`lib/services/bff_service.dart`):** cliente Dio com:
- SSL pinning via `badCertificateCallback`, comparando o fingerprint SHA-256 do certificado do servidor contra um valor esperado hardcoded (intencionalmente hardcoded ao invés de ser dirigido por configuração — veja o comentário nesse arquivo pela razão de segurança: `.env`/assets são enviados como texto claro, hardcoding força patching binário).
- Um interceptor de requisição que anexa `Authorization: Bearer <Firebase ID token>`, `x-account-id` (do armazenamento seguro, chave `NUMERO_CONTA`), e `x-correlation-id` (UUID v4 fresco) para cada chamada.
- Endpoints têm namespace sob `/bff-bank123/{usuario,extrato,movimentacoes}/v1/...`.

**Autodefesa em tempo de execução (`lib/main.dart`):** Antes de `runApp`, o app verifica `SafeDevice.isJailBroken` (do pacote `safe_device`) e procura por Frida (caminhos binários conhecidos, porta 27042, e assinaturas em `/proc/self/maps` como `frida-agent`/`gum-js-loop`). Se qualquer verificação disparar, roteia direto para `JailbreakPage` ao invés do app normal. Se a verificação inicial passar, um `Timer.periodic` re-verifica Frida a cada 5 segundos pela vida do app e chama `exit(0)` imediatamente se aparecer mid-session. Trate essa lógica de detecção como sensível a segurança — mudanças aqui afetam o modelo de ameaça central do app, não apenas um recurso.

**Armazenamento seguro:** `flutter_secure_storage` (com suporte de Keychain/Keystore) mantém valores/preferências sensíveis — ex: `biometric_enabled` (controla se o botão de login biométrico aparece) e `NUMERO_CONTA` (id da conta enviado como `x-account-id`). Não use `shared_preferences` para nada sensível a segurança; está presente em `pubspec.yaml` mas deve se limitar ao estado de UI não-sensível.

**Login biométrico:** `local_auth`. O botão biométrico na tela de login é condicional à flag `biometric_enabled` no armazenamento seguro — é opt-in, não mostrado por padrão.

**Inspeção de JWT:** A tela de Perfil decodifica o token ID do Firebase (`jwt_decoder`) para mostrar claims, escopos, e timestamps para transparência de auditoria/debug, e oferece uma ação de copiar-para-clipboard para o token bruto.

**Relatório de crashes:** `firebase_crashlytics` está conectado em `main.dart` para capturar erros fatais de framework Flutter e erros assincronos não capturados.

## Convenções

- Classes: `PascalCase`; arquivos: `snake_case`; variáveis: `camelCase`.
- Apenas Material 3 — use `Theme.of(context).colorScheme` ao invés de cores hardcoded (tema do app usa uma cor de seed vermelho/marrom).
- Builds de release devem ser compilados com `--obfuscate --split-debug-info` (por README) para remover metadados de debug como parte da postura anti-reverse-engineering — mantenha isso em mente se mexer em scripts de build/CI.
