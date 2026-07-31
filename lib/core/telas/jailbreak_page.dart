import 'package:flutter/material.dart';

class JailbreakPage extends StatelessWidget {
  const JailbreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.block,
              color: Colors.red,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "Foi detectado jailbreak",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
