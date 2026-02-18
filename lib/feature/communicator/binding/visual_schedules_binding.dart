import 'package:chatter_bee/feature/communicator/controller/visual_schedules_controller.dart';
import 'package:get/get.dart';

class VisualSchedulesBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put instead of Get.lazyPut to keep the controller alive
    Get.put<VisualSchedulesController>(
      VisualSchedulesController(),
      permanent: false, // Will be removed when the route is disposed
    );
  }
}