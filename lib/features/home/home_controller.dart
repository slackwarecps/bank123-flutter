import 'package:bank123/core/models/cartao_credito_model.dart';
import 'package:bank123/core/services/ibff_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class HomeController extends GetxController {
  final IBffService _bffService = Get.find<IBffService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var nome = ''.obs;
  var saldo = 0.0.obs;
  var numeroConta = ''.obs;
  var saldoVisivel = true.obs;
  var faturaVisivel = true.obs;
  Rxn<CartaoCreditoModel> cartao = Rxn<CartaoCreditoModel>();
  var abaAtiva = 'Bank'.obs;
  var componentesServico = Rxn<Map<String, dynamic>>();
  var carregandoServico = false.obs;
  var erroServico = false.obs;
  var erroTituloServico = ''.obs;
  var erroDescricaoServico = ''.obs;
  var erroStatusCode = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validarTokenInicial();
      _carregarDadosHome();
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

  Future<void> _carregarDadosHome() async {
    try {
      isLoading.value = true;

      final perfilFuture = _bffService.getPerfil();
      final saldoFuture = _bffService.getSaldo();
      final cartaoFuture = _bffService.getCartaoCredito();

      final results = await Future.wait([
        perfilFuture,
        saldoFuture,
        cartaoFuture,
      ]);

      if (results[0] is Map<String, dynamic> &&
          results[1] is Map<String, dynamic> &&
          results[2] is Map<String, dynamic>) {
        final perfilData = results[0] as Map<String, dynamic>;
        final saldoData = results[1] as Map<String, dynamic>;
        final cartaoData = results[2] as Map<String, dynamic>;

        nome.value = perfilData['nome'] ?? '';
        saldo.value = (saldoData['saldo'] as num?)?.toDouble() ?? 0.0;
        numeroConta.value = saldoData['numeroConta'] ?? '';
        cartao.value = CartaoCreditoModel.fromJson(cartaoData);
      } else {
        throw Exception('Formato de resposta inválido');
      }
    } catch (e) {
      developer.log('Erro ao carregar dados da Home: $e', name: 'HomeController');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os dados da Home',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSaldoVisivel() {
    saldoVisivel.value = !saldoVisivel.value;
  }

  void toggleFaturaVisivel() {
    faturaVisivel.value = !faturaVisivel.value;
  }

  void consultarExtrato() async {
    if (!await _sessaoValida()) return;
    Get.toNamed('/extrato');
  }

  void irParaTransferencia() async {
    if (!await _sessaoValida()) return;
    Get.toNamed('/transferencia');
  }

  Future<void> carregarComponentesServico() async {
    try {
      carregandoServico.value = true;
      erroServico.value = false;
      erroTituloServico.value = '';
      erroDescricaoServico.value = '';
      final dados = await _bffService.getComponentesServico();
      if (dados is Map<String, dynamic>) {
        componentesServico.value = dados;
      } else {
        throw Exception('Formato de resposta inválido');
      }
    } catch (e) {
      developer.log('Erro ao carregar componentes do serviço: $e', name: 'HomeController');
      erroServico.value = true;
      componentesServico.value = null;

      if (e is DioException && e.response != null) {
        final statusCode = e.response?.statusCode ?? 0;
        erroStatusCode.value = statusCode;
        developer.log('Status code: $statusCode', name: 'HomeController');
        developer.log('Response data: ${e.response?.data}', name: 'HomeController');
        developer.log('Response data type: ${e.response?.data.runtimeType}', name: 'HomeController');

        if (statusCode >= 400 && statusCode < 500) {
          var errorData = e.response?.data;

          // Se a resposta veio como String, faz parse manual
          if (errorData is String) {
            try {
              errorData = jsonDecode(errorData) as Map<String, dynamic>;
            } catch (parseError) {
              developer.log('Erro ao fazer parse do JSON: $parseError', name: 'HomeController');
              errorData = null;
            }
          }

          if (errorData is Map<String, dynamic>) {
            erroTituloServico.value = errorData['titulo'] ?? 'Erro';
            erroDescricaoServico.value = errorData['descricao'] ?? 'Ocorreu um erro inesperado';
          } else {
            erroTituloServico.value = 'Erro na Requisição';
            erroDescricaoServico.value = 'Não foi possível processar sua solicitação';
          }
        } else if (statusCode >= 500) {
          erroTituloServico.value = 'Erro no Servidor';
          erroDescricaoServico.value = 'Tente novamente mais tarde';
        }
      } else {
        erroTituloServico.value = 'Erro de Conexão';
        erroDescricaoServico.value = 'Verifique sua conexão com a internet';
      }

      developer.log('Erro setado - Titulo: ${erroTituloServico.value}, Descricao: ${erroDescricaoServico.value}', name: 'HomeController');
    } finally {
      carregandoServico.value = false;
    }
  }

  Future<void> recarregarAbaAtiva() async {
    try {
      if (abaAtiva.value == 'Bank') {
        await _carregarDadosHome();
      } else if (abaAtiva.value == 'Serviço') {
        await carregarComponentesServico();
      } else if (abaAtiva.value == 'Seguro') {
        try {
          final seguroController = Get.find(tag: 'tabSeguro');
          await seguroController.carregarSeguros();
        } catch (e) {
          developer.log('Controller de Seguro não encontrado: $e', name: 'HomeController');
        }
      }
    } catch (e) {
      developer.log('Erro ao recarregar aba: $e', name: 'HomeController');
    }
  }
}
