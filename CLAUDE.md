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

## Padrão: Telas com Estado, Sincronização e Tratamento de Erros

Ao criar uma tela que carrega dados remotos (listas, detalhes, etc.), siga este padrão para garantir consistência e UX robusta. Use como referência as telas implementadas: **Notificações**, **Chaves PIX**, **Aba Serviço** (Home).

### 1️⃣ Controller (GetxController)

Adicione estes estados:
```dart
class MeuController extends GetxController {
  final _bffService = Get.find<IBffService>();
  
  final dados = <MeuModel>[].obs;
  final isLoading = false.obs;
  final temErro = false.obs;
  final erroTitulo = ''.obs;
  final erroDescricao = ''.obs;
  final erroStatusCode = 0.obs;

  @override
  void onInit() {
    super.onInit();
    carregarDados();
  }

  Future<void> carregarDados() async {
    isLoading.value = true;
    temErro.value = false;
    try {
      final response = await _bffService.getMeusDados();
      dados.assignAll(/* parse response */);
    } on DioException catch (e) {
      _tratarErro(e);
    } catch (e) {
      temErro.value = true;
      erroTitulo.value = 'Erro ao carregar';
      erroDescricao.value = 'Ocorreu um erro inesperado.';
      erroStatusCode.value = 500;
    } finally {
      isLoading.value = false;
    }
  }

  void _tratarErro(DioException e) {
    temErro.value = true;
    final statusCode = e.response?.statusCode ?? 500;
    erroStatusCode.value = statusCode;

    if (statusCode == 422) {
      final data = e.response?.data as Map<String, dynamic>?;
      erroTitulo.value = data?['titulo'] ?? 'Serviço não disponível';
      erroDescricao.value = data?['descricao'] ?? 'Procure o SAC';
    } else {
      erroTitulo.value = 'Erro ao carregar';
      erroDescricao.value = 'Ocorreu um erro no servidor. Tente novamente.';
    }
  }
}
```

### 2️⃣ Page (Widget com RefreshIndicator)

Estrutura padrão com 4 estados:
```dart
class MeuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MeuController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Título')),
      body: Obx(() {
        // Estado 1: Loading inicial
        if (controller.isLoading.value && controller.dados.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        // Estado 2: Erro
        if (controller.temErro.value) {
          final is422 = controller.erroStatusCode.value == 422;
          final iconData = is422 ? Icons.warning_outlined : Icons.error_outline;
          final iconColor = is422 ? Colors.amber : colorScheme.error;

          return RefreshIndicator(
            onRefresh: () => controller.carregarDados(),
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(iconData, size: 80, color: iconColor),
                          const SizedBox(height: 24),
                          Text(
                            controller.erroTitulo.value,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (controller.erroDescricao.value.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              controller.erroDescricao.value,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Estado 3: Vazio
        if (controller.dados.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.carregarDados(),
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 80, color: colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text('Nenhum item',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Estado 4: Sucesso
        return RefreshIndicator(
          onRefresh: () => controller.carregarDados(),
          child: ListView.builder(
            itemCount: controller.dados.length,
            itemBuilder: (context, index) {
              final item = controller.dados[index];
              return _buildCard(context, item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCard(BuildContext context, MeuModel item) {
    // Implemente o card aqui
  }
}
```

### 3️⃣ BFF Service Interface & Implementação

**IBffService:**
```dart
abstract class IBffService {
  Future<dynamic> getMeusDados();
}
```

**HttpBffService:**
```dart
@override
Future<dynamic> getMeusDados() async {
  try {
    final response = await _dio.get('/bank123/pf/meus-dados/v1/lista');
    return response.data;
  } catch (e) {
    rethrow;
  }
}
```

**MockBffService:**
```dart
@override
Future<dynamic> getMeusDados() async {
  await Future.delayed(const Duration(milliseconds: 600));
  return {
    "dados": [
      {"id": "1", "titulo": "Item 1"},
      {"id": "2", "titulo": "Item 2"},
    ]
  };
}
```

### 4️⃣ Mockoon Endpoints

Para cada tela, adicione 3 respostas no mesmo endpoint:

**GET /bank123/pf/meus-dados/v1/lista**
- ✅ **200**: sucesso com dados
- ⚠️ **422**: serviço não disponível (título + descricao customizável)
- ❌ **500**: erro genérico do servidor

**Exemplo 422:**
```json
{
  "titulo": "Serviço indisponível",
  "descricao": "Procure o atendimento para reativar"
}
```

### Checklist ao Criar Nova Tela com Dados Remotos

- [ ] Controller com `isLoading`, `temErro`, `erroTitulo`, `erroDescricao`, `erroStatusCode`
- [ ] Método `carregarDados()` trata `DioException` via `_tratarErro()`
- [ ] Page com `RefreshIndicator` em todos os 4 estados
- [ ] Erro 422: ícone ⚠️ amarelo
- [ ] Erro 500: ícone ❌ vermelho
- [ ] BFF Service: interface → implementação real + mock
- [ ] Mockoon: 3 respostas (200, 422, 500)
