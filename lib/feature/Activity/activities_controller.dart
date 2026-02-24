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
  /// Bug fix: date_from/date_to আর days একসাথে দিলে API conflict করে।
  /// শুধু days=30 দিয়ে সব recent activity আনা হচ্ছে,
  /// তারপর Flutter side-এ todayActivities filter করা হচ্ছে।
  Future<void> fetchActivities() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getActivities(
        days: 30,   // শুধু days পাঠাও, date_from/date_to বাদ
        limit: 100,
      );

      if (response.isSuccess && response.data != null) {
        activities.value = response.data!;
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

  // ─── Today's Activities ──────────────────────────────────────────────────────
  /// Bug fix: API datetime UTC-তে আসে (e.g. "2026-02-24T17:47:00Z"),
  /// .toLocal() দিয়ে device timezone-এ convert করে তারপর date compare করতে হবে।
  List<ActivityModel> get todayActivities {
    final now = DateTime.now();
    return activities.where((a) {
      try {
        // UTC string → local device time
        final dt = DateTime.parse(a.datetime).toLocal();
        return dt.year == now.year &&
            dt.month == now.month &&
            dt.day == now.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // ─── Add Activity (called after returning from AddActivityScreen) ─────────────
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

  // ─── Navigate to Add Activity ─────────────────────────────────────────────────
  Future<void> goToAddActivity() async {
    // Get.toNamed ব্যবহার করলে ActivitiesController delete হয়ে যেতে পারে।
    // Get.toNamed এর বদলে Get.to() ব্যবহার করছি যাতে controller
    // route stack-এ থাকা অবস্থায় delete না হয়।
    final result = await Get.toNamed('/add-activity');

    if (result != null && result is ActivityModel) {
      // Optimistic add — API থেকে নতুন করে fetch না করেই list-এ যোগ করো
      onActivityAdded(result);
      Get.snackbar(
        'Success',
        '${result.activityName} added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );
    } else if (result == null) {
      // result না পেলে (e.g. controller recreated হয়ে গেছে) refresh করো
      fetchActivities();
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
}