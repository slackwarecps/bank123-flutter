import 'package:bank123/controllers/login_controller.dart';
import 'package:bank123/services/auth_service.dart';
import 'package:bank123/services/firebase_auth_service.dart';
import 'package:bank123/services/mock_auth_service.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
