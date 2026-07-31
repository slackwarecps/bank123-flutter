import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ConfiguracaoController extends GetxController {
  final _storage = const FlutterSecureStorage();
  
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
    isBiometricEnabled.value = value;
    // Salva 'true' ou 'false' como string no secure storage
    await _storage.write(key: 'biometric_enabled', value: value.toString());
  }
}
