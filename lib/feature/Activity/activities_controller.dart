import 'package:chatter_bee/Repository/activity/activity_repository.dart';
import 'package:chatter_bee/models/activity/activity_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivitiesController extends GetxController {
  final ActivityRepository _repository = ActivityRepository();

  // ─── Observable State ───────────────────────────────────────────────────────
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchActivities();
  }

  // ─── Fetch Activities ────────────────────────────────────────────────────────
  Future<void> fetchActivities() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final now = DateTime.now();
      final dateFrom =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
      final dateTo =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final response = await _repository.getActivities(
        days: 7,
        limit: 50,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      if (response.isSuccess && response.data != null) {
        activities.value = response.data!;
        // Sort by datetime ascending
        activities.sort((a, b) => a.datetime.compareTo(b.datetime));
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Add Activity (called from AddActivityScreen result) ─────────────────────
  void onActivityAdded(ActivityModel activity) {
    activities.add(activity);
    activities.sort((a, b) => a.datetime.compareTo(b.datetime));
  }

  // ─── Delete Activity ─────────────────────────────────────────────────────────
  Future<void> deleteActivity(ActivityModel activity) async {
    final confirmed = await _showDeleteConfirmation(activity.activityName);
    if (!confirmed) return;

    isDeleting.value = true;

    final response = await _repository.deleteActivity(activity.id);

    isDeleting.value = false;

    if (response.isSuccess) {
      activities.removeWhere((a) => a.id == activity.id);
      Get.snackbar(
        'Deleted',
        '${activity.activityName} has been removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  // ─── Confirm Delete Dialog ───────────────────────────────────────────────────
  Future<bool> _showDeleteConfirmation(String name) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─── Navigate to Add Activity ─────────────────────────────────────────────────
  Future<void> goToAddActivity() async {
    final result = await Get.toNamed('/add-activity');
    if (result != null && result is ActivityModel) {
      onActivityAdded(result);
      Get.snackbar(
        'Success',
        '${result.activityName} added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ─── Today's Activities ──────────────────────────────────────────────────────
  List<ActivityModel> get todayActivities {
    final now = DateTime.now();
    return activities.where((a) {
      try {
        final dt = DateTime.parse(a.datetime).toLocal();
        return dt.year == now.year &&
            dt.month == now.month &&
            dt.day == now.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }
}