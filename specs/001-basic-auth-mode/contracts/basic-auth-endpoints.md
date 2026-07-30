# Contrato HTTP: Endpoints de Autenticação Básica

**Data**: 2026-07-30 | **Fase**: Phase 1 Design | **Status**: Completo

---

## Informações Gerais

**Base URL**: `http://localhost:8089` (Mockoon)

**Autenticação**: Não necessária para endpoints de autenticação (públicos)

**Formato**: JSON (request/response)

**Timeout**: 10 segundos (padrão Dio)

---

## Endpoint 1: POST /auth/login

**Finalidade**: Autenticar usuário com email/senha, retornar JWT.

### Request

```http
POST /auth/login HTTP/1.1
Host: localhost:8089
Content-Type: application/json

{
  "email": "teste@teste.com.br",
  "password": "teste123"
}
```

**Campos Obrigatórios**:
- `email` (string): Email do usuário
- `password` (string): Senha do usuário

**Validações** (lado Mockoon):
- Email não vazio
- Senha não vazia
- Credenciais corretas contra lista mock (ex: `teste@teste.com.br` / `teste123`)

### Response Success (200 OK)

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJtb2NrLXVzZXItMTIzIiwiZW1haWwiOiJ0ZXN0ZUB0ZXN0ZS5jb20uYnIiLCJleHAiOjE3MjU5ODI0MDAsImlhdCI6MTcyNTk3ODgwMH0.signature",
  "expiresAt": "2026-07-31T12:00:00Z",
  "userId": "mock-user-123",
  "email": "teste@teste.com.br",
  "claims": {
    "sub": "mock-user-123",
    "email": "teste@teste.com.br",
    "exp": 1725982400,
    "iat": 1725978800
  }
}
```

**Campos na Response**:
- `token` (string): JWT estruturado (header.payload.signature SEM verificação criptográfica)
- `expiresAt` (ISO8601 datetime): Quando o token expira
- `userId` (string): ID único do usuário (também em `claims.sub`)
- `email` (string): Email confirmado
- `claims` (objeto): Claims adicionais (sempre inclui `sub`, `exp`, `iat`)

**Status Codes**:
- `200 OK`: Sucesso
- `401 Unauthorized`: Credenciais inválidas (email incorreto ou senha errada)
- `400 Bad Request`: Campo ausente ou formato inválido
- `500 Internal Server Error`: Erro do servidor

### Response Error (401)

```json
{
  "error": "Credenciais inválidas",
  "message": "Email ou senha incorretos"
}
```

### Exemplo de Uso (Dart)

```dart
final response = await _dio.post(
  '/auth/login',
  data: {
    'email': 'teste@teste.com.br',
    'password': 'teste123',
  },
);

final token = response.data['token'];  // JWT string
final userId = response.data['userId'];
final expiresAt = DateTime.parse(response.data['expiresAt']);
```

---

## Endpoint 2: POST /auth/refresh

**Finalidade**: Renovar token quando expirado.

### Request

```http
POST /auth/refresh HTTP/1.1
Host: localhost:8089
Content-Type: application/json
Authorization: Bearer <token-atual>

{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Campos Obrigatórios**:
- `token` (string): Token JWT atual (mesmo que no header `Authorization`)

**Validações** (lado Mockoon):
- Token presente
- Token decodificável (mesmo sem assinatura válida)
- Token não completamente expirado (permitir refresh dentro de 5 minutos pós-expiração)

### Response Success (200 OK)

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJtb2NrLXVzZXItMTIzIiwiZXhwIjoxNzI1OTg2MDAwfQ...",
  "expiresAt": "2026-07-31T13:00:00Z",
  "userId": "mock-user-123",
  "email": "teste@teste.com.br"
}
```

**Campos**: Idêntico a `/auth/login` response.

**Status Codes**:
- `200 OK`: Token renovado com sucesso
- `401 Unauthorized`: Token inválido ou expirado demais (>5 min)
- `400 Bad Request`: Token ausente ou formato inválido

### Exemplo de Uso (Dart)

```dart
final oldToken = await _secureStorage.read(key: 'ACCESS_TOKEN');

