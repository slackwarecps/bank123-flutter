import 'package:bank123/controllers/perfil_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Injeta o controller
    final PerfilController controller = Get.put(PerfilController());
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
            const Text('Meu Perfil'),
          ],
        ),
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (controller.email.value.isEmpty && controller.uid.value.isEmpty) {
               return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildInfoCard(context, 'Nome do Usuário', controller.nome.value),
                  _buildInfoCard(context, 'Email (Firebase)', controller.email.value),
                  _buildInfoCard(context, 'UID', controller.uid.value),
                  _buildInfoCard(context, 'Emitido em (iat)', controller.iat.value),
                  _buildInfoCard(context, 'Expira em (exp)', controller.exp.value),
                  _buildInfoCard(context, 'TTL Sessão (App)', controller.ttlSessao.value),
                  _buildInfoCard(context, 'Bank123 Claims', controller.bank123Claims.value),
                  const SizedBox(height: 16),
                  const Text(
                    'Token de Autenticação:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: SelectableText(
                      controller.token.value,
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
                      maxLines: 8,
                      // minLines: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: controller.copiarToken,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar Token'),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
