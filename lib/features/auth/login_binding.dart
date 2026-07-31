import 'package:bank123/features/auth/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    print('[LoginBinding] Creating LoginController immediately with Get.put()');
    Get.put<LoginController>(LoginController(), force: true);
  }
}
