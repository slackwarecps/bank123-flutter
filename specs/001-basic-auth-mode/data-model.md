# Modelo de Dados: Modos Duplos de Autenticação

**Data**: 2026-07-30 | **Fase**: Phase 1 Design | **Status**: Completo

---

## Visão Geral das Entidades

Três entidades principais modelam o sistema de autenticação duplo:

```
AuthMode (enum)
  ├── firebase (padrão)
  └── basic

IAuthService (interface — existente)
  ├── FirebaseAuthService (implementação)
  └── BasicAuthService (implementação NOVA)

AuthResult (DTO — existente)
  └── Reutilizado por ambas implementações
```

---

## Entidade 1: AuthMode

**Tipo**: Enumeração (Dart enum)

**Finalidade**: Controla qual implementação de `IAuthService` está ativa em build-time.

**Valores**:

```dart
enum AuthMode {
  firebase,  // Padrão: Firebase SDK para autenticação
  basic      // Modo de teste: HTTP endpoints de auth básica
}
```

**Determinação**: Via `const String.fromEnvironment('AUTH_MODE')` no `main.dart`:
- Se `AUTH_MODE` não definido (padrão) → `AuthMode.firebase`
- Se `--dart-define AUTH_MODE=basic` → `AuthMode.basic`

**Uso**:
```dart
// Em initial_binding.dart
const authMode = AuthMode.firebase; // ou .basic
if (authMode == AuthMode.firebase) {
  Get.put<IAuthService>(FirebaseAuthService(), permanent: true);
} else {
  Get.put<IAuthService>(BasicAuthService(), permanent: true);
}
```

**Invariantes**:
- Definida apenas 1 vez em compile-time (imutável durante execução)
- Não pode ser alterada em runtime

---

## Entidade 2: AuthResult (Existente, Reutilizado)

**Localização**: `lib/services/auth_service.dart`

**Finalidade**: DTO que encapsula resultado de autenticação (sucesso).

**Estrutura**:

```dart
class AuthResult {
  final String? uid;              // ID único do usuário
  final String? email;            // Email confirmado do usuário
  final String? token;            // Token de acesso (JWT Firebase ou JWT básico)
  final Map<String, dynamic>? claims;  // Claims/dados adicionais (ex: numeroConta)

  AuthResult({
    this.uid,
    this.email,
    this.token,
    this.claims
  });
}
```

**Compatibilidade**:
- **Firebase mode**: Firebase retorna `UserCredential` → convertido em `AuthResult`
  - `uid` = `credential.user.uid`
  - `email` = `credential.user.email`
  - `token` = result do `getIdTokenResult()`
  - `claims` = `tokenResult.claims` (inclui `bank123/jwt/claims`)

- **Basic mode**: Mockoon retorna JSON → parsed em `AuthResult`
  - `uid` = `response.data['userId']`
  - `email` = `response.data['email']` (da request)
  - `token` = `response.data['token']` (JWT estruturado sem assinatura)
  - `claims` = `response.data['claims']` (será `{'sub': uid, ...}`)

**Validações**:
- `token` não pode ser null após login bem-sucedido
- `uid` não pode ser vazio
- `expiresAt` (em claims) deve ser timestamp futuro

**Estado**: Resultado é imutável pós-criação (DTO puro)

---

## Entidade 3: BasicAuthToken (Nova)

**Localização**: `lib/services/basic_auth_service.dart`

**Finalidade**: Encapsula token JWT simples emitido pelo mock auth (não precisa ser entidade completa, pode ser DTO interno).

**Estrutura**:

```dart
class BasicAuthToken {
  final String token;         // JWT como string (header.payload.signature)
  final DateTime expiresAt;   // Timestamp de expiração
  final String userId;        // ID único do usuário (sub claim)
  final String email;         // Email do usuário
  final Map<String, dynamic> claims;  // Claims opcionais

  BasicAuthToken({
    required this.token,
    required this.expiresAt,
    required this.userId,
    required this.email,
    this.claims = const {},
  });

  // Factory para decodificar JWT
  factory BasicAuthToken.fromJwt(String jwtToken) {
    final decoded = JwtDecoder.decode(jwtToken);
    return BasicAuthToken(
      token: jwtToken,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (decoded['exp'] as int) * 1000
      ),
      userId: decoded['sub'] as String,
      email: decoded['email'] as String,
      claims: decoded,
    );
  }

  // Validação
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && token.isNotEmpty;
}
```

**Ciclo de Vida**:
1. **Emissão**: Mock auth endpoint `/auth/login` retorna `{token, expiresAt, userId, email}`
2. **Decodificação**: `BasicAuthToken.fromJwt()` parse JWT
3. **Validação**: `isExpired` verifica se passou expiração
4. **Refresh**: Se expirado, chamar `/auth/refresh` para novo token
5. **Uso**: Token armazenado em secure storage (`ACCESS_TOKEN` key)

**Invariantes**:
- `token` sempre é string não-vazia
- `expiresAt` sempre é no futuro (no momento de criação)
- `email` e `userId` não podem ser vazios

