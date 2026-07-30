import 'package:bank123/services/auth_service.dart';
import 'package:bank123/services/firebase_auth_service.dart';
import 'package:bank123/services/mock_auth_service.dart';
import 'package:bank123/services/basic_auth_service.dart';
import 'package:bank123/services/ibff_service.dart';
import 'package:bank123/services/bff_service.dart';
import 'package:bank123/services/mock_bff_service.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    const authMode = String.fromEnvironment('AUTH_MODE', defaultValue: 'firebase');
    const isMock = String.fromEnvironment('USE_MOCK') == 'true';

    if (authMode == 'basic') {
      Get.put<IAuthService>(BasicAuthService(), permanent: true);
      Get.put<IBffService>(HttpBffService(), permanent: true);
    } else if (isMock) {
      Get.put<IAuthService>(MockAuthService(), permanent: true);
      Get.put<IBffService>(MockBffService(), permanent: true);
    } else {
      Get.put<IAuthService>(FirebaseAuthService(), permanent: true);
      Get.put<IBffService>(HttpBffService(), permanent: true);
    }
  }
}
