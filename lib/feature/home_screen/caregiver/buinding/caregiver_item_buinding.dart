import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_item_controller.dart';
import 'package:get/get.dart';

class CaregiverItemBuinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CaregiverItemController>(() => CaregiverItemController());
  }
}
