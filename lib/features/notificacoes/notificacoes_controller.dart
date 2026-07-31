import 'package:bank123/core/services/ibff_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class Notificacao {
  final String id;
  final String titulo;
  final String mensagem;
  final DateTime data;
  final bool lida;
  final String? icone;

  Notificacao({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.data,
    required this.lida,
    this.icone,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      mensagem: json['mensagem'] as String,
      data: DateTime.parse(json['data'] as String),
      lida: json['lida'] as bool? ?? false,
      icone: json['icone'] as String?,
    );
  }
}

class NotificacoesController extends GetxController {
  final _bffService = Get.find<IBffService>();
  final notificacoes = <Notificacao>[].obs;
  final isLoading = false.obs;
  final temErro = false.obs;
  final erroTitulo = ''.obs;
  final erroDescricao = ''.obs;
  final erroStatusCode = 0.obs;

  @override
  void onInit() {
    super.onInit();
    carregarNotificacoes();
  }

  Future<void> carregarNotificacoes() async {
    isLoading.value = true;
    temErro.value = false;
    try {
      final response = await _bffService.getNotificacoes();
      final data = response as Map<String, dynamic>;
      final noticias = (data['notificacoes'] as List<dynamic>)
          .map((notif) => Notificacao.fromJson(notif as Map<String, dynamic>))
          .toList();
      notificacoes.assignAll(noticias);
    } on DioException catch (e) {
      _tratarErro(e);
    } catch (e) {
      debugPrint('Erro ao carregar notificações: $e');
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
      erroTitulo.value = 'Erro ao carregar notificações';
      erroDescricao.value = 'Ocorreu um erro no servidor. Tente novamente.';
    }
  }

  void marcarComoLida(String notificacaoId) {
    final index = notificacoes.indexWhere((n) => n.id == notificacaoId);
    if (index == -1) return;

    final notif = notificacoes[index];
    final notifAnterior = notif;

    // 1. Atualiza local IMEDIATAMENTE (Optimistic Update)
    notificacoes[index] = Notificacao(
      id: notif.id,
      titulo: notif.titulo,
      mensagem: notif.mensagem,
      data: notif.data,
      lida: true,
      icone: notif.icone,
    );

    // 2. Sincroniza no background
    _bffService.marcarNotificacaoComoLida(notificacaoId).then((_) {
      debugPrint('✅ Notificação sincronizada com sucesso');
    }).catchError((e) {
      debugPrint('❌ Erro ao sincronizar: $e');
      // 3. Se falhar, desfaz a mudança local
      notificacoes[index] = notifAnterior;
      Get.snackbar(
        'Erro',
        'Falha ao sincronizar notificação',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  Future<void> marcarMultiplasComoLidas(List<String> ids) async {
    // Backup dos dados atuais
    final backupNotificacoes = List<Notificacao>.from(notificacoes);

    // Atualiza local
    for (var i = 0; i < notificacoes.length; i++) {
      if (ids.contains(notificacoes[i].id)) {
        final notif = notificacoes[i];
        notificacoes[i] = Notificacao(
          id: notif.id,
          titulo: notif.titulo,
          mensagem: notif.mensagem,
          data: notif.data,
          lida: true,
          icone: notif.icone,
        );
      }
    }

    try {
      // Sincroniza no servidor
      await _bffService.marcarMultiplasNotificacoesComoLidas(ids);
      debugPrint('✅ Múltiplas notificações sincronizadas');
    } catch (e) {
      debugPrint('❌ Erro ao sincronizar múltiplas: $e');
      // Desfaz se falhar
      notificacoes.assignAll(backupNotificacoes);
      Get.snackbar(
        'Erro',
        'Falha ao sincronizar notificações',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  int get naoLidas => notificacoes.where((n) => !n.lida).length;
}
