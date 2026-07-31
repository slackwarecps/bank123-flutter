import 'package:bank123/core/services/ibff_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ChavePix {
  final String id;
  final String tipo;
  final String chave;
  final DateTime dataCriacao;

  ChavePix({
    required this.id,
    required this.tipo,
    required this.chave,
    required this.dataCriacao,
  });

  factory ChavePix.fromJson(Map<String, dynamic> json) {
    return ChavePix(
      id: json['id'] as String,
      tipo: json['tipo'] as String,
      chave: json['chave'] as String,
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
    );
  }
}

class ChavePixController extends GetxController {
  final _bffService = Get.find<IBffService>();
  final chavesPix = <ChavePix>[].obs;
  final isLoading = false.obs;
  final temErro = false.obs;
  final erroTitulo = ''.obs;
  final erroDescricao = ''.obs;
  final erroStatusCode = 0.obs;

  @override
  void onInit() {
    super.onInit();
    carregarChaves();
  }

  Future<void> carregarChaves() async {
    isLoading.value = true;
    temErro.value = false;
    try {
      final response = await _bffService.getChavesPix();
      final chaves = response
          .map((chave) => ChavePix.fromJson(chave as Map<String, dynamic>))
          .toList();
      chavesPix.assignAll(chaves);
    } on DioException catch (e) {
      _tratarErro(e);
    } catch (e) {
      debugPrint('Erro ao carregar chaves: $e');
      temErro.value = true;
      erroTitulo.value = 'Erro ao carregar';
      erroDescricao.value = 'Ocorreu um erro inesperado. Tente novamente.';
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
      erroTitulo.value = 'Erro ao carregar chaves';
      erroDescricao.value = 'Ocorreu um erro no servidor. Tente novamente.';
    }
  }

  void adicionarNovaChave() {
    Get.snackbar('Nova Chave', 'Funcionalidade de adicionar chave');
  }
}
