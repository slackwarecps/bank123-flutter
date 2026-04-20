import 'package:bank123/services/ibff_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransferenciaController extends GetxController {
  final IBffService _service = Get.find<IBffService>();
  var isLoading = false.obs;
  
  final formKey = GlobalKey<FormState>();
  final contaDestinoController = TextEditingController();
  final valorController = TextEditingController();

  Future<void> realizarTransferencia() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Limpar formatação de moeda (R$ 1.250,00 -> 1250.00)
      String valorLimpo = valorController.text
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();

      final payload = {
        "valor": valorLimpo,
        "destino-conta": contaDestinoController.text,
      };

      final response = await _service.postTransferencia(payload);

      if (response.statusCode == 201) {
        Get.snackbar(
          "Sucesso",
          "Transferência realizada com sucesso!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        contaDestinoController.clear();
        valorController.clear();
        Get.offAllNamed('/home-page');
      } else {
        _mostrarErroTransacao();
      }

    } catch (e) {
      _mostrarErroTransacao();
    } finally {
      isLoading.value = false;
    }
  }

  void _mostrarErroTransacao() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Nao foi possivel realizar a transacao!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Get.back(),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
