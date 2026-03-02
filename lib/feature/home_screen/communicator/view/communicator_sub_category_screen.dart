// lib/feature/home_screen/communicator/view/communicator_sub_category_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/home_screen/communicator/contoller/communicator_sub_category_controller.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
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

class CommunicatorSubCategoryScreen
    extends GetView<CommunicatorSubCategoryController> {
  const CommunicatorSubCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A)),
        ),
      ),
      body: Obx(() {
        if (controller.subCategories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_outlined,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'no_sub_categories_available'.tr,
                  style:
                  TextStyle(color: Colors.grey[500], fontSize: 15),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: controller.subCategories.length,
          itemBuilder: (_, i) {
            final sub = controller.subCategories[i];
            return Obx(() => _SubCategoryCard(
              sub: sub,
              isPlaying: controller.playingId.value == sub.id,
              onTap: () => controller.onSubCategoryTap(sub),
              onPlayAudio: sub.speak != null
                  ? () => controller.playAudio(sub.id, sub.speak)
                  : null,
            ));
          },
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SUB-CATEGORY CARD
// ════════════════════════════════════════════════════════════════════════════

class _SubCategoryCard extends StatelessWidget {
  final CommSubCategoryModel sub;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onPlayAudio;

  const _SubCategoryCard({
    required this.sub,
    required this.isPlaying,
    required this.onTap,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppUrl.mediaUrl(sub.imageIcon);
    final bgColor = _parseColor(sub.color, const Color(0xFFB5CFD1));

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
                  _CardImage(imageUrl: imageUrl, size: 56, bgColor: bgColor),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      sub.name,
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
                  if (sub.itemsCount > 0)
                    Text(
                      '${sub.itemsCount} ${'items_count_suffix'.tr}',
                      style: TextStyle(
                          fontSize: 9, color: Colors.grey[400]),
                    ),
                ],
              ),
            ),
            if (sub.speak != null)
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
          color: bgColor, borderRadius: BorderRadius.circular(10)),
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
      old.cardColor != cardColor || old.tabColor != tabColor;
}