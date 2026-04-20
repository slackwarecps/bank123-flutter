import 'package:bank123/services/ibff_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:developer' as developer;

class HomeController extends GetxController {
  final IBffService _bffService = Get.find<IBffService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Verifica o token assim que a Home é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validarTokenInicial();
    });
  }

  Future<void> _validarTokenInicial() async {
    const isMock = String.fromEnvironment('USE_MOCK') == 'true';
    if (isMock) return;

    final token = await _storage.read(key: 'ACCESS_TOKEN');

    if (token == null || JwtDecoder.isExpired(token)) {
      // Token inválido ou expirado
      developer.log('### TOKEN INVALIDO OU EXPIRADO AO ENTRAR NA HOME ###', name: 'HomeController');
      Get.offAllNamed('/login');
      Get.snackbar(
        "Sessão Expirada",
        "Sua sessão expirou. Por favor, faça login novamente.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      // Limpeza de segurança
      await _storage.delete(key: 'ACCESS_TOKEN');
      await _storage.delete(key: 'biometric_enabled');
      await _storage.delete(key: 'ttl_sessao');
    }
  }

  Future<bool> _sessaoValida() async {
    const isMock = String.fromEnvironment('USE_MOCK') == 'true';
    if (isMock) return true;

    try {
      // Verifica TTL customizado
      final ttlString = await _storage.read(key: 'ttl_sessao');
      if (ttlString != null) {
         final exp = DateTime.parse(ttlString);
         final agora = DateTime.now();
         if (agora.isAfter(exp)) {
           _mostrarAlertaSessaoExpirada();
           return false;
         }
      }

      // Verifica validade do JWT Real
      final token = await _storage.read(key: 'ACCESS_TOKEN');
      if (token == null || JwtDecoder.isExpired(token)) {
         _mostrarAlertaSessaoExpirada();
         return false;
      }
      
      return true;
    } catch (e) {
      _mostrarAlertaSessaoExpirada();
      return false;
    }
  }

  void confirmarLogout() {
    Get.defaultDialog(
      title: "Sair",
      middleText: "Será necessário fazer o login novamente. Deseja continuar?",
      textConfirm: "Sim",
      textCancel: "Não",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        // Limpar dados sensíveis e configurações de biometria
        await _storage.delete(key: 'ACCESS_TOKEN');
        await _storage.delete(key: 'biometric_enabled');
        await _storage.delete(key: 'ttl_sessao'); // Opcional: limpar sessão também
        
        await _auth.signOut();
        Get.offAllNamed('/login');
      },
    );
  }

  void _mostrarAlertaSessaoExpirada() {
    Get.defaultDialog(
      title: "Sessão Expirada",
      middleText: "O tempo de sessão expirou. É necessário fazer o login novamente.",
      barrierDismissible: false,
      actions: [
        FilledButton(
          onPressed: () async {
            await _auth.signOut();
            Get.offAllNamed('/login');
          },
          child: const Text("Ir para Login"),
        )
      ],
    );
  }

  Future<void> consultarSaldo() async {
    if (!await _sessaoValida()) return;

    try {
      isLoading.value = true;
      final dados = await _bffService.getSaldo();
      
      // Formatar valor para BRL
      final saldo = dados['saldo'];
      final saldoFormatado = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(saldo);
      final conta = dados['numeroConta'];

      Get.defaultDialog(
        title: "Saldo Atual",
        middleText: "Conta: $conta\n\n$saldoFormatado",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      Get.snackbar(
        "Erro", 
        "Não foi possível consultar o saldo: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  void consultarExtrato() async {
    if (!await _sessaoValida()) return;
    Get.toNamed('/extrato');
  }

  void irParaTransferencia() async {
    if (!await _sessaoValida()) return;
    Get.toNamed('/transferencia');
  }
}
