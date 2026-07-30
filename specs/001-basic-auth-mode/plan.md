# Plano de Implementação: Modos Duplos de Autenticação (Firebase + Básico)

**Branch**: `001-basic-auth-mode` | **Data**: 2026-07-30 | **Spec**: [spec.md](spec.md)

**Entrada**: Especificação de feature em `/specs/001-basic-auth-mode/spec.md`

## Resumo Executivo

Implementar suporte a dois modos de autenticação no app Bank123:

**LOGIN_FIREBASE** (padrão): Firebase SDK para autenticação de produção, verificação de usuário, geração e validação de tokens com assinatura criptográfica.

**LOGIN_BASICO**: Endpoints HTTP simples para testes offline e E2E automatizados, eliminando dependências do Firebase durante desenvolvimento.

**Abordagem**: Condicional em build-time (`--dart-define AUTH_MODE=firebase|basic`) que alterna entre `FirebaseAuthService` e nova `BasicAuthService`, ambas implementando `IAuthService`. Sem mudanças de UI, sem quebras em produção, reutilizando interceptadores de headers existentes.

---

## Contexto Técnico

**Linguagem/Versão**: Dart 3.12.2 (Flutter 3.44.8)

**Dependências Primárias**: Firebase Auth (produção), Dio (cliente HTTP), GetX (estado/DI)

**Armazenamento**: Flutter Secure Storage (Keychain/Keystore), sem banco de dados

**Testes**: flutter_test (17 testes unitários existentes de autenticação)

**Plataforma Alvo**: Android (emulador Pixel_3a_API_33) + iOS Simulator + Web

**Tipo de Projeto**: Aplicativo mobile Flutter

**Metas de Performance**: Fluxos E2E completam em <2 segundos com autenticação básica

**Restrições**: 
- Build-time constant (não runtime-changeable)
- Default = Firebase (segurança)
- SSL pinning ativo em produção (não afeta modo básico em HTTP)
- Compatibilidade total com BFF existente (mesmos headers/formato de token)

**Escopo**: 1 app mobile, 1 interface de autenticação, 2 implementações, 0 mudanças de UI

---

## Verificação de Constituição

*GATE: Deve passar antes de Phase 0 pesquisa. Re-verificar após Phase 1 design.*

**Constituição do Projeto**: Template em branco (não preenchida) — nenhuma gate de projeto para verificar.

**Decisões de Arquitetura**:
- Implementação dupla (Firebase + Basic) via strategy pattern (duas classes implementam `IAuthService`)
- Build-time multiplexing (condicional via Dart-define) — decisão de segurança ✅
- Zero mudanças de UI (reutilizar `LoginScreen` para ambos modos) ✅
- Zero mudanças de produção (default Firebase) ✅

**Status**: ✅ APPROVED — nenhuma violação, abordagem simples e segura.

---

## Estrutura do Projeto

### Documentação (esta feature)

```
specs/001-basic-auth-mode/
├── plan.md              # Este arquivo
├── research.md          # Phase 0: Decisões & Rationale
├── data-model.md        # Phase 1: Entidades & Fluxos
├── quickstart.md        # Phase 1: Validação End-to-End
├── contracts/           # Phase 1: Contrato HTTP Basic Auth
│   └── basic-auth-endpoints.md
└── tasks.md             # Phase 2: Tarefas decompostas (criado por /speckit-tasks)
```

### Código-fonte (raiz do repositório)

```
lib/
├── services/
│   ├── auth_service.dart              # Interface IAuthService (existente)
│   ├── firebase_auth_service.dart     # Implementação Firebase (existente)
│   ├── basic_auth_service.dart        # NOVO: Implementação básica
│   ├── auth_mode_factory.dart         # NOVO: Factory que alterna por dart-define
│   └── [demais services...]
├── controllers/
│   └── login_controller.dart          # Reutiliza IAuthService (sem mudanças)
├── bindings/
│   └── initial_binding.dart           # Injeção de deps: já usa Get.put<IAuthService>()
├── telas/
│   └── login.dart                     # UI reutilizada (sem mudanças)
└── [demais...]

test/
├── services/
│   ├── auth_service_test.dart         # Testes existentes (17 testes P1)
│   └── basic_auth_service_test.dart   # NOVO: Testes para BasicAuthService
└── [demais...]

bff-mockoon/
├── bff-bank123.json                   # Ambiente Mockoon existente (porta 8089)
└── [endpoints de mock auth ADICIONADOS aqui]
```

**Decisão de Estrutura**: Padrão Strategy com Factory — ambas implementações moram em `lib/services/`, factory em `initial_binding.dart` escolhe qual usar baseado em `const String.fromEnvironment()`.

---

## Rastreamento de Complexidade

| Aspecto | Complexidade | Justificativa |
|---------|--------------|---------------|
| Duas implementações de AuthService | Baixa | Strategy pattern simples, ambas implementam interface existente |
| Build-time multiplexing | Muito Baixa | Condicional Dart-define padrão, resolvido em compile-time |
| Endpoints HTTP no Mockoon | Baixa | Mockoon já em lugar, adicionar 2-3 endpoints simples de auth |
| Testes (Firebase vs Basic) | Média | 17 testes existentes + novos para BasicAuthService, ambos suites passam |
| Compatibilidade BFF | Muito Baixa | Tokens como `Authorization: Bearer <opaque-string>`, headers idênticos |

---

## Fases de Execução

### Phase 0: Pesquisa & Decisões

**Unknowns a resolver**:
1. Token format exato para basic auth? (opaco vs JWT estruturado)
2. Localização dos endpoints de basic auth? (Mockoon ou servidor separado)
3. Token refresh behavior? (auto-refresh vs user re-login)

**Saída esperada**: `research.md` com decisões documentadas.

---

### Phase 1: Design & Contratos

**Outputs**:
1. `data-model.md` — entidades `AuthMode`, `BasicAuthToken`, `FirebaseAuthResult`
2. `contracts/basic-auth-endpoints.md` — contrato HTTP para endpoints de auth
3. `quickstart.md` — guia de validação end-to-end

**Artefatos criados nesta fase**:
- Definição de entidades com atributos, validações, ciclos de vida
- Contrato HTTP: POST /auth/login, POST /auth/logout, GET /auth/validate
- Cenários de teste: offline dev, E2E paralelo, fallback Firebase

---

### Phase 2: Tasks (próximo: `/speckit-tasks`)

Será decomposto em tarefas menores, priorizadas por dependência:
- T1: Criar `BasicAuthService` (implementação)
- T2: Criar `BasicAuthToken` (modelo)
- T3: Criar endpoints no Mockoon
- T4: Integrar factory em `initial_binding`
- T5: Testes unitários (BasicAuthService)
- T6: Testes E2E (Firebase vs Basic mode)
- T7: Validação de bit-for-bit produção

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]

**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]

**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]

**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]

**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]

**Project Type**: [e.g., library/cli/web-service/mobile-app/compiler/desktop-app or NEEDS CLARIFICATION]

**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]

**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]

**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

[Gates determined based on constitution file]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

mantenha simples as implementacoes o objetivo é ser didatico e simples. 