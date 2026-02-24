import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/models/activity/activity_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activities_controller.dart';

class ActivitiesScreen extends GetView<ActivitiesController> {
  const ActivitiesScreen({super.key});

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
          'Visual Schedules',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFDD268)),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  "Today's Schedule",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              // ── Error Message ───────────────────────────────────────────────
              if (controller.errorMessage.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade400, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.fetchActivities,
                          child: Text(
                            'Retry',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Activity List ───────────────────────────────────────────────
              Expanded(
                child: controller.todayActivities.isEmpty
                    ? _EmptyState(onAdd: controller.goToAddActivity)
                    : RefreshIndicator(
                  onRefresh: controller.fetchActivities,
                  color: const Color(0xFFFDD268),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.todayActivities.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final activity =
                      controller.todayActivities[index];
                      return _ActivityListItem(
                        activity: activity,
                        onDelete: () =>
                            controller.deleteActivity(activity),
                      );
                    },
                  ),
                ),
              ),

              // ── Add Activity Button ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: controller.goToAddActivity,
                    icon: const Icon(Icons.add, color: Colors.black87),
                    label: Text(
                      'Add Activity',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDD268),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Activity List Item ─────────────────────────────────────────────────────────
class _ActivityListItem extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onDelete;

  const _ActivityListItem({
    required this.activity,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Activity Icon / Image ──────────────────────────────────────────
          _ActivityImage(imageUrl: activity.imageIcon),
          const SizedBox(width: 14),

          // ── Name & Time ────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.activityName,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.formattedTime,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // ── 3-dot Menu ────────────────────────────────────────────────────
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54, size: 20),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Activity Image Widget ──────────────────────────────────────────────────────
class _ActivityImage extends StatelessWidget {
  final String? imageUrl;

  const _ActivityImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
        imageUrl!.startsWith('http')
            ? imageUrl!
            : 'YOUR_BASE_URL$imageUrl', // Replace YOUR_BASE_URL
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(Icons.event_note, color: Color(0xFFFFB74D), size: 26),
    );
  }
}

// ─── Empty State Widget ─────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 44,
              color: Color(0xFFFDD268),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No activities today',
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add\nyour first activity.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}