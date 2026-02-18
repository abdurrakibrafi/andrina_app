import 'package:chatter_bee/feature/edit_button_screen/edit_button_controller.dart';
import 'package:get/get.dart';

class EditButtonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditButtonController>(() => EditButtonController());
  }
}