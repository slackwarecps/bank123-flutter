import 'package:bank123/services/ibff_service.dart';
import 'package:get/get.dart';

class ExtratoController extends GetxController {
  final IBffService _bffService = Get.find<IBffService>();
  var isLoading = false.obs;
  var extratoList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    buscarExtrato();
  }

  Future<void> buscarExtrato() async {
    try {
      isLoading.value = true;
      final lista = await _bffService.getExtrato();
      extratoList.assignAll(lista);
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Não foi possível carregar o extrato: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
