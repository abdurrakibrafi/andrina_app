// lib/feature/home_screen/caregiver/view/caregiver_home_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../communicator/view/communicator_home_screen.dart';

// ─── Explore More Item Model ───────────────────────────────────────────────────
class _ExploreItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _ExploreItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  // ── Explore More items ──────────────────────────────────────────────────────
  static const List<_ExploreItem> _exploreItems = [
    _ExploreItem(
      label: 'My Schedule',
      icon: Icons.calendar_month_outlined,
      color: Color(0xFFFDD268),
      route: AppRoutes.ACTIVITIES,
    ),
    // যোগ করতে চাইলে এখানে নতুন item দাও:
    // _ExploreItem(label: 'Goals', icon: Icons.flag_outlined, color: Color(0xFF7BC5D3), route: AppRoutes.GOALS),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaregiverHomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC857)),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.refresh,
            color: const Color(0xFFFFC857),
            child: CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(ImagesLink.logo, height: 47),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.PROFILE),
                          child: CustomPaint(
                            size: const Size(48, 48),
                            painter: DashedCirclePainter(
                              color: const Color(0xFFB5CFD1),
                              strokeWidth: 1.0,
                              dashWidth: 4.0,
                              dashSpace: 3.1,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                AssetImage(ImagesLink.profileImg),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Quick Speak Header ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionHeader(title: 'Quick Speak'),
                        Obx(() => Row(
                          children: [
                            GestureDetector(
                              onTap: controller.toggleQsEditMode,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: controller.isQsEditMode.value
                                      ? const Color(0xFFFFC857)
                                      : Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFFFC857)),
                                ),
                                child: Text(
                                  controller.isQsEditMode.value
                                      ? 'Done'
                                      : 'Edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: controller.isQsEditMode.value
                                        ? Colors.black
                                        : const Color(0xFFFFC857),
                                  ),
                                ),
                              ),
                            ),
                            if (!controller.isQsEditMode.value) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap:
                                controller.showAddQuickSpeakSheet,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFC857),
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add,
                                          size: 14, color: Colors.black),
                                      SizedBox(width: 4),
                                      Text('Add',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        )),
                      ],
                    ),
                  ),
                ),

                // ── Quick Speak Cards ────────────────────────────────────────
                if (controller.quickSpeaks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 130,
                      child: ListView.builder(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.quickSpeaks.length,
                        itemBuilder: (_, i) {
                          final qs = controller.quickSpeaks[i];
                          return Obx(
                                () => _QuickSpeakCard(
                              qs: qs,
                              isEditMode: controller.isQsEditMode.value,
                              onTap: () =>
                                  _onQsTap(context, controller, qs),
                              onEditTap: () =>
                                  controller.showEditQuickSpeakSheet(qs),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Text(
                        'No quick speaks yet. Tap Add to create one.',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 13),
                      ),
                    ),
                  ),

                // ── Tap to Talk Header ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionHeader(title: 'Tap to Talk'),
                        Obx(
                              () => Row(
                            children: [
                              _EditToggleBtn(controller: controller),
                              const SizedBox(width: 8),
                              if (!controller.isEditMode.value)
                                _AddCategoryBtn(controller: controller),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Categories Grid ──────────────────────────────────────────
                controller.categories.isEmpty
                    ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.category_outlined,
                              size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('No categories yet',
                              style: TextStyle(
                                  color: Colors.grey[500])),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed:
                            controller.showAddCategorySheet,
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFFFFC857)),
                            child: const Text('Add Category',
                                style:
                                TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (_, i) {
                        final cat = controller.categories[i];
                        return Obx(() {
                          final isSelected = controller
                              .selectedCategoryIds
                              .contains(cat.id);
                          return _CategoryCard(
                            category: cat,
                            isEditMode: controller.isEditMode.value,
                            isSelected: isSelected,
                            onTap: () =>
                                controller.onCategoryTap(cat),
                            onEditTap: () =>
                                controller
                                    .showEditCategorySheet(cat),
                          );
                        });
                      },
                      childCount: controller.categories.length,
                    ),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                  ),
                ),

                // ── Explore More Header ──────────────────────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: _SectionHeader(title: 'Explore More'),
                  ),
                ),

                // ── Explore More Grid (same folder style) ────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (_, i) => _ExploreCard(item: _exploreItems[i]),
                      childCount: _exploreItems.length,
                    ),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _onQsTap(
      BuildContext context,
      CaregiverHomeController controller,
      QuickSpeakModel qs,
      ) {
    if (controller.isQsEditMode.value) return;
    _showCardLiftDialog(
      context: context,
      imageUrl: AppUrl.mediaUrl(qs.imageIcon),
      label: qs.word ?? '',
      color: _parseColor(qs.color, const Color(0xFFFFD700)),
      hasAudio: qs.speak != null,
      onPlayAudio: () => controller.playQuickSpeak(qs),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  EXPLORE MORE CARD — same folder shape as category cards
// ════════════════════════════════════════════════════════════════════════════

class _ExploreCard extends StatelessWidget {
  final _ExploreItem item;
  const _ExploreCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(item.route),
      child: LayoutBuilder(builder: (context, constraints) {
        final tabH = constraints.maxHeight * 0.10;
        final contentTopPad = tabH + 6;

        return CustomPaint(
          painter: FolderShapePainter(
            cardColor: Colors.white,
            tabColor: item.color,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                top: contentTopPad,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: _darken(item.color, 30),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        item.label,
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
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _darken(Color color, int percent) {
    final f = 1 - percent / 100;
    return Color.fromARGB(
      color.alpha,
      (color.red * f).round(),
      (color.green * f).round(),
      (color.blue * f).round(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SECTION HEADER — reusable yellow-bar title
// ════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: const Color(0xFFFFC857),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Card-lift dialog ──────────────────────────────────────────────────────────
void _showCardLiftDialog({
  required BuildContext context,
  required String? imageUrl,
  required String label,
  required Color color,
  required bool hasAudio,
  VoidCallback? onPlayAudio,
}) {
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
        scale: Tween(begin: 0.7, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: anim,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: color.withOpacity(0.4), width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 4),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.2),
                        ),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Icon(
                                Icons.image_outlined,
                                color: color,
                                size: 48),
                          ),
                        )
                            : Icon(Icons.record_voice_over_outlined,
                            color: color, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A))),
                      if (hasAudio && onPlayAudio != null) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            onPlayAudio();
                            Navigator.of(ctx).pop();
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 12)
                              ],
                            ),
                            child: const Icon(Icons.volume_up,
                                color: Colors.white, size: 28),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Tap to speak',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                      ],
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

Color _parseColor(String hex, Color fallback) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return fallback;
  }
}

