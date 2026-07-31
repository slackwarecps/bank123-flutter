import 'package:get/get.dart';

class HomePixController extends GetxController {
  final numeroVisivel = false.obs;

  final numeroCartao = '5412 •••• •••• 7834'.obs;
  final numeroCompleto = '5412 7790 3312 7834';
  final titular = 'FABIO A PEREIRA'.obs;
  final validade = '09/30'.obs;
  final cvv = '182'.obs;

  void toggleNumeroVisivel() {
    numeroVisivel.value = !numeroVisivel.value;
    numeroCartao.value =
        numeroVisivel.value ? numeroCompleto : '5412 •••• •••• 7834';
  }
}
