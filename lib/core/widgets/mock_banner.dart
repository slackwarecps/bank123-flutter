import 'package:flutter/material.dart';

class MockBanner extends StatelessWidget {
  const MockBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return IgnorePointer(
      child: Positioned(
        top: padding.top,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Center(
            child: Text(
              'MOCK ATIVO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
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