// ════════════════════════════════════════════════════════════════
//  FOLDER SHAPE PAINTER
// ════════════════════════════════════════════════════════════════

class FolderShapePainter extends CustomPainter {
  final Color cardColor;
  final Color tabColor;
  final bool isSelected;
  final Color selectedBorderColor;

  const FolderShapePainter({
    required this.cardColor,
    required this.tabColor,
    this.isSelected = false,
    this.selectedBorderColor = const Color(0xFFFFC857),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = 16.0;
    final topRightRadius = 8.0;
    final tabWidth = size.width * 0.55;
    final tabHeight = size.height * 0.10;
    final tabSlantWidth = tabHeight * 0.5;

    final path = Path();
    path.moveTo(0, size.height - radius);
    path.quadraticBezierTo(0, size.height, radius, size.height);
    path.lineTo(size.width - radius, size.height);
    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height - radius);
    path.lineTo(size.width, topRightRadius);
    path.quadraticBezierTo(
        size.width, 0, size.width - topRightRadius, 0);
    path.lineTo(tabWidth + tabSlantWidth + radius, 0);
    path.quadraticBezierTo(tabWidth + tabSlantWidth, 0,
        tabWidth + tabSlantWidth, radius * 0.3);
    path.lineTo(tabWidth, tabHeight);
    path.lineTo(radius, tabHeight);
    path.quadraticBezierTo(0, tabHeight, 0, tabHeight + radius);
    path.lineTo(0, size.height - radius);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.10), 6.0, false);
    canvas.drawPath(path, Paint()
      ..color = cardColor
      ..style = PaintingStyle.fill);

    final tabPath = Path();
    tabPath.moveTo(0, 0);
    tabPath.lineTo(tabWidth + tabSlantWidth + radius, 0);
    tabPath.quadraticBezierTo(tabWidth + tabSlantWidth, 0,
        tabWidth + tabSlantWidth, radius * 0.3);
    tabPath.lineTo(tabWidth, tabHeight);
    tabPath.lineTo(0, tabHeight);
    tabPath.close();

    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(tabPath, Paint()
      ..color = tabColor
      ..style = PaintingStyle.fill);
    canvas.restore();

    if (isSelected) {
      canvas.drawPath(path, Paint()
        ..color = selectedBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0);
    }
  }

  @override
  bool shouldRepaint(FolderShapePainter old) =>
      old.cardColor != cardColor ||
          old.tabColor != tabColor ||
          old.isSelected != isSelected;
}

