import 'package:bank123/services/ibff_service.dart';
import 'package:dio/dio.dart';

class MockBffService implements IBffService {
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
      statusCode: 200,
    );
  }
}
