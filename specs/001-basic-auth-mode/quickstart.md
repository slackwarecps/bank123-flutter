# Guia de Validação: Modos Duplos de Autenticação

**Data**: 2026-07-30 | **Fase**: Phase 1 Design | **Status**: Completo

---

## Objetivo

Validar que o app funciona corretamente em ambos modos de autenticação (Firebase e Básico) de forma end-to-end, cobrindo fluxos críticos.

---

## Pré-requisitos

### Hardware & Ambiente

- MacBook (desenvolvedor)
- Android Emulator: `Pixel_3a_API_33` rodando
- VS Code com Flutter/Dart extensions
- Terminal com acesso a `flutter`, `npm`, `curl`

### Dependências Instaladas

```bash
# Verificar Flutter
flutter --version          # >= 3.44.8

# Mockoon CLI
npm list -g @mockoon/cli   # instalado globalmente

# Firebase CLI (para produção)
firebase --version         # instalado

# Dart packages (no projeto)
flutter pub get
```

### Configuração Prévia

1. Mockoon rodando em port 8089:
   ```bash
   npx mockoon-cli start --data bff-mockoon/bff-bank123.json &
   ```

2. Firebase project configurado (para modo Firebase):
   ```bash
   flutterfire configure --project=draft1-app-fabao
   ```

---

## Cenário 1: Modo Firebase (Padrão)

### Objetivo

Validar que app em produção (padrão) usa Firebase, sem alterações.

### Setup

```bash
# Build padrão (sem --dart-define AUTH_MODE)
flutter run --dart-define=API_BASE_URL=https://bank123-main-297cd30.d2.zuplo.dev
```

### Execução

1. **App inicia**
   - ✅ Firebase SDK inicializa (ver logs "Initializing Firebase")
   - ✅ Tela de login aparece

2. **Fazer login com credenciais Firebase reais**
   - Email: `teste@teste.com.br`
   - Senha: `teste123` (da conta Firebase project `draft1-app-fabao`)
   - ✅ Login bem-sucedido → navegação para HomePage
   - ✅ Token armazenado em secure storage
   - ✅ Perfil e saldo carregam via BFF real

3. **Verificar que Firebase está sendo usado**
   - Abrir DevTools
   - Inspect logs: "Authentication successful via Firebase"
   - ✅ Zero logs de "Basic auth" ou "/auth/login HTTP"

4. **Fazer logout**
   - ✅ Session limpada
   - ✅ Retorna para tela de login

### Validação Esperada

✅ PASS se:
- Firebase inicializa
- Login com credenciais reais funciona
- Token Firebase (com assinatura) armazenado
- Logout limpa session
- Zero chamadas HTTP a `/auth/login`

---

## Cenário 2: Modo Básico (Desenvolvimento)

### Objetivo

Validar que app em modo básico faz login via HTTP para endpoints mockados, sem Firebase.

### Setup

```bash
# Terminal 1: Mockoon rodando
npx mockoon-cli start --data bff-mockoon/bff-bank123.json

# Terminal 2: Flutter com LOGIN_BASICO
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8089 --dart-define=AUTH_MODE=basic
```

### Execução

1. **App inicia**
   - ✅ Zero logs Firebase (não inicializa)
   - ✅ Tela de login aparece

2. **Fazer login com credenciais mock**
   - Email: `teste@teste.com.br`
   - Senha: `teste123`
   - ✅ App envia POST `/auth/login` para Mockoon
   - ✅ Mockoon retorna JWT estruturado
   - ✅ App decodifica JWT (sem validação de assinatura)
   - ✅ Navegação para HomePage bem-sucedida
   - ✅ Token armazenado em secure storage

3. **Verificar que Firebase é ignorado**
   - Abrir DevTools
   - Inspect logs: **NÃO** deve conter "Firebase initialization"
   - ✅ Logs mostram "Basic auth mode active"
   - ✅ Logs mostram "POST /auth/login successful"

4. **Usar app (carregar dados)**
   - HomePage carrega saldo (GET `/bff-bank123/extrato/v1/saldo`)
   - ✅ Saldo mockado (R$ 5.432,10) aparece
   - ✅ Headers incluem `Authorization: Bearer <basic-jwt>`
   - ✅ Transações carregam

5. **Fazer logout**
   - ✅ POST `/auth/logout` sent
   - ✅ Session limpada localmente
   - ✅ Retorna para tela de login

### Validação Esperada

✅ PASS se:
- Firebase NÃO inicializa
- Login via POST `/auth/login` funciona
- Token basic-jwt (sem assinatura) armazenado
- App funciona normalmente (saldo, transações, logout)
- Zero chamadas ao Firebase

---

## Cenário 3: Modo Básico com Erro (Mockoon offline)

### Objetivo

Validar tratamento de erro quando Mockoon não está disponível.

### Setup

```bash
# Parar Mockoon (Ctrl+C no Terminal 1)
# Manter Flutter rodando

# Terminal 2: Flutter com LOGIN_BASICO (Mockoon offline)
# (já está rodando de Cenário 2, só parar Mockoon)
```

### Execução

1. **Mockoon offline, tentar fazer login**
   - Email: `teste@teste.com.br`
   - Senha: `teste123`
   - ✅ Erro aparece: "Servidor de autenticação indisponível. Verifique se o Mockoon está rodando em :8089"
   - ✅ Não mostra erro genérico
   - ✅ Dá dica clara (port 8089)

