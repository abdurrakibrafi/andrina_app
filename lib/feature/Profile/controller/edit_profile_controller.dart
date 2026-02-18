import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController {
  final fullNameController = TextEditingController();

  final selectedLanguage = Rx<String>('English (United States)');
  final isBuddyBeeMode = RxBool(true);
  final selectedVoiceType = Rx<String>('Male Child');

  final List<String> languages = [
    'English (United States)',
    'English (United Kingdom)',
    'Spanish',
    'French',
    'German',
  ];

  // Changed: Store icon paths as strings instead of SvgPicture widgets
  final List<Map<String, dynamic>> voiceTypes = [
    {'type': 'Male Adult', 'icon': ImagesLink.adultMale},
    {'type': 'Female Adult', 'icon': ImagesLink.adultFemale},
    {'type': 'Male Child', 'icon': ImagesLink.maleBoy},
    {'type': 'Female Child', 'icon': ImagesLink.femaleChild},
  ];

  void toggleBuddyBeeMode(bool value) {
    isBuddyBeeMode.value = value;
  }

  void selectVoiceType(String type) {
    selectedVoiceType.value = type;
  }

  void selectLanguage(String language) {
    selectedLanguage.value = language;
  }

  void onContinue() {
    if (fullNameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your full name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Navigate to next screen or save data
    Get.snackbar(
      'Success',
      'Profile setup completed!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.2),
    );

    //Get.offAllNamed(AppRoutes.NAVIGATIONBAR);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    super.onClose();
  }
}