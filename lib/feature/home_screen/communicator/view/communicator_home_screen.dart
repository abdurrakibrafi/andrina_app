// lib/feature/home_screen/communicator_home_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/Profile/controller/profile_controller.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

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

class _ExploreItem {
  final String labelKey;
  final IconData icon;
  final Color color;
  final String route;
  const _ExploreItem({
    required this.labelKey,
    required this.icon,
    required this.color,
    required this.route,
  });
}

// ════════════════════════════════════════════════════════════════════════════
//  COMMUNICATOR HOME SCREEN
// ════════════════════════════════════════════════════════════════════════════

class CommunicatorHomeScreen extends GetView<CommunicatorHomeController> {
  const CommunicatorHomeScreen({super.key});

  static const List<_ExploreItem> _exploreItems = [
    _ExploreItem(
      labelKey: 'my_schedule',
      icon: Icons.calendar_month_outlined,
      color: Color(0xFFFDD268),
      route: AppRoutes.ACTIVITIES,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC857)),
            );
          }

          return OrientationBuilder(
            builder: (context, orientation) {
              final cols = _crossAxisCount(context);

              return RefreshIndicator(
                onRefresh: controller.refresh,
                color: const Color(0xFFFFC857),
                child: CustomScrollView(
                  slivers: [
                    // ── Header ────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                                  padding: const EdgeInsets.all(3),
                                  child: Obx(() => CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: profileController
                                        .avatarUrl.value.isNotEmpty
                                        ? CachedNetworkImageProvider(
                                        profileController.avatarUrl.value)
                                        : null,
                                    child: profileController
                                        .avatarUrl.value.isEmpty
                                        ? const Icon(Icons.person,
                                        size: 26, color: Colors.grey)
                                        : null,
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Speak Bar ─────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Obx(() => _SpeakBar(
                          text: controller.quickSpeakText.value,
                          hint: 'select_quick_speak_hint'.tr,
                          onSpeak: controller.speakQuickSpeak,
                          onClear: controller.clearQuickSpeak,
                        )),
                      ),
                    ),

                    // ── Quick Speak ───────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                        child: _SectionHeader(title: 'quick_speak'.tr),
                      ),
                    ),

                    controller.quickSpeaks.isEmpty
                        ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Text('no_quick_speaks_yet'.tr,
                            style: TextStyle(color: Colors.grey[500])),
                      ),
                    )
                        : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (_, i) {
                            final qs = controller.quickSpeaks[i];
                            return Obx(() => _CommCard(
                              imageUrl: AppUrl.mediaUrl(qs.imageIcon),
                              label: qs.word ?? '',
                              bgColor: _parseColor(
                                  qs.color, const Color(0xFFFFD700)),
                              isSelected: controller.selectedQsId.value ==
                                  qs.id,
                              showCheck: false,
                              onTap: () =>
                                  controller.onQuickSpeakTap(qs),
                            ));
                          },
                          childCount: controller.quickSpeaks.length,
                        ),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                      ),
                    ),

                    // ── Tap to Talk ───────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                        child: _SectionHeader(title: 'tap_to_talk'.tr),
                      ),
                    ),

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
                              Text('no_categories_available'.tr,
                                  style: TextStyle(
                                      color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      ),
                    )
                        : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (_, i) {
                            final cat = controller.categories[i];
                            return _CommCard(
                              imageUrl: AppUrl.mediaUrl(cat.imageIcon),
                              label: cat.name,
                              subLabel: cat.subCategoriesCount > 0
                                  ? '${cat.subCategoriesCount} ${'sub_count_suffix'.tr}'
                                  : null,
                              bgColor: _parseColor(
                                  cat.color, const Color(0xFFB5CFD1)),
                              isSelected: false,
                              showCheck: false,
                              onTap: () => controller.onCategoryTap(cat),
                            );
                          },
                          childCount: controller.categories.length,
                        ),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                      ),
                    ),

                    // ── Explore More ──────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                        child: _SectionHeader(title: 'explore_more'.tr),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (_, i) {
                            final item = _exploreItems[i];
                            return _CommCard(
                              label: item.labelKey.tr,
                              bgColor: item.color,
                              icon: item.icon,
                              isSelected: false,
                              showCheck: false,
                              onTap: () => Get.toNamed(item.route),
                            );
                          },
                          childCount: _exploreItems.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SHARED — SPEAK BAR
// ════════════════════════════════════════════════════════════════════════════

class _SpeakBar extends StatelessWidget {
  final String text;
  final String hint;
  final VoidCallback onSpeak;
  final VoidCallback onClear;

  const _SpeakBar({
    required this.text,
    required this.hint,
    required this.onSpeak,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = text.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E3E9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 7,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                hasText ? text : hint,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: hasText ? Colors.black87 : Colors.grey[400],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _BarBtn(
          color: const Color(0xFF7BC5D3),
          onTap: onSpeak,
          child: SvgPicture.asset(
            ImagesLink.speakIcon,
            width: 22,
            height: 22,
            colorFilter:
            const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 10),
        _BarBtn(
          color: const Color(0xFFE57373),
          onTap: onClear,
          child: SvgPicture.asset(ImagesLink.cancelIcon, width: 22, height: 22),
        ),
      ],
    );
  }
}

