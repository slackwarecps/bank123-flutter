import 'package:flutter/material.dart';

class MockBanner extends StatelessWidget {
  const MockBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return IgnorePointer(
      child: Positioned(
        top: padding.top + 8,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'MOCK ATIVO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
