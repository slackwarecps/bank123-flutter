import 'package:flutter/material.dart';

class MockBanner extends StatelessWidget {
  const MockBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: padding.top + 4,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'MOCK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
