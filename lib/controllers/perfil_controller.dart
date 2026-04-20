import 'package:bank123/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class PerfilController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();
  
  final email = ''.obs;
  final uid = ''.obs;
  final iat = ''.obs;
  final exp = ''.obs;
  final ttlSessao = ''.obs;
  final token = ''.obs;
  final bank123Claims = ''.obs;

  @override
  void onInit() {
    super.onInit();
    carregarDadosUsuario();
  }

  Future<void> carregarDadosUsuario() async {
    User? user = _auth.currentUser;

    if (user != null) {
      email.value = user.email ?? 'Não disponível';
      uid.value = user.uid;

      // Obter o ID Token e seus claims
      IdTokenResult tokenResult = await user.getIdTokenResult();
      token.value = tokenResult.token ?? 'Erro ao obter token';
      
      // Claims
      final claims = tokenResult.claims ?? {};
      
      if (claims.containsKey('bank123/jwt/claims')) {
        bank123Claims.value = claims['bank123/jwt/claims'].toString();
      } else {
        bank123Claims.value = 'N/A';
      }

      // IAT e EXP
      DateTime? authTime = tokenResult.authTime;
      DateTime? expirationTime = tokenResult.expirationTime;

      iat.value = authTime != null ? authTime.toString() : 'N/A';
      exp.value = expirationTime != null ? expirationTime.toString() : 'N/A';

      // Ler TTL Sessão do Storage
      final savedTtl = await _storage.read(key: 'ttl_sessao');
      ttlSessao.value = savedTtl ?? 'N/A';
    }
  }

  void copiarToken() {
    if (token.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: token.value));
      Get.snackbar(
        'Sucesso',
        'Token copiado para a área de transferência!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
