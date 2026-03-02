// lib/feature/home_screen/caregiver/view/caregiver_sub_catagory_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_sub_catagory_controller.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'caregiver_home_screen.dart'; // FolderShapePainter

class CaregiverSubCategoryScreen extends StatelessWidget {
  const CaregiverSubCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaregiverSubCategoryController>();

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
          controller.parentCategory.name,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A)),
        ),
        actions: [
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
                        : const Color(0xFFFFC857),
                  ),
                ),
              ),
            ),
          )),
          Obx(() => !controller.isEditMode.value
              ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: controller.showAddSheet,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC857),
                  borderRadius: BorderRadius.circular(10),
                ),
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
              child: CircularProgressIndicator(color: Color(0xFFFFC857)));
        }

        if (controller.subCategories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'no_sub_categories_yet'.tr,
                  style:
                  TextStyle(color: Colors.grey[500], fontSize: 15),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.showAddSheet,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: Text('add_sub_category'.tr,
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

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: const Color(0xFFFFC857),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemCount: controller.subCategories.length,
            itemBuilder: (_, i) {
              final sub = controller.subCategories[i];
              return Obx(() {
                final isSelected =
                controller.selectedIds.contains(sub.id);
                return _SubCategoryCard(
                  sub: sub,
                  isEditMode: controller.isEditMode.value,
                  isSelected: isSelected,
                  onTap: () => controller.onSubCategoryTap(sub),
                  onEditTap: () => controller.showEditSheet(sub),
                );
              });
            },
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  SUB-CATEGORY CARD — folder shape, properly centered
// ════════════════════════════════════════════════════════════════

class _SubCategoryCard extends StatelessWidget {
  final SubCategoryModel sub;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const _SubCategoryCard({
    required this.sub,
    required this.isEditMode,
    required this.isSelected,
    required this.onTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppUrl.mediaUrl(sub.imageIcon);
    Color bgColor;
    try {
      bgColor = Color(
          int.parse('FF${sub.color.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      bgColor = const Color(0xFFB5CFD1);
    }

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabH = constraints.maxHeight * 0.10;
          final contentTopPad = tabH + 6;

          return CustomPaint(
            painter: FolderShapePainter(
              cardColor:
              isSelected ? bgColor.withOpacity(0.12) : Colors.white,
              tabColor: bgColor,
              isSelected: isSelected,
              selectedBorderColor: bgColor,
            ),
            child: Stack(
              children: [
                // ── Centered content below tab ────────────────
                Positioned.fill(
                  top: contentTopPad,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildImage(imageUrl, bgColor),
                      const SizedBox(height: 6),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          sub.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (sub.items.isNotEmpty)
                        Text(
                          '${sub.items.length} ${'items_count_suffix'.tr}',
                          style: TextStyle(
                              fontSize: 9, color: Colors.grey[400]),
                        ),
                    ],
                  ),
                ),

                // ── Edit button ───────────────────────────────
                if (isEditMode)
                  Positioned(
                    top: tabH - 8,
                    right: 5,
                    child: GestureDetector(
                      onTap: onEditTap,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFC857),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.edit,
                            size: 12, color: Colors.black),
                      ),
                    ),
                  ),

                // ── Selected checkmark ────────────────────────
                if (isSelected)
                  Positioned(
                    top: tabH - 8,
                    left: 5,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: bgColor, shape: BoxShape.circle),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 13),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String? imageUrl, Color bgColor) {
    const size = 54.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(
              Icons.image_outlined,
              color: Colors.white,
              size: 26),
        )
            : const Icon(Icons.image_outlined,
            color: Colors.white, size: 26),
      ),
    );
  }
}