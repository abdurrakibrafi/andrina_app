import 'package:chatter_bee/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_controller.dart';

// Custom Switch Widget
class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.value ? 1.0 : 0.0,
    );

    _animation = _controller.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 40,
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
            decoration: BoxDecoration(
              color: widget.value ? AppColors.primaryColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.lerp(
                      Alignment.centerLeft, Alignment.centerRight, _animation.value)!,
                  child: Container(
                    width: 20,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(1, 2),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationControllerdamo());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Container(
        color: AppColors.bgColor,
        child: Column(
          children: [
            SizedBox(height: 45,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildTab(
                      'Notification',
                      controller.selectedTab.value == 0,
                          () => controller.changeTab(0),
                    ),
                  ),
                  Expanded(
                    child: _buildTab(
                      'Alert Settings',
                      controller.selectedTab.value == 1,
                          () => controller.changeTab(1),
                    ),
                  ),
                ],
              )),
            ),
            // Content Area
            Expanded(
              child: Obx(() {
                // Show Notification Tab Content
                if (controller.selectedTab.value == 0) {
                  return _buildNotificationContent(controller);
                }
                // Show Alert Settings Tab Content
                else {
                  return _buildAlertSettingsContent(controller);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Notification Content
  Widget _buildNotificationContent(NotificationControllerdamo controller) {
    if (controller.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Today Section
        if (controller.todayNotifications.isNotEmpty) ...[
          Text(
            'Today',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          ...controller.todayNotifications.map((notification) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildNotificationItem(
                imagePath: notification.imagePath,
                title: notification.title,
                time: notification.time,
                iconBg: notification.iconBg,
                iconColor: notification.iconColor,
                onTap: () => controller.onNotificationTap(notification),
                onDismiss: () => controller.deleteNotification(notification),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
        // Yesterday Section
        if (controller.yesterdayNotifications.isNotEmpty) ...[
          Text(
            'Yesterday',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          ...controller.yesterdayNotifications.map((notification) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildNotificationItem(
                imagePath: notification.imagePath,
                title: notification.title,
                time: notification.time,
                iconBg: notification.iconBg,
                iconColor: notification.iconColor,
                onTap: () => controller.onNotificationTap(notification),
                onDismiss: () => controller.deleteNotification(notification),
              ),
            );
          }).toList(),
        ],
        // Older Section
        if (controller.olderNotifications.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Older',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          ...controller.olderNotifications.map((notification) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildNotificationItem(
                imagePath: notification.imagePath,
                title: notification.title,
                time: notification.time,
                iconBg: notification.iconBg,
                iconColor: notification.iconColor,
                onTap: () => controller.onNotificationTap(notification),
                onDismiss: () => controller.deleteNotification(notification),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  // Alert Settings Content
  Widget _buildAlertSettingsContent(NotificationControllerdamo controller) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Obx(() => _buildSettingItem(
                title: 'Button Alerts',
                subtitle: 'Receive alerts when buttons are tapped',
                value: controller.buttonAlerts.value,
                onChanged: (val) => controller.toggleButtonAlerts(val),
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Colors.grey[100]),
              ),
              Obx(() => _buildSettingItem(
                title: 'Sentence Builder Alerts',
                subtitle: 'Receive alerts when sentences are built',
                value: controller.sentenceBuilderAlerts.value,
                onChanged: (val) =>
                    controller.toggleSentenceBuilderAlerts(val),
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Colors.grey[100]),
              ),
              Obx(() => _buildSettingItem(
                title: 'My Schedule Alerts',
                subtitle: 'Receive alerts for Schedule activities',
                value: controller.myScheduleAlerts.value,
                onChanged: (val) =>
                    controller.toggleMyScheduleAlerts(val),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                color: isActive ? AppColors.primaryColor : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 2,
              width: double.infinity,
              color: isActive ? AppColors.primaryColor : Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String imagePath,
    required String title,
    required String time,
    required Color iconBg,
    Color? iconColor,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    return Dismissible(
      key: Key(title + time),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (onDismiss != null) onDismiss();
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      imagePath,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image not found
                        return Icon(
                          Icons.notifications,
                          color: iconColor ?? Colors.grey,
                          size: 24,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CustomSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}