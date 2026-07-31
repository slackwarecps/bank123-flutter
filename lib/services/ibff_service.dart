import 'package:dio/dio.dart';

abstract class IBffService {
  Future<dynamic> getPerfil();
  Future<dynamic> getSaldo();
  Future<List<dynamic>> getExtrato();
  Future<Response> postTransferencia(Map<String, dynamic> payload);
  Future<dynamic> getCartaoCredito();
}
