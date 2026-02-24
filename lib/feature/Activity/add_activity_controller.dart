import 'dart:io';
import 'package:chatter_bee/Repository/activity/activity_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


class AddActivityController extends GetxController {
  final TextEditingController activityNameController = TextEditingController();
  final ActivityRepository _repository = ActivityRepository();
  final ImagePicker _picker = ImagePicker();

  // ─── Observable State ───────────────────────────────────────────────────────
  final RxString selectedTime = ''.obs;
  final RxString selectedImagePath = ''.obs;
  final RxBool isSaving = false.obs;

  // Store the raw TimeOfDay for building the datetime ISO string
  TimeOfDay? _pickedTime;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final now = TimeOfDay.now();
    _pickedTime = now;
    selectedTime.value = _formatTime(now);
  }

  // ─── Time Picker ─────────────────────────────────────────────────────────────
  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _pickedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFDD268),
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
      _pickedTime = picked;
      selectedTime.value = _formatTime(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Builds ISO 8601 datetime string from today's date + picked time
  String _buildDatetimeString() {
    final now = DateTime.now();
    final hour = _pickedTime?.hour ?? now.hour;
    final minute = _pickedTime?.minute ?? now.minute;
    final dt = DateTime(now.year, now.month, now.day, hour, minute, 0);
    return dt.toUtc().toIso8601String();
    // e.g., "2026-02-24T12:00:00.000Z"
  }

  // ─── Image Picker ─────────────────────────────────────────────────────────────
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  // ─── Save Activity ────────────────────────────────────────────────────────────
  Future<void> saveActivity() async {
    final name = activityNameController.text.trim();

    // ── Validation ────────────────────────────────────────────────────────────
    if (name.isEmpty) {
      Get.snackbar(
        'Missing Field',
        'Please enter an activity name.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isSaving.value = true;

    final datetime = _buildDatetimeString();
    final imageFile =
    selectedImagePath.value.isNotEmpty ? File(selectedImagePath.value) : null;

    final response = await _repository.createActivity(
      activityName: name,
      datetime: datetime,
      imageFile: imageFile,
    );

    isSaving.value = false;

    if (response.isSuccess && response.data != null) {
      // Return the created ActivityModel back to ActivitiesScreen
      Get.back(result: response.data);
    } else {
      Get.snackbar(
        'Error',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ─── Cleanup ──────────────────────────────────────────────────────────────────
  @override
  void onClose() {
    activityNameController.dispose();
    super.onClose();
  }
}