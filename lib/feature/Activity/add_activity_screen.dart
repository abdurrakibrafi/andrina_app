import 'dart:io';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_activity_controller.dart';

class AddActivityScreen extends GetView<AddActivityController> {
  const AddActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add Activity',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable Form ───────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Activity Name ─────────────────────────────────────────
                    _FieldLabel(label: 'Activity Name'),
                    const SizedBox(height: 8),
                    _inputCard(
                      child: TextField(
                        controller: controller.activityNameController,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter activity name',
                          hintStyle: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Colors.black54,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Time ──────────────────────────────────────────────────
                    _FieldLabel(label: 'Time'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => controller.selectTime(context),
                      child: _inputCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.black54,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Obx(() => Text(
                                controller.selectedTime.value,
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: controller
                                      .selectedTime.value.isNotEmpty
                                      ? Colors.black87
                                      : Colors.grey.shade400,
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Upload Image / Icon ────────────────────────────────────
                    _FieldLabel(label: 'Upload Image/Icon'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: controller.pickImage,
                      child: Obx(() {
                        final hasImage =
                            controller.selectedImagePath.value.isNotEmpty;
                        return _inputCard(
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 36),
                              child: hasImage
                                  ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    child: Image.file(
                                      File(controller
                                          .selectedImagePath.value),
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Tap to change image',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              )
                                  : Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_upload_outlined,
                                    size: 48,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Upload Image',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Image must be in JPG or PNG format\nand at least 100*100 pixels.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // ── Save Button ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDD268),
                    disabledBackgroundColor:
                    const Color(0xFFFDD268).withOpacity(0.6),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black54),
                    ),
                  )
                      : Text(
                    'Save',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Reusable Card Container ────────────────────────────────────────────────
  Widget _inputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Field Label Widget ──────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}