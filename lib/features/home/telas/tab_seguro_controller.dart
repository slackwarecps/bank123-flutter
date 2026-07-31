import 'package:bank123/core/services/ibff_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CardSeguro {
  final String id;
  final String titulo;
  final String descricao;
  final String icone;
  final String link;

  CardSeguro({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.link,
  });

  factory CardSeguro.fromJson(Map<String, dynamic> json) {
    return CardSeguro(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      icone: json['icone'] as String,
      link: json['link'] as String,
    );
  }
}

class TabSeguroController extends GetxController {
  final _bffService = Get.find<IBffService>();
  final cardsSeguro = <CardSeguro>[].obs;
  final isLoading = false.obs;
  final temErro = false.obs;
  final erroTitulo = ''.obs;
  final erroDescricao = ''.obs;
  final erroStatusCode = 0.obs;

  @override
  void onInit() {
    super.onInit();
    carregarSeguros();
  }

  Future<void> carregarSeguros() async {
    isLoading.value = true;
    temErro.value = false;
    try {
      final response = await _bffService.getSeguroHome();
      final data = response as Map<String, dynamic>;
      final cards = (data['cards'] as List<dynamic>)
          .map((card) => CardSeguro.fromJson(card as Map<String, dynamic>))
          .toList();
      cardsSeguro.assignAll(cards);
    } catch (e) {
      debugPrint('Erro ao carregar seguros: $e');
      temErro.value = true;
      erroTitulo.value = 'Erro ao carregar';
      erroDescricao.value = 'Não foi possível carregar os seguros. Tente novamente.';
      erroStatusCode.value = 500;
    } finally {
      isLoading.value = false;
    }
  }
}
