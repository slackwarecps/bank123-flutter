import 'package:bank123/features/configuracao/configuracao_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfiguracaoPage extends StatelessWidget {
  const ConfiguracaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Injeta o controller
    final ConfiguracaoController controller = Get.put(ConfiguracaoController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icon/bank_icon.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text('Configurações'),
          ],
        ),
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: colorScheme.surface,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Segurança',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Entrar com Biometria',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Habilita o login usando impressão digital ou Face ID',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: controller.isBiometricEnabled.value,
                  onChanged: (bool value) {
                    controller.toggleBiometria(value);
                  },
                  activeThumbColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
