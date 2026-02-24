// lib/feature/home_screen/communicator_home_screen.dart
// ── REPLACES the old dummy-data screen ────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/imagesUrl.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_home_controller.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color helper ─────────────────────────────────────────────────────────────
Color _parseColor(String hex, Color fallback) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return fallback;
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  COMMUNICATOR HOME SCREEN
// ════════════════════════════════════════════════════════════════════════════

class CommunicatorHomeScreen extends GetView<CommunicatorHomeController> {
  const CommunicatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.bgColor,
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
                // ── Header ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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

                SliverAppBar(
                  actions: [
                    ElevatedButton(onPressed: (){
                      Get.toNamed(AppRoutes.ACTIVITIES);
                    }, child: Text("Activity"))
                  ],
                ),

                // ── Quick Speak Action Bar ──────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Obx(() => Row(
                      children: [
                        // Text display bar
                        Expanded(
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(12),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFE3E3E9),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  Colors.black.withOpacity(0.08),
                                  blurRadius: 7,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                controller.quickSpeakText.value
                                    .isEmpty
                                    ? 'Select a Quick Speak...'
                                    : controller
                                    .quickSpeakText.value,
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: controller
                                      .quickSpeakText
                                      .value
                                      .isEmpty
                                      ? Colors.grey[400]
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Speak button
                        GestureDetector(
                          onTap: controller.speakQuickSpeak,
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7BC5D3),
                              borderRadius:
                              BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                ImagesLink.speakIcon,
                                width: 22,
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Clear button
                        GestureDetector(
                          onTap: controller.clearQuickSpeak,
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE57373),
                              borderRadius:
                              BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                ImagesLink.cancelIcon,
                                width: 22,
                                height: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                ),

                // ── Quick Speak Header ──────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Row(
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
                        Text('Quick Speak',
                            style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                      ],
                    ),
                  ),
                ),

                // ── Quick Speak Cards ───────────────────────────────
                controller.quickSpeaks.isEmpty
                    ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Text('No quick speaks yet.',
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                )
                    : SliverToBoxAdapter(
                  child: SizedBox(
                    height: 130,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.quickSpeaks.length,
                      itemBuilder: (_, i) {
                        final qs = controller.quickSpeaks[i];
                        return Obx(() => _QsCard(
                          qs: qs,
                          isSelected: controller
                              .selectedQsId.value ==
                              qs.id,
                          isPlaying:
                          controller.playingId.value ==
                              qs.id,
                          onTap: () =>
                              controller.onQuickSpeakTap(qs),
                          onPlayAudio: qs.speak != null
                              ? () => controller.playAudio(
                              qs.id, qs.speak)
                              : null,
                        ));
                      },
                    ),
                  ),
                ),

                // ── Tap to Talk Header ──────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Row(
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
                        Text('Tap to Talk',
                            style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                      ],
                    ),
                  ),
                ),

                // ── Category Grid ───────────────────────────────────
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
                          Text('No categories available',
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
                        return Obx(() => _CategoryCard(
                          category: cat,
                          isPlaying:
                          controller.playingId.value ==
                              cat.id,
                          onTap: () =>
                              controller.onCategoryTap(cat),
                          onPlayAudio: cat.speak != null
                              ? () => controller.playAudio(
                              cat.id, cat.speak)
                              : null,
                        ));
                      },
                      childCount: controller.categories.length,
                    ),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),

                // ── Activity ───────────────────────────────────


              ],
            ),
          );
        }),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  QUICK SPEAK CARD — folder shape, horizontal list
// ════════════════════════════════════════════════════════════════════════════

class _QsCard extends StatelessWidget {
  final CommQuickSpeakModel qs;
  final bool isSelected;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onPlayAudio;

  const _QsCard({
    required this.qs,
    required this.isSelected,
    required this.isPlaying,
    required this.onTap,
    this.onPlayAudio,
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
          child: LayoutBuilder(builder: (context, constraints) {
            final tabH = constraints.maxHeight * 0.10;
            final topPad = tabH + 8;

            return CustomPaint(
              painter: _FolderPainter(
                cardColor:
                isSelected ? bgColor.withOpacity(0.15) : Colors.white,
                tabColor: bgColor,
                isSelected: isSelected,
                selectedBorderColor: bgColor,
              ),
              child: Stack(children: [
                Positioned.fill(
                  top: topPad,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _CardImage(
                          imageUrl: imageUrl, size: 50, bgColor: bgColor),
                      const SizedBox(height: 5),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 4),
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
                // Audio dot
                if (qs.speak != null)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: onPlayAudio,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isPlaying ? Colors.red : bgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying ? Icons.stop : Icons.volume_up,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ),
              ]),
            );
          }),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  CATEGORY CARD — folder shape, grid
// ════════════════════════════════════════════════════════════════════════════

class _CategoryCard extends StatelessWidget {
  final CommCategoryModel category;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onPlayAudio;

  const _CategoryCard({
    required this.category,
    required this.isPlaying,
    required this.onTap,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppUrl.mediaUrl(category.imageIcon);
    final bgColor =
    _parseColor(category.color, const Color(0xFFB5CFD1));

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(builder: (context, constraints) {
        final tabH = constraints.maxHeight * 0.10;
        final topPad = tabH + 6;

        return CustomPaint(
          painter: _FolderPainter(
            cardColor: Colors.white,
            tabColor: bgColor,
          ),
          child: Stack(children: [
            Positioned.fill(
              top: topPad,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _CardImage(
                      imageUrl: imageUrl, size: 56, bgColor: bgColor),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      category.name,
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
                  if (category.subCategoriesCount > 0)
                    Text(
                      '${category.subCategoriesCount} sub',
                      style:
                      TextStyle(fontSize: 9, color: Colors.grey[400]),
                    ),
                ],
              ),
            ),
            // Audio play dot (top-right)
            if (category.speak != null)
              Positioned(
                top: tabH - 8,
                right: 5,
                child: GestureDetector(
                  onTap: onPlayAudio,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isPlaying ? Colors.red : bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.stop : Icons.volume_up,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ]),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ════════════════════════════════════════════════════════════════════════════

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
          errorWidget: (_, __, ___) => Icon(Icons.image_outlined,
              color: Colors.white, size: size * 0.45),
        )
            : Icon(Icons.image_outlined,
            color: Colors.white, size: size * 0.45),
      ),
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
    path.quadraticBezierTo(size.width, 0, size.width - topRightRadius, 0);
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

    // Tab color area
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
  bool shouldRepaint(_FolderPainter old) =>
      old.cardColor != cardColor ||
          old.tabColor != tabColor ||
          old.isSelected != isSelected;
}

// ════════════════════════════════════════════════════════════════════════════
//  DASHED CIRCLE PAINTER (kept from original)
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
    final dashCount =
    (circumference / (dashWidth + dashSpace)).floor();

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
  bool shouldRepaint(DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
          oldDelegate.strokeWidth != strokeWidth ||
          oldDelegate.dashWidth != dashWidth ||
          oldDelegate.dashSpace != dashSpace;
}