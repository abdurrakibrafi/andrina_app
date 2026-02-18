import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/home_screen/home_controller.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - dynamically changes based on edit mode
              Obx(() => controller.isEditMode.value
                  ? _buildEditModeHeader()
                  : _buildNormalHeader()),

              // Quick Speak Section
              _buildQuickSpeakSection(),

              // Tap to Talk Section
              _buildSection(
                title: 'Tap to Talk',
                items: controller.tapToTalkItems,
              ),

              // Explore More Section
              _buildSection(
                title: 'Explore More',
                items: controller.exploreMoreItems,
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Normal Header
  Widget _buildNormalHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showMenuPopup(),
            child: SvgPicture.asset(ImagesLink.vectorMenu),
          ),
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
                  backgroundImage: AssetImage(ImagesLink.profileImg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Edit Mode Header
  Widget _buildEditModeHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => controller.exitEditMode(),
            child: const Icon(Icons.arrow_back, size: 24),
          ),
          Image.asset(ImagesLink.logo, height: 47),
          Row(
            children: [
              _buildEditAction(Icons.undo, 'Undo', controller.handleUndo),
              const SizedBox(width: 12),
              _buildEditAction(Icons.delete_outline, 'Delete', controller.handleDelete),
              const SizedBox(width: 12),
              _buildEditAction(Icons.select_all, 'Select All', controller.handleSelectAll),
              const SizedBox(width: 12),
              _buildEditAction(
                Icons.check_circle_outline,
                'Change',
                controller.handleSaveChanges,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditAction(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color ?? Colors.black87),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Show Menu Popup
  void _showMenuPopup() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuOption(
                icon: Icons.edit,
                label: 'Edit Button',
                onTap: () {
                  Get.back();
                  controller.enterEditMode();
                },
              ),
              const SizedBox(height: 12),
              _buildMenuOption(
                icon: Icons.add,
                label: 'Add Button',
                onTap: () {
                  Get.back();
                  controller.onAddButton();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSpeakSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Speak',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: controller.quickSpeakItems.length,
            itemBuilder: (context, index) {
              final item = controller.quickSpeakItems[index];
              return Obx(() => _QuickSpeakItem(
                imagePath: item.imagePath,
                label: item.label,
                itemId: item.id,
                isSelected: controller.selectedQuickSpeak.value == item.label,
                isEditMode: controller.isEditMode.value,
                isItemSelected: controller.isItemSelected(item.id),
                showSelection: true,
                onTap: () {
                  if (controller.isEditMode.value) {
                    controller.toggleItemSelection(item.id);
                  } else {
                    controller.onQuickSpeakTap(item.label);
                  }
                },
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<CategoryItemModel> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isExploreMore = title == 'Explore More';
              return Obx(() => _CategoryItem(
                imagePath: item.imagePath,
                label: item.label,
                itemId: item.id,
                isEditMode: controller.isEditMode.value,
                isItemSelected: controller.isItemSelected(item.id),
                showSelection: !isExploreMore,
                onTap: () {
                  if (controller.isEditMode.value && !isExploreMore) {
                    controller.toggleItemSelection(item.id);
                  } else if (!controller.isEditMode.value) {
                    controller.onCategoryTap(item.label);
                  }
                },
              ));
            },
          ),
        ],
      ),
    );
  }
}

// ========== QUICK SPEAK ITEM WITH IMAGE ==========
class _QuickSpeakItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final String itemId;
  final bool isSelected;
  final bool isEditMode;
  final bool isItemSelected;
  final bool showSelection;
  final VoidCallback onTap;

  const _QuickSpeakItem({
    required this.imagePath,
    required this.label,
    required this.itemId,
    this.isSelected = false,
    required this.isEditMode,
    required this.isItemSelected,
    this.showSelection = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              painter: _FolderShapePainter(
                isSelected: isSelected,
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Selection Circle in Edit Mode
          if (isEditMode && showSelection)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isItemSelected ? AppColors.primaryColor : Colors.white,
                  border: Border.all(
                    color: isItemSelected ? AppColors.primaryColor : Color(0xFF211F2F),
                    width: 2,
                  ),
                ),
                child: isItemSelected
                    ? const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

// ========== FOLDER SHAPE PAINTER ==========
class _FolderShapePainter extends CustomPainter {
  final bool isSelected;

  _FolderShapePainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final radius = 16.0;
    final topRightRadius = 8.0;
    final tabWidth = size.width * 0.55;
    final tabHeight = size.height * 0.10;
    final tabSlantWidth = tabHeight * 0.5;

    // Start from bottom-left corner
    path.moveTo(0, size.height - radius);

    // Bottom-left rounded corner
    path.quadraticBezierTo(
      0,
      size.height,
      radius,
      size.height,
    );

    // Bottom edge
    path.lineTo(size.width - radius, size.height);

    // Bottom-right rounded corner
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - radius,
    );

    // Right edge
    path.lineTo(size.width, topRightRadius);

    // Top-right rounded corner (8px radius)
    path.quadraticBezierTo(
      size.width,
      0,
      size.width - topRightRadius,
      0,
    );

    // Top edge (going left towards tab)
    path.lineTo(tabWidth + tabSlantWidth + radius, 0);

    // Tab top-right rounded corner
    path.quadraticBezierTo(
      tabWidth + tabSlantWidth,
      0,
      tabWidth + tabSlantWidth,
      radius * 0.3,
    );

    // Tab diagonal edge (steeper angle)
    path.lineTo(tabWidth, tabHeight);

    // Top edge of main body (left of tab)
    path.lineTo(radius, tabHeight);

    // Top-left rounded corner
    path.quadraticBezierTo(
      0,
      tabHeight,
      0,
      tabHeight + radius,
    );

    // Left edge back to start
    path.lineTo(0, size.height - radius);

    path.close();

    // Draw shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.1), 8.0, false);

    // Draw folder
    canvas.drawPath(path, paint);

    // Draw border if selected
    if (isSelected) {
      final borderPaint = Paint()
        ..color = AppColors.primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_FolderShapePainter oldDelegate) {
    return oldDelegate.isSelected != isSelected;
  }
}

// ========== CATEGORY ITEM WIDGET ==========
class _CategoryItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final String itemId;
  final bool isEditMode;
  final bool isItemSelected;
  final bool showSelection;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.imagePath,
    required this.label,
    required this.itemId,
    required this.isEditMode,
    required this.isItemSelected,
    this.showSelection = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              painter: _FolderShapePainter(
                isSelected: false,
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Selection Circle in Edit Mode (showSelection true হলেই দেখাবে)
          if (isEditMode && showSelection)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isItemSelected ? AppColors.primaryColor : Colors.white,
                  border: Border.all(
                    color: isItemSelected ? AppColors.primaryColor : Color(0xFF211F2F),
                    width: 2,
                  ),
                ),
                child: isItemSelected
                    ? const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

// ========== DASHED CIRCLE PAINTER ==========
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * 3.14159 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace) / radius);
      final sweepAngle = dashWidth / radius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}