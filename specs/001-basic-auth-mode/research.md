# Pesquisa & Decisões: Modos Duplos de Autenticação

**Data**: 2026-07-30 | **Fase**: Phase 0 (Pesquisa) | **Status**: Completo

---

## Pergunta 1: Formato de Token para Autenticação Básica

**Questão**: Como os tokens serão estruturados no modo de autenticação básica? Opaco vs JWT?

**Contexto**: O app espera tokens como strings opacas nos headers `Authorization: Bearer <token>`. Firebase retorna JWT com assinatura criptográfica. O modo básico precisa retornar algo que funcione no mesmo lugar.

**Alternativas Consideradas**:

| Opção | Formato | Validação | Complexidade | Escolhido |
|-------|---------|-----------|--------------|-----------|
| A | String opaca aleatória (UUID/hash) | Apenas servidor-side (DB lookup) | Baixa | ❌ |
| B | JWT simples (header.payload.signature SEM verificação) | Decodificação client-side, validação server | Média | ✅ |
| C | JWT completo (assinado criptograficamente) | Verificação de assinatura RSA | Alta | ❌ |

**Decisão**: **Opção B — JWT estruturado SEM verificação de assinatura**

**Rationale**: 
- Reutiliza lógica de decode existente (`JwtDecoder` package já importado em `perfil_page.dart`)
- Simples de gerar no mock auth (nenhuma chave criptográfica necessária)
- Suficientemente seguro para modo de teste/dev (confiança no servidor mock)
- Compatível com payload que contém claims (ex: `{"sub": "user123", "exp": 1234567890}`)

**Alternativas Rejeitadas**:
- Opção A: sem estrutura = sem expiração, claims ou validação
- Opção C: requer geração de RSA keys, overkill para modo de teste

**Implementação**: 
```dart
// Token básico: payload simples com claims
{
  "sub": "mock-user-123",
  "email": "teste@teste.com.br",
  "exp": 1234567890,
  "iat": 1234567800
}
// Codificado como Base64 com estrutura JWT (mesmo sem assinatura válida)
```

---

## Pergunta 2: Localização dos Endpoints de Autenticação Básica

**Questão**: Onde os endpoints HTTP de login/logout/validate ficarão?

**Contexto**: O Mockoon já está rodando em porta 8089 com os 4 endpoints do BFF (perfil, saldo, extrato, transferência). Os endpoints de autenticação são separados do BFF — precisam de um lugar dedicado.

**Alternativas Consideradas**:

| Opção | Localização | Setup | Manutenção | Escolhido |
|-------|-------------|-------|-----------|-----------|
| A | Novo servidor Node/Python | Criar novo servidor local | Complexo | ❌ |
| B | Adicionar ao Mockoon 8089 | Expandir bff-bank123.json | Trivial | ✅ |
| C | Servidor em memória no app | Mock intra-process | Não realista | ❌ |

**Decisão**: **Opção B — Adicionar 3 rotas ao Mockoon existente**

**Rationale**:
- Mockoon já está em lugar na porta 8089
- Adicionar 3 rotas de auth (`POST /auth/login`, `POST /auth/logout`, `GET /auth/validate`) é trivial
- Centraliza mock de toda API em um lugar
- Fácil de ligar/desligar para testes

**Alternativas Rejeitadas**:
- Opção A: overhead de manter servidor separado
- Opção C: não forneceria ambiente realista (não testaria over-network)

**Implementação**:
```json
// Adicionar ao bff-bank123.json (Mockoon)
{
  "method": "post",
  "endpoint": "/auth/login",
  "responses": [
    {
      "statusCode": 200,
      "body": {
        "token": "<jwt-estruturado>",
        "expiresAt": "2026-07-31T12:00:00Z",
        "userId": "mock-user-123"
      }
    }
  ]
}
```

---

## Pergunta 3: Comportamento de Renovação de Token

**Questão**: O que acontece quando um token expira em modo básico? Auto-refresh automático ou pedir re-login?

**Contexto**: Firebase tokens expiram em 1 hora. O app usa `JwtDecoder.isExpired()` para verificar. No modo básico, com tokens que expiram muito mais rápido (dev/teste), o comportamento precisa ser claro.

**Alternativas Consideradas**:

| Opção | Comportamento | UX | Complexidade | Escolhido |
|-------|---------------|----|--------------| ----------|
| A | Auto-refresh transparente (endpoint GET /auth/refresh) | Simples, sem prompt | Média | ✅ |
| B | Pedir re-login quando expirado | Disruptivo mas seguro | Baixa | ❌ |
| C | Tokens não expiram (modo básico) | Sem overhead, irreal | Muito Baixa | ❌ |

