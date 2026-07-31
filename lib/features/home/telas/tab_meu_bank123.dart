import 'package:bank123/core/widgets/widgets.dart';
import 'package:bank123/features/home/telas/tab_meu_bank123_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TabMeuBank123 extends StatelessWidget {
  const TabMeuBank123({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.put(TabMeuBank123Controller(), tag: 'tabMeuBank123');

    return Obx(() {
      // Estado 1: Loading inicial
      if (controller.isLoading.value && controller.componentes.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        );
      }

      // Estado 2: Erro
      if (controller.temErro.value) {
        final is422 = controller.erroStatusCode.value == 422;
        final iconData = is422 ? Icons.warning_outlined : Icons.error_outline;
        final iconColor = is422 ? Colors.amber : colorScheme.error;

        return RefreshIndicator(
          onRefresh: () => controller.carregarHomeApp(),
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
                        Icon(iconData, size: 80, color: iconColor),
                        const SizedBox(height: 24),
                        Text(
                          controller.erroTitulo.value,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (controller.erroDescricao.value.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            controller.erroDescricao.value,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
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

      // Estado 3: Vazio
      if (controller.componentes.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.carregarHomeApp(),
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.dashboard_customize_outlined,
                        size: 80,
                        color: colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nada por aqui ainda',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Estado 4: Sucesso — renderiza o SDU vindo do BFF
      return RefreshIndicator(
        onRefresh: () => controller.carregarHomeApp(),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          itemCount: controller.componentes.length,
          itemBuilder: (context, index) {
            final componente = controller.componentes[index];
            return _buildComponente(context, controller, componente);
          },
        ),
      );
    });
  }

  Widget _buildComponente(
    BuildContext context,
    TabMeuBank123Controller controller,
    Map<String, dynamic> componente,
  ) {
    switch (componente['tipo']) {
      case 'acoes_rapidas':
        return _buildAcoesRapidas(context, controller, componente);
      case 'banner_destaque':
        return _buildBannerDestaque(context, controller, componente);
      case 'conta_saldo':
        return _buildContaSaldo(context, controller, componente);
      case 'cartao_credito':
        return _buildCartaoCredito(context, controller, componente);
      case 'carrossel_promocional':
        return _buildCarrosselPromocional(context, controller, componente);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAcoesRapidas(
    BuildContext context,
    TabMeuBank123Controller controller,
    Map<String, dynamic> componente,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final itens =
        (componente['itens'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itens.length,
        itemBuilder: (context, index) {
          final item = itens[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap:
                  () =>
                      controller.executarAcao(item['action'] as String? ?? ''),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 84,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconFromName(item['icone'] as String? ?? ''),
                      color: colorScheme.primary,
                      size: 26,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['label'] as String? ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerDestaque(
    BuildContext context,
    TabMeuBank123Controller controller,
    Map<String, dynamic> componente,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: BannerDestaque(
        icone: _getIconFromName(componente['icone'] as String? ?? ''),
        titulo: componente['titulo'] as String? ?? '',
        descricao: componente['descricao'] as String? ?? '',
        onTap:
            () =>
                controller.executarAcao(componente['action'] as String? ?? ''),
      ),
    );
  }

  Widget _buildContaSaldo(
    BuildContext context,
    TabMeuBank123Controller controller,
    Map<String, dynamic> componente,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final valor = (componente['valor'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  componente['titulo'] as String? ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  componente['label'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        controller.saldoVisivel.value
                            ? NumberFormat.currency(
                              locale: 'pt_BR',
                              symbol: 'R\$',
                            ).format(valor)
                            : 'R\$ ••••••',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed:
                          () => controller.executarAcao(
                            componente['action'] as String? ?? '',
                          ),
                      icon: Text(
                        componente['acaoLabel'] as String? ?? 'Acessar',
                      ),
                      label: const Icon(Icons.chevron_right, size: 18),
                      style: TextButton.styleFrom(
                        iconAlignment: IconAlignment.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartaoCredito(
    BuildContext context,
    TabMeuBank123Controller controller,
    Map<String, dynamic> componente,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final fatura = (componente['fatura'] as num?)?.toDouble() ?? 0.0;
    final limite = (componente['limite'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  componente['titulo'] as String? ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.faturaVisivel.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: controller.toggleFaturaVisivel,
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      (componente['bandeira'] as String? ?? '').toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        componente['descricao'] as String? ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            componente['faturaLabel'] as String? ??
                                'Sua fatura',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              controller.faturaVisivel.value
                                  ? NumberFormat.currency(
                                    locale: 'pt_BR',
                                    symbol: 'R\$',
                                  ).format(fatura)
                                  : 'R\$ ••••••',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            componente['limiteLabel'] as String? ??
                                'Limite disponível',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              controller.faturaVisivel.value
                                  ? NumberFormat.currency(
                                    locale: 'pt_BR',
                                    symbol: 'R\$',
                                  ).format(limite)
                                  : 'R\$ ••••••',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed:
                          () => controller.executarAcao(
                            componente['acaoFaturaAction'] as String? ?? '',
                          ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        componente['acaoFaturaLabel'] as String? ??
                            'Ver fatura',
                      ),
                    ),
                    TextButton(
                      onPressed:
                          () => controller.executarAcao(
                            componente['acaoMaisAction'] as String? ?? '',
                          ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        componente['acaoMaisLabel'] as String? ?? 'Ver mais',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrosselPromocional(
    BuildContext context,
    TabMeuBank123Controller controller,
    Map<String, dynamic> componente,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final itens =
        (componente['itens'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();

    if (itens.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              componente['titulo'] as String? ?? '',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 340,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.72),
              itemCount: itens.length,
              onPageChanged:
                  (index) => controller.paginaCarrossel.value = index,
              itemBuilder: (context, index) {
                final item = itens[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: CarrosselPromocionalCard(
                    tag: item['tag'] as String? ?? '',
                    titulo: item['titulo'] as String? ?? '',
                    cta: item['cta'] as String? ?? '',
                    imagemUrl: item['imagem'] as String?,
                    onTap:
                        () => controller.executarAcao(
                          item['action'] as String? ?? '',
                        ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                itens.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        controller.paginaCarrossel.value == index
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    final iconMap = {
      'credit_card': Icons.credit_card_outlined,
      'pix': Icons.pix,
      'payments': Icons.payments_outlined,
      'attach_money': Icons.attach_money,
      'receipt_long': Icons.receipt_long_outlined,
      'account_balance': Icons.account_balance_outlined,
    };
    return iconMap[iconName] ?? Icons.apps_outlined;
  }
}
