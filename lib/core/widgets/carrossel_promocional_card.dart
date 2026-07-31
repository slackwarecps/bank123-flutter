import 'package:flutter/material.dart';

class CarrosselPromocionalCard extends StatelessWidget {
  final String tag;
  final String titulo;
  final String cta;
  final VoidCallback? onTap;

  const CarrosselPromocionalCard({
    super.key,
    required this.tag,
    required this.titulo,
    required this.cta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tag,
              style: TextStyle(
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
            Text(
              titulo,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      cta,
                      style: TextStyle(color: colorScheme.onPrimary, fontSize: 13),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.onPrimary, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
