import 'package:bank123/features/home/telas/tab_seguro_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TabSeguro extends StatelessWidget {
  const TabSeguro({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.put(TabSeguroController(), tag: 'tabSeguro');

    return Obx(
      () {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
            ),
          );
        }

        if (controller.temErro.value) {
          return ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          controller.erroTitulo.value,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (controller.erroDescricao.value.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            controller.erroDescricao.value,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => controller.carregarSeguros(),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        if (controller.cardsSeguro.isEmpty) {
          return ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 80,
                        color: colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Nenhum seguro disponível',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  'Seguros Disponíveis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: controller.cardsSeguro.length,
                  itemBuilder: (context, index) {
                    final card = controller.cardsSeguro[index];
                    return GestureDetector(
                      onTap: () => _abrirLink(card.link),
                      child: _buildCardSeguro(context, card, colorScheme),
                    );
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardSeguro(
    BuildContext context,
    CardSeguro card,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconFromName(card.icone),
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  card.titulo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  card.descricao,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Icon(
              Icons.arrow_forward,
              size: 16,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    final iconMap = {
      'heart': Icons.favorite_outline,
      'home': Icons.home_outlined,
      'directions_car': Icons.directions_car_outlined,
      'flight': Icons.flight_outlined,
      'medical_services': Icons.medical_services_outlined,
      'shield': Icons.shield_outlined,
    };
    return iconMap[iconName] ?? Icons.shield_outlined;
  }

  Future<void> _abrirLink(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        Get.snackbar(
          'Erro',
          'Não foi possível abrir o navegador',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao abrir o link: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
