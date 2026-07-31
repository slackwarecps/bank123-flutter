import 'package:bank123/features/home/home_controller.dart';
import 'package:bank123/features/home/telas/home_bank.dart';
import 'package:bank123/features/home/telas/tab_principal.dart';
import 'package:bank123/features/home/telas/tab_seguro.dart';
import 'package:bank123/features/home/telas/tab_servico.dart';
import 'package:bank123/features/notificacoes/notificacoes_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com logo, título e kebab menu
            Container(
              color: colorScheme.primary,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/icon/bank_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  Text(
                    'Bank123',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: colorScheme.onPrimary),
                    onSelected: (value) {
                      if (value == 'perfil') {
                        Get.toNamed('/perfil');
                      } else if (value == 'configuracoes') {
                        Get.toNamed('/configuracoes');
                      } else if (value == 'sair') {
                        controller.confirmarLogout();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'perfil', child: Text('Perfil')),
                      const PopupMenuItem(
                        value: 'configuracoes',
                        child: Text('Configurações'),
                      ),
                      const PopupMenuItem(value: 'sair', child: Text('Sair')),
                    ],
                  ),
                ],
              ),
            ),
            // Linha de saudação com nome e sino de notificação
            Container(
              color: colorScheme.primary,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Row(
                      children: [
                        Text(
                          'Olá, ${controller.nome.value}',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: colorScheme.onPrimary,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: colorScheme.onPrimary,
                    ),
                    onPressed: () => _abrirNotificacoes(),
                  ),
                ],
              ),
            ),
            // Linha de abas (Bank ativo, outros placeholders)
            Container(
              color: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Obx(
                    () => _buildTab(
                      context,
                      'Meu Bank123',
                      active: controller.abaAtiva.value == 'Meu Bank123',
                      onTap: () => controller.abaAtiva.value = 'Meu Bank123',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Obx(
                    () => _buildTab(
                      context,
                      'Bank',
                      active: controller.abaAtiva.value == 'Bank',
                      onTap: () => controller.abaAtiva.value = 'Bank',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Obx(
                    () => _buildTab(
                      context,
                      'Seguro',
                      active: controller.abaAtiva.value == 'Seguro',
                      onTap: () => controller.abaAtiva.value = 'Seguro',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Obx(
                    () => _buildTab(
                      context,
                      'Serviço',
                      active: controller.abaAtiva.value == 'Serviço',
                      onTap: () {
                        controller.abaAtiva.value = 'Serviço';
                        controller.carregarComponentesServico();
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Conteúdo das abas
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.recarregarAbaAtiva(),
                child: Obx(
                  () {
                    if (controller.abaAtiva.value == 'Meu Bank123') {
                      return const TabPrincipal();
                    } else if (controller.abaAtiva.value == 'Seguro') {
                      return const TabSeguro();
                    } else if (controller.abaAtiva.value == 'Serviço') {
                      return const TabServico();
                    } else {
                      return const HomeBank();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label,
      {required bool active, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (active)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                height: 2,
                width: 20,
                color: colorScheme.onPrimary,
              ),
            ),
        ],
      ),
    );
  }

  void _abrirNotificacoes() {
    Get.to(
      () => const NotificacoesPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }
}
