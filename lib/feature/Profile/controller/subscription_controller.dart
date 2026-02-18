import 'package:chatter_bee/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionController extends GetxController {
  // Observable for selected plan
  var selectedPlan = 'free'.obs;

  // Observable for selected payment method
  var selectedPaymentMethod = ''.obs;

  // Plan prices
  final double freePlanPrice = 0.00;
  final double proPlanPrice = 2.99;

  // Payment methods list
  final List<Map<String, String>> paymentMethods = [
    {
      'type': 'card',
      'number': '**** **** **** 0561',
      'icon': 'mastercard', // You can use your own icon
    },
    {
      'type': 'card',
      'number': '**** **** **** 1234',
      'icon': 'visa',
    },
  ];

  // Method to select a plan
  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  // Method to check if a plan is selected
  bool isPlanSelected(String plan) {
    return selectedPlan.value == plan;
  }

  // Method to get current plan price
  double getCurrentPlanPrice() {
    return selectedPlan.value == 'free' ? freePlanPrice : proPlanPrice;
  }

  // Method to select payment method
  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  // Method to check if payment method is selected
  bool isPaymentMethodSelected(String method) {
    return selectedPaymentMethod.value == method;
  }

  // Method to handle continue button
  void onContinuePressed() {
    if (selectedPlan.value == 'pro') {
      // Show payment method bottom sheet
      _showPaymentMethodBottomSheet();
    } else {
      // Continue with free plan
      Get.snackbar(
        'Free Plan',
        'You are using the free plan',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    }
  }

  // Show Payment Method Bottom Sheet
  void _showPaymentMethodBottomSheet() {
    // Reset selected payment method
    selectedPaymentMethod.value = paymentMethods[0]['number']!;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Text(
                  'Payment Method',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Methods List
                ...paymentMethods.map((method) => Obx(() => _buildPaymentMethodCard(
                  cardNumber: method['number']!,
                  isSelected: isPaymentMethodSelected(method['number']!),
                  onTap: () => selectPaymentMethod(method['number']!),
                ))),

                const SizedBox(height: 24),

                // Confirm and Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close payment method sheet
                      _showPaymentSuccessBottomSheet();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Confirm and Pay',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  // Build Payment Method Card
  Widget _buildPaymentMethodCard({
    required String cardNumber,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFC107) : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Mastercard Icon
              Container(
                width: 40,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 10,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEB001B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF79E1B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Card Number
              Expanded(
                child: Text(
                  cardNumber,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              // Radio Button
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFC107) : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFC107),
                    ),
                  ),
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show Payment Success Bottom Sheet
  void _showPaymentSuccessBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Color(0xFFFFC107),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                // Success Message
                Text(
                  'Payment\nSuccessfully',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Your payment has been done\nsuccessfully.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Done Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close success sheet
                      Get.back(); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
    );
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with free plan selected
    selectedPlan.value = 'free';
  }
}