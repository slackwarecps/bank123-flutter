import 'package:bank123/core/widgets/widgets.dart';
import 'package:bank123/features/home/telas/home_pix_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomePix extends StatelessWidget {
  const HomePix({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.put(HomePixController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartão Virtual'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.credit_card, color: colorScheme.onPrimary),
                    Text(
                      'Virtual',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Obx(
                  () => Text(
                    controller.numeroCartao.value,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 20,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TITULAR',
                            style: TextStyle(
                              color: colorScheme.onPrimary.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.titular.value,
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VALIDADE',
                            style: TextStyle(
                              color: colorScheme.onPrimary.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.validade.value,
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CVV',
                            style: TextStyle(
                              color: colorScheme.onPrimary.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.numeroVisivel.value ? controller.cvv.value : '•••',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => OutlinedButton.icon(
              onPressed: controller.toggleNumeroVisivel,
              icon: Icon(
                controller.numeroVisivel.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              label: Text(
                controller.numeroVisivel.value ? 'Ocultar dados' : 'Mostrar dados',
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Copiar número do cartão',
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: controller.numeroCompleto),
              );
              Get.snackbar(
                'Copiado',
                'Número do cartão copiado para a área de transferência.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }
}
