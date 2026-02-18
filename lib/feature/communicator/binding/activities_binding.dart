import 'package:chatter_bee/feature/communicator/controller/activities_controller.dart';
import 'package:get/get.dart';

class ActivitiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivitiesController>(
          () => ActivitiesController(),
    );
  }
}