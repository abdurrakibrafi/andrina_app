import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/support_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportScreen extends GetView<SupportController> {
  const SupportScreen({super.key});

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
          'Support',
          style: GoogleFonts.nunito(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Image.asset(
              ImagesLink.logo,
              height: 50,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // What is ChatterBee Section
              _buildExpandableSection(
                title: 'What is ChatterBee?',
                content:
                'At ChatterBee, your privacy is very important to us. This Privacy Policy explains how we collect, use, store, and protect your personal information while you use our mobile application. By using the app, you agree to the practices described below.',
                isExpanded: true,
              ),
              const SizedBox(height: 12),

              // Other Sections
              _buildExpandableSection(
                title: 'Information We Collect?',
                content: 'At ChatterBee, your privacy is very important to us. This Privacy Policy explains how we collect, use, store, and protect your personal information while you use our mobile application. By using our app, you agree to the practices described below.',
                isExpanded: false,
              ),
              const SizedBox(height: 12),

              _buildExpandableSection(
                title: 'How We Use Your Information?',
                content: 'At ChatterBee, your privacy is very important to us. This Privacy Policy explains how we collect, use, store, and protect your personal information while you use our mobile application. By using our app, you agree to the practices described below.',
                isExpanded: false,
              ),
              const SizedBox(height: 12),

              _buildExpandableSection(
                title: 'Sharing of Information?',
                content: '',
                isExpanded: false,
              ),
              const SizedBox(height: 12),

              _buildExpandableSection(
                title: 'Data Storage and Security?',
                content: '',
                isExpanded: false,
              ),
              const SizedBox(height: 12),

              _buildExpandableSection(
                title: 'User Control?',
                content: '',
                isExpanded: false,
              ),
              const SizedBox(height: 12),

              _buildExpandableSection(
                title: 'Children\'s Privacy?',
                content: '',
                isExpanded: false,
              ),
              const SizedBox(height: 12),

              _buildExpandableSection(
                title: 'Contact Us?',
                content: '',
                isExpanded: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String content,
    required bool isExpanded,
  }) {
    final RxBool expanded = isExpanded.obs;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Obx(
              () => ExpansionTile(
            initiallyExpanded: isExpanded,
            onExpansionChanged: (value) {
              expanded.value = value;
            },
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: expanded.value
                      ? AppColors.primaryColor
                      : Color(0xFFE3E3E9),
                  width: 1.5,
                ),
              ),
              child: Icon(
                expanded.value ? Icons.remove : Icons.add,
                size: 16,
                color: expanded.value
                    ? AppColors.primaryColor
                    : Color(0xFFE3E3E9),
              ),
            ),
            children: [
              if (content.isNotEmpty)
                Text(
                  content,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFF636F85),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}