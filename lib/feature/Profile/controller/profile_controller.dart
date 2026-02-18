import 'dart:io';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Observable variables
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString selectedRole = 'Communicator'.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userType = ''.obs;
  final RxString voiceType = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxBool isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  // ==================== LOAD PROFILE FROM API ====================
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final response = await _authRepository.getProfile();

      if (response.isSuccess && response.data != null) {
        // API returns: { "success": true, "data": { ... } }
        final profileData = response.data!['data'] ?? response.data!;

        userName.value = profileData['full_name'] ?? '';
        userEmail.value = profileData['email'] ?? '';
        userType.value = profileData['profile_type'] ?? '';
        voiceType.value = profileData['voice_type'] ?? '';
        avatarUrl.value = profileData['avatar'] ?? '';

        final role = profileData['role'] ?? '';
        selectedRole.value = _capitalizeRole(role);
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  String _capitalizeRole(String role) {
    if (role.isEmpty) return 'Communicator';
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  // ==================== PICK PROFILE IMAGE ====================
  Future<void> pickImage() async {
    try {
      await Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
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
                onTap: () async {
                  Get.back();
                  await _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Get.back();
                  await _pickImageFromSource(ImageSource.gallery);
                },
              ),
              if (profileImage.value != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Get.back();
                    removeProfileImage();
                  },
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to open image picker', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image != null) {
        profileImage.value = File(image.path);
        // Upload avatar immediately
        await _uploadAvatar(File(image.path));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _uploadAvatar(File file) async {
    try {
      final response = await _authRepository.updateProfile(avatar: file);
      if (response.isSuccess) {
        Get.snackbar('Success', 'Profile picture updated', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload picture', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeProfileImage() {
    profileImage.value = null;
    Get.snackbar('Success', 'Profile picture removed', snackPosition: SnackPosition.BOTTOM);
  }



  // ==================== NAVIGATION ====================
  void onSubscriptionTap() => Get.toNamed(AppRoutes.SUBSCRIPTION);

  /// Navigate to the correct profile edit screen based on current user role
  void onEditPersonalInfo() {
    final role = selectedRole.value.toLowerCase();
    if (role == 'caregiver') {
      Get.toNamed(AppRoutes.CAREGIVERPROFILE);
    } else {
      Get.toNamed(AppRoutes.COMMUNICATORPROFILE);
    }
  }

  void onLanguageTap() => Get.toNamed(AppRoutes.LANGUAGESCREEN);
  void onChangePasswordTap() => Get.toNamed(AppRoutes.CHANGEPASSWORD);
  void onPrivacyPolicyTap() => Get.toNamed(AppRoutes.PRIVACYPOLICY);
  void onSupportTap() => Get.toNamed(AppRoutes.SUPPORT);

  // ==================== DELETE ACCOUNT ====================
  void onDeleteAccountTap() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Delete',
                style: GoogleFonts.nunito(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor)),
            const SizedBox(height: 24),
            Text('Are you sure you want\nto Delete ?',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                    height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: AppColors.primaryColor, width: 1.5),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor)),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      deleteAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Yes, Delete',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2D2D))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  // ==================== LOGOUT ====================
  void onLogoutTap() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Logout',
                style: GoogleFonts.nunito(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor)),
            const SizedBox(height: 24),
            Text('Are you sure you want\nto log out?',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                    height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: AppColors.primaryColor, width: 1.5),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor)),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      logout();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Yes, Logout',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  // ==================== API: DELETE ACCOUNT ====================
  Future<void> deleteAccount() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final response = await _authRepository.deleteAccount();

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.isSuccess) {
        Get.snackbar('Success', 'Account deleted successfully',
            snackPosition: SnackPosition.BOTTOM);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.SIGNINSCREEN);
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Failed to delete account. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ==================== API: LOGOUT ====================
  Future<void> logout() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final response = await _authRepository.logout();

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.isSuccess) {
        Get.snackbar('Success', 'Logged out successfully',
            snackPosition: SnackPosition.BOTTOM);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.SIGNINSCREEN);
      } else {
        // Even on API error, storage is cleared — go to login
        Get.offAllNamed(AppRoutes.SIGNINSCREEN);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(AppRoutes.SIGNINSCREEN);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}