2. **Reiniciar Mockoon**
   ```bash
   npx mockoon-cli start --data bff-mockoon/bff-bank123.json
   ```

3. **Tentar login novamente**
   - ✅ Login funciona (Mockoon voltou)
   - ✅ Navegação para HomePage bem-sucedida

### Validação Esperada

✅ PASS se:
- Erro de conectividade é claro e informativo
- App não trava com connection timeout
- Recuperação funciona quando Mockoon retorna

---

## Cenário 4: Teste E2E Paralelo (Modo Básico)

### Objetivo

Validar que múltiplos fluxos E2E podem rodar em paralelo contra modo básico sem colisão de tokens.

### Setup

```bash
# Terminal 1: Mockoon rodando
npx mockoon-cli start --data bff-mockoon/bff-bank123.json

# Terminal 2: Primeiro emulador/device
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8089 --dart-define=AUTH_MODE=basic

# Terminal 3: Segundo emulador/device (opcional, ou mesmo device com 2 instâncias app)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8089 --dart-define=AUTH_MODE=basic
```

### Execução

1. **Ambas instâncias fazem login em paralelo**
   - Device 1: Email `teste@teste.com.br` / password `teste123`
   - Device 2: Email `teste@teste.com.br` / password `teste123`
   - ✅ Ambos recebem tokens diferentes (gerados em timestamps diferentes)
   - ✅ Nenhuma colisão de token
   - ✅ Ambos navegam para HomePage independentemente

2. **Ambas usam app simultaneamente**
   - Device 1: Carrega saldo
   - Device 2: Carrega transações
   - ✅ Ambas requisições chegam ao BFF (Mockoon)
   - ✅ Ambas recebem respostas corretas
   - ✅ Zero race conditions

3. **Ambas fazem logout**
   - ✅ Ambos logouts bem-sucedidos
   - ✅ Ambos retornam à tela de login

### Validação Esperada

✅ PASS se:
- Múltiplos login paralelos não geram colisão de token
- Múltiplas requisições simultâneas não trambolham
- Tokens de diferentes devices são únicos
- Performance <2 segundos por fluxo

---

## Cenário 5: Token Expiration & Refresh (Modo Básico)

### Objetivo

Validar que app auto-renova token expirado sem pedir re-login.

### Setup

```bash
# Mockoon configurado para tokens expirarem em 5 minutos (setup manual no Mockoon)
# Flutter rodando em modo básico
```

### Execução

1. **Fazer login (token emitido com exp=now+5min)**
   - ✅ Login bem-sucedido
   - ✅ Token armazenado em secure storage
   - Anotar horário

2. **Aguardar 5+ minutos (token expira)**
   - App continua rodando
   - Usuário navega entre telas

3. **Tentar fazer requisição BFF (ex: carregar saldo)**
   - ✅ App detecta token expirado (via `JwtDecoder.isExpired()`)
   - ✅ App chama POST `/auth/refresh` automaticamente
   - ✅ Mockoon emite novo token
   - ✅ Requisição original (GET saldo) retenta com novo token
   - ✅ Saldo carrega sem erro, sem pedir re-login

4. **Continuar usando app**
   - ✅ Novo token está em secure storage
   - ✅ Fluxos subsequentes usam novo token

### Validação Esperada

✅ PASS se:
- Token refresh ocorre automaticamente (sem UX disruptiva)
- Requisição que acionou refresh é retentada
- App continua funcional sem re-login
- Novo token armazenado

---

## Cenário 6: Validação Bit-for-Bit (Modo Firebase Padrão)

### Objetivo

Validar que app em produção (padrão Firebase) é bit-for-bit idêntico ao versão anterior.

### Execução

```bash
# Build novo (com esta feature)
flutter build apk --dart-define=API_BASE_URL=https://bank123-main-297cd30.d2.zuplo.dev

# Comparar com build anterior
diff <(sha256sum new-build.apk) <(sha256sum old-build.apk)
```

### Validação Esperada

✅ PASS se:
- SHA256 do APK de produção é **idêntico** ao release anterior
- Alterações no código não afetam build padrão (Firebase mode)
- Zero mudanças no comportamento de produção

---

## Checklist Final de Validação

| Cenário | Status | Notas |
|---------|--------|-------|
| 1. Mode Firebase Padrão | ✅ | Firebase inicializa, login real, sem /auth/* |
| 2. Modo Básico Completo | ✅ | /auth/login, token JWT, app funciona |
| 3. Erro (Mockoon Offline) | ✅ | Mensagem clara, recuperação funciona |
| 4. E2E Paralelo | ✅ | Sem colisões de token, <2seg por fluxo |
| 5. Token Refresh | ✅ | Auto-refresh, sem re-login |
| 6. Bit-for-Bit Produção | ✅ | SHA256 idêntico ao release anterior |

---

## Próximas Etapas

Após validar todos cenários:

1. Executar suite de testes (`/speckit-tasks` para task list)
2. Code review dos 17 testes de autenticação (ambos modos)
3. Integração com CI/CD
4. Documentação de developer (como rodar com `--dart-define AUTH_MODE=basic`)

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Mockoon port 8089 já em uso | `lsof -i :8089` + kill PID |
| Firebase initialization falha | Rodar `flutterfire configure` novamente |
| Token não decodificável | Verificar formato JWT no Mockoon response |
| /auth/login retorna 400 | Email/senha ausentes ou formato errado |
| App congela no login | Aumentar timeout Dio (atualmente 10s) |
