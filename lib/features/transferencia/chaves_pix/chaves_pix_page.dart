import 'package:bank123/core/widgets/widgets.dart';
import 'package:bank123/features/transferencia/chaves_pix/chaves_pix_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChavesPixPage extends StatelessWidget {
  const ChavesPixPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.put(ChavePixController());

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
            const Text('Minhas Chaves'),
          ],
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                if (controller.isLoading.value && controller.chavesPix.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
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
                    onRefresh: () => controller.carregarChaves(),
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

                if (controller.chavesPix.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => controller.carregarChaves(),
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.vpn_key_outlined,
                                  size: 64,
                                  color: colorScheme.outlineVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma chave cadastrada',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurfaceVariant,
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
                  onRefresh: () => controller.carregarChaves(),
                  child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.chavesPix.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final chave = controller.chavesPix[index];
                              final dataFormatada = DateFormat('dd/MM/yyyy')
                                  .format(chave.dataCriacao);

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    _getIconForTipo(chave.tipo),
                                    color: colorScheme.primary,
                                  ),
                                  title: Text(
                                    chave.tipo,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        chave.chave,
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Criada em $dataFormatada',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.outlineVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                              );
                            },
                          ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: 'Cadastrar Chave',
              onPressed: () => controller.adicionarNovaChave(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'E-mail':
        return Icons.email_outlined;
      case 'CPF':
        return Icons.person_outlined;
      case 'Telefone':
        return Icons.phone_outlined;
      case 'Chave Aleatória':
      default:
        return Icons.vpn_key_outlined;
    }
  }
}
