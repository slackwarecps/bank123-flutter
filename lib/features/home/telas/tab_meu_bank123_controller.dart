import 'package:bank123/core/services/ibff_service.dart';
import 'package:bank123/features/home/telas/home_pix.dart';
import 'package:bank123/features/transferencia/chaves_pix/chaves_pix_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class TabMeuBank123Controller extends GetxController {
  final _bffService = Get.find<IBffService>();

  final componentes = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final temErro = false.obs;
  final erroTitulo = ''.obs;
  final erroDescricao = ''.obs;
  final erroStatusCode = 0.obs;

  final saldoVisivel = true.obs;
  final faturaVisivel = true.obs;
  final paginaCarrossel = 0.obs;

  @override
  void onInit() {
    super.onInit();
    carregarHomeApp();
  }

  Future<void> carregarHomeApp() async {
    isLoading.value = true;
    temErro.value = false;
    try {
      final response = await _bffService.getHomeApp();
      final data = response as Map<String, dynamic>;
      final lista = (data['componentes'] as List<dynamic>)
          .map((c) => c as Map<String, dynamic>)
          .toList();
      componentes.assignAll(lista);
    } on DioException catch (e) {
      _tratarErro(e);
    } catch (e) {
      debugPrint('Erro ao carregar Meu Bank123: $e');
      temErro.value = true;
      erroTitulo.value = 'Erro ao carregar';
      erroDescricao.value = 'Ocorreu um erro inesperado.';
      erroStatusCode.value = 500;
    } finally {
      isLoading.value = false;
    }
  }

  void _tratarErro(DioException e) {
    temErro.value = true;
    final statusCode = e.response?.statusCode ?? 500;
    erroStatusCode.value = statusCode;

    if (statusCode == 422) {
      final data = e.response?.data as Map<String, dynamic>?;
      erroTitulo.value = data?['titulo'] ?? 'Serviço não disponível';
      erroDescricao.value = data?['descricao'] ?? 'Procure o SAC';
    } else {
      erroTitulo.value = 'Erro ao carregar';
      erroDescricao.value = 'Ocorreu um erro no servidor. Tente novamente.';
    }
  }

  void toggleSaldoVisivel() => saldoVisivel.value = !saldoVisivel.value;

  void toggleFaturaVisivel() => faturaVisivel.value = !faturaVisivel.value;

  void executarAcao(String action) {
    switch (action) {
      case 'CARTAO_VIRTUAL':
        Get.to(() => const HomePix());
        break;
      case 'PIX':
        Get.to(() => const ChavesPixPage());
        break;
      case 'EXTRATO':
        Get.toNamed('/extrato');
        break;
      default:
        Get.snackbar(
          'Em desenvolvimento',
          'Esta ação estará disponível em breve.',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }
}
