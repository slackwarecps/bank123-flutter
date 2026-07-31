import 'package:bank123/core/services/ibff_service.dart';
import 'package:dio/dio.dart';

class MockBffService implements IBffService {
  // Flag para testar erros - mude para true para simular erro 422
  static bool simularErroServico = false;
  static bool simularErroChaves = false;
  @override
  Future<dynamic> getPerfil() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "nome": "Fabão (Mock User)",
      "email": "teste@teste.com.br",
      "ultimoAcesso": DateTime.now().toIso8601String(),
      "metadata": {
        "isMock": true,
        "tccStatus": "Running local"
      }
    };
  }

  @override
  Future<dynamic> getSaldo() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      "saldo": 5432.10,
      "moeda": "BRL",
      "numeroConta": "123456-7",
      "dataAtualizacao": DateTime.now().toIso8601String()
    };
  }

  @override
  Future<List<dynamic>> getExtrato() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        "id": "1",
        "dataTransacao": DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        "destino": "Café Starbucks (Mock)",
        "valorTransacao": 25.50,
        "operacao": "TRANSFERENCIA_SAIDA",
        "categoria": "ALIMENTACAO"
      },
      {
        "id": "2",
        "dataTransacao": DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        "destino": "Amigo Depósito (Mock)",
        "valorTransacao": 150.00,
        "operacao": "ENTRADA",
        "categoria": "TRANSFERENCIA"
      },
      {
        "id": "3",
        "dataTransacao": DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        "destino": "Aluguel Apartamento (Mock)",
        "valorTransacao": 2500.00,
        "operacao": "SAIDA",
        "categoria": "MORADIA"
      },
      {
        "id": "4",
        "dataTransacao": DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        "destino": "Salário TCC Bank123 (Mock)",
        "valorTransacao": 8000.00,
        "operacao": "ENTRADA",
        "categoria": "SALARIO"
      }
    ];
  }

  @override
  Future<Response> postTransferencia(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(seconds: 2));

    // Simula uma resposta de sucesso do Dio
    return Response(
      requestOptions: RequestOptions(path: '/transferencia'),
      data: {
        "status": "SUCCESS",
        "transactionId": "mock-trx-999888777",
        "timestamp": DateTime.now().toIso8601String(),
        "mensagem": "Transferência simulada com sucesso!"
      },
      statusCode: 201,
    );
  }

  @override
  Future<dynamic> getCartaoCredito() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return {
      "bandeira": "Platinum",
      "final": "0000",
      "faturaAtual": 1287.45,
      "limiteDisponivel": 4200.00,
    };
  }

  @override
  Future<dynamic> getComponentesServico() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Simular erro 422 se o flag estiver ativo
    if (simularErroServico) {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/bank123/servicos/v1/home-servicos-sdu'),
        response: Response(
          requestOptions: RequestOptions(path: '/bank123/servicos/v1/home-servicos-sdu'),
          statusCode: 422,
          data: {
            "titulo": "Problema de Cadastro",
            "code": 422,
            "descricao": "Parece que você não tem habilitado o Serviço. Procure o Sac"
          },
        ),
      );
      throw dioException;
    }

    return {
      "buttons": [
        {
          "id": "servico1",
          "label": "Serviço 1",
          "icon": "receipt_long",
          "action": "SERVICO_1"
        },
        {
          "id": "servico2",
          "label": "Serviço 2",
          "icon": "history",
          "action": "SERVICO_2"
        },
        {
          "id": "servico3",
          "label": "Serviço 3",
          "icon": "download",
          "action": "SERVICO_3"
        }
      ]
    };
  }

  @override
  Future<List<dynamic>> getChavesPix() async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (simularErroChaves) {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/bff-bank123/pf/pix-chaves/v1/chaves'),
        response: Response(
          requestOptions: RequestOptions(path: '/bff-bank123/pf/pix-chaves/v1/chaves'),
          statusCode: 422,
          data: {
            "titulo": "Serviço de chaves PIX não disponível",
            "code": 422,
            "descricao": "Procure o atendimento para ativar este recurso"
          },
        ),
      );
      throw dioException;
    }

    return [
      {
        "id": "1",
        "tipo": "E-mail",
        "chave": "fabio.pereira@zup.com.br",
        "dataCriacao": "2024-01-15T00:00:00.000Z"
      },
      {
        "id": "2",
        "tipo": "Chave Aleatória",
        "chave": "4e810a2c-d32e-4be8-bf8e-b66944ccfff1",
        "dataCriacao": "2024-02-20T00:00:00.000Z"
      },
      {
        "id": "3",
        "tipo": "CPF",
        "chave": "123.456.789-10",
        "dataCriacao": "2024-03-10T00:00:00.000Z"
      }
    ];
  }

  @override
  Future<dynamic> getSeguroHome() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      "cards": [
        {
          "id": "1",
          "titulo": "Seguro de Vida",
          "descricao": "Proteja sua família",
          "icone": "heart",
          "link": "https://thecoxinha.com.br"
        },
        {
          "id": "2",
          "titulo": "Seguro Residencial",
          "descricao": "Proteja seu imóvel",
          "icone": "home",
          "link": "https://thecoxinha.com.br"
        },
        {
          "id": "3",
          "titulo": "Seguro Automóvel",
          "descricao": "Proteja seu veículo",
          "icone": "directions_car",
          "link": "https://thecoxinha.com.br"
        },
        {
          "id": "4",
          "titulo": "Seguro Viagem",
          "descricao": "Viaje com segurança",
          "icone": "flight",
          "link": "https://thecoxinha.com.br"
        },
        {
          "id": "5",
          "titulo": "Seguro Saúde",
          "descricao": "Cuide da sua saúde",
          "icone": "medical_services",
          "link": "https://thecoxinha.com.br"
        }
      ]
    };
  }

  @override
  Future<dynamic> getNotificacoes() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {
      "notificacoes": [
        {
          "id": "1",
          "titulo": "Transferência realizada",
          "mensagem": "Você transferiu R\$ 150,00 para João Silva",
          "data": DateTime.now().toIso8601String(),
          "lida": false,
          "icone": "transfer"
        },
        {
          "id": "2",
          "titulo": "Pagamento processado",
          "mensagem": "Seu pagamento foi processado com sucesso",
          "data": DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          "lida": false,
          "icone": "payment"
        },
        {
          "id": "3",
          "titulo": "Segurança da conta",
          "mensagem": "Novo login detectado em São Paulo",
          "data": DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          "lida": true,
          "icone": "security"
        },
        {
          "id": "4",
          "titulo": "Atualização de seguro",
          "mensagem": "Seu seguro foi atualizado com sucesso",
          "data": DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          "lida": true,
          "icone": "info"
        },
      ]
    };
  }

  @override
  Future<List<dynamic>> getNotificacoesSimples() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        "id": "1",
        "notificacao": "Você transferiu R\$ 150,00 para João Silva em 31/07 às 15:30"
      },
      {
        "id": "2",
        "notificacao": "Seu pagamento foi processado com sucesso em 31/07 às 14:30"
      },
      {
        "id": "3",
        "notificacao": "Novo login detectado em São Paulo em 31/07 às 13:30"
      },
      {
        "id": "4",
        "notificacao": "Seu seguro foi atualizado com sucesso em 30/07 às 12:00"
      },
      {
        "id": "5",
        "notificacao": "Limite de crédito aumentado para R\$ 5.000,00 em 29/07"
      },
    ];
  }

  @override
  Future<Response> marcarNotificacaoComoLida(String notificacaoId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      requestOptions: RequestOptions(path: '/notificacoes/$notificacaoId/lida'),
      data: {
        "status": "success",
        "mensagem": "Notificação marcada como lida",
        "notificacaoId": notificacaoId
      },
      statusCode: 200,
    );
  }

  @override
  Future<Response> marcarMultiplasNotificacoesComoLidas(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Response(
      requestOptions: RequestOptions(path: '/notificacoes/marcar-lidas'),
      data: {
        "status": "success",
        "mensagem": "Notificações marcadas como lidas",
        "quantidade": ids.length,
        "ids": ids
      },
      statusCode: 200,
    );
  }

  @override
  Future<dynamic> getHomeApp() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return {
      "componentes": [
        {
          "tipo": "acoes_rapidas",
          "id": "acoes1",
          "itens": [
            {"id": "cartao_virtual", "label": "Cartão virtual", "icone": "credit_card", "action": "CARTAO_VIRTUAL"},
            {"id": "pix", "label": "Pix", "icone": "pix", "action": "PIX"},
            {"id": "credito", "label": "Crédito", "icone": "payments", "action": "CREDITO"},
            {"id": "cartao", "label": "Cartão", "icone": "credit_card", "action": "CARTAO"},
          ]
        },
        {
          "tipo": "banner_destaque",
          "id": "banner1",
          "icone": "attach_money",
          "titulo": "Conheça o Bank123 Invest!",
          "descricao": "Invista com segurança e a solidez Bank123.",
          "action": "INVEST"
        },
        {
          "tipo": "conta_saldo",
          "id": "conta1",
          "titulo": "Minha Conta Bank123",
          "label": "Saldo disponível",
          "valor": 4582.37,
          "acaoLabel": "Acessar",
          "action": "EXTRATO"
        },
        {
          "tipo": "cartao_credito",
          "id": "cartao1",
          "titulo": "Meus cartões",
          "bandeira": "Visa",
          "descricao": "Sem Anuidade final 1119",
          "faturaLabel": "Sua fatura",
          "fatura": 812.45,
          "limiteLabel": "Limite disponível",
          "limite": 3200.00,
          "acaoFaturaLabel": "Ver fatura",
          "acaoFaturaAction": "FATURA",
          "acaoMaisLabel": "Ver mais",
          "acaoMaisAction": "CARTAO_DETALHES"
        },
        {
          "tipo": "carrossel_promocional",
          "id": "carrossel1",
          "titulo": "Mais Bank123 para você",
          "itens": [
            {
              "id": "1",
              "tag": "Bank123 Invest",
              "titulo": "Conheça a nossa nova solução",
              "cta": "Diversificar seu patrimônio ficou ainda mais fácil",
              "imagem": "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=800&q=80&auto=format&fit=crop",
              "action": "INVEST"
            },
            {
              "id": "2",
              "tag": "Bank123 Seguros",
              "titulo": "Proteja o que importa",
              "cta": "Garanta já a sua proteção",
              "imagem": "https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=800&q=80&auto=format&fit=crop",
              "action": "SEGURO"
            },
          ]
        },
      ]
    };
  }
}
