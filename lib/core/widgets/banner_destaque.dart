import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerDestaque extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final VoidCallback? onTap;

  const BannerDestaque({
    super.key,
    required this.icone,
    required this.titulo,
    required this.descricao,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Get.snackbar(
          '',
          'Clicou me!',
          snackPosition: SnackPosition.BOTTOM,
        );
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                icone,
                color: colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                  children: [
                    TextSpan(
                      text: '$titulo ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: descricao),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: colorScheme.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
