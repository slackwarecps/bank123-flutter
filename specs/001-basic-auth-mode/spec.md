# Especificação da Feature: Modos Duplos de Autenticação (Firebase + Básico)

**Branch da Feature**: `001-basic-auth-mode`

**Criado em**: 2026-07-30

**Status**: Rascunho

**Entrada**: Descrição do usuário: "vamos ter um if no auth_service, quero que dada uma certa constante LOGIN_FIREBASE|LOGIN_BASICO; deve ter endpoints necessarios a suportar o login e validacao dos tokens quando a constante for LOGIN_BASICO; A ideia é eu poder testar o app isolando o Firebase para depois poder automatizar os testes end2end"

## Cenários de Usuário & Testes *(obrigatório)*

### História de Usuário 1 - Desenvolvedor Testa App Offline Sem Firebase (Prioridade: P1)

Um desenvolvedor quer executar o app localmente sem dependências do Firebase durante desenvolvimento e testes, usando um modo de autenticação HTTP leve em vez da integração Firebase de produção. Isso permite iteração mais rápida, testes offline e testes isolados de features sem dependências de serviços em nuvem.

**Por que essa prioridade**: Requisito central - feature bloqueadora para velocidade de desenvolvimento e configuração de testes E2E automatizados. Sem isto, desenvolvedores precisam manter configuração do Firebase e acesso à rede para todos os cenários de teste.

**Teste Independente**: Pode ser totalmente testado rodando o app com a constante `LOGIN_BASICO` definida, autenticando via endpoints HTTP e verificando que Firebase nunca é chamado. Entrega testes isolados sem dependências externas.

**Cenários de Aceitação**:

1. **Dado** que o app está configurado com modo `LOGIN_BASICO`, **Quando** um desenvolvedor executa o app, **Então** nenhuma chamada ao Firebase SDK é feita e todas as operações de autenticação usam endpoints HTTP
2. **Dado** que o modo de autenticação básica está ativo, **Quando** um usuário digita email/senha na tela de login, **Então** o app envia credenciais a um endpoint HTTP local/mock e recebe uma resposta de token válido
3. **Dado** que o modo de autenticação básica está habilitado, **Quando** o app faz requisições subsequentes da API, **Então** usa o token da autenticação básica (não Firebase) nos headers da requisição

---

### História de Usuário 3 - App em Produção Continua Usando Firebase (Prioridade: P1)

O build de produção do app deve continuar usando Firebase para toda autenticação (verificação de usuário, geração de tokens, segurança). O modo de autenticação básica é estritamente para desenvolvimento e testes - o comportamento de produção é inalterado.

**Por que essa prioridade**: Crítico para segurança e estabilidade de produção. A integração Firebase não pode ser removida ou comprometida. Apenas desenvolvedores com configuração explícita escolhem modo de autenticação básica.

**Teste Independente**: Pode ser totalmente testado rodando o app em configuração de produção (padrão ou com constante `LOGIN_FIREBASE` explícita) e verificando que Firebase está inicializado e todas as chamadas de autenticação usam SDK do Firebase.

**Cenários de Aceitação**:

1. **Dado** que o app é construído para produção (configuração padrão), **Quando** o app inicia, **Então** Firebase SDK é inicializado e ativo
2. **Dado** que a configuração de produção está ativa, **Quando** usuário faz login, **Então** credenciais são validadas exclusivamente via Firebase (nenhum endpoint HTTP de autenticação)
3. **Dado** que modo de produção está rodando, **Quando** o app faz chamadas da API, **Então** tokens são tokens de ID do Firebase com assinaturas criptográficas

---

### Casos Extremos

- O que acontece quando um desenvolvedor configura `LOGIN_BASICO` mas o servidor mock de autenticação não está rodando? (Deveria mostrar erro claro, não falhar silenciosamente)
- Como o app manipula tokens expirados no modo de autenticação básica? (pedir re-login)

## Requisitos *(obrigatório)*

