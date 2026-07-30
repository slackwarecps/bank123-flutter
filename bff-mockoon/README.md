# BFF Mock Server (Mockoon)

Mock completo do BFF Bank123, simulando todas as chamadas HTTP que o app Flutter faz para o backend.

## Quick Start

### 1. Rodar o Mockoon

**Com CLI:**
```bash
npx mockoon-cli start --data bff-mockoon/bff-bank123.json
```

**Ou no Desktop:**
1. Baixe/instale [Mockoon Desktop](https://mockoon.com/download/)
2. Abra o arquivo `bff-mockoon/bff-bank123.json` no app

### 2. Rodar o Flutter apontando pro mock

**Android Emulator (Pixel_3a_API_33):**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8089
```

**iOS Simulator ou Flutter Web:**
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8089
```

### 3. Login no app

- **Use o Firebase real** — autenticação continua via Firebase (projeto `draft1-app-fabao`), não é mockada
- Não use `USE_MOCK=true` (senão o app usa `MockBffService` em vez do Mockoon)
- Após logar com credenciais Firebase válidas, o app vai bater no mock em vez do BFF real

## Endpoints Disponíveis

### GET `/bff-bank123/usuario/v1/perfil`
Retorna dados do perfil do usuário.

**Resposta padrão (200):**
```json
{
  "nome": "Fabão (Mock User)",
  "email": "teste@teste.com.br",
  "ultimoAcesso": "2026-07-30T12:00:00.000",
  "metadata": {
    "isMock": true,
    "tccStatus": "Running local"
  }
}
```

**Alternativas de erro:**
- `401 Unauthorized` — "Token inválido ou expirado"
- `500 Internal Server Error` — "Erro interno no servidor"

---

### GET `/bff-bank123/extrato/v1/saldo`
Retorna saldo da conta.

**Resposta padrão (200):**
```json
{
  "saldo": 5432.10,
  "moeda": "BRL",
  "numeroConta": "123456-7",
  "dataAtualizacao": "2026-07-30T12:00:00.000"
}
```

**Alternativas de erro:**
- `500 Internal Server Error` — "Erro ao buscar saldo"

---

### GET `/bff-bank123/extrato/v1/listagem`
Retorna lista de transações.

**Resposta padrão (200):**
Array com 4 transações mockadas (TRANSFERENCIA_SAIDA, ENTRADA, SAIDA, ENTRADA)

**Alternativas de erro:**
- `200 OK` (vazio) — `[]` — extrato zerado
- `500 Internal Server Error` — "Erro ao buscar extrato"

---

### POST `/bff-bank123/movimentacoes/v1/transferencia-conta`
Realiza transferência entre contas.

**Request body:**
```json
{
  "valor": "1250.00",
  "destino-conta": "123456-7"
}
```

**Resposta padrão (201 Created):**
```json
{
  "status": "SUCCESS",
  "transactionId": "mock-trx-999888777",
  "timestamp": "2026-07-30T12:00:00.000",
  "mensagem": "Transferência simulada com sucesso!"
}
```

**Alternativas de erro:**
- `400 Bad Request` — "Saldo insuficiente"
- `500 Internal Server Error` — "Erro ao processar transferência"

## Headers Enviados pelo App

O app injeta esses headers em **todas** as requisições (você não precisa fazer nada no Mockoon, é apenas informação):

- `Authorization: Bearer <firebase-id-token>`
- `x-account-id: <account-id-from-secure-storage>` (padrão: `1`)
- `x-correlation-id: <uuid-v4>`

## Alternar Entre Sucesso e Erro

1. Abra o Mockoon Desktop ou console do CLI
2. Clique na rota desejada
3. Selecione a resposta alternativa (ex: "Erro do servidor")
4. Próxima chamada do app retornará aquele erro

## SSL Pinning — Nota

O app tem SSL pinning habilitado (`lib/services/bff_service.dart:38-65`), mas **só é acionado em conexões HTTPS**. Ao rodar contra o mock em **HTTP puro**, o pinning nunca é verificado — nenhuma alteração de código é necessária.

Se precisar testar com HTTPS futuramente, será preciso desabilitar pinning temporariamente ou usar um proxy que termine a conexão com um certificado confiável.

## Validação Local

Antes de rodar o app, você pode testar os endpoints com `curl`:

```bash
# GET /perfil
curl http://localhost:8089/bff-bank123/usuario/v1/perfil

# GET /saldo
curl http://localhost:8089/bff-bank123/extrato/v1/saldo

# GET /listagem
curl http://localhost:8089/bff-bank123/extrato/v1/listagem

# POST /transferencia-conta
curl -X POST http://localhost:8089/bff-bank123/movimentacoes/v1/transferencia-conta \
  -H "Content-Type: application/json" \
  -d '{"valor":"10.00","destino-conta":"123456-7"}'
```

Todos devem retornar JSON com status 200/201 (ou o status que estiver selecionado no Mockoon).
