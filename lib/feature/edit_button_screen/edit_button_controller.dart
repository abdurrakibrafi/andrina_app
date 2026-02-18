import 'package:chatter_bee/feature/home_screen/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditButtonController extends GetxController {
  // Text Controllers
  final wordController = TextEditingController();
  final speakAsController = TextEditingController();

  // Observable Variables
  var selectedColor = const Color(0xFFB5CFD1).obs;
  var selectedImagePath = ''.obs;

  // Available Colors
  final List<Color> availableColors = [
    const Color(0xFFB5CFD1), // Light Blue
    const Color(0xFFFFC107), // Yellow
    const Color(0xFFE91E63), // Pink
    const Color(0xFF4CAF50), // Green
  ];

  // Item Data
  CategoryItemModel? itemData;
  String? itemId;

  @override
  void onInit() {
    super.onInit();

    // Get item data from arguments
    if (Get.arguments != null && Get.arguments is CategoryItemModel) {
      itemData = Get.arguments as CategoryItemModel;
      _loadItemData();
    }
  }

  // Load Item Data
  void _loadItemData() {
    if (itemData != null) {
      itemId = itemData!.id;
      wordController.text = itemData!.label;
      speakAsController.text = itemData!.label;
      selectedImagePath.value = itemData!.imagePath;

      // Log for debugging
      print('Editing item: ${itemData!.label} (ID: ${itemData!.id})');
    }
  }

  // Select Color
  void selectColor(Color color) {
    selectedColor.value = color;
  }

  // Pick Image
  void pickImage() {
    // TODO: Implement image picker
    Get.snackbar('Image Picker', 'Image picker functionality');
  }

  // Audio Controls
  void playAudio() {
    Get.snackbar('Audio', 'Play audio');
  }

  void recordAudio() {
    _showAudioNote();
  }

  void deleteAudio() {
    Get.snackbar('Audio', 'Delete audio');
  }

  void uploadAudio() {
    _showAudioNote();
  }

  // Show Audio Note Dialog
  void _showAudioNote() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.note_alt,
                  size: 40,
                  color: Color(0xFFFFC107),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Note!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please note that ChatterBee\ncurrently supports audio\nformats.mp3 and .wav only',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Save Button
  void saveButton() {
    if (wordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a word',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // TODO: Update button logic - এখানে API call বা local storage update করতে পারেন

    Get.snackbar(
      'Success',
      'Button "${wordController.text}" updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );

    // Go back to home screen
    Get.back();
  }

  @override
  void onClose() {
    wordController.dispose();
    speakAsController.dispose();
    super.onClose();
  }
}