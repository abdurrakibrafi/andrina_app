import 'package:chatter_bee/feature/home_screen/communicator_home_controller.dart';
import 'package:get/get.dart';

class CommunicatorHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunicatorHomeController> (() => CommunicatorHomeController(),
    );
  }

}