import 'package:chatter_bee/feature/authentication/controller/signup_controller.dart';
import 'package:get/get.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(() => SignUpController());

    // Alternative options:

    // Put - Creates instance immediately
    // Get.put<SignUpController>(SignUpController());

    // Put Async - For controllers that need async initialization
    // Get.putAsync<SignUpController>(() async => SignUpController());

    // You can also add other dependencies here
    // For example, if you have services or repositories:

    // Get.lazyPut<AuthService>(() => AuthService());
    // Get.lazyPut<UserRepository>(() => UserRepository());
  }
}