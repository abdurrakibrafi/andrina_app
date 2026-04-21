// notification_controller.dart
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Notification Model
class NotificationModel {
  final String id;
  final String title;
  final String time;
  final String imagePath;
  final Color iconBg;
  final Color? iconColor;
  final DateTime timestamp;
  final String type;
  final String? subtitle; // Additional info like "Amy pressed:" or "Amy completed:"
  bool isRead; // Track read/unread status

  NotificationModel({
    required this.id,
    required this.title,
    required this.time,
    required this.imagePath,
    required this.iconBg,
    this.iconColor,
    required this.timestamp,
    required this.type,
    this.subtitle,
    this.isRead = false,
  });

  // Factory method for creating from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      time: json['time'],
      imagePath: json['imagePath'],
      iconBg: Color(json['iconBg']),
      iconColor: json['iconColor'] != null ? Color(json['iconColor']) : null,
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      subtitle: json['subtitle'],
      isRead: json['isRead'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'imagePath': imagePath,
      'iconBg': iconBg.value,
      'iconColor': iconColor?.value,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'subtitle': subtitle,
      'isRead': isRead,
    };
  }
}

// Notification Controllerdamo
class NotificationControllerdamo extends GetxController {
  // Observable variables for alert settings
  var buttonAlerts = true.obs;
  var sentenceBuilderAlerts = true.obs;
  var myScheduleAlerts = true.obs;
  var soundNotifications = true.obs;
  var vibration = false.obs;

  // Observable list of notifications
  var notifications = <NotificationModel>[].obs;

  // Selected tab (0 = Notification, 1 = Alert Settings)
  var selectedTab = 0.obs;

  // Loading state
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadSettings();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Load notifications (mock data for demo)
  void loadNotifications() {
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 500), () {
      notifications.value = [
        NotificationModel(
          id: '1',
          title: '"I\'m Hungry"',
          subtitle: 'Amy pressed:',
          time: '11:30 AM',
          imagePath: ImagesLink.hungryImg,
          iconBg: Colors.orange.withOpacity(0.15),
          iconColor: Colors.orange,
          timestamp: DateTime.now(),
          type: 'button',
          isRead: false,
        ),
        NotificationModel(
          id: '2',
          title: 'Take Medicine',
          subtitle: 'Amy completed:',
          time: '10:30 AM',
          imagePath: ImagesLink.textToSpeakImg,
          iconBg: Colors.green.withOpacity(0.15),
          iconColor: Colors.green,
          timestamp: DateTime.now(),
          type: 'schedule',
          isRead: false,
        ),
        NotificationModel(
          id: '3',
          title: 'I need a break',
          time: '9:30 AM',
          imagePath: ImagesLink.breakImg,
          iconBg: Colors.grey[200]!,
          iconColor: Colors.grey[700],
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: 'sentence',
          isRead: true,
        ),
        NotificationModel(
          id: '4',
          title: 'Help me',
          time: '6:30 AM',
          imagePath: ImagesLink.helpMeImg,
          iconBg: Colors.red.withOpacity(0.15),
          iconColor: Colors.red,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: 'button',
          isRead: true,
        ),
      ];
      isLoading.value = false;
    });
  }

  // Load settings from storage
  void loadSettings() {
    // TODO: Load from SharedPreferences or GetStorage
  }

  // Save settings to storage
  void saveSettings() {
    // TODO: Save to SharedPreferences or GetStorage
  }

  // Toggle alert settings
  void toggleButtonAlerts(bool value) {
    buttonAlerts.value = value;
    saveSettings();
    Get.snackbar(
      'Button Alerts',
      value ? 'Enabled' : 'Disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleSentenceBuilderAlerts(bool value) {
    sentenceBuilderAlerts.value = value;
    saveSettings();
    Get.snackbar(
      'Sentence Builder Alerts',
      value ? 'Enabled' : 'Disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleMyScheduleAlerts(bool value) {
    myScheduleAlerts.value = value;
    saveSettings();
    Get.snackbar(
      'My Schedule Alerts',
      value ? 'Enabled' : 'Disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Change tab
  void changeTab(int index) {
    selectedTab.value = index;
  }

  // Get notifications by date
  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    return notifications.where((notification) {
      return notification.timestamp.year == now.year &&
          notification.timestamp.month == now.month &&
          notification.timestamp.day == now.day;
    }).toList();
  }

  List<NotificationModel> get yesterdayNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return notifications.where((notification) {
      return notification.timestamp.year == yesterday.year &&
          notification.timestamp.month == yesterday.month &&
          notification.timestamp.day == yesterday.day;
    }).toList();
  }

  List<NotificationModel> get olderNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return notifications.where((notification) {
      return notification.timestamp.isBefore(
        DateTime(yesterday.year, yesterday.month, yesterday.day),
      );
    }).toList();
  }

  // Notification actions
  void onNotificationTap(NotificationModel notification) {
    // Show notification detail dialog
    _showNotificationDialog(notification);
  }

  // Show detailed notification bottom sheet
  void _showNotificationDialog(NotificationModel notification) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with gradient background
                  Image.asset(ImagesLink.success, height: 100,),
                  const SizedBox(height: 20),

                  // Subtitle (if exists)
                  if (notification.subtitle != null) ...[
                    Text(
                      notification.subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Title
                  Text(
                    notification.type == 'schedule'
                        ? 'Task Complete!'
                        : notification.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: notification.type == 'schedule'
                          ? Color(0xFFFDD268)
                          : Color(0xFFFDD268),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Additional info for schedule type
                  if (notification.type == 'schedule') ...[
                    const SizedBox(height: 8),
                    Text(
                      'Amy completed: ${notification.title}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D2D2D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Info text
                  Text(
                    'This notification will remain\nhighlighted until you mark it as read.',
                    style: TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Color(0xFFFDD268)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Dismiss',
                            style: TextStyle(
                              color: Color(0xFFFDD268),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            markAsRead(notification);
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFDD268),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Mark as Read',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Add bottom padding for safe area
                  SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  // Mark notification as read
  void markAsRead(NotificationModel notification) {
    final index = notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
      // TODO: Save to storage
    }
  }

  // Delete notification
  void deleteNotification(NotificationModel notification) {
    notifications.remove(notification);
    Get.snackbar(
      'Deleted',
      '${notification.title} notification removed',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      mainButton: TextButton(
        onPressed: () {
          notifications.add(notification);
          Get.back();
        },
        child: const Text('UNDO'),
      ),
    );
  }

  // Clear all notifications
  void clearAllNotifications() {
    Get.defaultDialog(
      title: 'Clear All',
      middleText: 'Are you sure you want to clear all notifications?',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        notifications.clear();
        Get.back();
        Get.snackbar(
          'Success',
          'All notifications cleared',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      },
    );
  }

  // Add new notification
  void addNotification({
    required String title,
    required String type,
    String? subtitle,
    required String imagePath,
    required Color iconBg,
    Color? iconColor,
  }) {
    final now = DateTime.now();
    final timeString = '${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: subtitle,
      time: timeString,
      imagePath: imagePath,
      iconBg: iconBg,
      iconColor: iconColor,
      timestamp: now,
      type: type,
      isRead: false,
    );

    notifications.insert(0, notification);

    if (soundNotifications.value) {
      // TODO: Play notification sound
    }
    if (vibration.value) {
      // TODO: Vibrate device
    }

    // Show notification dialog automatically
    _showNotificationDialog(notification);
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    loadNotifications();
  }

  // Get notification counts
  int get notificationCount => notifications.length;
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}