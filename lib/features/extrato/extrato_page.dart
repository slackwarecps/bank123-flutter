import 'package:bank123/features/extrato/extrato_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExtratoPage extends StatelessWidget {
  const ExtratoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ExtratoController controller = Get.put(ExtratoController());
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
            const Text('Extrato'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Obx(() {
        // Mostra loading central apenas se estiver carregando E a lista estiver vazia (primeira carga)
        if (controller.isLoading.value && controller.extratoList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.buscarExtrato,
          child: controller.extratoList.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    const Center(
                      child: Text(
                        'Não existem registros no extrato!',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.extratoList.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = controller.extratoList[index];
                    final valor = item['valorTransacao'];
                    final valorFormatado = NumberFormat.currency(
                      locale: 'pt_BR',
                      symbol: 'R\$',
                    ).format(valor);
                    
                    String dataFormatada = '';
                    if (item['dataTransacao'] != null) {
                        try {
                            final data = DateTime.parse(item['dataTransacao']);
                            dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(data);
                        } catch(e) {
                            dataFormatada = item['dataTransacao'].toString();
                        }
                    }
                    
                    final operacao = item['operacao'];
                    // Ajustar lógica de entrada/saída conforme sua regra de negócio ou retorno da API
                    final isSaida = operacao == 'SAIDA' || operacao == 'TRANSFERENCIA_SAIDA'; 
                    
                    final color = isSaida ? Colors.red : Colors.green;
                    final icon = isSaida ? Icons.arrow_circle_up : Icons.arrow_circle_down;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color),
                      ),
                      title: Text(
                        'Conta Destino: ${item['destino'] ?? 'Não informada'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Valor: $valorFormatado', style: TextStyle(color: color, fontWeight: FontWeight.w500)),
                          Text('Data: $dataFormatada'),
                        ],
                      ),
                    );
                  },
                ),
        );
      }),
    );
  }
}