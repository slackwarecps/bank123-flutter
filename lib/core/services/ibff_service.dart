import 'package:dio/dio.dart';

abstract class IBffService {
  Future<dynamic> getPerfil();
  Future<dynamic> getSaldo();
  Future<List<dynamic>> getExtrato();
  Future<Response> postTransferencia(Map<String, dynamic> payload);
  Future<dynamic> getCartaoCredito();
  Future<dynamic> getComponentesServico();
  Future<List<dynamic>> getChavesPix();
  Future<dynamic> getSeguroHome();
  Future<dynamic> getNotificacoes();
  Future<List<dynamic>> getNotificacoesSimples();
  Future<Response> marcarNotificacaoComoLida(String notificacaoId);
  Future<Response> marcarMultiplasNotificacoesComoLidas(List<String> ids);
}