**Decisão**: **Opção A — Endpoint `/auth/refresh` com auto-refresh**

**Rationale**:
- Simula realismo de produção (tokens expiram)
- Testa lógica de refresh sem disrupção de UX
- Mockoon pode emitir novo token via endpoint simples
- Integra-se com `local_auth` (biometria) que valida TTL

**Alternativas Rejeitadas**:
- Opção B: E2E tests falhariam por timeout (2 segundos é muito curto se pedir re-login)
- Opção C: não testa refresh logic de verdade

**Implementação**:
```dart
// Em BasicAuthService
Future<String?> refreshToken() async {
  final response = await _dio.post('/auth/refresh', 
    data: {'currentToken': _currentToken}
  );
  _currentToken = response.data['token'];
  return _currentToken;
}

// LoginController valida e auto-refresh se expirado
if (JwtDecoder.isExpired(token)) {
  token = await _authService.refreshToken();
}
```

---

## Pergunta 4: Tratamento de Erro (Mock Auth Não Disponível)

**Questão**: O que mostra na tela se desenvolvedora configura `LOGIN_BASICO` mas o Mockoon não está rodando?

**Contexto**: Erro atual é genérico "E-mail ou senha inválidos". Precisamos diferenciar erro de autenticação (credenciais ruins) de erro de disponibilidade (servidor não roda).

**Alternativas Consideradas**:

| Opção | Mensagem | Debug | Escolhido |
|-------|----------|-------|-----------|
| A | "Erro ao conectar ao servidor de autenticação" | Claro pro dev | ✅ |
| B | Genérico "Falha na autenticação" | Confuso | ❌ |
| C | Stacktrace completo | Verboso | ❌ |

**Decisão**: **Opção A — Mensagem específica de conectividade**

**Rationale**:
- Desenvolvedor sabe imediatamente que é Mockoon, não credenciais
- Reduz ciclo de debug
- Similar ao comportamento de offline (Firebase também retorna erro de conectividade)

**Implementação**:
```dart
// BasicAuthService.signInWithEmailAndPassword()
try {
  final response = await _dio.post('/auth/login', data: credentials);
  // ...
} catch (e) {
  if (e is DioException && e.type == DioExceptionType.connectionTimeout) {
    throw AuthException("Servidor de autenticação indisponível. Verifique se o Mockoon está rodando em :8089");
  }
  rethrow;
}
```

---

## Pergunta 5: Prevenção de Deploy Acidental com `LOGIN_BASICO`

**Questão**: Como evitar que alguém acidentalmente faça build de produção com modo básico?

**Contexto**: Dart-define é build-time, não runtime — impossível pegar errado em produção se default for Firebase. Mas CI/CD deveria validar.

**Alternativas Consideradas**:

| Opção | Mecanismo | Quando | Escolhido |
|-------|-----------|--------|-----------|
| A | Nenhum (default Firebase é seguro o suficiente) | N/A | ✅ |
| B | CI check que falha se não `--dart-define AUTH_MODE=firebase` | Build | ❌ (overkill) |
| C | Runtime assertion (never happens) | App start | ❌ (overkill) |

**Decisão**: **Opção A — Sem validação adicional (segurança por padrão)**

**Rationale**:
- Dart define `LOGIN_FIREBASE` é padrão (se omitido, usa Firebase)
- Build de produção nunca passa `--dart-define AUTH_MODE=basic`
- Zero risco: alguém precisaria ATIVAMENTE passar `--dart-define AUTH_MODE=basic` para release build
- Adicionar check CI é overkill para risco praticamente zero

**Alternativas Rejeitadas**:
- Opção B: CI check é overkill, add overhead sem muito ganho
- Opção C: runtime assertion nunca acionaria

---

## Resumo de Decisões

| Aspecto | Decisão | Rationale | Risco |
|--------|---------|-----------|-------|
| Token Format | JWT sem assinatura | Simples + estruturado | Baixo (dev-only) |
| Auth Endpoints | Mockoon port 8089 | Centralizado + existente | Muito Baixo |
| Refresh Token | Auto via `/auth/refresh` | Realista + simples | Baixo |
| Error Messaging | Específico de conectividade | Debug claro | Nenhum |
| Deployment Safety | Default Firebase | Seguro por padrão | Muito Baixo |

**Próximo Passo**: Phase 1 Design — gerar `data-model.md`, `contracts/`, `quickstart.md`.
