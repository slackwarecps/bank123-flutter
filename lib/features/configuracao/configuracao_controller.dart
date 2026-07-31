import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class ConfiguracaoController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Variável observável para o switch
  var isBiometricEnabled = false.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    isLoading.value = true;
    try {
      // Lê o valor salvo. Se for nulo, assume false (padrão solicitado).
      String? value = await _storage.read(key: 'biometric_enabled');
      isBiometricEnabled.value = value == 'true';
    } catch (e) {
      // Em caso de erro, mantém false
      isBiometricEnabled.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBiometria(bool value) async {
    // Se estiver desativando (ON → OFF), apenas desativa sem pedir biometria
    if (!value) {
      isBiometricEnabled.value = false;
      await _storage.write(key: 'biometric_enabled', value: 'false');
      return;
    }

    // Se estiver ativando (OFF → ON), pede autenticação biométrica
    try {
      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Autentique-se para habilitar login com biometria',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        isBiometricEnabled.value = true;
        await _storage.write(key: 'biometric_enabled', value: 'true');
      } else {
        // Mantém o valor anterior se a autenticação foi cancelada
        isBiometricEnabled.value = false;
      }
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Erro ao autenticar com biometria: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Mantém o valor anterior em caso de erro
      isBiometricEnabled.value = false;
    }
  }
}
