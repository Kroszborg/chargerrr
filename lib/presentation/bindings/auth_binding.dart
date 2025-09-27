import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Auth controller is already created in InitialBinding
    // Just ensure it's available
    if (!Get.isRegistered<AuthController>()) {
      throw Exception('AuthController not found. Make sure InitialBinding is loaded first.');
    }
  }
}