final response = await _dio.post(
  '/auth/refresh',
  data: {'token': oldToken},
);

final newToken = response.data['token'];
await _secureStorage.write(key: 'ACCESS_TOKEN', value: newToken);
```

---

## Endpoint 3: POST /auth/logout

**Finalidade**: Logout do usuário (invalidar token no servidor).

### Request

```http
POST /auth/logout HTTP/1.1
Host: localhost:8089
Content-Type: application/json
Authorization: Bearer <token>

{}
```

**Campos Obrigatórios**: Nenhum (body pode ser vazio ou `{}`)

**Validações** (lado Mockoon):
- Header `Authorization` presente
- Token decodificável

### Response Success (204 No Content)

```
(sem corpo de response)
```

ou (200 OK com confirmação)

```json
{
  "message": "Logout bem-sucedido"
}
```

**Status Codes**:
- `204 No Content`: Logout bem-sucedido (sem body)
- `200 OK`: Logout bem-sucedido (com body)
- `401 Unauthorized`: Token inválido
- `400 Bad Request`: Token ausente

### Exemplo de Uso (Dart)

```dart
final token = await _secureStorage.read(key: 'ACCESS_TOKEN');

try {
  await _dio.post(
    '/auth/logout',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );
  
  // Limpar local storage
  await _secureStorage.delete(key: 'ACCESS_TOKEN');
  await _secureStorage.delete(key: 'NUMERO_CONTA');
  
} catch (e) {
  // Logout local mesmo se servidor falha
  await _secureStorage.delete(key: 'ACCESS_TOKEN');
}
```

---

## Endpoint 4: GET /auth/validate

**Finalidade**: Validar se token atual é válido (sem renovar).

### Request

```http
GET /auth/validate HTTP/1.1
Host: localhost:8089
Authorization: Bearer <token>
```

**Parâmetros**: Nenhum (token no header)

**Validações** (lado Mockoon):
- Token presente e decodificável
- Token não expirado

### Response Success (200 OK)

```json
{
  "valid": true,
  "userId": "mock-user-123",
  "email": "teste@teste.com.br",
  "expiresAt": "2026-07-31T12:00:00Z"
}
```

**Status Codes**:
- `200 OK`: Token válido
- `401 Unauthorized`: Token inválido, expirado ou ausente

### Exemplo de Uso (Dart)

```dart
final token = await _secureStorage.read(key: 'ACCESS_TOKEN');

final response = await _dio.get(
  '/auth/validate',
  options: Options(
    headers: {'Authorization': 'Bearer $token'},
  ),
);

if (response.statusCode == 200 && response.data['valid']) {
  // Token ainda é válido
} else {
  // Precisa re-login ou refresh
}
```

---

## Padrões de Erro Globais

Todos os endpoints podem retornar:

### 5XX Errors

```json
{
  "error": "Internal Server Error",
  "message": "Algo deu errado no servidor"
}
```

### Network Errors (Timeouts)

Retorno será `DioException` no Flutter (não JSON):
- `DioExceptionType.connectionTimeout`
- `DioExceptionType.receiveTimeout`

**Tratamento no app**: Mostrar "Servidor indisponível. Verifique sua conexão."

---

## Configuração no Mockoon

Adicionar 4 rotas ao arquivo `bff-mockoon/bff-bank123.json`:

```json
{
  "routes": [
    // ... rotas BFF existentes (perfil, saldo, etc) ...
    
    {
      "method": "post",
      "endpoint": "/auth/login",
      "responses": [
        {
          "statusCode": 200,
          "body": {
            "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
            "expiresAt": "2026-07-31T12:00:00Z",
            "userId": "mock-user-123",
            "email": "teste@teste.com.br",
            "claims": {"sub": "mock-user-123", "exp": 1725982400, "iat": 1725978800}
          },
          "label": "Sucesso"
        },
        {
          "statusCode": 401,
          "body": {"error": "Credenciais inválidas"},
          "label": "Falha"
        }
      ]
    },
    // ... POST /auth/refresh, POST /auth/logout, GET /auth/validate ...
  ]
}
```

---

## Próximo Passo

Validar endpoints via `quickstart.md` com exemplos end-to-end.
