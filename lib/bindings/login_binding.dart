import 'package:bank123/controllers/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    print('[LoginBinding] Creating LoginController immediately with Get.put()');
    Get.put<LoginController>(LoginController());
  }
}
