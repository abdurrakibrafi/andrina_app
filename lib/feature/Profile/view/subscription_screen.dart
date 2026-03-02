import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionScreen extends GetView<SubscriptionController> {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'subscription'.tr,  // ✅
          style: GoogleFonts.nunito(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Image.asset(ImagesLink.logo, height: 50),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'unlock_pro'.tr,  // ✅
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'unlock_pro_desc'.tr,  // ✅
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: Colors.black, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // ── Free Plan ──
                  Obx(() => _buildPlanCard(
                    context: context,
                    planType: 'free',
                    title: 'free_plan'.tr,  // ✅
                    price: '\$${controller.freePlanPrice.toStringAsFixed(2)}',
                    features: [
                      'free_feature_1'.tr,  // ✅
                      'free_feature_2'.tr,
                      'free_feature_3'.tr,
                      'free_feature_4'.tr,
                    ],
                    isSelected: controller.isPlanSelected('free'),
                    onTap: () => controller.selectPlan('free'),
                  )),
                  const SizedBox(height: 22),

                  // ── Pro Plan ──
                  Obx(() => _buildPlanCard(
                    context: context,
                    planType: 'pro',
                    title: 'unlock_pro'.tr,  // ✅
                    price: '\$${controller.proPlanPrice.toStringAsFixed(2)}/month',
                    features: [
                      'pro_feature_1'.tr,  // ✅
                      'pro_feature_2'.tr,
                      'pro_feature_3'.tr,
                      'pro_feature_4'.tr,
                      'pro_feature_5'.tr,
                    ],
                    isSelected: controller.isPlanSelected('pro'),
                    onTap: () => controller.selectPlan('pro'),
                    isPro: true,
                  )),
                ],
              ),
            ),
          ),

          // ── Continue Button ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => controller.onContinuePressed(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'continue_btn'.tr,  // ✅
                  style: GoogleFonts.nunito(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required String planType,
    required String title,
    required String price,
    required List<String> features,
    required bool isSelected,
    required VoidCallback onTap,
    bool isPro = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFC107)
                : Colors.grey.shade300,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFC107)
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFC107),
                      ),
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                ),
                Text(price,
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(ImagesLink.check),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(feature,
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.3)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}