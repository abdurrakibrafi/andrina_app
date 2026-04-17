// lib/feature/home_screen/caregiver/view/caregiver_item_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_item_controller.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/view/caregiver_home_screen.dart'
    show CgFolderCard, CgFolderPainter;
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Color _parseColor(String hex, Color fallback) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return fallback;
  }
}

int _crossAxisCount(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w >= 900) return 6;
  if (w >= 600) return 4;
  return 3;
}

// ════════════════════════════════════════════════════════════════════════════
//  CAREGIVER ITEM SCREEN
//  — Folder cards, tap → card-lift dialog, edit mode, add button
// ════════════════════════════════════════════════════════════════════════════

class CaregiverItemScreen extends StatelessWidget {
  const CaregiverItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaregiverItemController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF1A1A1A)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.parentSubCategory.name,
          style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A)),
        ),
        actions: [
          // Edit / Done
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: controller.toggleEditMode,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: controller.isEditMode.value
                      ? const Color(0xFFFFC857)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFC857)),
                ),
                child: Text(
                  controller.isEditMode.value ? 'done'.tr : 'edit'.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: controller.isEditMode.value
                          ? Colors.black
                          : const Color(0xFFFFC857)),
                ),
              ),
            ),
          )),
          // Add button
          Obx(() => !controller.isEditMode.value
              ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: controller.showAddSheet,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFC857),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add,
                    color: Colors.black, size: 20),
              ),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child:
              CircularProgressIndicator(color: Color(0xFFFFC857)));
        }

        if (controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('no_items_yet'.tr,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 15)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.showAddSheet,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: Text('add_item'.tr,
                      style: const TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC857),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        return OrientationBuilder(builder: (context, _) {
          final cols = _crossAxisCount(context);
          return RefreshIndicator(
            onRefresh: controller.refresh,
            color: const Color(0xFFFFC857),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final item = controller.items[i];
                return Obx(() {
                  final isSelected =
                  controller.selectedIds.contains(item.id);
                  return CgFolderCard(
                    imageUrl: AppUrl.mediaUrl(item.imageIcon),
                    label: item.word ?? '',
                    bgColor: _parseColor(
                        item.color, const Color(0xFFFFD700)),
                    isSelected: isSelected,
                    showEditBtn: controller.isEditMode.value,
                    onTap: () {
                      if (controller.isEditMode.value) {
                        controller.toggleSelection(item.id);
                      } else {
                        _showItemDialog(context, controller, item);
                      }
                    },
                    onEditTap: () => controller.showEditSheet(item),
                  );
                });
              },
            ),
          );
        });
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ITEM CARD-LIFT DIALOG
// ════════════════════════════════════════════════════════════════════════════

void _showItemDialog(
    BuildContext context,
    CaregiverItemController controller,
    ItemModel item,
    ) {
  final bgColor = _parseColor(item.color, const Color(0xFFFFD700));
  final imageUrl = AppUrl.mediaUrl(item.imageIcon);
  final hasAudio = item.speak != null;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved =
      CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return ScaleTransition(
        scale: Tween(begin: 0.65, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: anim,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: bgColor.withOpacity(0.4), width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: bgColor.withOpacity(0.35),
                          blurRadius: 32,
                          spreadRadius: 4)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image circle
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bgColor.withOpacity(0.2),
                        ),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Icon(
                                Icons.record_voice_over_outlined,
                                color: bgColor,
                                size: 48),
                          ),
                        )
                            : Icon(Icons.record_voice_over_outlined,
                            color: bgColor, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(item.word ?? '',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A))),
                      const SizedBox(height: 20),
                      // Speak / No-audio button
                      GestureDetector(
                        onTap: () async {
                          if (!hasAudio) {
                            Navigator.of(ctx).pop();
                            Get.snackbar('no_audio_title'.tr,
                                'item_has_no_audio'.tr,
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          await controller.playItemAudio(item);
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: hasAudio
                                ? bgColor
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                            boxShadow: hasAudio
                                ? [
                              BoxShadow(
                                  color:
                                  bgColor.withOpacity(0.5),
                                  blurRadius: 14,
                                  spreadRadius: 2)
                            ]
                                : [],
                          ),
                          child: Icon(
                            hasAudio
                                ? Icons.volume_up
                                : Icons.volume_off,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasAudio ? 'tap_to_speak'.tr : 'no_audio'.tr,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}