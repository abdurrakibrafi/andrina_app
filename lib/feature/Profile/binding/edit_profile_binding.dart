import 'package:chatter_bee/feature/Profile/controller/edit_profile_controller.dart';
import 'package:get/get.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController> (() => EditProfileController(),);
  }

}