### Requisitos Funcionais

- **RF-001**: O app DEVE suportar uma constante de build-time (Dart define) que alterna entre modos de autenticação `LOGIN_FIREBASE` e `LOGIN_BASICO`
- **RF-002**: Quando `LOGIN_BASICO` é selecionado, o app NÃO DEVE inicializar ou usar o Firebase SDK de autenticação
- **RF-003**: Quando `LOGIN_BASICO` é selecionado, o app DEVE fornecer endpoints HTTP de autenticação que aceitem email/senha e retornem um token válido
- **RF-004**: O modo de autenticação básica DEVE suportar operações de login (email + senha → token), logout e validação de token
- **RF-005**: Tokens retornados pela autenticação básica DEVEM ser compatíveis com chamadas da API downstream existentes (requisições BFF que esperam header `Authorization: Bearer <token>`)
- **RF-006**: O app DEVE incluir um mecanismo de validação/renovação de token no modo de autenticação básica para suportar gerenciamento de sessão
- **RF-007**: Quando `LOGIN_FIREBASE` é selecionado (padrão), Firebase SDK DEVE ser totalmente inicializado e usado para toda autenticação
- **RF-008**: A constante de modo de autenticação DEVE ser definida em build-time via `--dart-define` e não ser alterável em runtime
- **RF-009**: O modo de autenticação básica DEVE suportar a UI de login existente (mesmas telas, mesma experiência de usuário) sem mudanças de UI entre modos
- **RF-010**: Tratamento de erro no modo de autenticação básica DEVE fornecer mensagens de erro equivalentes e caminhos de recuperação como modo Firebase (ex: credenciais inválidas, erros de rede)

### Entidades Principais

- **AuthMode**: Enumeração com valores `firebase` (padrão) e `basic` — controla qual implementação de autenticação está ativa
- **BasicAuthToken**: Objeto de token retornado por endpoints de autenticação básica contendo `token` (string tipo JWT), `expiresAt` (timestamp), `userId` (identificador)
- **Interface AuthService**: Contrato abstrato que ambas implementações Firebase e Basic cumprem (já existe como `IAuthService`)

## Critérios de Sucesso *(obrigatório)*

### Resultados Mensuráveis

- **CS-001**: App inicia em modo `LOGIN_BASICO` sem inicialização do Firebase SDK (verificado pela ausência de logs/chamadas de inicialização do Firebase)
- **CS-002**: Suite de testes E2E completa workflows completos do usuário (login → home → transações → logout) em menos de 2 segundos por workflow ao usar autenticação básica
- **CS-003**: Todos os 17 testes de autenticação existentes passam em ambos modos de autenticação Firebase e básica
- **CS-004**: Builds de produção padronizam para modo Firebase e não podem incluir acidentalmente endpoints de autenticação básica
- **CS-005**: Renovação/validação de token no modo de autenticação básica tem sucesso para tokens válidos e rejeita tokens expirados em menos de 1 segundo
- **CS-006**: App construído com `LOGIN_FIREBASE` (padrão) é bit-a-bit idêntico e funcionalmente equivalente ao comportamento de produção atual

## Suposições

- A interface `IAuthService` existente é suficiente para suportar ambas implementações sem modificação em controladores ou código downstream
- Endpoints de autenticação básica serão fornecidos por um servidor mock existente ou podem ser adicionados à configuração do Mockoon (já em lugar na porta 8089)
- Tokens da autenticação básica não requerem verificação criptográfica — podem ser strings opacas simples ou estruturas tipo JWT validadas pelo servidor
- Os interceptadores de headers/requisições existentes do app (`Authorization`, `x-account-id`, `x-correlation-id`) continuam funcionando com ambos modos de autenticação
- Nenhuma mudança de fluxo de UI é necessária — tela de login e telas pós-autenticação permanecem idênticas
- Comportamento padrão/produção deve permanecer inalterado (Firebase continua funcionando como está)
