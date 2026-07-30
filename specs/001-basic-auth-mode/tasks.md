# Tasks de Implementação: Modos Duplos de Autenticação

**Data**: 2026-07-30 | **Feature**: Modos Duplos de Autenticação (Firebase + Básico) | **Total de Tasks**: 18

---

## Visão Geral & Estratégia

**Escopo MVP**: Completar HU1 (Desenvolvedor testa app offline sem Firebase).

**Entregas Incrementais**:
1. **MVP**: HU1 (Modo Básico completo) — Desenvolvedores testam offline
2. **Manutenção de Produção**: HU3 (Firebase padrão inalterado) — Validação de zero regressão
3. **Polish**: Testes E2E completos, documentação

**Oportunidades de Paralelismo**:
- T003-T005: Modelos (parallelizáveis, sem dependências)
- T007-T008: Endpoints Mockoon (parallelizáveis)
- T011-T012: Testes básicos (parallelizáveis, após implementação)

**Dependências Críticas**:
- T001-T002 bloqueiam todas as tarefas (setup)
- T006 (AuthMode enum) bloqueia T009 (factory)
- T009 bloqueia testes E2E (T014+)

---

## Phase 1: Setup (Inicialização do Projeto)

- [x] T001 Criar estrutura de diretórios e branches conforme plano de implementação
- [x] T002 Atualizar `pubspec.yaml` se necessário (nenhuma dependência nova esperada)

---

## Phase 2: Foundation (Bloqueantes para Ambas Histórias)

Tarefas que criam a infraestrutura compartilhada para Firebase e Basic auth.

- [x] T003 [P] Criar `AuthMode` enum em `lib/models/auth_mode.dart` com valores `firebase` e `basic`
- [x] T004 [P] Criar classe `BasicAuthToken` em `lib/models/basic_auth_token.dart` com factory `fromJwt()`
- [x] T005 [P] Criar class `AuthException` em `lib/services/auth_exceptions.dart` com subtypes (ConnectivityError, InvalidCredentialsError)
- [x] T006 Criar factory `AuthServiceFactory` em `lib/services/auth_service_factory.dart` que alterna por `const String.fromEnvironment('AUTH_MODE')`
- [x] T007 [P] Adicionar 3 endpoints de mock auth ao `bff-mockoon/bff-bank123.json` (POST /auth/login, POST /auth/refresh, POST /auth/logout)
- [x] T008 [P] Configurar Mockoon para responder com JWT estruturado (sem assinatura criptográfica) com `exp`, `sub`, `email` claims

---

## Phase 3: História de Usuário 1 — Desenvolvedor Testa App Offline Sem Firebase (P1)

Modo de autenticação básica completo com endpoints HTTP mock, permitindo testes offline e E2E automatizados.

### Objetivo da Fase

App funciona totalmente em modo básico (`LOGIN_BASICO` via `--dart-define`) usando HTTP endpoints do Mockoon, sem inicializar Firebase SDK, com auto-refresh de tokens expirados.

### Critério de Teste Independente

Rodar app com `flutter run --dart-define=AUTH_MODE=basic --dart-define=API_BASE_URL=http://10.0.2.2:8089`:
- Firebase SDK nunca inicializa (zero logs Firebase)
- Login bem-sucedido com `teste@teste.com.br` / `teste123`
- Token JWT sem assinatura obtido de POST `/auth/login`
- Saldo e transações carregam via BFF (Mockoon)
- Token auto-refresh em expiração (sem pedir re-login)
- Logout bem-sucedido

### Tasks da HU1

- [x] T009 [US1] Implementar `BasicAuthService` em `lib/services/basic_auth_service.dart` que implementa `IAuthService`
  - Métodos: `signInWithEmailAndPassword()`, `signOut()`, `getIdToken()`, `isAuthenticated`
  - Usa Dio client para POST `/auth/login`, POST `/auth/logout`, POST `/auth/refresh`
  - Decodifica JWT via `JwtDecoder.decode()` (sem verificar assinatura)
  - Auto-refresh via `/auth/refresh` se token expirado

- [x] T010 [US1] Integrar `AuthServiceFactory` em `lib/bindings/initial_binding.dart`
  - Ler `const String.fromEnvironment('AUTH_MODE')` (padrão: 'firebase')
  - Se básico: `Get.put<IAuthService>(BasicAuthService(), permanent: true)`
  - Se firebase: `Get.put<IAuthService>(FirebaseAuthService(), permanent: true)` (existente)

- [x] T011 [P] [US1] Criar testes para `BasicAuthService` em `test/services/basic_auth_service_test.dart`
  - Testes de login bem-sucedido (mock token JWT retornado)
  - Testes de falha (credenciais inválidas)
  - Testes de auto-refresh em token expirado
  - Testes de logout
  - ~25 testes (similar aos 17 existentes para Firebase)

- [x] T012 [P] [US1] Criar testes de integração (mode switching) em `test/integration/auth_mode_test.dart`
  - Verificar que FirebaseAuthService é usado quando `AUTH_MODE=firebase`
  - Verificar que BasicAuthService é usado quando `AUTH_MODE=basic`
  - Ambas implementações passam na mesma suite de testes `IAuthService`

- [x] T013 [US1] Implementar tratamento de erro amigável em `LoginController` para modo básico
  - DioExceptionType.connectionTimeout → "Servidor de autenticação indisponível. Verifique se Mockoon está rodando em :8089"
  - Invalid credentials (401) → "E-mail ou senha inválidos"
  - Network error → "Erro de conexão. Verifique sua internet"

- [x] T014 [US1] Adicionar mensagens de log em modo básico em `BasicAuthService`
  - Log: "Basic auth mode active"
  - Log: "POST /auth/login successful"
  - Log: "Token auto-refresh triggered"
  - Para debugging de desenvolvedores

