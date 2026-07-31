import 'package:bank123/features/notificacoes/notificacoes_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.put(NotificacoesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value && controller.notificacoes.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            );
          }

          if (controller.temErro.value) {
            final titulo = controller.erroTitulo.value;
            final descricao = controller.erroDescricao.value;
            final statusCode = controller.erroStatusCode.value;
            final is422 = statusCode == 422;
            final iconData = is422 ? Icons.warning_outlined : Icons.error_outline;
            final iconColor = is422 ? Colors.amber : colorScheme.error;

            return RefreshIndicator(
              onRefresh: () => controller.carregarNotificacoes(),
              child: ListView(
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
                    ),
                  ),
                ],
              ),
            );
          }

          if (controller.notificacoes.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => controller.carregarNotificacoes(),
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma notificação',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.carregarNotificacoes(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.notificacoes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = controller.notificacoes[index];
                return _buildNotificacaoCard(context, notif, colorScheme, controller);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificacaoCard(
    BuildContext context,
    Notificacao notif,
    ColorScheme colorScheme,
    NotificacoesController controller,
  ) {
    final dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(notif.data);

    return GestureDetector(
      onTap: () => controller.marcarComoLida(notif.id),
      child: Container(
        decoration: BoxDecoration(
          color: notif.lida
              ? colorScheme.surface
              : colorScheme.primary.withValues(alpha: 0.1),
          border: Border.all(
            color: notif.lida ? colorScheme.outlineVariant : colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconFromName(notif.icone),
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif.titulo,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notif.lida)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.mensagem,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dataFormatada,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.outlineVariant,
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
    );
  }

  IconData _getIconFromName(String? iconName) {
    final iconMap = {
      'info': Icons.info_outlined,
      'warning': Icons.warning_outlined,
      'success': Icons.check_circle_outlined,
      'error': Icons.error_outline,
      'transfer': Icons.swap_horiz,
      'payment': Icons.payment,
      'security': Icons.security,
      'notification': Icons.notifications_outlined,
    };
    return iconMap[iconName] ?? Icons.notifications_outlined;
  }
}
