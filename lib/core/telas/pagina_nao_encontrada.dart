import 'package:flutter/material.dart';

class PaginaNaoEncontrada extends StatelessWidget {
  const PaginaNaoEncontrada({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ops! Página não encontrada 404'),
      ),
      body: const Center(
        child: Text('Página não encontrada'),
      ),
    );
  }
}