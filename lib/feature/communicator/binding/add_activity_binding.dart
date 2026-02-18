import 'package:chatter_bee/feature/communicator/controller/add_activity_controller.dart';
import 'package:get/get.dart';

class AddActivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddActivityController>(
          () => AddActivityController(),
    );
  }
}