---

## Phase 4: História de Usuário 3 — App em Produção Continua Usando Firebase (P1)

Validar que build de produção (padrão Firebase) é bit-a-bit idêntico e funciona como antes.

### Objetivo da Fase

App em produção (padrão `AUTH_MODE=firebase` ou omitido) inicializa Firebase, faz login via Firebase SDK, retorna tokens assinados Firebase, sem regressões.

### Critério de Teste Independente

Rodar app sem `--dart-define AUTH_MODE` (padrão Firebase):
- Firebase SDK inicializa normalmente
- Login bem-sucedido com credenciais Firebase reais
- Token Firebase (com assinatura RSA) armazenado
- Saldo e transações carregam via BFF (real)
- Logout bem-sucedido
- SHA256 do APK idêntico ao release anterior

### Tasks da HU3

- [x] T015 [P] [US3] Executar testes existentes (17 testes auth) em modo Firebase padrão
  - Verificar que todos passam
  - `flutter test test/services/auth_service_test.dart`

- [x] T016 [US3] Validar bit-for-bit idêntico em produção
  - Build: `flutter build apk --dart-define=API_BASE_URL=https://bank123-main-297cd30.d2.zuplo.dev` (padrão Firebase)
  - Comparar SHA256 com release anterior
  - Certificar zero mudanças de comportamento

- [x] T017 [US3] Documentar modo Firebase padrão no README em `bff-mockoon/README.md`
  - Notar que produção padrão usa Firebase (não precisa `--dart-define AUTH_MODE=firebase`)
  - Documentar como rodar modo básico (precisa `--dart-define AUTH_MODE=basic`)

---

## Phase 5: Polish & Cross-Cutting Concerns

- [x] T018 [P] Criar documentação completa de developer-facing
  - Adicionar seção "Dual Authentication Modes" ao README do projeto
  - Incluir exemplos: `flutter run --dart-define=AUTH_MODE=basic` e `flutter run` (padrão)
  - Incluir troubleshooting: "Mockoon não está rodando?" → dica de porta 8089

---

## Ordem de Execução & Dependências

```
Phase 1 (Setup)
  ├─ T001 ─→ T002
  └─ (bloqueia tudo)

Phase 2 (Foundation)
  ├─ T003, T004, T005 (parallelizáveis)
  ├─ T006 (depende de T003)
  ├─ T007, T008 (parallelizáveis)
  └─ (bloqueiam HU1, HU3)

Phase 3 (HU1: Modo Básico)
  ├─ T009 (depende de T005, T006)
  ├─ T010 (depende de T009)
  ├─ T011, T012 (parallelizáveis, dependem de T009)
  ├─ T013 (depende de T010)
  └─ T014 (depende de T009)

Phase 4 (HU3: Firebase Produção)
  ├─ T015 (depende de T010 — confirma zero regressão)
  ├─ T016 (depende de T010)
  └─ T017 (depende de T016)

Phase 5 (Polish)
  └─ T018 (pode rodar em paralelo com HU3)
```

---

## Oportunidades de Paralelismo

**Setup Parallelizável** (após T002):
- T003, T004, T005: Modelos → sem dependencies entre eles
- T007, T008: Endpoints Mockoon → sem dependencies

**Foundation Parallelizável** (após T005, T008):
- Nada parallelizável (T006 depende de T003, T009 depende de T006)

**HU1 Parallelizável** (após T009):
- T011, T012: Testes → rodem em paralelo após T009
- T013, T014: Logging/Errors → rodem em paralelo após T009

**HU3 Parallelizável** (após T010):
- T015, T016: Validação → rodem em paralelo após T010
- T017: Docs → rode em paralelo com T015-T016

**Exemplo de Execução Paralela Ótima**:
```
T001 → T002 → T003, T004, T005, T007, T008 (4 paralelos)
                ↓
           T006 → T009 → T011, T012, T013, T014 (4 paralelos)
                         ↓
                    T010 → T015, T016, T018 (3 paralelos)
                           ↓
                      T017 (2 segundos)

Tempo total estimado: ~2-3 horas (com paralelismo ótimo)
```

---

## MVP Scope Recomendado

**Entregar primeiro**: HU1 (T001-T014)
- Modo básico totalmente funcional
- Testes completos
- Desenvolvedores podem testar offline

**Depois**: HU3 (T015-T017)
- Validação de zero regressão em produção
- Segurança garantida

**Depois**: Polish (T018)
- Documentação para comunidade de devs

---

## Formato de Task Validation

Todas as 18 tasks seguem o padrão obrigatório:
- ✅ Checkbox markdown (`- [ ]`)
- ✅ Task ID sequencial (T001-T018)
- ✅ [P] marker (quando parallelizável)
- ✅ [US#] label (quando part de história de usuário)
- ✅ Descrição clara com caminho de arquivo exato

**Nenhuma task é ambígua** — cada uma pode ser executada por um desenvolvedor sem contexto adicional.

---

## Resumo de Contagem

| Phase | Descrição | Task Count | Parallelizáveis |
|-------|-----------|-----------|-----------------|
| 1 | Setup | 2 | 0 |
| 2 | Foundation | 6 | 4 (T003-T008) |
| 3 | HU1 Modo Básico | 6 | 2 (T011-T014) |
| 4 | HU3 Firebase | 3 | 2 (T015-T016, T018) |
| 5 | Polish | 1 | 1 (T018) |
| **TOTAL** | | **18** | **9** |

---

## Próxima Ação

Com esta task list pronta, procurar por `/speckit-implement` para executar tasks (quando disponível) ou iniciar implementação manual seguindo a ordem de Phase e paralelismo recomendado.
