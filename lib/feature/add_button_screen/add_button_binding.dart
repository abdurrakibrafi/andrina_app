import 'package:chatter_bee/feature/add_button_screen/add_button_controller.dart';
import 'package:get/get.dart';

class AddButtonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddButtonController>(() => AddButtonController());
  }
}