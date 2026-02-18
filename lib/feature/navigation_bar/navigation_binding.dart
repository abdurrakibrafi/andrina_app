import 'package:chatter_bee/feature/home_screen/home_controller.dart';
import 'package:chatter_bee/feature/navigation_bar/navigation_bar.dart';
import 'package:get/get.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}