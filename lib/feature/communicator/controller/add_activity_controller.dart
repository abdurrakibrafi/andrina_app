import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddActivityController extends GetxController {
  final TextEditingController activityNameController = TextEditingController();
  var selectedTime = 'Select Time'.obs;
  var selectedImagePath = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    print('🟢 AddActivityController initialized');
    // Set current time as default
    final now = TimeOfDay.now();
    selectedTime.value = now.format(Get.context!);
  }

  Future<void> selectTime(BuildContext context) async {
    print('⏰ Opening time picker...');
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFD166),
              onPrimary: Colors.black87,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedTime = picked.format(context);
      selectedTime.value = formattedTime;
      print('⏰ Time selected: $formattedTime');
    } else {
      print('⏰ Time picker cancelled');
    }
  }

  Future<void> pickImage() async {
    print('📸 Opening image picker...');
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImagePath.value = image.path;
        print('📸 Image selected: ${image.path}');
        Get.snackbar(
          'Success',
          'Image selected successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        print('📸 Image picker cancelled');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void saveActivity() {
    print('💾 Save button pressed');
    print('📝 Activity Name: ${activityNameController.text.trim()}');
    print('⏰ Time: ${selectedTime.value}');
    print('📸 Image Path: ${selectedImagePath.value}');

    // Validate inputs
    if (activityNameController.text.trim().isEmpty) {
      print('❌ Validation failed: Activity name is empty');
      Get.snackbar(
        'Error',
        'Please enter activity name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (selectedImagePath.value.isEmpty) {
      print('❌ Validation failed: Image path is empty');
      Get.snackbar(
        'Error',
        'Please upload an image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    print('✅ Validation passed');

    // Prepare activity data
    final activityData = {
      'name': activityNameController.text.trim(),
      'time': selectedTime.value,
      'imagePath': selectedImagePath.value,
    };

    print('📦 Activity data prepared: $activityData');
    print('📦 Data type: ${activityData.runtimeType}');

    // IMPORTANT: Navigate back with result IMMEDIATELY
    // Don't show snackbar before navigation - it interferes with Get.back()
    print('🔙 Calling Get.back() with result...');
    Get.back(result: activityData);

    print('✅ Get.back() called - screen should close now');
  }

  void _resetForm() {
    print('🔄 Resetting form...');
    activityNameController.clear();
    selectedImagePath.value = '';
    final now = TimeOfDay.now();
    selectedTime.value = now.format(Get.context!);
  }

  @override
  void onClose() {
    print('🔴 AddActivityController disposed');
    activityNameController.dispose();
    super.onClose();
  }
}