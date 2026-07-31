import 'package:bank123/features/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

class TabServico extends StatelessWidget {
  const TabServico({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final HomeController controller = Get.find<HomeController>();

    return Obx(
      () {
        developer.log(
          'TabServico: loading=${controller.carregandoServico.value}, erro=${controller.erroServico.value}, titulo=${controller.erroTituloServico.value}',
          name: 'TabServico',
        );

        if (controller.carregandoServico.value) {
          return Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
            ),
          );
        }

        if (controller.erroServico.value) {
          final titulo = controller.erroTituloServico.value.isNotEmpty
              ? controller.erroTituloServico.value
              : 'Acabou o leite, sorry 🥛';
          final descricao = controller.erroDescricaoServico.value;
          final statusCode = controller.erroStatusCode.value;

          final is422 = statusCode == 422;
          final iconData = is422 ? Icons.warning_outlined : Icons.error_outline;
          final iconColor = is422 ? Colors.amber : colorScheme.error;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    size: 80,
                    color: iconColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (descricao.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      descricao,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        final componentes = controller.componentesServico.value;
        if (componentes == null || componentes['buttons'] == null) {
          return const SizedBox.shrink();
        }

        final buttons = componentes['buttons'] as List<dynamic>;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: buttons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final button = buttons[index] as Map<String, dynamic>;
              return _buildBotaoServico(
                context,
                button['icon'] as String? ?? 'help',
                button['label'] as String? ?? 'Serviço',
                button['action'] as String? ?? '',
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBotaoServico(
    BuildContext context,
    String iconName,
    String label,
    String action,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = _getIconFromName(iconName);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _executarAcao(action),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      action,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    final iconMap = {
      'receipt_long': Icons.receipt_long,
      'history': Icons.history,
      'download': Icons.download,
      'help': Icons.help_outline,
      'payment': Icons.payment,
      'account_balance': Icons.account_balance,
      'credit_card': Icons.credit_card,
    };
    return iconMap[iconName] ?? Icons.help_outline;
  }

  void _executarAcao(String action) {
    Get.snackbar(
      'Ação: $action',
      'Esta ação será implementada em breve.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