---

## Entidade 4: IAuthService Interface (Existente)

**Localização**: `lib/services/auth_service.dart`

**Finalidade**: Contrato que ambas implementações cumprem.

**Métodos**:

```dart
abstract class IAuthService {
  // Login com email/senha → AuthResult
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);

  // Logout
  Future<void> signOut();

  // Verificar se autenticado
  bool get isAuthenticated;

  // Obter token atual
  Future<String?> getIdToken();
}
```

**Implementações**:
- **FirebaseAuthService**: Existente, usa Firebase SDK
- **BasicAuthService**: Nova, usa HTTP ao Mockoon

**Nenhuma mudança necessária** na interface para suportar ambos modos.

---

## Fluxos de Estado

### Firebase Mode (Existente)

```
[LoginScreen]
  ↓ user enters email/password
[FirebaseAuthService.signInWithEmailAndPassword()]
  ↓ Firebase.auth.signInWithEmailAndPassword()
[FirebaseAuth.instance]
  ↓ validates at Firebase servers
[AuthResult: uid, email, token (Firebase JWT), claims]
  ↓ saved to secure storage
[HomePage]
```

### Basic Mode (Novo)

```
[LoginScreen]
  ↓ user enters email/password (same UI)
[BasicAuthService.signInWithEmailAndPassword()]
  ↓ POST /auth/login to Mockoon
[Mockoon Mock Auth Endpoint]
  ↓ validates locally, emits JWT
{token, expiresAt, userId, email} ← JSON response
  ↓ BasicAuthToken.fromJwt() parse
[BasicAuthToken: token (JWT sem assinatura), expiresAt, userId, email]
  ↓ converted to AuthResult
[AuthResult: uid=userId, email, token, claims={sub, ...}]
  ↓ saved to secure storage
[HomePage]
```

### Token Refresh (Basic Mode)

```
[BffService request headers]
  ↓ interceptor calls getIdToken()
[BasicAuthService.getIdToken()]
  ↓ check if isExpired
  ├─ if not expired: return current token
  └─ if expired: POST /auth/refresh
    ↓ Mockoon emits new token
[new BasicAuthToken + AuthResult]
  ↓ update secure storage
[request continues with fresh token]
```

---

## Tabela de Compatibilidade

| Aspecto | Firebase | Basic | Compatibilidade |
|---------|----------|-------|-----------------|
| Token Format | JWT com assinatura RSA | JWT sem assinatura | ✅ Ambos são strings |
| Header `Authorization` | `Bearer <Firebase-JWT>` | `Bearer <Basic-JWT>` | ✅ Mesmo formato |
| Claims Structure | Firebase claims + `bank123/jwt/claims` | `{sub, email, exp, iat}` | ✅ Ambos têm `sub` |
| Header `x-account-id` | De secure storage | De secure storage | ✅ Idêntico |
| Header `x-correlation-id` | UUID v4 | UUID v4 | ✅ Idêntico |
| Token Validation | Firebase SDK verifica assinatura | Apenas decode, não verifica | ✅ Dev-only, aceitável |
| Token Expiry | 1 hora (Firebase padrão) | Configurável (Mockoon) | ✅ Ambos têm `exp` |
| Refresh Endpoint | `await user.getIdToken()` | `POST /auth/refresh` | ✅ Abstrato em interface |

---

## Relacionamentos

```
┌─────────────────────────────────────────┐
│         LoginController                 │
│  (reutilizado, sem mudanças)            │
└──────────────────┬──────────────────────┘
                   │
                   ↓ injeção via Get.find()
        ┌──────────┴──────────┐
        │   IAuthService      │
        │   (interface)       │
        └──────────┬──────────┘
                   │
         ┌─────────┴─────────┐
         ↓                   ↓
  ┌─────────────────┐  ┌──────────────────┐
  │ Firebase        │  │ BasicAuthService │
  │ AuthService     │  │ (NOVO)           │
  │ (existente)     │  │                  │
  └─────────────────┘  └──────────────────┘
         │                   │
         │                   ├─→ BasicAuthToken (NOVO)
         │                   │
         │                   └─→ /auth/login endpoint (Mockoon)
         │
         └─→ Firebase SDK

  ┌──────────────────┐
  │  AuthResult      │  ← Retornado por ambas implementações
  │  (existente,     │
  │   reutilizado)   │
  └──────────────────┘
```

---

## Resumo

| Entidade | Status | Mudanças |
|----------|--------|----------|
| AuthMode | NOVO | Enum de 2 valores, build-time |
| IAuthService | EXISTENTE | Sem mudanças |
| AuthResult | EXISTENTE | Reutilizado como-está |
| BasicAuthToken | NOVO | DTO interno para Basic mode |
| FirebaseAuthService | EXISTENTE | Sem mudanças |
| BasicAuthService | NOVO | Implementação de IAuthService |

**Próximo Passo**: Gerar `contracts/basic-auth-endpoints.md` e `quickstart.md`.