// ════════════════════════════════════════════════════════════════
//  HEADER WIDGETS
// ════════════════════════════════════════════════════════════════

class _EditToggleBtn extends StatelessWidget {
  final CaregiverHomeController controller;
  const _EditToggleBtn({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.toggleEditMode,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: controller.isEditMode.value
              ? const Color(0xFFFFC857)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFC857)),
        ),
        child: Text(
          controller.isEditMode.value ? 'Done' : 'Edit',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: controller.isEditMode.value
                ? Colors.black
                : const Color(0xFFFFC857),
          ),
        ),
      ),
    );
  }
}

class _AddCategoryBtn extends StatelessWidget {
  final CaregiverHomeController controller;
  const _AddCategoryBtn({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.showAddCategorySheet,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFC857),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 20),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  QUICK SPEAK CARD
// ════════════════════════════════════════════════════════════════

class _QuickSpeakCard extends StatelessWidget {
  final QuickSpeakModel qs;
  final bool isEditMode;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const _QuickSpeakCard({
    required this.qs,
    required this.isEditMode,
    required this.onTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppUrl.mediaUrl(qs.imageIcon);
    final bgColor = _parseColor(qs.color, const Color(0xFFFFD700));

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: SizedBox(
          width: 90,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabH = constraints.maxHeight * 0.10;
              final contentTopPad = tabH + 8;

              return CustomPaint(
                painter: FolderShapePainter(
                  cardColor: Colors.white,
                  tabColor: bgColor,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      top: contentTopPad,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
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
                                errorWidget: (_, __, ___) => Icon(
                                    Icons.record_voice_over_outlined,
                                    color: Colors.white,
                                    size: 26),
                              )
                                  : const Icon(
                                Icons.record_voice_over_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              qs.word ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isEditMode)
                      Positioned(
                        top: tabH - 8,
                        right: 5,
                        child: GestureDetector(
                          onTap: onEditTap,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFC857),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit,
                                size: 11, color: Colors.black),
                          ),
                        ),
                      ),
                    if (qs.speak != null && !isEditMode)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                              color: bgColor, shape: BoxShape.circle),
                          child: const Icon(Icons.volume_up,
                              color: Colors.white, size: 9),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  CATEGORY CARD
// ════════════════════════════════════════════════════════════════

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const _CategoryCard({
    required this.category,
    required this.isEditMode,
    required this.isSelected,
    required this.onTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppUrl.mediaUrl(category.imageIcon);
    final bgColor =
    _parseColor(category.color, const Color(0xFFB5CFD1));

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
                Positioned.fill(
                  top: contentTopPad,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _CardImage(
                        imageUrl: imageUrl,
                        size: 56,
                        bgColor: bgColor,
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          category.name,
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
                      if (category.subCategories.isNotEmpty)
                        Text(
                          '${category.subCategories.length} sub',
                          style: TextStyle(
                              fontSize: 9, color: Colors.grey[400]),
                        ),
                    ],
                  ),
                ),
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
}

// ════════════════════════════════════════════════════════════════
//  CARD IMAGE WIDGET
// ════════════════════════════════════════════════════════════════

class _CardImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Color bgColor;

  const _CardImage(
      {this.imageUrl, required this.size, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Icon(
            Icons.image_outlined,
            color: Colors.white,
            size: size * 0.45,
          ),
        )
            : Icon(
          Icons.image_outlined,
          color: Colors.white,
          size: size * 0.45,
        ),
      ),
    );
  }
}