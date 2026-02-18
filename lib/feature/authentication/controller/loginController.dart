import 'package:chatter_bee/feature/authentication/repo/auth_repository.dart';
//import 'package:chatter_bee/feature/authentication/repository/auth_repository.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Text editing controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable variables
  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;

  // Focus nodes
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    emailController.text = '';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle remember me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // Validate email
  bool validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = 'Email is required';
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      emailError.value = 'Please enter a valid email';
      return false;
    }
    emailError.value = '';
    return true;
  }

  // Validate password
  bool validatePassword() {
    final password = passwordController.text;
    if (password.isEmpty) {
      passwordError.value = 'Password is required';
      return false;
    }
    if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      return false;
    }
    passwordError.value = '';
    return true;
  }

  // Validate all fields
  bool validateForm() {
    final emailValid = validateEmail();
    final passwordValid = validatePassword();
    return emailValid && passwordValid;
  }

  // Sign in method with role-based navigation
  Future<void> signIn() async {
    if (!validateForm()) {
      return;
    }

    try {
      isLoading.value = true;

      // Call login API
      final response = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.isSuccess && response.data != null) {
        final userData = response.data!.user;

        // Show success message
        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Navigate based on role
        _navigateBasedOnRole(userData.getRoleSafe());
      } else {
        // Handle specific error codes
        if (response.statusCode == 403) {
          // 403 means email not verified or account disabled
          Get.snackbar(
            'Email Not Verified',
            'Please verify your email before logging in. Check your inbox for verification code.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );

          // Optionally navigate to verification screen
          // Get.toNamed(
          //   AppRoutes.VERIFICATIONSCREEN,
          //   arguments: {'email': emailController.text.trim()},
          // );
        } else {
          // Other errors
          Get.snackbar(
            'Login Failed',
            response.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate based on user role
  void _navigateBasedOnRole(String role) {
    switch (role.toLowerCase()) {
      case 'communicator':
      // Navigate to Communicator Profile Screen
        Get.offAllNamed(AppRoutes.COMMUNICATORPROFILE);
        break;

      case 'caregiver':
      // Navigate to Caregiver Profile Screen
        Get.offAllNamed(AppRoutes.CAREGIVERPROFILE);
        break;

      default:
      // If role is unknown or null, navigate to a default screen or role selection
        Get.snackbar(
          'Role Not Found',
          'User role not set. Please contact support.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Fallback: Navigate to a default screen or role selection
        // Get.offAllNamed(AppRoutes.ROLESELECTION);
        // OR
        Get.offAllNamed(AppRoutes.NAVIGATIONBAR);
        break;
    }
  }

  // Forgot password method
  void forgotPassword() {
    Get.toNamed(AppRoutes.FORGOTSCREEN);
  }

  // Sign up navigation - GO TO ROLE SELECTION
  void goToSignUp() {
    Get.toNamed(AppRoutes.ROLESELECTION);
  }

  // Clear form
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    emailError.value = '';
    passwordError.value = '';
    rememberMe.value = false;
  }
}