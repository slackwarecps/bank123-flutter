import 'package:bank123/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      onPressed: () => _showEmDesenvolvimento(context, 'Notificações'),
                    ),
                  ],
                ),
              ),
              // Linha de abas (Meu Bank123 ativo, outros placeholders)
              Container(
                color: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildTab(context, 'Meu Bank123', active: true),
                    const SizedBox(width: 24),
                    _buildTab(
                      context,
                      'Bank',
                      active: false,
                      onTap: () => _showEmDesenvolvimento(context, 'Bank'),
                    ),
                    const SizedBox(width: 24),
                    _buildTab(
                      context,
                      'Seguro',
                      active: false,
                      onTap: () => _showEmDesenvolvimento(context, 'Seguro'),
                    ),
                    const SizedBox(width: 24),
                    _buildTab(
                      context,
                      'Serviço',
                      active: false,
                      onTap: () => _showEmDesenvolvimento(context, 'Serviço'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Grid 2x2 de ações rápidas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    _buildQuickAction(
                      context,
                      Icons.pix,
                      'Pix',
                      () => _showEmDesenvolvimento(context, 'Pix'),
                    ),
                    _buildQuickAction(
                      context,
                      Icons.credit_card,
                      'Cartão virtual',
                      () => _showEmDesenvolvimento(context, 'Cartão virtual'),
                    ),
                    _buildQuickAction(
                      context,
                      Icons.lock_outline,
                      'Senha do Cartão',
                      () => _showEmDesenvolvimento(context, 'Senha do Cartão'),
                    ),
                    _buildQuickAction(
                      context,
                      Icons.receipt_long,
                      'Pagar boleto',
                      () => _showEmDesenvolvimento(context, 'Pagar boleto'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Card "Saldo em conta"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Saldo em conta',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            Obx(
                              () => IconButton(
                                icon: Icon(
                                  controller.saldoVisivel.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: controller.toggleSaldoVisivel,
                              ),
                            ),
                          ],
                        ),
                        Obx(
                          () => Text(
                            controller.saldoVisivel.value
                                ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                                    .format(controller.saldo.value)
                                : '••••',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: controller.consultarExtrato,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Ver extrato'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Card "Meu cartão de crédito"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.cartao.value?.descricao ?? 'Carregando...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sua fatura',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    controller.faturaVisivel.value
                                        ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                                            .format(controller.cartao.value?.faturaAtual ?? 0.0)
                                        : 'R\$ ••••',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Obx(
                              () => IconButton(
                                icon: Icon(
                                  controller.faturaVisivel.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                ),
                                onPressed: controller.toggleFaturaVisivel,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Limite disponível',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    controller.faturaVisivel.value
                                        ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                                            .format(controller.cartao.value?.limiteDisponivel ?? 0.0)
                                        : 'R\$ ••••',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => _showEmDesenvolvimento(context, 'Fatura'),
                              child: const Text('Ver fatura'),
                            ),
                            TextButton(
                              onPressed: () => _showEmDesenvolvimento(context, 'Detalhes do cartão'),
                              child: const Text('Ver mais'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // "Você também tem" section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Você também tem',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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

  Widget _buildQuickAction(BuildContext context, IconData icon, String label,
      VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: colorScheme.onSurface),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmDesenvolvimento(BuildContext context, String feature) {
    Get.snackbar(
      'Em desenvolvimento',
      '$feature estará disponível em breve.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
