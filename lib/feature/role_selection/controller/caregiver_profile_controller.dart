import 'dart:io';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CaregiverProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final ImagePicker _picker = ImagePicker();

  final fullNameController = TextEditingController();
  final selectedLanguage = Rx<String>('English (United States)');
  final isBuddyBeeMode = RxBool(false);
  // FIX: Store API key ('male_adult' etc.) for comparison in grid
  final selectedVoiceType = Rx<String>('male_child');
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final List<String> languages = [
    'English (United States)',
    'English (United Kingdom)',
    'Spanish',
    'French',
    'German',
  ];

  // 'key' = API value, 'type' = display label
  final List<Map<String, dynamic>> voiceTypes = [
    {'type': 'Male Adult',   'key': 'male_adult',   'icon': ImagesLink.adultMale},
    {'type': 'Female Adult', 'key': 'female_adult', 'icon': ImagesLink.adultFemale},
    {'type': 'Male Child',   'key': 'male_child',   'icon': ImagesLink.maleBoy},
    {'type': 'Female Child', 'key': 'female_child', 'icon': ImagesLink.femaleChild},
  ];

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  // ==================== LOAD PROFILE ====================
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final response = await _authRepository.getProfile();
      if (response.isSuccess && response.data != null) {
        final data = response.data!['data'] ?? response.data!;
        fullNameController.text = data['full_name'] ?? '';
        isBuddyBeeMode.value = data['buddy_mode'] ?? false;
        // API returns 'male_adult' etc. → store as-is
        selectedVoiceType.value = data['voice_type'] ?? 'male_child';
      }
    } catch (e) {
      debugPrint('Load caregiver profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBuddyBeeMode(bool value) => isBuddyBeeMode.value = value;
  // FIX: receives API key
  void selectVoiceType(String key) => selectedVoiceType.value = key;
  void selectLanguage(String language) => selectedLanguage.value = language;

  // ==================== PICK IMAGE ====================
  Future<void> pickImage() async {
    try {
      await Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose Profile Picture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async { Get.back(); await _pickFrom(ImageSource.camera); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async { Get.back(); await _pickFrom(ImageSource.gallery); },
              ),
              if (profileImage.value != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () { Get.back(); profileImage.value = null; },
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to open image picker', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _pickFrom(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 75);
      if (image != null) profileImage.value = File(image.path);
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ==================== SAVE PROFILE ====================
  Future<void> onContinue() async {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your full name', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      isSaving.value = true;
      final response = await _authRepository.updateProfile(
        fullName: fullNameController.text.trim(),
        buddyMode: isBuddyBeeMode.value,
        voiceType: selectedVoiceType.value,
        avatar: profileImage.value,
      );
      if (response.isSuccess) {
        Get.snackbar('Success', 'Profile updated successfully!',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFE8F5E9));
        Get.offAllNamed(AppRoutes.NAVIGATIONBAR);
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong. Please try again.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    super.onClose();
  }
}