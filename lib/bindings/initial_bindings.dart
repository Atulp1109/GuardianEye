import 'package:get/get.dart';
import 'package:guardians_eye/authentication/viewmodels/auth_viewmodel.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthViewModel(), permanent: true);
  }
}
