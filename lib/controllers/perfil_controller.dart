import 'package:bank123/services/auth_service.dart';
import 'package:bank123/services/ibff_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PerfilController extends GetxController {
  final IAuthService _authService = Get.find<IAuthService>();
  final IBffService _bffService = Get.find<IBffService>();
  final _storage = const FlutterSecureStorage();
  
  final nome = 'Carregando...'.obs;
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
    try {
      // 1. Buscar dados do BFF (Mock ou Real)
      final profileData = await _bffService.getPerfil();
      nome.value = profileData['nome'] ?? 'N/A';

      // 2. Buscar dados de Autenticação
      final idToken = await _authService.getIdToken();
      if (idToken != null) {
        token.value = idToken;
        
        // Decodificar claims do token (seja mock ou real)
        Map<String, dynamic> claims = JwtDecoder.decode(idToken);
        email.value = claims['email'] ?? profileData['email'] ?? 'N/A';
        uid.value = claims['user_id'] ?? claims['sub'] ?? 'N/A';

        if (claims.containsKey('bank123/jwt/claims')) {
          bank123Claims.value = claims['bank123/jwt/claims'].toString();
        } else {
          bank123Claims.value = 'N/A';
        }

        // IAT e EXP
        if (claims.containsKey('iat')) {
           iat.value = DateTime.fromMillisecondsSinceEpoch(claims['iat'] * 1000).toString();
        }
        if (claims.containsKey('exp')) {
           exp.value = DateTime.fromMillisecondsSinceEpoch(claims['exp'] * 1000).toString();
        }
      }

      // 3. Ler TTL Sessão do Storage
      final savedTtl = await _storage.read(key: 'ttl_sessao');
      ttlSessao.value = savedTtl ?? 'N/A';
      
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar perfil: $e');
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
