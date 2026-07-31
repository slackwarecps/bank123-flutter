import 'package:bank123/core/services/ibff_service.dart';
import 'package:dio/dio.dart';

class MockBffService implements IBffService {
  // Flag para testar erros - mude para true para simular erro 422
  static bool simularErroServico = false;
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
}