class _BarBtn extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  const _BarBtn({required this.color, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        width: 46,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SHARED — UNIFORM COMM CARD  (folder shape, no audio icon)
// ════════════════════════════════════════════════════════════════════════════

class _CommCard extends StatelessWidget {
  final String? imageUrl;
  final String label;
  final String? subLabel;
  final Color bgColor;
  final IconData? icon; // fallback when no imageUrl
  final bool isSelected;
  final bool showCheck;
  final VoidCallback onTap;

  const _CommCard({
    this.imageUrl,
    required this.label,
    this.subLabel,
    required this.bgColor,
    this.icon,
    required this.isSelected,
    required this.showCheck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabH = constraints.maxHeight * 0.10;
          final topPad = tabH + 6;
          final imgSize = constraints.maxWidth * 0.52;

          return CustomPaint(
            painter: _FolderPainter(
              cardColor: isSelected ? bgColor.withOpacity(0.15) : Colors.white,
              tabColor: bgColor,
              isSelected: isSelected,
              selectedBorderColor: bgColor,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  top: topPad,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image / Icon box
                      Container(
                        width: imgSize,
                        height: imgSize,
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
                                size: imgSize * 0.45),
                          )
                              : Icon(
                            icon ?? Icons.image_outlined,
                            color: icon != null
                                ? bgColor._darken(30)
                                : Colors.white,
                            size: imgSize * 0.50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (subLabel != null)
                        Text(
                          subLabel!,
                          style: TextStyle(
                              fontSize: 9, color: Colors.grey[400]),
                        ),
                    ],
                  ),
                ),
                // Selection check badge
                if (isSelected && showCheck)
                  Positioned(
                    top: tabH - 8,
                    left: 5,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                          color: bgColor, shape: BoxShape.circle),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 12),
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

// ════════════════════════════════════════════════════════════════════════════
//  SECTION HEADER
// ════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  COLOR EXTENSION
// ════════════════════════════════════════════════════════════════════════════

extension _ColorX on Color {
  Color _darken(int percent) {
    final f = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FOLDER SHAPE PAINTER
// ════════════════════════════════════════════════════════════════════════════

class _FolderPainter extends CustomPainter {
  final Color cardColor;
  final Color tabColor;
  final bool isSelected;
  final Color selectedBorderColor;

  const _FolderPainter({
    required this.cardColor,
    required this.tabColor,
    this.isSelected = false,
    this.selectedBorderColor = const Color(0xFFFFC857),
  });

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 16.0;
    const topRightRadius = 8.0;
    final tabWidth = size.width * 0.55;
    final tabHeight = size.height * 0.10;
    final tabSlantWidth = tabHeight * 0.5;

    final path = Path()
      ..moveTo(0, size.height - radius)
      ..quadraticBezierTo(0, size.height, radius, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(
          size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, topRightRadius)
      ..quadraticBezierTo(size.width, 0, size.width - topRightRadius, 0)
      ..lineTo(tabWidth + tabSlantWidth + radius, 0)
      ..quadraticBezierTo(tabWidth + tabSlantWidth, 0,
          tabWidth + tabSlantWidth, radius * 0.3)
      ..lineTo(tabWidth, tabHeight)
      ..lineTo(radius, tabHeight)
      ..quadraticBezierTo(0, tabHeight, 0, tabHeight + radius)
      ..lineTo(0, size.height - radius)
      ..close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.10), 6.0, false);
    canvas.drawPath(path, Paint()
      ..color = cardColor
      ..style = PaintingStyle.fill);

    final tabPath = Path()
      ..moveTo(0, 0)
      ..lineTo(tabWidth + tabSlantWidth + radius, 0)
      ..quadraticBezierTo(tabWidth + tabSlantWidth, 0,
          tabWidth + tabSlantWidth, radius * 0.3)
      ..lineTo(tabWidth, tabHeight)
      ..lineTo(0, tabHeight)
      ..close();

    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(tabPath, Paint()
      ..color = tabColor
      ..style = PaintingStyle.fill);
    canvas.restore();

    if (isSelected) {
      canvas.drawPath(
          path,
          Paint()
            ..color = selectedBorderColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0);
    }
  }

  @override
  bool shouldRepaint(_FolderPainter old) =>
      old.cardColor != cardColor ||
          old.tabColor != tabColor ||
          old.isSelected != isSelected;
}

// ════════════════════════════════════════════════════════════════════════════
//  DASHED CIRCLE PAINTER
// ════════════════════════════════════════════════════════════════════════════

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
  bool shouldRepaint(DashedCirclePainter old) =>
      old.color != color ||
          old.strokeWidth != strokeWidth ||
          old.dashWidth != dashWidth ||
          old.dashSpace != dashSpace;
}