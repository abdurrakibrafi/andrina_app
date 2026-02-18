
import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  late TextEditingController emailController;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Email validation
  String? _emailError;
  String? get emailError => _emailError;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  // Email validation method
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  // Validate email input
  bool validateEmail() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _emailError = 'Email is required';
      update();
      return false;
    }

    if (!_isValidEmail(email)) {
      _emailError = 'Please enter a valid email address';
      update();
      return false;
    }

    _emailError = null;
    update();
    return true;
  }

  // Clear email error when user starts typing
  void clearEmailError() {
    if (_emailError != null) {
      _emailError = null;
      update();
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    update();
  }

  // Send reset password email
  Future<void> sendResetPasswordEmail() async {
    // Validate email first
    if (!validateEmail()) {
      return;
    }

    try {
      _setLoading(true);

      // Call forgot password API
      final response = await _authRepository.forgotPasswordRequest(
        email: emailController.text.trim(),
      );

      if (response.isSuccess) {
        // Show success message
        Get.snackbar(
          'Success',
          'Password reset code sent to your email',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Navigate to verification screen
        Get.toNamed(
          AppRoutes.FORGOTOTPSCREEN,
          arguments: {
            'email': emailController.text.trim(),
          },
        );
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reset email. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _setLoading(false);
    }
  }

  // Method to be called when email field changes
  void onEmailChanged(String value) {
    clearEmailError();
  }
}